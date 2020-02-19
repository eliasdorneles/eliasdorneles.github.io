# -*- coding: utf-8 -*-
from __future__ import unicode_literals
import os
_locally = os.getenv('USER') == 'elias'

SITENAME = 'Hopeful Ramble'

SITEURL = 'https://eliasdorneles.github.io'

if _locally:
    RELATIVE_URLS = True

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
    'extra/CNAME',
]
EXTRA_PATH_METADATA = {'extra/CNAME': {'path': 'CNAME'},}

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
