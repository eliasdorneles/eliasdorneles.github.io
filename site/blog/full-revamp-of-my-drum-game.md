Title: Full revamp of my drum game
Date: 2026-01-18 22:24
Author: Elias Dorneles
Status: published

In the past week I've fully revamped my [drum
game](https://github.com/eliasdorneles/drum-game) that I had initially written like 10
years ago.

[Play it here](https://eliasdorneles.com/drum-game/)

## The Revamp Story

**Before:**

<img src="{static}/images/drum_game-before.png" />

**After:**

<img src="{static}/images/drum_game-after.png" />


Did I use agent coding? Well, yes, I did!

I also used Gemini for some help improving the copy.

Actually I used this game project to try Claude Code again, since I had paid
for an annual subscription which I was not using at all, after getting
disenchanted with AI agent coding assistance.

Btw, I am sure I'm not the only person who have gone through a phase like this,
and it might be not even my last one -- I might need a break from AI coding
assistance in the future again. As a programmer who really _enjoys_ to program,
I am clearly mourning a certain loss of something, maybe the relevance of some
abilities that I had worked hard to build, like typing fast, or generally using
my creativity to write code.

Anyway, I had read some news about how agent coding had got much better over
the past 6 months and saw some colleagues having some good successes with it,
so I decided to give it another chance.

I'm glad I did, because I've got some good results with my game project, I
managed to implement -- gosh, I feel ashamed of using the word _implement_
when most of the code changes were done by the coding agent in "vibecoding"
mode... anyway, I managed to _get done_ several features that were sitting on a
[to-do list](https://github.com/eliasdorneles/drum-game/blob/master/PLAN.md)
for _years_ which I had never had the energy to implement previously.

It allowed me to greatly improve the game, and I have a bunch of ideas for what
to do next.

### Adding a level editor

One big enabler was adding a level editor, something that I wanted to do but wasn't sure exactly how to begin.

Until a few days ago, adding a level had to be done editing a JSON file. You
know, okay for simple patterns, but not a good workflow to work with music. To
be able to design better levels, I needed a way to be able to quickly preview a
drum loop, make adjustments and check the result.

It took like 3 or 4 prompts to have a nice usable level editor that I could use
right away. This alone already allowed me to make the game much better, with
more interesting and musical drum patterns, and got me very excited.

The level editor looks like this:

<img src="{static}/images/level_editor.png" />

## Coding with AI

So yeah, I guess I am back to using AI for coding again.

I am worried of getting hooked to it and becoming "dumb", because there is
clearly a big dopamine hit when things work, and it can get addictive.

For production work, I will need to be a lot more careful and disciplined than
what I can get away with on a weekend project like my drum game. So, we'll see!

### Usage limits

I did bump into the usage limits after like 40 prompts or so, that was a bit annoying. I didn't
do anything special to optimize my token usage except compacting the conversations a few times.

Honestly, I don't feel like doing that -- using the lesser model would be less
reliable, and I can live with the limit. It is a good reminder that these tools
are expensive and energy-intensive, so it's a good thing to be mindful about
how much I use it anyway, and maybe this way I won't rely on it too much.
Working in bursts is fine by me.

### Conclusion?

I am excited about the possibilities of creating more things!

At the same time, I'm mourning the value loss about manually written code
and relevance of some of my hard-earned abilities.
I am also worried about the cost of this kind of technology and the power that
it gives to people that will use it for malicious purposes...

I hope that it will be used more for good than for evil!

I believe in the world there is just enough love to prevent hate from
destroying everything, I hope it will continue to be the case!
