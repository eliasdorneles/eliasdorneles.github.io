Title: On getting productive with Git
Date: 2016-06-19 00:29
Author: Elias Dorneles
Slug: on-getting-productive-with-git


I remember the first time I submitted a pull request in GitHub and some
reviewer asked me to [squash the
commits](https://git-scm.com/book/en/v2/Git-Tools-Rewriting-History#Squashing-Commits).
I had no idea what they were talking about. I didn't have any friends who knew
Git, I was pretty much a noob on Git and GitHub. It's easy to forget how scary
this stuff can be for someone just starting out with their first open source
contribution.

<div class="figure align-right" style="width: 250px">
<img src="{static}/images/confused.png">
<p class="caption">
    First-timer OSS contributor asked to rebase and squash commits
</p>
</div>

It took me several weeks to figure out the whole thing because I was so afraid
of messing up. And in the end the code didn't even get merged.

I never forgot my frustration during this, which is why today I avoid as much
as possible to ask for someone to rebase their code in a pull request, unless I
can pair with them and show how to do it.

<!-- PELICAN_END_SUMMARY -->

Well, nowadays [GitHub allows a maintainer to squash commits when
merging](https://help.github.com/articles/about-pull-request-merge-squashing/),
which is pretty cool. However, this isn't a task that's particularly hard to
do. When you have someone else to show you how, you pick it up real fast. It's
just a bit scary when you're on your own.

I've found there are many little things like this with Git. Git is a fine tool
for collaborating on software development and many open source developers would
find hard to use any other thing.

However, there is all this learning curve you must go through until you're
finally actually productive with it. When you're just starting to use it, this
XKCD comic is very real:

<a href="https://xkcd.com/1597">
<img src="https://imgs.xkcd.com/comics/git.png" class="align-center">
</a>

You want to get stuff done, you don't want to be spending cognition on your
version control tool. With Git, it takes a little while to get to a point where
you don't need to think much about it, at least when you're collaborating on a
project with many different people, as is the case in many open source
projects.

I want to share with you a couple things I learned in order to get productive
with Git, in the hopes that it will ease your own learning curve and get you
productive quicker. This won't be a Git tutorial, it's more like a booster of
your own Git learning. These are things that helped me to learn and use Git
better. If you want a tutorial, [this is a cool one](https://try.github.io).

I'm far from a Git expert, most of what I learned was while trying to get stuff
done, usually after googling for _"how to do X in Git"_. I have trouble
understanding Git's help because it seems to be written for people that know Git
internals, using all this unfamiliar vocabulary. But I can get stuff done, and
you can too.

So, let's start! The first thing I want you to know is ...

## There is always a way to undo

The fact that this isn't obvious and that undoing things in Git aren't
always straightforward, is one of the biggest reasons for the fear of messing up.
So, let's get rid of those fears first.

Almost always, there is a way to undo whatever you've done. This is true even
when you've used one of the power tools (`git rebase`) that rewrites the commit
history. As long as you haven't deleted your local repo, you can always get
back to a previous state.

### Undo a commit

If you've committed and then realized that you didn't mean to,
don't worry, you can undo it with the following command:

    git undo-commit

This will undo the last commit, but will keep your files intact
so you won't lose any work.

Now, if you've just tried running that and it didn't work it's because I've
lied to you -- sorry! That command doesn't exist by default in Git, but it
should! In order to add it, run the following command:

    git config --global alias.undo-commit 'reset HEAD~1 --mixed'

This adds an alias, which is essentially a shortcut to another command.
Git aliases are very helpful, because that's how you tweak Git's complicated
command line interface to something that's actually usable. Aliases (and
Git's global configuration for your user) are stored in a `.gitconfig`
file in your user directory, which you can edit using your editor if you like.

In fact, you can even add an alias to add new aliases more easily, but this may
be getting out of hand... Anyway, later on, we'll see also how to use Bash
aliases and functions to further improve the workflow.

You can check [my personal
gitconfig](https://github.com/eliasdorneles/dotfiles/tree/master/gitconfig)
(which contains the stuff I share here and more) if you're already familiar
with this stuff and came here only for the Git aliases.

You can use any other alias name that you prefer instead of `undo-commit`
there. Personally, I use just `undo` for this one.


### Undo adding a file to commit

If you've added a file with `git add` that you didn't mean to,
you can undo it with:

    git undo-add

Again, this is only after you've added the proper alias with the following command:

    git config --global alias.undo-add 'reset --keep'


### Undo a rebase that went wrong

If you've tried doing a rebase or some other command that rewrote the commit history
and you want to undo it, you can use something called the reference log (or, `reflog`).
Try running `git reflog` in a Git repository, you'll see something like this:

    26e15cf HEAD@{0}: rebase finished: returning to refs/heads/master
    26e15cf HEAD@{1}: pull --rebase: moving basic path config to ~/.profile to work with gnome apps
    f993d5c HEAD@{2}: pull --rebase: checkout f993d5cc3d6df6ce9f5c083ebf17d45b9c7e9130
    b517509 HEAD@{3}: pull: Merge made by the 'recursive' strategy.
    29438f2 HEAD@{4}: commit: moving basic path config to ~/.profile to work with gnome apps
    a000618 HEAD@{5}: clone: from git@github.com:eliasdorneles/dotfiles.git

This is a log of every state of your files that is stored, which includes
when you commit changes, checkout branches, do rebases (with separate states
for every step of the rebase), merges and etc.

You can get back to any of those states, using the command below, replacing
`REFLOG_ENTRY` by the `HEAD@{index}` from the reflog for the state
you want to go back:

    git reset --hard REFLOG_ENTRY

Note that those numbers are counting backwards, they change every time you make
a change in the repo. You want to always run `git reflog` before going back,
to be sure you'll use the up-to-date reference.

Also, note that these logs are only stored locally, you'll lose them if you delete
your local repo.

------------------

Alright, we're done covering undoing stuff. I hope now that you know how to
undo, you will feel more comfortable trying more stuff without the fear of
breaking things. The next tips will be a bit more random.


## Enable colors

Your brain can parse this:

<img src="https://i.imgur.com/OBOFz7A.png" width="400" class="align-center">

Much easier than this:

<img src="https://i.imgur.com/ajXQxbA.png" width="400" class="align-center">

In case your Git output isn't showing colored output, configure it to do so:

    git config --global color.ui auto

Also, if you end up needing to do this, consider upgrading Git, this has been
the default for some time, together with many other nice usability
improvements.


## Preparing files to commit, the easy way

I rarely run the command `git add FILENAME`.

I usually use short aliases to either `git add --update` or `git add --all`.

### Add only files that were edited, ignore new ones

When you want to commit all files that you have edited,
ignoring any new files that may now be inside the repo
directory, do:

    git add -u

This is a shortcut to `git add --update`, which is the equivalent
of doing a `git add` on every modified file that were previously
committed.

It can also take a directory, you can ask Git to add only
files that were edited inside a directory:

    git add -u tests/

### Add all files, detecting file renames and deletes

Git expects you to tell it when you rename or delete files. You can ask Git to
add all changes to be committed, including adding, deleting and renaming
files, using the command:

    git add --all

You can also give it a directory, so that Git only does this for the stuff under it:

    git add --all some_dir/

I use this so often that it deserved an alias:

    git config --global alias.aa 'add --all'


## Solve conflicts only once

When you're merging or rebasing often, some conflicts keep reappearing,
specially when you're working temporarily on a branch. Instead of solving them
again manually every time, ask Git to do it automatically, by enabling
[`rerere`](https://git-scm.com/docs/git-rerere):

    git config --global rerere.enabled true

The name `rerere` stands for "reuse recorded resolution", and that's exactly what
it does: it will record how you solved previous conflicts and next time it finds
the same conflict it will just apply your previous fix. This way, you won't need to
keep solving the same conflicts again and again and save a few brain cycles.


## Opening files in your editor

I edit code in [Vim](https://www.vim.org).

But even if you don't, you might find useful these Bash functions and aliases
(taken from [my `~/.bashrc` file](https://github.com/eliasdorneles/dotfiles/blob/master/bashrc))
and tweak them to your needs:

```
edit_modified_files(){
    $EDITOR $( (git ls-files -m -o --exclude-standard; git diff --cached --name-only --relative .) | sort | uniq)
}
edit_files_with_conflicts(){
    $EDITOR $(git diff --name-only --diff-filter=U)
}
edit_recently_committed(){
    $EDITOR $(git show --name-only --oneline --relative . | egrep -v "^[a-z0-9]+ ")
}
alias em=edit_modified_files
alias ec=edit_files_with_conflicts
alias er=edit_recently_committed
```

I came up with these functions when I realized how often I wanted to do open
the editor and load one of these set of files:

1. the ones that are currently modified, so I can wrap it up for commit
2. the ones that have conflicts, so I can fix them
3. the ones that were in the last commit, so I can continue working on them

This may or may not be useful to you, depending on how you use your editor.
In my case, I open and close vim often, sometimes in different terminals,
so this has been quite handy.


## Fetching code from a pull request (GitHub only)

> **Update:** [A friend](https://github.com/immerrr) has pointed out that
> another option is to [add a configuration to have the PRs fetched
> automatically](https://gist.github.com/piscisaureus/3342247).

If you maintain open source projects, you may like this one.

When you want to check out locally the changes introduced by
a pull request, in vanilla Git it's a bit of work (you have to add
a new remote, fetch from it and then checkout the branch). GitHub
allows you to skip adding a new remote, you can fetch the code
from a pull request into a new branch with only one command:

    git fetch origin pull/$PULL_REQUEST_ID/head:BRANCH_NAME

If you're like me, you'll be lazy to type (and memorize) all that too,
so here is an alias for doing that, paste it under the `[alias]` section
in your `~/.gitconfig`:

    fetch-pr = "!f(){\
        [ -z \"$1\" ] && { echo Usage: git fetch-pr PULL_REQUEST_ID [new_branch_name]; exit 1; }; \
        branch=${2:-pr-$1}; \
        git fetch origin \"pull/$1/head:$branch\"; \
        }; f "

This alias is using a shell function to parameterize it.
If you run `git fetch-pr` it will show the help:

    $ git fetch-pr
    Usage: git fetch-pr PULL_REQUEST_ID [new_branch_name]

Using this, to fetch the code from pull request #1234, you can do simply:

    git fetch-pr 1234

This will create a branch called `pr-1234` with the checked-out code.
If you want to name the branch, just provide yet another parameter:

    git fetch-pr 1234 new-branch-for-pull-request-1234


## Other things that might be helpful

`git stash` is an useful command to know: it sets aside your current changes,
so you can work in other stuff. Use `git stash pop` to get back the changes.
This is handy to switch to a different task, without having to copy files or
lose your current uncommitted progress.

I've also found useful to know how to use diffs & patches, including the diff
tools `git diff` & `git apply` and also the `patch` command-line tool. These
are helpful a few times, when you have to replay your work in another
repository.

If you like to do atomic commits (i.e., making each commit introduces a small
self-contained change), you will like the `git add -p` command. It starts an
interactive session, asking for each piece of the diff if you want to include
in the next commit or not.

You will also like the `git diff --cached` command, which shows the diff for
the stuff added to the index, i.e., the changes you're about to commit.

One tool that I've been meaning to learn is [tig](http://jonas.nitro.dk/tig/),
a console interface for Git. It has some nice features, like you can do `tig
grep` to search files and then hit `e` on top of a search result to open the
file in your editor in that exact place. I haven't adopted this tool fully
in my workflow, though, I'm still evaluating.

There is also this thing called [Legit](http://www.git-legit.org), a set of
extensions (used via aliases) created by [Kenneth
Reitz](https://twitter.com/kennethreitz) (from [Python
Requests](https://www.python-requests.org) and [httpbin](https://httpbin.org/)
fame) which looks interesting. I have only recently started experimenting with
it, so I can't comment much. I know that Git deserves something like it. If you
use it, let me know how you like it.

Finally, you may also like this [StackOverflow thread with Git questions and
answers](https://stackoverflow.com/questions/315911/git-for-beginners-the-definitive-practical-guide).

That's all I had for now, folks!
