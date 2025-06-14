SHELL := /bin/bash
OUTPUT_DIR := ./output

.DEFAULT_GOAL := help

sitegen.bin: sitegen/tool.odin sitegen/template_engine.odin config_sitegen.json
	odin build sitegen

.PHONY: compile-dev
compile-dev: clean sitegen.bin  ## Run the site generator for local testing
	./sitegen.bin --local --output output --config-file config_sitegen.json

.PHONY: compile-prod
compile-prod: clean sitegen.bin  ## Run the site generator for production
	./sitegen.bin --output output --config-file config_sitegen.json

.PHONY: clean
clean:  ## Clean up generated files
	rm -rf ${OUTPUT_DIR} cache

.PHONY: server
server: compile-dev  ## Start a local server to view the site
	(cd ${OUTPUT_DIR} && python3 -m webbrowser http://localhost:8000 && python3 -m http.server &)

.PHONY: posts
post:  ## Create a new post
	./posts new

.PHONY: fix
fix: 
	uv run ./posts rename-drafts

.PHONY: deploy
deploy: clean compile-prod  ## Deploy the site to GitHub Pages
	uv run ghp-import -m "Update site" ${OUTPUT_DIR}
	git push origin gh-pages:master --force

.PHONY: sitegen.bin
test:  ## Run sitegen tests
	odin test sitegen

# Implements this pattern for autodocumenting Makefiles:
# https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
#
# Picks up all comments that start with a ## and are at the end of a target definition line.
.PHONY: help
help:  ## Display command usage
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
