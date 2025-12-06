# -------------------------------
# Configuration
# -------------------------------

SHELL      := bash
SRCDIR_TD  := src/TD
SRCDIR_TP  := src/TP
BUILDDIR   := build
DOCSDIR    := docs

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

TD_MAIN := LEA
TPs := gedit jflex cup types interpreteur analyse

# generated PDFs
PDFS := $(DOCSDIR)/td.pdf $(TPs:%=$(DOCSDIR)/tp-%.pdf)

# -------------------------------
# Main targets
# -------------------------------

.PHONY: all td correction both tp tp-% deps depscorr update clean cleanall help FORCE

all: $(PDFS)

td:  $(DOCSDIR)/td.pdf
correction: $(DOCSDIR)/td-correction.pdf
both: td correction

tp:  $(TPs:%=%)
# Ex: `make flex` builds docs/tp-flex.pdf
tp-%: $(DOCSDIR)/tp-%.pdf
$(TPs): %: $(DOCSDIR)/tp-%.pdf

# -------------------------------
# Compilation rules
# -------------------------------

# Livret TD
$(DOCSDIR)/td.pdf: $(SRCDIR_TD)/$(TD_MAIN).tex FORCE | $(BUILDDIR) $(DOCSDIR) deps
	$(PDFLATEX) $(PDFLATEX_FLAGS) -jobname=td $<
	$(PDFLATEX) $(PDFLATEX_FLAGS) -jobname=td $<
	@mv -f "$(BUILDDIR)/td.pdf" "$@"

$(DOCSDIR)/td-correction.pdf: $(SRCDIR_TD)/$(TD_MAIN).tex FORCE | $(BUILDDIR) $(DOCSDIR) deps depscorr
	@echo "\def\CORRECTION{}\input{$(SRCDIR_TD)/$(TD_MAIN).tex}" > "$(BUILDDIR)/td-correction.tex"
	$(PDFLATEX) $(PDFLATEX_FLAGS) -jobname=td-correction "$(BUILDDIR)/td-correction.tex"
	$(PDFLATEX) $(PDFLATEX_FLAGS) -jobname=td-correction "$(BUILDDIR)/td-correction.tex"
	@mv -f "$(BUILDDIR)/td-correction.pdf" "$@"

# Fiches TP
$(DOCSDIR)/tp-%.pdf: $(SRCDIR_TP)/%.tex FORCE | $(BUILDDIR) $(DOCSDIR) deps
	$(PDFLATEX) $(PDFLATEX_FLAGS) -jobname=tp-$* $<
	$(PDFLATEX) $(PDFLATEX_FLAGS) -jobname=tp-$* $<
	@mv -f "$(BUILDDIR)/tp-$*.pdf" "$@"

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
	@echo "  make            – build all PDFs (td + all tps)"
	@echo "  make td         – build docs/td.pdf"
	@echo "  make correction – build docs/td-correction.pdf (requires private repo access)"
	@echo "  make tp         – build all tp PDFs"
	@echo "  make flex       – build docs/tp-flex.pdf (same for other TPs)"
	@echo "  make update     – update local project and latex-libs (git pull)"
	@echo "  make clean      – remove build artifacts"
	@echo "  make cleanall   – also remove generated PDFs"
