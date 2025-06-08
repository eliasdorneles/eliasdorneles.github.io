Title: The power of a good template
Date: 2015-10-18 14:25
Author: Elias Dorneles

Almost ten years ago, I was an intern helping to maintain a PHP application and
attempting to write a little framework to create the new version of that
application. My little framework generated PHP classes from some templates and
a description you’d write in a DSL language I came up with.

It was a nice feeling to come up with a little model and quickly generate a
bunch of classes, but it was also pretty stupid: the generated classes would
get edited, and later the templates would change too, and suddenly all the
generated classes needed manual update.

So I learned back then the following lesson: generating code that needs to be
edited later is a bad idea -- instead of doing that, I must create libraries
and components that allow to be combined and build on top of them. I never
wanted to use boilerplate code generation again. I started thinking that any
solution that required boilerplate were too bloated. I also dismissed the
utility of code snippets too, because I wanted a function, not boilerplate
code.

Great, except this is the wrong conclusion.

It’s true that solutions which don’t require generated code are generally
better for reusability and long term maintenance (e.g. Python properties vs
Java getters), but good templates for boilerplate code generation can be of
great utility sometimes. Good templates are nice not only because they help you
get started in something quickly, they can also teach you the proper way of
doing things and get you started learning more about something.

I started to realize the power of code snippets a couple of years ago, when I
noticed that I was being lazy to write argument parsing code properly for my
Python scripts. I knew the script would be much better parsing arguments with
argparse, but as I wasn’t sure if the script would be useful when I started
writing it, I would be lazy and write something like:


```
import sys

inputfile = sys.argv[1]
if len(sys.argv) < 2:
    print("Please provide an input file")
else:
    process(inputfile)
```


And this is just awful, for a variety of reasons:

1. it doesn't have a nice help, so people would often need to read the code to
   understand what it does
2. the code isn’t obvious, one has to keep in mind details about sys.argv
3. it is hard to change when you have more arguments


After thinking about this laziness, I decided this was a good use case for a
code snippet, so I grabbed a vim plugin for code snippets and came up with the
following snippet:

```
:::python
#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Script description here
"""

from __future__ import print_function


def run(args):
    pass


if '__main__' == __name__:
    import argparse
    parser = argparse.ArgumentParser(description=__doc__)

    args = parser.parse_args()
    run(args)
```


Well, as you can see, there is not that much going on here, just simple
boilerplate stuff: a docstring, a shebang, a docstring, and an argparse
initialization inside the if main block.

However, now every time I started a script, even if I _really_ wanted to be
lazy, I could just add to the if main block:

    parser.add_argument('my_argument_name')
    
Then, I could code my script inside the `run()` function, ending up with a neat
code with help for free. Plus, it was easy to change, I could use the `argparse`
features for providing defaults, argument help text and maybe validate and type
check the arguments.

This little snippet changed my habit for writing scripts. It made the scripts
easier for people to use and modify them (including myself) and it helped me
to learn better the library, which I didn’t knew much besides the basics earlier
as I didn’t use it much. As I started using `argparse` more, I started
designing the command line interfaces better, making decisions about
positional vs optional arguments, handling grouping and conflicting options,
trying to come up with truly helpful help text.
The snippet freed me of making small bad decisions when starting a script.

My bad habit was impeding my learning, making life harder for people wanting to
use my scripts and making my life harder when maintaining the scripts. This
little snippet helped me to solve all these problems.

That is the power of a good template.

It helps you grow. If you let it. :)

Templates are not about being lazy -- they’re about _learning_.

A good template empowers you to learn better, by reducing the initial barrier.

About an year ago, I didn’t know much about Python packaging, my Python
projects were all badly packaged, the `setup.py` being patched when I hit
an issue. And every time I tried to read some packaging guide I’d get
overwhelmed pretty quickly. _“Uh, this is for Python gurus, too many
decisions I don’t understand, it will take years for me to learn enough to
build a nice Python package, nevermind.”_

Then I heard about [cookiecutter](http://cookiecutter.rtfd.org/) (tool for
building and using project templates), found this template for Python packages
called
[cookiecutter-pypackage](https://github.com/audreyr/cookiecutter-pypackage) and
gave it a try.

I was very happy when I first built my first little package in a matter of
minutes, wrapping some lame script I had around. It had gorgeous docs published
on [ReadTheDocs](http://readthedocs.org), tests running in
[Travis-CI](http://travis-ci.org), and last but not least, it was published in
[PyPI](http://pypi.python.org)! Now anyone can install it with `pip install
my_lame_package` -- this is awesome!

As the months went by, I got involved in splitting some code bases into smaller
packages. I used the cookiecutter-pypackage template for some of the new small
packages, and for others that needed more custom packaging I would get
inspiration about how the template solved a problem, discuss with others about
better ways to do it, and ended up learning a lot about Python packaging in the
process. I’m far from a guru, but I’m much less ignorant than one year ago.

All this in a learning process that started with trying out a template.

Templates are a great learning tool.

The lesson I should have learned in my failed framework attempt of long time
ago was not that boilerplate code generation is bad in general. It was bad for
what I was using it, generating application code that needed to be kept in sync
with the template sources, quickly turning the generated code into legacy.

But for code that can stand on its own, don’t require updates when the template
source changes, and specially for things that are a bit awkward to get started,
templates are awesome.
