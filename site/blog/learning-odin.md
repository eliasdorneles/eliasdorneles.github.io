Title: Learning Odin
Date: 2025-06-15 21:04:50
Author: Elias Dorneles

Over the past month or so I've been learning [Odin](https://odin-lang.org/) and
I'm enjoying it so much that I'm breaking the silence on the blog.

I was quite into [Zig](https://ziglang.org/) for a while, but Odin seems more
mature at this point and, honestly, much more learnable and easier to make
things work. Writing Odin makes me remember what it was like when I started
writing Python -- that feeling of _"it can't be this easy, can it??"_. I still
like Zig, but Odin is just more... fun? And much faster to learn, I feel.

I like that "joy of programming" is one of the principles behind it. I also
like the vibe of "have fun, make something" that seems to come from the
community, maybe particularly from people like [Karl
Zylinksi](https://zylinski.se/), who wrote [an Odin
book](https://odinbook.com/) and made some [great tutorials for Odin and
Raylib](https://www.youtube.com/@karl_zylinski), among others.

In the world of AI agents that can spit code faster than you can say
"supercalifragilisticexpialidocious", I believe _joy_ becomes even more
important for enjoying the activity of programming.

What I've made so far:

- toyed around with raylib, which comes installed with Odin, and for which there
  are some [great tutorials](https://www.youtube.com/@karl_zylinski), from the
  same Odin book fellow aforementioned.
- [odin-jack-example-clients](https://github.com/eliasdorneles/odin-jack-example-clients):
  I ported some example programs for the [JACK Audio
  API](https://jackaudio.org/api/) from C to Odin: a program that generates a
  sine wave, one that reads MIDI events and sends audio to the output device,
  and another which records from the microphone and saves a WAVE file. Audio
  programming is a long-term journey for me and has been one of the main
  motivations for me to get back to low-level programming again after many
  years of mostly doing Python.
- this very website ([source code
  here](https://github.com/eliasdorneles/eliasdorneles.github.io)), which I've
  migrated from Pelican to [my own custom static site
  generator](https://github.com/eliasdorneles/eliasdorneles.github.io/tree/source/sitegen),
  which includes a tiny Jinja-like template engine.

Can't wait to make something else!
