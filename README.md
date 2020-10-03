

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

## processing logic


1. extract kan ticket number from legal commit msg, if extraction fail, commit fail
2. make an api call to kanbanize api with ticket number, if not 200, commit fail
3. if kanbanize task check confirmed by ticket number, construct a kanban web access (slug) url and append to the commit message