# -*- coding: utf-8 -*-
from __future__ import unicode_literals

import os

_locally = os.getenv("USER") in ("elias", "batman")

SITENAME = "Elias Dorneles"

SITEURL = "https://eliasdorneles.com"

if _locally:
    RELATIVE_URLS = True

FILENAME_METADATA = "(?P<name>[^/]+)"

ARTICLE_URL = "{date:%Y}/{date:%m}/{date:%d}/{name}.html"

ARTICLE_SAVE_AS = ARTICLE_URL

MENUITEMS = [
    {"title": "Blog", "url": ""},
    {"title": "Today I Learned...", "url": "til"},
    {"title": "About me", "url": "pages/about.html"},
]

# I'm the only author
AUTHOR_SAVE_AS = ""

TIMEZONE = "Europe/Paris"

GITHUB_URL = "https://github.com/eliasdorneles"

# DISQUS_SITENAME = 'hopefulramble'

STATIC_PATHS = [
    "images",
    "static",
    "extra/CNAME",
]

EXTRA_PATH_METADATA = {
    "extra/CNAME": {"path": "CNAME"},
}

CLEAN_SUMMARY_MINIMUM_ONE = True

CLEAN_SUMMARY_MAXIMUM = 1

FEED_DOMAIN = SITEURL
FEED_ATOM = "atom.xml"
FEED_RSS = "feed.xml"
RSS_FEED_SUMMARY_ONLY = False

PLUGIN_PATHS = ["plugins"]
PLUGINS = [
    "summary",
    "clean_summary",
    "pelican_alias",
]

DEFAULT_LANG = "en"


def lang_display_name(lang):
    try:
        import langcodes
        import language_data  # noqa
    except ImportError:
        return lang
    try:
        return langcodes.get(lang).display_name(lang).title()
    except KeyError:
        return lang


JINJA_GLOBALS = {
    "lang_display_name": lang_display_name,
}
