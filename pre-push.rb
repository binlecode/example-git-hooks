#!/usr/bin/env ruby

#todo: build some git hook logic as pre-push validation

# This hook is called with the following parameters:
#
# $1 -- Name of the remote to which the push is being done
# $2 -- URL to which the push is being done

# hook_ctx = { :remote_name => ARGV[0], :remote_url => ARGV[1] }
# puts hook_ctx.inspect

#todo: tranform script into a PrePushHookHandler class

forbidden_branchs = ['main', 'master', 'dev']

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
  $(ps -ocommand= -p $PPID)
end
  

if forbidden_branchs.include? current_branch
  puts "Error: push not allowed toward branch: #{current_branch}"
  exit 1
end

if cmd_is_destructive? current_command
  puts "Error: push is too dangerous to run with your commend: #{current_command}"
  puts "  If you really know what you are doing, you can use:"
  puts "  git push <remote> <branch> --force --no-verify"
  exit 1
end

puts '*' * 20 + ' pre-push hook complete ' + '*' * 20
