# -------------------------------
# Configuration
# -------------------------------

SHELL      := bash
BUILDDIR   := build
DOCSDIR    := docs

# Course selection (persistent)
-include .current_course.mk
COURSE     ?= lea
COURSE 	   := $(strip $(COURSE))
PREFIX     := $(COURSE)
PREFIXCORR := $(COURSE)-correction
SRCDIR     := src/$(COURSE)

# LaTeX engine (override with: make PDFLATEX=xelatex)
PDFLATEX ?= pdflatex
PDFLATEX_FLAGS := -halt-on-error -interaction=nonstopmode -output-directory=$(BUILDDIR)

# latex-libs (local clone + TEXINPUTS)
LATEX_LIBS_DIR       := latex-libs
LATEX_LIBS_SSH_URL   := git@github.com:MatthieuPerrin/Latex-libs.git
LATEX_LIBS_HTTPS_URL := https://github.com/MatthieuPerrin/Latex-libs.git

# Corrections library (local clone + TEXINPUTS)
CORRECTIONS_REPO := git@github.com:LangagesEtAutomates/Corrections.git
CORRECTIONS_DIR  ?= src/corrections

# Path separator (Windows vs Unix)
ifeq ($(OS),Windows_NT)
  PATHSEP := ;
else
  PATHSEP := :
endif

# Add latex-libs to TeX search path (recursive with //); keep default path via trailing sep
export TEXINPUTS := $(CURDIR)/$(LATEX_LIBS_DIR)//$(PATHSEP)$(TEXINPUTS)

# -------------------------------
# Documents to generate
# -------------------------------

