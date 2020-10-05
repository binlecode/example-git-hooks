#!/usr/bin/env ruby

require 'yaml'

tgt_repo_path = ARGV[0]

unless tgt_repo_path
  print "Please enter target repo path: "
  tgt_repo_path = gets().chomp
end
puts "received target repo path: #{tgt_repo_path}"

tgt_repo_hook_path = File.join(tgt_repo_path, '.git', 'hooks')
puts "target repo hook path: #{tgt_repo_hook_path}"

unless File.directory? tgt_repo_hook_path
  puts "target path is not valid, quit install"
  exit 1
end

# parse install config yaml file into a dictionary
files_dict = YAML.load_file('install_hooks.config.yml')

# copy files
files_dict.each { |hook, src_file|
  
  cmd_line = "cp #{src_file} #{File.join(tgt_repo_hook_path, hook)}"
  puts "running command: #{cmd_line}"
  output = system cmd_line
  puts output ? 'success' : 'failed'

}


