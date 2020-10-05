#!/usr/bin/env ruby

require 'yaml'

mode = 'install'

if ARGV.size > 1
  option, tgt_repo_path = ARGV[0], ARGV[1]
  puts option, tgt_repo_path
  if option.downcase == '--remove'
    mode = 'remove'
  end
else
  tgt_repo_path = ARGV[0]
end


unless tgt_repo_path
  print "Please enter target repo path: "
  tgt_repo_path = gets().chomp
end
puts "target repo path: #{tgt_repo_path}"

tgt_repo_hook_path = File.join(tgt_repo_path, '.git', 'hooks')
puts "target repo hook path: #{tgt_repo_hook_path}"

unless File.directory? tgt_repo_hook_path
  puts "target path is not valid, quit install"
  exit 1
end

# parse install config yaml file into a dictionary
files_dict = YAML.load_file('install_hooks.config.yml')

if mode == 'install'
  # copy files
  files_dict.each { |hook, src_file|
    cmd_line = "cp #{src_file} #{File.join(tgt_repo_hook_path, hook)}"
    puts "running command: #{cmd_line}"
    output = system cmd_line
    puts output ? 'success' : 'failed'
  }

elsif mode == 'remove'
  # remove files
  files_dict.keys.each { |hook|
    cmd_line = "rm #{File.join(tgt_repo_hook_path, hook)}"
    puts "running command: #{cmd_line}"
    output = system cmd_line
    puts output ? 'success' : 'failed'
  }

end


