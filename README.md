


whining that will inevitably result when your users' commit pushes are rejected. Having their carefully crafted work rejected at the last minute can be extremely frustrating and confusing; and furthermore, they will have to edit their history to correct it, which isn’t always for the faint of heart.

The answer to this dilemma is to provide some client-side hooks that users can run to notify them when they’re doing something that the server is likely to reject. That way, they can correct any problems before committing and before those issues become more difficult to fix. Because hooks aren’t transferred with a clone of a project, you must distribute these scripts some other way and then have your users copy them to their .git/hooks directory and make them executable. You can distribute these hooks within the project or in a separate project, but Git won’t set them up automatically.

that means `the commit-msg` file will need to be manually copied to each user's local repo `<repo-path>/.git/hooks/` folder.

the hook file is written in ruby but file should be without an extension to follow git hook file execution logic.

"ref/feat/fix/chore then followed by ':' then a ticket number, then message"
