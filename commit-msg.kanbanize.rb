#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'yaml'


def prompt(*args)
  print(*args)
  gets
end

def post_kan_api(kan_url, apikey, params = {})
  puts ">> calling Kanbanize API: #{kan_url}"
  uri = URI(kan_url)
  req = Net::HTTP::Post.new(uri)
  req['Content-Type'] = 'application/json'
  req['Accept'] = 'application/json'
  if apikey
    req['apikey'] = apikey
  end
  req.body = params.to_json
  
  res = Net::HTTP.start(uri.hostname, 
                        uri.port, 
                        :use_ssl => uri.scheme == 'https') { |http|
    http.request(req)
  }
  
  puts ">> http resp code #{res.code}"
  puts ">> http resp body #{res.body}"
  return res
end

# auth with prompt for username and pswd
def auth_apikey(config, secret)
    email = (prompt "Please input email: ").chomp
    pswd = (prompt "Please input password: ").chomp
  
    auth_res = post_kan_api(
      config['kan_api_url'].sub('<domain>', secret['domain']) + config['kan_api_auth'],
      nil,
      { :email => email, :pass => pswd }
    )

    unless auth_res.code == '200'
      puts ">> login failed with code #{auth_res.code} => #{auth_res.body || 'Unknown'}"
      return nil
    end
      
    apikey = JSON.parse(auth_res.body)['apikey']
    puts ">> login successful, apikey: #{apikey}"
    return apikey
end

def resolve_apikey(config, secret)
  input_or_api = (prompt "Choose your option to get apikey: \n" + 
    " - [1] call login API \n" + 
    " - [2] enter kanbanize API key \n" +
    " - [3] set environment variable '#{config['env_var_kan_api_key_name']}' instead \n" +
    "Please select [1/2/3] (default 1): ").chomp

  if input_or_api == '1' || input_or_api == ''
    apikey = auth_apikey(config, secret)  # could be nil if auth fails
  elsif input_or_api == '2'
    apikey = (prompt "Input kanbanize API key: ").chomp  # could be a bad input
  end # do nothing for opiton 3

  puts ">> returnning apikey: #{apikey}"
  return apikey
end


## ** main routine

message_file = ARGV[0]
message = File.read(message_file) if message_file

#todo: needs a better way to switch hook mode and test mode (no message_file)
unless message
  # this is for debug/test only
  message = YAML.load_file('./fixture.yml')['commit_msg']
  puts "loading testing msg: #{message}"
end


# get repo root folder path
repo_root = `git rev-parse --show-toplevel`.chomp  # remove trailing newline

# config file should exist
unless File.exists? "./commit-msg.config"
  puts 'Error: kanbanize hook config file not found'
  exit 1
end
config = YAML.load_file("#{repo_root}/.git/hooks/commit-msg.config")   # yml => hash



#todo: make these prefix (type) options externalized and reconfigurable
#todo: follow types in: https://github.com/conventional-changelog/commitlint
#todo: make regex pattern externalized and reconfigurable
$regex = /^(ref|feat|fix|chore|docs): (\d+)/
# $regex = /^(ref|feat|fix|chore|docs): KAN-(\d+)/

caught = $regex.match(message)

if !caught
  #todo: need better validation message here
  puts "[POLICY] Your message is not formatted correctly"
  puts "Allowed commit message SHOULD begin with:"
  puts "ref,feat,fix,chore, or docs, followed by ':' then a ticket number, then message"
  exit 1
end

puts "Your message is formatted correctly with pattern match: #{caught}"
tkt_nbr = caught[-1]

puts "found ticket number: #{tkt_nbr}"

## ** initialize secret for domain and api key

# secret file should exist
SECRET_FILE = './commit-msg.secret'
if File.exists? SECRET_FILE
  secret = YAML.load_file(SECRET_FILE)
  puts '>> secret: ' + secret.inspect
end
unless secret
  secret = {}
end

# resolve kanbanize domain for API and web urls
# secret domain is optional, env vars can be used instead
domain = ENV[config['env_var_kan_api_domain_name']] || secret['domain']
# ask to input domain if not yet set
unless domain
  domain = (prompt "Input kanbanize domain: ").chomp
  secret['domain'] = domain
  File.open(SECRET_FILE, 'w') { |f| f.write(secret.to_yaml)}
end


# obtain kanbanize api key
# try env var first then secret file
apikey = ENV[config['env_var_kan_api_key_name']] || secret['apikey']

# resolve api key if not available from external source
unless apikey
  apikey = resolve_apikey(config, secret)
  unless apikey
    puts 'Api key appears to be invalid, please try again.'
    exit 1
  end
end

## ** Kanbanize API call

res = post_kan_api(
    config['kan_api_url'].sub('<domain>', domain) + config['kan_api_get_task_details'],
    apikey,
    { :taskid => tkt_nbr }
)

if res.code == '401'
  should_auth = (prompt "API key invaid, do you want to update it (y/n): ").chomp.downcase == 'y'
  unless should_auth
    exit 1
  end

  apikey = resolve_apikey(config, secret)

  # retry api call with updated api key
  res = post_kan_api(
    config['kan_api_url'].sub('<domain>', domain) + config['kan_api_get_task_details'],
    apikey,
    { :taskid => tkt_nbr }
  )

  # when retrial fails, no more retrial
  unless res.code == '200'  
    puts "API call failed: #{res.code} => #{res.body || 'Unknown'}"
    exit 1
  end

elsif res.code != '200'
  puts "API call failed: #{res.code} => #{res.body || 'Unknown'}"
  exit 1
end

# at this point the kanbanize task check is successful
# update secret file with correct api key
secret['apikey'] = apikey
File.open(SECRET_FILE, 'w') { |f| f.write(secret.to_yaml)}
puts ">> secret file saved"

#todo: besides appending web url to commit message,
#todo: consider other 'call-back' functions like:
#todo: - post commit message to kanbanize taks as comment 
#todo: - look for CHANGELOG.md and add semantic version

rb = JSON.parse(res.body)

kan_task_web_url = config['kan_web_url_task']
    .sub('<domain>', domain)
    .sub('<boardid>', rb['boardid'])
    .sub('<taskid>', rb['taskid'])

tkt_web_url_msg = "\nKanbanize Ticket #{tkt_nbr} URL: #{kan_task_web_url}\n"
puts "Appending web url to message:#{tkt_web_url_msg}"

File.write(message_file, message + tkt_web_url_msg) if message_file

puts "Message saved."
puts '*' * 20 + ' commit-msg hook complete ' + '*' * 20

