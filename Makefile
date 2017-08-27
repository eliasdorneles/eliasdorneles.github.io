SHELL := /bin/bash
SITE_DIR := site
THEME_DIR := ./mytheme
OUTPUT_DIR := ./output

COMPILE := pelican ${SITE_DIR} -t ${THEME_DIR} -o ${OUTPUT_DIR} -s settings.py

.PHONY: clean compile

help:
	@echo Quick help:
	@echo
	@echo "compile  generate site"
	@echo "server   generate site watching for changes and start server"
	@echo "clean    removes output and cache directories"

compile:
	${COMPILE}

debug:
	pudb `which pelican` ${SITE_DIR} -t ${THEME_DIR} -o ${OUTPUT_DIR} -s settings.py

clean:
	rm -rf ${OUTPUT_DIR} cache

server: compile
	(cd ${OUTPUT_DIR} && python -m webbrowser http://localhost:8000 && python -m http.server &)
	${COMPILE} --autoreload
