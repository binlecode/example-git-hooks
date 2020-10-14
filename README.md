


## install git hooks

```bash
install_hooks <target-repo-folder-path>
```

This install script is taking configuration from [`install_hooks.config.yml`](./install_hooks.config.yml) file.

## remove git hooks

```bash
install_hooks --remove <target-repo-folder-path>
```

The `--remove` option enables deletion of all installed (copied) hooks.

## supported git hooks

- `pre-commit` hook to prevent commiting to main or master branch
- `commit-msg` hook for kanbanize task validation and info fetch
- pre-push hook to prevent destructive push


## client side commit message check

The fact that users' commit pushes are rejected due to bad commit message format (thus having their carefully crafted work rejected at the last minute) can be **extremely** frustrating and confusing.

And furthermore, user will have to edit their history, the already commited change locally, to correct it. This isn’t always a walk in the park.

Thus the need of some client-side git hooks that are automatically triggered at the time of user commit, and block the commit with the messsage that the server is likely to reject.


## client side pre push check

Read this blog to know more about this script:
http://blog.bigbinary.com/2013/09/19/do-not-allow-force-push-to-master.html



## git hook script

Because hooks aren’t transferred with a clone of a project by Git,
they have to explicitly copied .git/hooks directory and made executable. 

For exmaple, a commit message check hook script `the commit-msg` file will need to be manually copied to each user's local repo `<repo-path>/.git/hooks/` folder.

the hook file is written in ruby but file should be without an extension to follow git hook file execution logic.

"ref/feat/fix/chore then followed by ':' then a ticket number, then message"
The above pattern can be configured as per user needs in commit-mesg.config file

## comment-msg kanbanize hook processing logic

1. extract kan ticket number from legal commit msg, if extraction fail, commit fail
2. make an api call to kanbanize api with ticket number, if not 200, commit fail
3. if kanbanize task check confirmed by ticket number, construct a kanban web access (slug) url and append to the commit message

Supported environment variables
- `KAN_API_KEY`: kanbanize API auth key
- `KAN_API_DOMAIN`: kanbanize portal domain, eg: `<your-domain>.kanbanize.com/..`


## pre-commit hook processing logic

Common use cases of pre-commit hook
- checking if current branch is not main or master
- scan source code for
  - TODO or FIXME tags, give warning or error depending on how strict the rule is
  - TAB charactor, normally this should lead to a check error

TODO:
- check current branch name conforms to a defined naming pattern

## ref - semantic release

https://github.com/semantic-release/semantic-release


## implementation notes:

### non-tty terminal prompt for interactive user input

Ruby `STDIN.gets` doesn't pause for user input in a non-tty terminal environment.
This is likely a case when there's a terminal opened from an IDE like VS Code or IDEA.

Therefore, we use a file handler instead of STDIN to take `/dev/tty`, 
for example, like below:

```ruby
file = File.open("/dev/tty")
line = file.gets
p line
```


## appendix - useful hooks

Every Git repository has a .git/hooks folder with a script for each hook you can bind to.
This is the [official git hooks doc](https://www.git-scm.com/docs/githooks).

Hooks are either placed on client (local) side or server (remote) side.

Some useful hooks are listed below.

### pre-commit

This hook is called before obtaining the proposed commit message.

It is ideal for syntax checkers, linters, and other checks that you want to run before you allow a commit to even be created.

### prepare-commit-msg

Called after receiving the default commit message, just prior to firing up the commit message editor.

### commit-msg

Can be used to adjust the message after it has been edited in order to ensure conformity to a standard or to reject based on any criteria.

This is a commonly used hook to append additonal information to the commit message.

### post-commit

Can be used to run some event call back logic such as
email/SMS team members of a new commit.

### pre-push

Called prior to a push to a remote. In addition to the parameters, additional information, separated by a space is passed in through stdin in the form of:
`<local ref> <local sha1> <remote ref> <remote sha1>`.

This is a hook suitable to invokie some testing and build check.

### pre-auto-gc

Is used to do some checks before automatically cleaning repos.

### pre-rebase

Called when rebasing a branch. Mainly used to halt the rebase if it is not desirable.

### applypatch-msg

Can edit the commit message file and is often used to verify or actively format a patch's message to a project's standards.

### pre-receive

This is called on the remote repo just before updating the pushed refs.

This is a common hook to enforce project coding standards by rejecting bad formed commits or suspicious user.

### post-receive

This is run on the remote when pushing after the all refs have been updated. It does not take parameters, but receives info through stdin in the form of <old-value> <new-value> <ref-name>.

### post-rewrite

This is called when git commands are rewriting already committed data.

