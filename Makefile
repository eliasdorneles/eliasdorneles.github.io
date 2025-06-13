SHELL := /bin/bash
SITE_DIR := site
THEME_DIR := ./mytheme
OUTPUT_DIR := ./output

COMPILE := pelican ${SITE_DIR} -t ${THEME_DIR} -o ${OUTPUT_DIR} -s settings.py

.PHONY: clean compile post require_pipenv

help:
	@echo Quick help:
	@echo
	@echo "compile  generate site"
	@echo "server   generate site watching for changes and start server"
	@echo "clean    removes output and cache directories"
	@echo "post     start writing new post (alias: make new)"
	@echo "fix      fix draft file names, after updating a title"
	@echo "deploy   deploy to Github pages from local content"

require_pipenv:
	(which pipenv || pip install pipenv)

compile: require_pipenv
	pipenv run ${COMPILE}

debug: require_pipenv
	pipenv run pudb3 ${COMPILE}

clean:
	rm -rf ${OUTPUT_DIR} cache

install: require_pipenv
	pipenv sync

server: install compile
	(cd ${OUTPUT_DIR} && python3 -m webbrowser http://localhost:8000 && python3 -m http.server &)
	pipenv run ${COMPILE} --autoreload

post: require_pipenv
	pipenv run ./posts new

new:
	make post

fix: require_pipenv
	pipenv run ./posts rename-drafts

deploy: clean compile require_pipenv
	pipenv run ghp-import -m "Update site" output
	git push origin gh-pages:master --force

sitegen.bin: sitegen
	odin build sitegen

run-sitegen: sitegen.bin
	./sitegen.bin --local --output output_sitegen --config-file config_sitegen.json

serve-sitegen: output_sitegen
	cd output_sitegen && python3 -m webbrowser http://localhost:8000 && python3 -m http.server

test:  # Run sitegen tests
	odin test sitegen
