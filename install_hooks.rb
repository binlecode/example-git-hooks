#!/usr/bin/env ruby

# pre-commit hook
`cp pre-commit.rb .git/hooks/pre-commit`

# commit-msg hook
`cp commit-msg.kanbanize.rb .git/hooks/commit-msg`
`cp commit-msg.config       .git/hooks/commit-msg.config`

