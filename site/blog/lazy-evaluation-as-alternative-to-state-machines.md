Title: Lazy evaluation as alternative to state machines, maybe
Date: 2017-03-27 22:13
Author: Elias Dorneles
Status: published

Some days ago I read [this nice article talking about co-routines as an
alternative to state
machines](http://eli.thegreenplace.net/2009/08/29/co-routines-as-an-alternative-to-state-machines).

The most popular use case for co-routines in Python has been asynchronous I/O,
and there are a bunch of Python things that use them (like
[Twisted](https://twistedmatrix.com), [Tornado](http://www.tornadoweb.org) and
the standard library module
[asyncio](https://docs.python.org/3/library/asyncio.html) which appeared in
Python 3.4).

Apart from the async stuff, I find quite hard to think up use cases for
co-routines, they mostly look like complicated stuff that smart people have a
lot of trouble to make it useful.

So I was curious about this idea of using co-routines as alternative for [state
machines](https://en.wikipedia.org/wiki/Finite-state_machine), because state
machines are kind of everywhere, even if not always explicitly.

I've seen a few other examples that kinda made sense, like David's [scheduler
for cooperative tasks](http://www.dabeaz.com/coroutines/pyos8.py), and a
discrete event simulation in the book [Fluent
Python](http://shop.oreilly.com/product/0636920032519.do) by [Luciano
Ramalho](https://twitter.com/ramalhoorg), but these still seem a bit far away
for me.

So I decided to test out for myself reimplementing some simple state
machine as a co-routine and see how it goes.

## Are co-routines an alternative to state machines?

To try out the idea, I decided to write a small program using a state machine,
and then write a co-routine version of it. I decided to implement a naive
program to strip out C-style comments.

I must say that this is not production code, it ignores the case of comments
inside of a string (as in `'/**/'` for the sake of simplicity). I only wrote
this to explore the idea of alternatives to state machines.

Here is a diagram of the state machine:

<center>

![Picture with diagram of Finite State machine]({static}/images/fsm_strip_comments.png)
</center>

[Here is the state machine implementation](https://github.com/eliasdorneles/lazy-eval-gt-state-machines/blob/master/001_state_machine.py).

It was fairly straightforward to implement, but the code ends up a bit verbose.

Next, I went on and wrote [the co-routine version](https://github.com/eliasdorneles/lazy-eval-gt-state-machines/blob/master/002_coroutine.py), and didn't really like the result.
First of all, I find a bit cumbersome having to write the sink and build the driving code,
I thought: "why can't I just use the function? what if I want to do something
else than just print, do I have to write a sink-like code every time?"

After mulling for a bit, I realized that the most important gain from the
co-routine code was being able to "pause execution", so I figured I could write
a generator function that would consume the input lazily. While attempting
to do that, I realized I don't even need it to be a generator, it can
be just a regular function that will consume the input lazily and
return the full results.

And [that's what I did, and decided that I like this code more than the co-routine version](https://github.com/eliasdorneles/lazy-eval-gt-state-machines/blob/master/004_imperative_final.py).
I think it allows you to skip thinking about the explicit states when writing
the code, it's lazy and it's easy to use (just a regular function).

I'm not sure if it's better than the state machine version, though,
because I think to read it and understand you sort of have to build a
mental model of the states in your head. So it seems easier to write,
but may be tougher to read.
I think for state machines with high number of states this would not be
good for maintainability, and you'd probably want have a diagram.

I also had [a bug on the first
implementation](https://github.com/eliasdorneles/lazy-eval-gt-state-machines/commit/458fb7e124dff3bb06a9f61b62453507ad0c3d75),
which I only noticed when writing this blog post and [creating the state
machine
diagram](https://github.com/eliasdorneles/lazy-eval-gt-state-machines/blob/master/diagram.dot)
and then had to go back and [fix it in the other implementations](https://github.com/eliasdorneles/lazy-eval-gt-state-machines/commit/0bb8092a7d7b80aae34ef95af1334657ffd04ff5).
Fixing the bug was a lot easier for the state machine implementation.


## Conclusions, or, how I feel about this

State machines are complicated, but they're very useful. Even if it takes some
effort to understand them, I feel it's still less effort than co-routines.

Co-routines are also complicated, I find they demand too much cognition
to work with and can be harder to debug than regular state machine code.

Combining lazy evaluation and Python functions probably work better as an
alternative of state machines than co-routines, because they give you the
benefits without most of the drawbacks.

I'm not sure if they're as much powerful nor I'm convinced that the code is
more maintainable, but for some state machines it may be very expressive.

Also, [regular expressions are awesome](https://github.com/eliasdorneles/lazy-eval-gt-state-machines/blob/master/005_pro.py). =)
