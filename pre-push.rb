#!/usr/bin/env ruby

# This hook is called with the following parameters:
#
# $1 -- Name of the remote to which the push is being done
# $2 -- URL to which the push is being done

# hook_ctx = { :remote_name => ARGV[0], :remote_url => ARGV[1] }
# puts hook_ctx.inspect

#todo: tranform this script into a PrePushHookHandler class

forbidden_branchs = ['main', 'master']

def current_branch
  `git rev-parse --abbrev-ref HEAD`.chomp.downcase
end

def cmd_is_delete?(command)
  command =~ /--delete/
end

def cmd_is_forced?(command)
  command =~ /--force|-f|--pfush/
end

def cmd_is_destructive?(command)
  cmd_is_delete?(command) || cmd_is_forced?(command)
end

def current_command
  ppid = Process.ppid
  `ps -ocommand= -p #{ppid}`.chomp
end
  
def print_err_msg(msg)
  puts msg
  puts "  If you REALLY know what you are doing, you can:"
  puts "  git push <remote> <branch> --force --no-verify"
end

if forbidden_branchs.include? current_branch
  print_err_msg "Error: push not allowed toward branch: #{current_branch}"
  exit 1
end

if cmd_is_destructive? current_command
  print_err_msg "Error: push is too dangerous by your commend: #{current_command}"
  exit 1
end

puts '*' * 20 + ' pre-push hook complete ' + '*' * 20
