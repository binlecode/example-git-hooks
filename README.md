


## install git hooks

```bash
install_hooks <target-repo-folder-path>
```

## remove git hooks

```bash
install_hooks --remove <target-repo-folder-path>
```

The `--remove` option enables deletion of all installed (copied) hooks.


## supported git hooks

- pre-commit hook to prevent commiting to main or master branch
- commit-msg hook for kanbanize task validation and info fetch



## client side commit message check

The fact that users' commit pushes are rejected due to bad commit message format (thus having their carefully crafted work rejected at the last minute) can be **extremely** frustrating and confusing.

And furthermore, user will have to edit their history, the already commited change locally, to correct it. This isn’t always a walk in the park.

Thus the need of some client-side git hooks that are automatically triggered at the time of user commit, and block the commit with the messsage that the server is likely to reject.

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

A common use case of pre-commit hook is checking if current branch is not main or master.

TODO:
- check current branch name conforms to a defined naming pattern

## ref - semantic release

https://github.com/semantic-release/semantic-release

## appendix - useful hooks

pre-commit - This hook is called before obtaining the proposed commit message.

prepare-commit-msg - Called after receiving the default commit message, just prior to firing up the commit message editor.

commit-msg - Can be used to adjust the message after it has been edited in order to ensure conformity to a standard or to reject based on any criteria.

pre-push - Called prior to a push to a remote. In addition to the parameters, additional information, separated by a space is passed in through stdin in the form of <local ref> <local sha1> <remote ref> <remote sha1>.

pre-auto-gc - Is used to do some checks before automatically cleaning repos.

pre-rebase - Called when rebasing a branch. Mainly used to halt the rebase if it is not desirable.

applypatch-msg - Can edit the commit message file and is often used to verify or actively format a patch's message to a project's standards.

pre-receive - This is called on the remote repo just before updating the pushed refs.

post-receive - This is run on the remote when pushing after the all refs have been updated. It does not take parameters, but receives info through stdin in the form of <old-value> <new-value> <ref-name>.

post-rewrite - This is called when git commands are rewriting already committed data.

