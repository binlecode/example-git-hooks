#!/usr/bin/env ruby

#todo: build some git hook logic as pre-push validation

# This hook is called with the following parameters:
#
# $1 -- Name of the remote to which the push is being done
# $2 -- URL to which the push is being done


forbidden_branchs = ['main', 'master']

current_branch = `git rev-parse --abbrev-ref HEAD`.chomp.downcase

if forbidden_branchs.contains current_branch
  puts "push not allowed toward #{current_branch}"
  exit 1
end

hook_ctx = { :remote_name => ARGV[0], :remote_url => ARGV[1] }

puts hook_ctx.inspect