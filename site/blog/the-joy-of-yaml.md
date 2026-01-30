Title: The Joy of YAML
Date: 2021-08-13 22:14
Author: Elias Dorneles
Status: published

I haven't written much on the blog on the last few years, I don't know, I
didn't felt like I had much to say.  There is so much being said on the Web,
lots of great stuff, but also tons of crap too, and I didn't feel like adding
to the noise. I've learned loads of stuff, but not in the mood for sharing, and
anyway the most important stuff wasn't related to tech.

But today I've got the itch to write, and this little comeback is to tell you that I think
[YAML](https://en.wikipedia.org/wiki/YAML) is a pretty cool thing because it
lets you cut corners, ship things fast, give power to your power users, all
that while keeping the design straightforward.

The traditional way most Web programmers have learned to do things like content
management systems, forms, and such, goes something along these lines:

1. get a database (usually relational)
2. setup a web app with your framework of choice
3. create the user facing features, either by old-fashioned Web app, or API + frontend app
4. create an administration interface for staff users to update content

<sup>(yeah yeah, there are cloud paas providers, nosql, graphql, brainfucql,
yadda yadda... whatever, I said _traditional way_! By that I mean, people that
learned like me =P)</sup>

I want to talk about this last step: the admin interface for your internal users.

When you're doing this for users that you can trust, that's where YAML can be
of great value.

## Growing the admin interface is tricky

If you use a framework like
[Django](https://docs.djangoproject.com/en/3.2/ref/contrib/admin/), you get
lots of help for quickly having a neat administration interface from the start. With a
few lines of code, you get something that users can actually use, which can be
extended in many ways by adding a few more lines of code.

<sup>(If you're not using Django or something similar, you don't get much help
and you gotta implement it like any other user feature, which means it's
even more expensive.  I'll stick to Django or similar here to make my
point.)</sup>

So it's great, and it is one of the reasons why I and many people like
Django. It's a web framework for perfectionists with deadlines. Even as a solo
developer, you get a lot of shit done real fast, with code that doesn't look
too bad. Awesome!

Except... well, if the system continues living on for a few years, it keeps
increasing and being patched up, you keep adding models and relationships, and
your admin interface starts getting quite complicated.

Users start to get lost on the many different models and the relationships
between them, because the structure isn't clear anymore when you have a few
dozens of models / tables. You start reaching the limits of what can be
achieved with extending the Django admin, it's not as easy to add things
quickly anymore, things like proper validation are quite complicated because of
the many relationships, the admin is getting complex and slow.

And if you have multiple deployment environments (production, staging, beta,
etc), it can get tricky for users as well. They will maybe have to do all this
complicated setup on a testing environment, and then redo everything again on
production once things are deployed. Ugh, it's getting painful.

What to do?

## Your admin interface is configuration

When I was learning how to program in college, I quickly developed some sort of
taste / habit for most of the code I'd write: I would start with a hard-coded
hash table with configuration at the top of the module file, then a bunch of
functions under that, and at the very bottom there would be some main-like code
that would drive the execution and use the configuration.

A lot of what I wrote back then was PHP, so reducing it to a minimal example, it looked to something like this:

```php
<?php

$config = array(
  "items" => array(
    "apple" => array("count" => 2, "description" => "Apples for baking a pie"),
    "banana" => array("count" => 1, "description" => "Banana for quick dessert"),
    "tomato" => array("count" => 3, "description" => "Tomatoes for a salad"),
  )
);

function generate_table($items) {
  $out = "<table>\n";
  $out .= "<th><td>Name</td><td>Count</td><td>Description</td></th>\n";
  foreach($items as $name => $it) {
    $out .= "<tr>";
    $out .= "<td>" . $name . "</td>";
    $out .= "<td>" . $it["count"] . "</td>";
    $out .= "<td>" . $it["description"] . "</td>";
    $out .= "</tr>\n";
  }
  $out .= "</table>\n";
  return $out;
}

echo generate_table($config["items"]);
```

I remember that my friend Valdir, with whom I hanged out all the time, after I showed him some code I was working on, he told me: "dude, I know a piece of code is from you when I see a big array of configuration in the beginning!". He was teasing me, of course, we had a laugh, and I remember feeling kind of proud of it! _"Yeah, this is my thing!"_

There were a bunch of things that I liked about this:

1. I had one central place to put all the "knobs" that determined how the program behave. That's pretty neat, if I came back later to code that I had written before, I didn't need to read through the code to figure out where to tweak some parameter: I would go directly to my configuration array.

2. I could quickly extend the configuration (copy and paste, modify, tap tap tap...), and use my text editor features and my growing [vim](https://www.vim.org) skills.  Working on vim is addictive: I still code on it to this day, even after trying lots of other editors and IDEs ([and my configuration files are on Github, if you're curious](https://github.com/eliasdorneles/dotfiles)).

3. I could easily add new knobs and extend the model as needed, sometimes by only changing the type of structure: need to add more details to some value in one place? Replace the scalar variable and turn it yet into an array, then in the code type-check and do the right thing if it's an array or scalar.

At the time I was doing it mostly out of intuition, I don't remember having
clearly stated why I like to do it like this back then. But I like to think
that the young programmer I was, in his own way, felt already the need to
come up with something of a clean architecture.

Though I'd probably tell you off if you'd tell me something like that, back
then I was pretty rebellious and I hated jargon that wanted to sound important
like "architecture", "layers". I only trusted code that I could read and run.
I had absorbed a bit too much that phrase from Linus Torvalds, _"talk is cheap,
show me the code"_.

If you had sent me the link to a [blog post by Robert Martin defending clean
architecture](https://blog.cleancoder.com/uncle-bob/2011/11/22/Clean-Architecture.html),
I would scoff.

But, deep down, I was working my way into those ideas. Years later, when I was ready,
I read folks like Martin Fowler, Robert Martin, Kent Beck, and was like "yes, yes!"

Okay, I like that I showed you some PHP code even though you, dear reader, are most likely a lover of Python, but I will stop digressing and get to the point.

The first point is: every big enough well-structured program has need of some form of configuration.

That is, structured information that some power user may need change from time to time. Some values are more stable than others, some almost never change, some are specific to a deployment environment, etc. It's usually not truly programming code, but it can be, or it can contain code bits. And if it's kept in text files, it starts looking a lot like code, and you can use text editors, with syntax highlighting and automatic checks.

The second point, and this is the important one, is that you can turn some of
your admin interface into configuration files, and let your internal power
users use their text editor to copy and paste, and have their fix of
dopamine when they write "code" and it works!

And that's where YAML comes in!

There is a lot to gain from using well-structured YAML files for the more
stable bits of admin configuration.

Put the files somewhere where your staff users can access and change them, for
example, a dedicated Git repository, or something like an S3 bucket -- this way
you can even track history for free, no need to implement anything fancy.

Then, you can either sync the files with the database, or make your system read
directly from S3, or whatever suits better your system.

## YAML is powerful and human readable

Of the most commonly available configuration file formats, YAML is the one that
has the best combination of tooling support, power and readability.

In my current job, I will sometimes draft some YAML together with the product
folks who can immediately understand what it means, and later even write YAML
on their own. That YAML draft becomes a spec once everyone is happy with it,
and feeds right into the implementation. In a way, it's almost like it would
answer the programmer who would say: _"talk is cheap, show me the code"_.

It's widely supported, has plenty of tooling support, and if you've never done
any YAML, you may be surprised that it has even some [reuse
features](https://www.netways.de/en/blog/2019/11/21/gitlab-ci-yaml-write-less-with-anchors-extends-and-hidden-keys/),
so that I don't need to repeat myself, unless if I so desire.

And it's not hard to learn, you can learn the basics in Y minutes:
[https://learnxinyminutes.com/docs/yaml/](https://learnxinyminutes.com/docs/yaml/).
Of course you won't do this right now, you'll learn as you go when you need it,
on your rhythm, and that's totally fine.

The only kinda bad thing about using YAML is that, depending on your parser
implementation, sometimes you might run into some confusing error messages for
some silly syntax errors, which is **VERY** annoying.  As YAML is
indentation-based (like Python), there are some corner cases for which it's
tricky to handle the error with a clear error message -- oh well.

But most of the time it works correctly, and the value that it brings overcomes
this by far.  Plus, the tooling will get better and better, and perhaps more
importantly, people get better at avoiding mistakes even more quickly, so it's
fine.


## YAML inspiration

The DevOps folks have known about the power of YAML for quite a while, plenty of DevOps tools
use YAML for its configuration.

One great example is [the Gitlab CI
configuration](https://docs.gitlab.com/ee/ci/quick_start/#create-a-gitlab-ciyml-file)
which is all YAML-based, which is a great inspiration. They've actually kind of extended
YAML supporting "include" features and other things.

Someone did a round up of [some common formats used for configuration
here](https://octopus.com/blog/state-of-config-file-formats), mostly to explain
why Hashicorp went out to develop [their own language](https://github.com/hashicorp/hcl) to use
in Terraform, which is actually quite cool, but not really usable for anything other at this point.

A non-DevOps example: a French startup called Papernest [has essentially built
an internal CMS based on
YAML](https://medium.com/papernest/papercraft-le-secret-des-po-de-papernest-pour-sortir-des-features-sans-une-seule-ligne-de-code-f5b85de97202),
with AB-testing support and all.  I specially like how they came up with a neat
way of representing nested AND/OR conditions that you can see on one of the
screenshots, something which is [notably hard to come up with a good user
interface
for](https://ux.stackexchange.com/questions/11177/good-solutions-for-boolean-filter-with-sub-conditions),
[even for
Apple](https://ux.stackexchange.com/questions/1737/intuitive-interface-for-composing-boolean-logic).

Okay, I think I said everything I wanted to say, let's stop here!

Aaaand, I've managed to write a blog post about YAML with zero YAML snippets on it, only PHP, haha!

I'm off, have a good one, folks!
Have fun coding, or whatever it is you like to do! =)
