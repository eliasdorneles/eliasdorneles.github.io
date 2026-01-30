Title: Useful small scripts for your ~/bin
Date: 2015-01-28 00:03
Author: Elias Dorneles
Status: published

### fields


So you are a command line geek, you do your
shell-scripts and one-liners using bash to get information you
need.

You use [cut](https://en.wikipedia.org/wiki/Cut_(Unix))
for handling things delimited by some character like comma or space, but
sometimes you have a list of stuff separated by a varied amount of
spaces, like this:


    $ cat myfile.txt
    Amelia        555-5553     amelia.zodiacusque@gmail.com
    Julie         555-6699     julie@skeeve.com


This form of vertical alignment is cool because you can skim through any column
very quickly, but it makes your life a little bit harder when processing it in
the command line. Well, maybe you're smiling to yourself because you already
know about [awk](https://en.wikipedia.org/wiki/AWK), and you use it all the time
for this kind of stuff doing something like:  

    $ cat myfile.txt | awk '{ print $3 }'
    amelia.zodiacusque@gmail.com
    julie@skeeve.com


That's all fine, [awk is a great tool to
grok](http://ferd.ca/awk-in-20-minutes.html), but typing all that just for
getting out a field is a bit annoying. So I've written a little script to make
that yet easier: just [download
it](https://github.com/eliasdorneles/dotfiles/raw/master/bin/fields) and put
somewhere in your $PATH. After that, next time you find yourself in this
situation you'll do:


    $ cat myfile.txt | fields 1
    Amelia
    Julie
    $ cat myfile.txt | fields 2
    555-5553
    555-6699
    $ cat myfile.txt  | fields 2 3          # get fields separated by TABs
    555-5553    amelia.zodiacusque@gmail.com
    555-6699    julie@skeeve.com
    $ cat myfile.txt  | fields -s , 2 3     # or by comma
    555-5553,amelia.zodiacusque@gmail.com
    555-6699,julie@skeeve.com



### total_sum

Another thing you may found yourself running to awk is when you need a sum of
numbers. Often when you need a summation you will also need some more stuff,
and then it might be time to start writing a Python/Ruby/Perl script instead of
hacking in the command line. But I've often finding myself wanting just a
simple sum that justified putting the little awk one-liner [into a script of
its own](https://github.com/eliasdorneles/dotfiles/raw/master/bin/total_sum):


    $ cat ~/bin/total_sum
    #!/bin/bash
    # Report sum of numbers fed to the stdin
    
    awk '{ total+=$1 } END { print total }'
    $ echo -e "1\n2\n3\n4"
    1
    2
    3
    4
    $ echo -e "1\n2\n3\n4"| total_sum
    10


### humanize

If you find yourself having to count digits from a long number representing the
size in bytes of some big file, you're not alone.

I got tired of this and wrote [a Python script to humanize these
numbers](https://github.com/eliasdorneles/dotfiles/blob/master/bin/humanize)
([download
here](https://github.com/eliasdorneles/dotfiles/raw/master/bin/humanize)),
shamelessly stealing the naturalsize function from the [humanize Python
library](https://pypi.python.org/pypi/humanize).

Look how pleasant it is to use it:


    $ humanize 32432
    32.4 kB
    $ echo -e "10\n1200\n54356\n3123342\n3294384948" > some_file.txt
    $ cat some_file.txt
    10
    1200
    54356
    3123342
    3294384948
    $ cat some_file.txt | humanize
    10 Bytes
    1.2 kB
    54.4 kB
    3.1 MB
    3.3 GB
    $ cat some_file.txt | humanize--binary
    10 Bytes
    1.2 KiB
    53.1 KiB
    3.0 MiB
    3.1 GiB


That's all I had, folks! :)
