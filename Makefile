# Makefile for Python and MkDocs commands
# Use bash for shell commands
SHELL := /bin/bash
# Default variables
INPUT_DIR  := notebooks
NOTEBOOK ?= notebooks/7.OOP.ipynb
# Default output directory for converted notebooks
# If OUTPUT is not set, it defaults to docs/lectures/
OUTPUT   ?= docs/lectures/
OUTPUT_DIR := docs/lectures
NOTEBOOKS  := $(wildcard $(INPUT_DIR)/*.ipynb)

.PHONY: run deploy build serve convert all convert-all

run:
	python main.py

deploy:
	mkdocs gh-deploy

build:
	mkdocs build

serve:
	mkdocs serve

convert:
	jupyter nbconvert --to markdown $(NOTEBOOK) --output-dir=$(OUTPUT)

# Batch convert all notebooks
convert-all:
	@echo "Converting all notebooks in $(INPUT_DIR)/ to Markdown..."
	@mkdir -p $(OUTPUT_DIR)
	@for nb in $(NOTEBOOKS); do \
		echo "Converting $$nb..."; \
		jupyter nbconvert --to markdown $$nb --output-dir=$(OUTPUT_DIR); \
	done

all: build serve