MAIN := $(basename $(notdir $(wildcard $(SRCDIR)/*.tex)))
CORR := $(MAIN:%=%-correction)

# -------------------------------
# Main targets
# -------------------------------

.PHONY: main corr all deps depscorr update clean cleanall help FORCE configure list check-course

main:			$(MAIN:%=$(DOCSDIR)/$(PREFIX)-%.pdf)
corr: 			$(MAIN:%=$(DOCSDIR)/$(PREFIXCORR)-%.pdf)
all: 			main corr

$(MAIN): %:	    	$(DOCSDIR)/$(PREFIX)-%.pdf
$(CORR): %-correction:	$(DOCSDIR)/$(PREFIXCORR)-%.pdf

# -------------------------------
# Compilation rules
# -------------------------------

# Sujet
$(DOCSDIR)/$(PREFIX)-%.pdf: $(SRCDIR)/%.tex FORCE | $(BUILDDIR) $(DOCSDIR) deps check-course
	$(PDFLATEX) $(PDFLATEX_FLAGS) -jobname=$(PREFIX)-$* $<
	$(PDFLATEX) $(PDFLATEX_FLAGS) -jobname=$(PREFIX)-$* $<
	@mv -f "$(BUILDDIR)/$(PREFIX)-$*.pdf" "$@"

# Correction
$(DOCSDIR)/$(PREFIXCORR)-%.pdf: $(SRCDIR)/%.tex FORCE | $(BUILDDIR) $(DOCSDIR) deps depscorr check-course
	@printf '\\def\\CORRECTION{}\\input{%s}\n' "$(SRCDIR)/$*.tex" > "$(BUILDDIR)/$(PREFIXCORR)-$*.tex"
	$(PDFLATEX) $(PDFLATEX_FLAGS) -jobname=$(PREFIXCORR)-$* "$(BUILDDIR)/$(PREFIXCORR)-$*.tex"
	$(PDFLATEX) $(PDFLATEX_FLAGS) -jobname=$(PREFIXCORR)-$* "$(BUILDDIR)/$(PREFIXCORR)-$*.tex"
	@mv -f "$(BUILDDIR)/$(PREFIXCORR)-$*.pdf" "$@"

FORCE:

# -------------------------------
# Dependencies management
# -------------------------------

# Ensure local clone of latex-libs exists (used as a prerequisite by build rules)
deps:
	@if [ ! -d "$(LATEX_LIBS_DIR)/.git" ]; then \
	  echo ">>> Cloning latex-libs into $(LATEX_LIBS_DIR)"; \
	  ( git clone --depth 1 "$(LATEX_LIBS_SSH_URL)"   "$(LATEX_LIBS_DIR)" 2>/dev/null \
	    || git clone --depth 1 "$(LATEX_LIBS_HTTPS_URL)" "$(LATEX_LIBS_DIR)" ); \
	fi

# Ensure local clone of Corrections exists (used as a prerequisite by build rules)
depscorr:
	@if [ ! -d "$(CORRECTIONS_DIR)/.git" ]; then \
	  echo ">>> Cloning Corrections into $(CORRECTIONS_DIR)"; \
	  git clone --depth 1 $(CORRECTIONS_REPO) $(CORRECTIONS_DIR) || { \
	    echo ">>> ERROR: impossible to clone Corrections (SSH key/token ?)"; exit 1; }; \
	fi

# Update both the main repo and the local dependency clone
update:
	@echo ">>> Updating main repository"; \
	git pull --ff-only || echo ">>> Skipping main repo update (offline or non-fast-forward)."; \
	if [ -d "$(LATEX_LIBS_DIR)/.git" ]; then \
	  echo ">>> Updating $(LATEX_LIBS_DIR)"; \
	  git -C "$(LATEX_LIBS_DIR)" pull --ff-only || echo ">>> Skipping latex-libs update (offline or non-fast-forward)."; \
	else \
	  echo ">>> latex-libs not present; run 'make deps' when online."; \
	fi; \
	if [ -d "$(CORRECTIONS_DIR)/.git" ]; then \
	  echo ">>> Updating $(CORRECTIONS_DIR)"; \
	  git -C "$(CORRECTIONS_DIR)" fetch -q --depth 1 origin; \
	  git -C "$(CORRECTIONS_DIR)" reset -q --hard FETCH_HEAD; \
	fi

# -------------------------------
# Course selection
# -------------------------------

configure:
	@if [ -z "$(COURSE)" ]; then \
	  echo "Usage: make configure COURSE=<nom>"; exit 1; \
	fi
	@c=$$(echo "$(COURSE)" | tr '[:upper:]' '[:lower:]'); \
	echo "COURSE=$$c" > .current_course.mk; \
	echo ">>> Cours courant: $$c"

list:
	@echo "Cours disponibles :"; \
	for d in src/*; do \
	  if [ -d "$$d" ] && ls "$$d"/*.tex >/dev/null 2>&1; then \
	    echo " - $${d##*/}"; \
	  fi; \
	done; \
	if [ -f .current_course.mk ]; then \
	  echo "Cours courant : $(COURSE)"; \
	else \
	  echo "(aucun cours configuré, défaut: $(COURSE))"; \
	fi

check-course:
	@if [ ! -d "$(SRCDIR)" ]; then \
	  echo ">>> ERROR: cours '$(COURSE)' introuvable (dossier manquant: $(SRCDIR))"; \
	  echo ">>> Utilisez: make list  puis  make configure COURSE=<nom>"; \
	  exit 1; \
	fi

# -------------------------------
# Create folders
# -------------------------------

$(BUILDDIR):
	@mkdir -p $@

$(DOCSDIR):
	@mkdir -p $@

# -------------------------------
# Cleaning
# -------------------------------

clean:
	@rm -rf "$(BUILDDIR)"/*

cleanall: clean
	@rm -f "$(DOCSDIR)"/*.pdf

# -------------------------------
# Help
# -------------------------------

help:
	@echo "Usage:"
	@echo "  make                       – build all subject PDFs (tds + tps)"
	@echo "  make corr                  – build tds and tps correction PDFs (requires private repo access)"
	@echo "  make all                   – build all subject and correction PDFs (requires private repo access)"
	@echo "  make tp1-lexer             – build $(DOCSDIR)/lea-tp1-lexer.pdf (same for other files in $(SRCDIR))"
	@echo "  make tp1-lexer-correction  – build $(DOCSDIR)/lea-correction-tp1-lexer.pdf (same for other files in $(SRCDIR))"
	@echo "  make configure COURSE=xxx  – Sets current course main repository as src/xxx (default: $(COURSE))"
	@echo "  make list                  – Lists available courses"
	@echo "  make update                – update local project, latex-libs, and corrections if needed (git pull)"
	@echo "  make clean                 – remove build artifacts"
	@echo "  make cleanall              – also remove generated PDFs"

