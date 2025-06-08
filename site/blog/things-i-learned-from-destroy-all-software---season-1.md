Title: Things I Learned from Destroy All Software - Season 1
Date: 2015-01-18 10:07
Author: Elias Dorneles
Tags: das-screencasts


So, a few weeks ago I purchased and watched the first season of [Destroy All
Software screencasts](https://www.destroyallsoftware.com/) (from [Gary
Bernhard](https://twitter.com/garybernhardt)), and it was awesome. I'd say
there are different kinds of stuff to learn from it, depending on your personal
interests and experience.


Here are my notes for some things I found useful and want to remember for
later.


### About Git:


You can use the `git rev-list HEAD`  command to get a list of commits in the
current branch. This is useful for writing scripts to report something about
each commit in the repo.  You can, for example, check the evolution of line
counts over the course of the project (or any other statistic like number of
tests, number of files, etc). You can also run the tests for every commit in
the history:


    :::shell
    git rev-list HEAD | while read rev; do
       git checkout $rev && git clean-fd && make test
    done


Gary has a script ready for this:
[run-command-on-git-revisions](https://github.com/garybernhardt/dotfiles/blob/master/bin/run-command-on-git-revisions)

Git tracks everything that happens in the local repo, even stuff that is not
shared when you push (like when you rewrite history doing a rebase). You can
use `git reflog` to see the history of local changes and `git reset --hard
REFLOG_ENTRY` to go back to where you were.


### About design:

* Avoiding `nil` is good because it makes your code more predictable and tracebacks
more understandable.

* When adding tests to a suite, it's important to pay attention at your stubs.
If they are getting complicated, the design can probably be improved in a way
that will render better tests and better production code.

* When adding extra functions to a 3rd party API, sometimes it's tempting to do
monkey-patching of the library for a small change. It's usually better to use
a wrapper it instead, because later you will probably need more changes and
this will be easier if your production code is already using a wrapper.

* Isolated tests are good because they run faster, they encourage better design
and code clarity. This is something I've read about repeatedly in the past and
also applied to some of the code I've done myself, so it's not that new. But it
was great to watch someone applying this on several different code bases,
showing some interesting paths -- it inspired me to apply a bit more of this in
my work.


### About Unix:

To bring a background process to foreground, besides fg, you can also use `%N`
where N is the job number reported by the command jobs.

You can use the output of a command as if it were a filename, using
`<(COMMAND)`, like so:


    $ diff <(echo) <(date)
    1c1
    < 
    ---
    > Sat Jan 17 18:47:48 BRST 2015


The shell will run the commands and pass to the program file descriptors
with the proper contents, which you can verify doing:

    $ echo <(ls -l) <(ls -l)
    /dev/fd/63
    /dev/fd/62


This is useful for commands like diff that need more than one input file (and
therefore can't just use the stdin), to use it with arbitrary stuff generated
from other commands.

I found this specially helpful for when I want to refactor a script: before I
make changes, I store its original output in a file and then while refactoring
I keep comparing the output of the script with the file to see if I'm not
breaking anything:

    diff <(./my_script) original.txt

It can also be useful to see differences between two different versions of
the same web application or sites:


    diff <(curl -s http://somesite.com) <(curl -s http://anothersite.com)



### About vim:

It's nice to see people using vim well, because I can compare with my own
habits and see things where I can improve. Gary seems to strive to keep a tight
feedback loop in everything he's doing, so seeing him using vim and the shell
to build things in this fashion is pretty cool. I see it as a nice validation
for the choice of tools.

I found myself using splits a bit more, after watching the screencasts.  I'm
more used to using vim tabs, mostly because I'm not much comfortable with stuff
happening outside my view. This is probably something I can work better if I
grow some tolerance for it.


Apart from this, I stole a bunch of vim functions and ideas from [Gary's
dotfiles](https://github.com/garybernhardt/dotfiles), which I also share in [my
dotfiles](https://github.com/eliasdorneles/dotfiles).
