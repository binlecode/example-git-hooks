#!/usr/bin/env ruby

#TODO: check current branch name conforms to a defined naming pattern

current_branch = `git rev-parse --abbrev-ref HEAD`.chomp

forbidden_branches = ['main', 'master']
if forbidden_branches.include?(current_branch)
  puts "commit not allowed in your current #{current_branch} branch"
  puts "commit is not allowed in these branches: #{forbidden_branches}"
  exit 1
end

puts '*' * 20 + ' pre-commit hook complete ' + '*' * 20
