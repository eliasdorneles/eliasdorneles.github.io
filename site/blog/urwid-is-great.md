Title: Urwid is great!
Date: 2017-04-21 22:09
Author: Elias Dorneles
Status: published

Ever since I started using the awesome [pudb debugger for Python
programs](https://pypi.python.org/pypi/pudb) I've been curious about the [urwid
library](http://urwid.org/), an user interface library for console-based
applications that the debugger uses. The [examples in the
gallery](http://urwid.org/examples/index.html) are just gorgeous!

So last week I decided I would write a console-based game and learn Urwid in the process.
I decided to implement a [Solitaire clone (specifically, the Klondike form)](https://en.wikipedia.org/wiki/Patience_(game)).
I thought it would be fun to draw the cards using the [box-drawing characters](https://en.wikipedia.org/wiki/Box-drawing_character) and [card symbols](https://en.wikipedia.org/wiki/Playing_cards_in_Unicode) available in Unicode.

Here is a screenshot of the final game:

![Screenshot showing usolitaire](https://raw.githubusercontent.com/eliasdorneles/usolitaire/master/screenshot-usolitaire.png)

Before starting to code, I explored the library a bit in the shell, following [the examples from the tutorial](http://urwid.org/tutorial/index.html).
I also did [some planning](https://raw.githubusercontent.com/eliasdorneles/usolitaire/c18b4643bcd20cf53705a16de6072f2d1e766a43/PLAN.txt), working out how to draw the game elements so that it would fit a 40x80 characters terminal window.

Then it was time to start coding, I started by trying to write something that I could put in the screen, a [custom widget](http://urwid.org/manual/widgets.html) to represent a card.

After reading about widget layouts and sizings, I thought I wanted a fixed size widget, but my attempts to write one were hard to use, I kept running into [errors that happen when you try to use a fixed widget with things that expect something else](https://github.com/urwid/urwid/wiki/FAQ#what-does-the-attributeerror-xxx-object-has-no-attribute-rows-error-mean).

I was finally able to do it after reading more carefully the [documentation about custom widgets](http://urwid.org/manual/widgets.html#custom-widgets) and figured it was easier to use the ``urwid.WidgetWrap`` class around a ``urwid.Text`` widget drawing the card using line-breaks to break the content.

Overall I found the library nicely documented and very well designed.

I kept running into those errors related to the sizing mode later on, so I had to become a bit more acquainted with the widgets I was using to know if they were box-sizing or flow-sizing mode. I wonder if there is an easier way of dealing with those.

I'm really liking to play with this library, I think I'll try more stuff with it soon.

If you want to play the game, you can install it with:

    pip install usolitaire

The [source code is on Github](https://github.com/eliasdorneles/usolitaire).
