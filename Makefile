SHELL := /bin/bash
SITE_DIR := site
THEME_DIR := ./mytheme
OUTPUT_DIR := ./output

COMPILE := pelican ${SITE_DIR} -t ${THEME_DIR} -o ${OUTPUT_DIR} -s settings.py

.PHONY: clean compile post

help:
	@echo Quick help:
	@echo
	@echo "compile  generate site"
	@echo "server   generate site watching for changes and start server"
	@echo "clean    removes output and cache directories"
	@echo "post     start writing new post"

compile:
	pipenv run ${COMPILE}

debug:
	pipenv run pudb ${COMPILE}

clean:
	rm -rf ${OUTPUT_DIR} cache

server: compile
	(cd ${OUTPUT_DIR} && python3 -m webbrowser http://localhost:8000 && python3 -m http.server &)
	pipenv run ${COMPILE} --autoreload

post:
	./posts new
