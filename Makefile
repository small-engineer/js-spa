# Makefile

DIST_DIR := dist
SRC_DIR := src

CSS_SOURCES := \
  $(SRC_DIR)/assets/styles/base.css \
  $(shell find $(SRC_DIR)/assets/styles/blocks/layout -type f -name "*.css" | sort) \
  $(shell find $(SRC_DIR)/assets/styles/blocks/profile -type f -name "*.css" | sort)

DIST_CSS := $(DIST_DIR)/assets/styles/main.css

PAGES := $(wildcard $(SRC_DIR)/assets/pages/*)
SCRIPTS := $(wildcard $(SRC_DIR)/assets/scripts/*.js)
IMAGES := $(wildcard $(SRC_DIR)/assets/images/*)
COMPONENTS := $(wildcard $(SRC_DIR)/assets/components/*)

all: help

help:
	@echo "Usage: make [dev|build|clean|re|help]"
	@echo ""
	@echo "Targets:"
	@echo "  dev    Start development server"
	@echo "  build  Build the project to dist/"
	@echo "  clean  Remove dist/ directory"
	@echo "  re     Clean and build again"
	@echo "  help   Show this help message"

dev:
	@echo "[DEV] Starting development server..."
	@if ! command -v python3 >/dev/null; then \
		echo "[ERROR] python3 is required but not installed."; \
		exit 1; \
	fi
	@cd $(SRC_DIR) && python3 ../server.py

build: $(DIST_DIR)/index.html $(DIST_CSS) $(addprefix $(DIST_DIR)/assets/pages/,$(notdir $(PAGES))) $(addprefix $(DIST_DIR)/assets/scripts/,$(notdir $(SCRIPTS))) $(addprefix $(DIST_DIR)/assets/images/,$(notdir $(IMAGES))) $(addprefix $(DIST_DIR)/assets/components/,$(notdir $(COMPONENTS)))
	@echo "[BUILD] Project build complete."

$(DIST_DIR):
	@mkdir -p $(DIST_DIR)/assets/images
	@mkdir -p $(DIST_DIR)/assets/components
	@mkdir -p $(DIST_DIR)/assets/pages
	@mkdir -p $(DIST_DIR)/assets/scripts
	@mkdir -p $(DIST_DIR)/assets/styles

$(DIST_DIR)/index.html: $(SRC_DIR)/index.html | $(DIST_DIR)
	@echo "[BUILD] Copying index.html..."
	@cp $< $@

$(DIST_DIR)/assets/pages/%: $(SRC_DIR)/assets/pages/% | $(DIST_DIR)/assets/pages
	@cp $< $@

$(DIST_DIR)/assets/components/%: $(SRC_DIR)/assets/components/% | $(DIST_DIR)/assets/components
	@cp $< $@

$(DIST_DIR)/assets/scripts/%.js: $(SRC_DIR)/assets/scripts/%.js | $(DIST_DIR)/assets/scripts
	@echo "[BUILD] Stripping comments from $<..."
	@mkdir -p $(DIST_DIR)/assets/scripts
	@awk '\
		BEGIN { in_comment=0; } \
		{ \
			line=$$0; \
			if (in_comment) { \
				if (line ~ /\*\//) { \
					sub(/^.*\*\//, "", line); \
					in_comment=0; \
				} else next; \
			} \
			while (match(line, /\/\*/)) { \
				start=RSTART; \
				if (match(substr(line, start+2), /\*\//)) { \
					end=RSTART + start + 1; \
					line = substr(line, 1, start-1) substr(line, end+2); \
				} else { \
					line = substr(line, 1, start-1); \
					in_comment=1; \
					break; \
				} \
			} \
			if (line ~ /^\s*\/\//) next; \
			if (line ~ /\/\//) sub(/\/\/.*/, "", line); \
			if (line ~ /\S/) print line; \
		}' $< > $@

$(DIST_DIR)/assets/images/%: $(SRC_DIR)/assets/images/% | $(DIST_DIR)/assets/images
	@cp $< $@

$(DIST_DIR)/assets/styles/main.css: $(CSS_SOURCES) | $(DIST_DIR)/assets/styles
	@echo "[BUILD] Merging CSS into main.css..."
	@cat $(CSS_SOURCES) > $@

clean:
	@echo "[CLEAN] Removing dist/..."
	@rm -rf $(DIST_DIR)
	@echo "[CLEAN] Done."

re: clean build
	@echo "[RE] Rebuild complete."


.PHONY: all dev build clean re help
