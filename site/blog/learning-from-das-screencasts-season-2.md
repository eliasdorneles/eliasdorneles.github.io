Title: Learning from DAS screencasts - season 2
Date: 2015-08-17 01:41
Author: Elias Dorneles
Tags: das-screencasts

These are my notes for [season 2 of Destroy All Software
screencasts](https://www.destroyallsoftware.com/screencasts/catalog).

## The command line, Unix, git and Vim

In the first episode Gary teaches how to compose a complex Unix command line:
the point is that you want to build it slowly, checking if it works at every
step of the way. This becomes common sense pretty quickly after you acquire the
habit of doing this kind of thing for a while.

For example, say you want to remove the untracked files from a git repo.
Instead of trying to write all of this in one go:

    $ git status -s | grep '??' | awk '{ print $2 }' | xargs rm -f

Since you don't want to delete any files by mistake, you will check every step
along the way, until arriving at the safe command:

    $ git status -s
     M README.rst
    ?? anotherfile.txt
    ?? file.txt
    $ git status -s | grep '^??'
    ?? anotherfile.txt
    ?? file.txt
    $ git status -s | grep '^??' | awk '{ print $2 }'
    anotherfile.txt
    file.txt
    $ # great, got right the list of files now!
    $ # now let's pipe it to xargs and print the delete command:
    $ git status -s | grep '^??' | awk '{ print $2 }' | xargs echo rm -f
    rm -f anotherfile.txt file.txt
    $ # looks safe, let's remove the echo and do it for real:
    $ git status -s | grep '^??' | awk '{ print $2 }' | xargs rm -f


His example is more complicated and more interesting than this, but you get the gist of it.

The second episode is about the tar pipe, you can read [Gary's own post about
it here](http://blog.extracheese.org/2010/05/the-tar-pipe.html). I was already
familiar with the shell inner workings because I had to implement a toy shell
as homework when I was in college (my buddy
[Valdir](https://twitter.com/stummjr) and I had loads of fun with that).  It
was pretty cool to see it takes a few minutes and 10 lines of Python code what
took us days and many lines of C code at the time.

Later there is an episode about Vim with tips about how to learn it.
Here is a summary:

* Learn the normal mode
* Learn the motions (`:help motions`)
* Don't repeat yourself
* When automating stuff, you usually start with something that you *read* (a
  message in a buffer), then with something that you *scan* (a list of things),
  then finally with something that you *do* (an action or command).
* An action is better than scanning over a list which is better than having to
  read an interpret a message. Choose plugins that are more of the former than
  the latter.

The thing about Vim is that it feels like practicing a sport or playing an
instrument, you can often do edit work with your eyes closed.

In another episode Gary builds a command-line to look at evolution of the
execution time of the test suite, and then demonstrates using `git bisect` to
find out which change was responsible for a nice performance boost. He used a
few tricks which I thought were pretty neat. 

First trick was, while building a command line for a long list of commits, he
used awk to filter the input to get only every 50th line, before getting the
rest of the command line right for the full output, like this:

    some command generating many lines | awk 'NR % 50 == 0'

I can see myself using this in the future, it’s a good way of previewing the results of a command. :)

The other trick I liked was getting a quick histogram in the command-line using
[a command utility called jot](http://www.unix.com/man-page/freebsd/1/jot/)
present in Mac OS X and other BSD based systems. The `jot` command is pretty
similar to seq in Linux-based distros, only it allows to print a string
repeatedly (`-b` argument) while `seq` does not allow printing things other
than numbers. This is nice, because you can do things like this:

    $ jot -s '' -b'#' 10
    ##########

Now for an example plotting some numbers:

    $ seq 15 20 | sort -R | while read num; do echo `jot -s '' -b'#' $num` $num; done
    ################ 16
    ################### 19
    ################# 17
    ################## 18
    #################### 20
    ############### 15

While we don’t have `jot` distributed by default in Linux distros, we can do the
same thing in Linux using python:

    $ seq 15 20 | sort -R | while read num; do echo `python -c "print('#'*$num)"` $num; done
    ################# 17
    ############### 15
    ################### 19
    #################### 20
    ################## 18
    ################ 16

There are [a bunch of other ways of doing it in the shell
itself](http://superuser.com/questions/86340/linux-command-to-repeat-a-string-n-times),
but I like the conciseness and readability of this one.


## TDD

Some videos deal with Test Driven Design vs Test Driven Development, talking
about an idea I had never heard before called
[spiking](http://lizkeogh.com/2012/06/24/beyond-test-driven-development/)
(apparently I’ve missed some TDD literature). The idea is to write some code
without tests in a sort of exploratory way, usually to get an understanding of
what’s possible, and then throw it away and restart from the beginning writing
tests first.

Gary demonstrates the idea of doing [continuous
spiking](https://www.destroyallsoftware.com/screencasts/catalog/spiking-and-continuous-spiking),
where instead of throwing all the code away you’d transition it in a TDD-style
manner, as you write tests for it. (He shows another example of this later in
another video in a workflow using git, where you'd rebase the branch where you
spiked on top of the new implementation you're TDDing.) He mentions there is a
danger of doing this because the end result will probably be heavily influenced
by the design you ended up when doing the spike (writing code without tests),
so you’ll not be driving the design in a test-driven manner.

This probably sounds a bit extreme to some, but the reasoning is that you will
miss some design insights when you’re not putting yourself in the shoes of the
user. It makes sense to me, even though I confess I often do not work that hard
to do test driven design as I'd want to.

There was a nice video about test stubs making the distinction between
incidental interaction vs essential interaction and the relation to using a
normal stub (a dummy for an incidental interaction) vs a null object stub (aka
mocks, when you assert on methods, checking essential interactions). Testing
a module mixin may be a special case, you can mixin directly in the stub for
simpler testing.

As an additional note, it’s useful to make stubs first and share them for
several tests, to localize and make clear what each test cares about.

In another episode Gary shows something I’ve also learned on my own: it’s a
good practice to split tests that test several things into finer grained
isolated tests with meaningful names that test only one thing. This is
specially useful when you’re refactoring and a test breaks, because you can see
more directly what went wrong.

## Refactoring in a codebase new to you

There are two episodes quite interesting to watch, where Gary refactors out a
Rails controller without much previous knowledge about the code.

I find it hard to write about it, it seems to be the kind of thing for which
video is the best vehicle because it's hard to talk about it using words alone,
without showing the mechanics of it. It seems to me that these videos
illustrate that if you know well your language and tools, you can work
reasonably well in codebases that are new to you. It’s nice to try this kind of
thing every once in a while.

## Acceptance tests

In a video about acceptance tests, Gary shows the usage of
[Cucumber](https://cucumber.io/) for testing a Rails application, using a
browser engine to simulate user actions and a few tricks he uses to make it run
fast (20 scenarios with 104 tests in total, finish under ten seconds). I don’t
have much experience with [acceptance test-driven
development](https://en.wikipedia.org/wiki/Acceptance_test-driven_development),
but one good point I took from from this is that it’s better to come up with
meaningful short names for user actions ("when user creates a monthly coupon")
instead of long names that describe the input ("when user enters X into field Y
and selects option Z").

In another video he investigates the performance of tests testing the same
feature but from different levels for a Rails app: two acceptance tests using a
browser engine to simulate an user, two tests running the controller method
including rendering the view, two tests for the view only and finally two tests
for the same functionality inside a class method.

Plotting the results of the execution times for the tests at different levels,
the curve looks exponential. I suppose the lesson here is that it’s good to
move a lot of functionality into classes and libraries, in order to be able to
rely as much as possible into unit tests and not need to rely much on
integration and acceptance tests. This should probably not be much surprising.

Following that, Gary explains which of those tests he would actually want to
keep for the test suite of the app (he discards the controller tests, leaves
only one acceptance test and reluctantly keeps the view tests because they're
around a conditional). A good point he makes is that if you see a test that
it’s mostly talking about dependencies of the things it claims to be testing,
then it’s probably not testing at the right level.

And that's it for season 2, a pretty cool experience -- thanks for reading! =)
