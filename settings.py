# -*- coding: utf-8 -*-
from __future__ import unicode_literals

SITENAME = 'Hopeful Ramble'

SITEURL = 'https://eliasdorneles.github.io'

FILENAME_METADATA = '(?P<name>[^/]+)'

ARTICLE_URL = '{date:%Y}/{date:%m}/{date:%d}/{name}.html'

ARTICLE_SAVE_AS = ARTICLE_URL

MENUITEMS = [('Blog', '')]

# I'm the only author
AUTHOR_SAVE_AS = ''

TIMEZONE = 'America/Sao_Paulo'

GITHUB_URL = 'https://github.com/eliasdorneles'

# DISQUS_SITENAME = 'hopefulramble'

JINJA_ENVIRONMENT = {
    'extensions': ['jinja2.ext.with_'],
}

STATIC_PATHS = [
    'images',
    'static',
]

CLEAN_SUMMARY_MINIMUM_ONE = True

CLEAN_SUMMARY_MAXIMUM = 1

FEED_DOMAIN = SITEURL
FEED_ATOM = 'atom.xml'
FEED_RSS = 'feed.xml'
RSS_FEED_SUMMARY_ONLY = False

PLUGIN_PATHS = ["plugins"]
PLUGINS = [
    'summary',
    'clean_summary',
    'pelican_alias',
]
