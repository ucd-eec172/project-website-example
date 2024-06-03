PROJ_DIR := $(realpath .)
# TARGET ?= index
TARGETS = $(wildcard $(PROJ_DIR)/markdown/*.md)
SRCS = $(notdir $(TARGETS))

HTMLS = $(SRCS:.md=.html)

# specify css files to include
CSS =  assets/github-markdown-light.css
CSS += assets/style-customization.css
CSS_OPTS = $(foreach css, $(CSS), --css=$(css))

# specify new syntax definitions
SYNTAX_DEFS = $(PROJ_DIR)/assets/simple-console.xml
SYNTAX_DEF_OPTS = $(foreach def, $(SYNTAX_DEFS), --syntax-definition=$(def))

TEMPLATE = $(PROJ_DIR)/assets/template.html

all: $(HTMLS)

%.html: $(PROJ_DIR)/markdown/%.md $(TEMPLATE) $(SYNTAX_DEFS) $(CSS)
	@pandoc \
		--template=$(TEMPLATE) \
		$(CSS_OPTS) \
		$(SYNTAX_DEF_OPTS) \
		--highlight-style pygments \
		--toc \
		-f gfm -t html $< -o $@

.PHONY: clean
clean:
	rm $(HTMLS)