# CONFIGURATION OPTIONS

BUILD = build
MAKEFILE = Makefile
OUTPUT_FILENAME = textbook
METADATA = metadata.yml
TOC = --toc --toc-depth 3
METADATA_ARGS = --metadata-file $(METADATA)
IMAGES = $(shell find assets/images -type f)
TEMPLATES = $(shell find assets/templates/ -type f)
COVER_IMAGE = assets/images/cover.png
MATH_FORMULAS = --mathjax
CHAPTERS = chapters/*.md
CONTENT = awk 'FNR==1 && NR!=1 {print "\n\n"}{print}' $(CHAPTERS)
CONTENT_FILTERS = tee 

# DEBUG_ARGS = --verbose
# FILTER_ARGS = --filter pandoc-crossref

ARGS = $(TOC) $(MATH_FORMULAS) $(METADATA_ARGS) $(FILTER_ARGS) $(DEBUG_ARGS)
PANDOC_COMMAND = pandoc

DOCX_ARGS = --standalone --reference-doc assets/templates/docx.docx
EPUB_ARGS = --template assets/templates/epub.html --epub-cover-image $(COVER_IMAGE)
HTML_ARGS = --template assets/templates/lantern.html --standalone --to html5 --section-divs
PDF_ARGS = --template assets/templates/lantern.tex --pdf-engine xelatex

BASE_DEPENDENCIES = $(MAKEFILE) $(CHAPTERS) $(METADATA) $(IMAGES) $(TEMPLATES)
DOCX_DEPENDENCIES = $(BASE_DEPENDENCIES)
EPUB_DEPENDENCIES = $(BASE_DEPENDENCIES)
HTML_DEPENDENCIES = $(BASE_DEPENDENCIES)
PDF_DEPENDENCIES = $(BASE_DEPENDENCIES)

all:	book

book:	epub html pdf docx

clean:
	rm -r $(BUILD)

epub:	$(BUILD)/$(OUTPUT_FILENAME).epub

html:	$(BUILD)/$(OUTPUT_FILENAME).html

pdf:	$(BUILD)/$(OUTPUT_FILENAME).pdf

docx:	$(BUILD)/$(OUTPUT_FILENAME).docx

$(BUILD)/epub/$(OUTPUT_FILENAME).epub:	$(EPUB_DEPENDENCIES)
	mkdir -p $(BUILD)/epub
	$(CONTENT) | $(CONTENT_FILTERS) | $(PANDOC_COMMAND) $(ARGS) $(EPUB_ARGS) -o $@
	@echo "$@ was built"

$(BUILD)/$(OUTPUT_FILENAME).html:	$(HTML_DEPENDENCIES)
	mkdir -p $(BUILD)
	$(CONTENT) | $(CONTENT_FILTERS) | $(PANDOC_COMMAND) $(ARGS) $(HTML_ARGS) -o $@
	cp --parents $(IMAGES) $(BUILD)
	cp assets/css/* $(BUILD)
	cp assets/js/* $(BUILD)
	#purgecss --css assets/uikit.css --content build/book.html --safelist uk-open uk-offcanvas-bar-animation uk-offcanvas-slide --output build/styles.css
	mv build/textbook.html build/index.html
	@echo "$@ was built"

$(BUILD)/pdf/$(OUTPUT_FILENAME).pdf:	$(PDF_DEPENDENCIES)
	mkdir -p $(BUILD)/pdf
	$(CONTENT) | $(CONTENT_FILTERS) | $(PANDOC_COMMAND) $(ARGS) $(PDF_ARGS) -o $@
	@echo "$@ was built"

$(BUILD)/docx/$(OUTPUT_FILENAME).docx:	$(DOCX_DEPENDENCIES)
	mkdir -p $(BUILD)/docx
	$(CONTENT) | $(CONTENT_FILTERS) | $(PANDOC_COMMAND) $(ARGS) $(DOCX_ARGS) -o $@
	@echo "$@ was built"

####################################################################################################
# CONFIGURATION OPTIONS FOR LANTERN DOCUMENTATION
####################################################################################################

DOCS_BUILD = build/docs
DOCS_OUTPUT_FILENAME = lantern
DOCS_METADATA = assets/docs/metadata.yml
DOCS_METADATA_ARGS = --metadata-file $(DOCS_METADATA)
DOCS_IMAGES = $(shell find assets/docs/images -type f)
DOCS_COVER_IMAGE = assets/docs/images/cover.png
DOCS_CHAPTERS = assets/docs/chapters/*.md
DOCS_CONTENT = awk 'FNR==1 && NR!=1 {print "\n\n"}{print}' $(DOCS_CHAPTERS)
DOCS_CONTENT_FILTERS = tee # Use this to add sed filters or other piped commands
DOCS_ARGS = $(TOC) $(MATH_FORMULAS) $(DOCS_METADATA_ARGS) $(FILTER_ARGS)
DOCX_ARGS = --standalone --reference-doc assets/templates/docx.docx
EPUB_ARGS = --template assets/templates/epub.html --epub-cover-image $(DOCS_COVER_IMAGE)
HTML_ARGS = --template assets/templates/lantern.html --standalone --to html5 --section-divs
PDF_ARGS = --template assets/templates/lantern.tex --pdf-engine xelatex
DOCS_DEPENDENCIES = $(MAKEFILE) $(DOCS_CHAPTERS) $(DOCS_METADATA) $(DOCS_IMAGES) $(TEMPLATES)

docs:	docs_html

documentation:	docs_html

clean_docs:
	rm -r $(DOCS_BUILD)

docs_epub:	$(DOCS_BUILD)/$(DOCS_OUTPUT_FILENAME).epub
docs_html:	$(DOCS_BUILD)/$(DOCS_OUTPUT_FILENAME).html
docs_pdf:	$(DOCS_BUILD)/$(DOCS_OUTPUT_FILENAME).pdf
docs_docx:	$(DOCS_BUILD)/$(DOCS_OUTPUT_FILENAME).docx

$(DOCS_BUILD)/$(DOCS_OUTPUT_FILENAME).epub:	$(DOCS_DEPENDENCIES)
	mkdir -p $(DOCS_BUILD)
	$(DOCS_CONTENT) | $(DOCS_CONTENT_FILTERS) | $(PANDOC_COMMAND) $(ARGS) $(EPUB_ARGS) -o $@
	@echo "$@ was built"

$(DOCS_BUILD)/$(DOCS_OUTPUT_FILENAME).html:	$(DOCS_DEPENDENCIES)
	mkdir -p $(DOCS_BUILD)
	$(DOCS_CONTENT) | $(DOCS_CONTENT_FILTERS) | $(PANDOC_COMMAND) $(DOCS_ARGS) $(HTML_ARGS) -o $@
	cp $(DOCS_IMAGES) $(DOCS_BUILD)
	cp assets/css/* $(DOCS_BUILD)
	cp assets/js/* $(DOCS_BUILD)
	mv $(DOCS_BUILD)/$(DOCS_OUTPUT_FILENAME).html $(DOCS_BUILD)/index.html
	@echo "$@ was built"

$(DOCS_BUILD)/$(DOCS_OUTPUT_FILENAME).pdf:	$(DOCS_DEPENDENCIES)
	mkdir -p $(BUILD)
	$(DOCS_CONTENT) | $(CONTENT_FILTERS) | $(PANDOC_COMMAND) $(ARGS) $(PDF_ARGS) -o $@
	@echo "$@ was built"

$(DOCS_BUILD)/$(DOCS_OUTPUT_FILENAME).docx:	$(DOCS_DEPENDENCIES)
	mkdir -p $(BUILD)
	$(DOCS_CONTENT) | $(CONTENT_FILTERS) | $(PANDOC_COMMAND) $(ARGS) $(DOCX_ARGS) -o $@
	@echo "$@ was built"