# My blog

Source code and content for [my blog](https://eliasdorneles.com)

Built with a custom static site generator written in [Go](https://go.dev).

## Setting up

Install [uv](https://docs.astral.sh/uv/) (currently only used for deploying).

Install [Go](https://go.dev/dl/).

Run `make` to see the help.

## History

My blog has known many homes, and the one that lived longer was
a static website built with [Pelican](https://getpelican.com/).

In 2025 I learned Odin and decided to use it for building my website, as it was
a good learning opportunity. That's how the [sitegen](https://github.com/eliasdorneles/eliasdorneles.github.io/tree/source/sitegen) tool was born.
In 2026 it was rewritten in Go, using [gonja](https://github.com/NikolaLohinski/gonja)
for templates and [goldmark](https://github.com/yuin/goldmark) for markdown.

In early 2026, I built a blog editor/manager tool, the whole tale and a bit more history [is explained in this blog post](https://eliasdorneles.com/2026/01/31/fluid-blogging-again.html).
