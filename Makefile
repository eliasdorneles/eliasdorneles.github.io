SHELL := /bin/bash
LOCAL_OUTPUT_DIR := ./output
PROD_OUTPUT_DIR := ./output_prod

.DEFAULT_GOAL := help

sitegen.bin: sitegen/tool.odin sitegen/template_engine.odin config_sitegen.json
	odin build sitegen

.PHONY: compile-dev
compile-dev: clean-local sitegen.bin
	./sitegen.bin --local --output output --config-file config_sitegen.json

.PHONY: compile-prod
compile-prod: sitegen.bin
	./sitegen.bin --output ${PROD_OUTPUT_DIR} --config-file config_sitegen.json

.PHONY: server
server: compile-dev  ## Start a local server to view the site
	(cd ${LOCAL_OUTPUT_DIR} && python3 -m http.server)

.PHONY: watch
watch: compile-dev  ## Start a local server and watch for changes
	python3 -m webbrowser http://localhost:8000
	uv run watchmedo auto-restart \
		--directory=site \
		--directory=sitegen \
		--directory=mytheme \
		--patterns="*.odin;*.md;*.css;*.html" \
		--recursive -- \
		make server

.PHONY: deploy
deploy: clean-prod compile-prod  ## Deploy the site to GitHub Pages
	uv run ghp-import -m "Update site" ${PROD_OUTPUT_DIR}
	git push origin gh-pages:master --force

manage.bin: manage/site_manage.odin
	odin build manage

.PHONY: posts
post: manage.bin  ## Create a new post
	./manage.bin new-post

.PHONY: autorename
autorename: manage.bin  ## Rename posts according to their titles
	 ./manage.bin auto-rename-drafts

.PHONY: clean-prod
clean-prod:
	rm -rf ${PROD_OUTPUT_DIR}

.PHONY: clean-local
clean-local:
	rm -rf ${LOCAL_OUTPUT_DIR}

.PHONY: clean
clean:  ## Clean up generated files
	make clean-local clean-prod

.PHONY: test-manage
test-manage: manage.bin  ## Run manage tests
	odin test manage -all-packages

.PHONY: test-sitegen
test-sitegen: sitegen.bin  ## Run sitegen tests
	odin test sitegen -all-packages

.PHONY: test
test: test-manage test-sitegen  ## Run all tests
	@echo

# Implements this pattern for autodocumenting Makefiles:
# https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
#
# Picks up all comments that start with a ## and are at the end of a target definition line.
.PHONY: help
help:  ## Display command usage
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
