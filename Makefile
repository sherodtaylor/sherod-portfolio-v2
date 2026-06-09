# Resume Generation Makefile
# Builds LaTeX resume from YAML configuration via Python script

# Variables
LATEX_ENGINE = xelatex
PYTHON_SCRIPT = generate-resume.py
YAML_CONFIG = config.yaml
GENERATED_TEX = generated-resume.tex
OUTPUT_NAME = resume
DIST_DIR = public
TEX_PATH = /Library/TeX/texbin
REQUIRED_FONT = FiraCode Nerd Font Mono

# Ensure PATH includes LaTeX binaries
export PATH := $(TEX_PATH):$(PATH)

# Default target
.PHONY: all
all: check-dependencies $(DIST_DIR)/$(OUTPUT_NAME).pdf

# Setup dependencies
.PHONY: setup
setup:
	@echo "Running setup script to install dependencies..."
	@./setup.sh

# Check dependencies (Python, PyYAML, font)
.PHONY: check-dependencies
check-dependencies: check-python check-pyyaml check-font

# Check if Python is available
.PHONY: check-python
check-python:
	@echo "Checking for Python..."
	@if ! command -v python3 >/dev/null 2>&1; then \
		echo "ERROR: Python 3 not found!"; \
		echo "Please install Python 3"; \
		exit 1; \
	fi
	@echo "Python check passed"

# Check if PyYAML is installed
.PHONY: check-pyyaml
check-pyyaml:
	@echo "Checking for PyYAML..."
	@if [ -d "venv" ]; then \
		if ! source venv/bin/activate && python3 -c "import yaml" >/dev/null 2>&1; then \
			echo "ERROR: PyYAML not found in virtual environment!"; \
			echo "Run 'make setup' to install all dependencies automatically"; \
			exit 1; \
		fi; \
	else \
		if ! python3 -c "import yaml" >/dev/null 2>&1; then \
			echo "ERROR: PyYAML not found!"; \
			echo "Run 'make setup' to install all dependencies automatically"; \
			exit 1; \
		fi; \
	fi
	@echo "PyYAML check passed"

# Check if required font is installed
.PHONY: check-font
check-font:
	@echo "Checking for required font: $(REQUIRED_FONT)..."
	@if ! fc-list | grep -q "$(REQUIRED_FONT)"; then \
		echo "ERROR: Required font '$(REQUIRED_FONT)' not found!"; \
		echo "Please install FiraCode Nerd Font from: https://github.com/ryanoasis/nerd-fonts"; \
		echo "Or install via Homebrew: brew install font-fira-code-nerd-font"; \
		exit 1; \
	fi
	@echo "Font check passed: $(REQUIRED_FONT) is installed"

# Create dist directory if it doesn't exist
$(DIST_DIR):
	mkdir -p $(DIST_DIR)

# Generate LaTeX from YAML configuration
$(GENERATED_TEX): $(YAML_CONFIG) $(PYTHON_SCRIPT)
	@echo "Generating LaTeX from YAML configuration..."
	@if [ -d "venv" ]; then \
		source venv/bin/activate && python3 $(PYTHON_SCRIPT); \
	else \
		python3 $(PYTHON_SCRIPT); \
	fi
	@echo "LaTeX generation complete: $(GENERATED_TEX)"

# Build resume PDF
$(DIST_DIR)/$(OUTPUT_NAME).pdf: $(GENERATED_TEX) | $(DIST_DIR)
	@echo "Building resume PDF..."
	$(LATEX_ENGINE) $(GENERATED_TEX)
	@echo "Moving PDF to dist folder..."
	mv generated-resume.pdf $(DIST_DIR)/$(OUTPUT_NAME).pdf
	@echo "Resume built successfully: $(DIST_DIR)/$(OUTPUT_NAME).pdf"

# Clean temporary LaTeX files
.PHONY: clean
clean:
	@echo "Cleaning temporary files..."
	rm -f *.aux *.log *.out *.fdb_latexmk *.fls *.synctex.gz $(GENERATED_TEX)
	@echo "Cleanup complete."

# Clean everything including output
.PHONY: clean-all
clean-all: clean
	@echo "Removing resume from public folder..."
	rm -f $(DIST_DIR)/$(OUTPUT_NAME).pdf
	@echo "Full cleanup complete."

# Show help
.PHONY: help
help:
	@echo "Resume Generation Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  all               Build resume PDF from YAML config (default)"
	@echo "  setup             Install all dependencies (Python venv, PyYAML)"
	@echo "  check-dependencies Check Python, PyYAML, and font requirements"
	@echo "  check-python      Verify Python 3 is installed"
	@echo "  check-pyyaml      Verify PyYAML is installed"
	@echo "  check-font        Verify required font is installed"
	@echo "  clean             Remove temporary LaTeX files and generated TeX"
	@echo "  clean-all         Remove all generated files and dist folder"
	@echo "  help              Show this help message"
	@echo ""
	@echo "Dependencies:"
	@echo "  Python: python3 with PyYAML package"
	@echo "  Font: $(REQUIRED_FONT)"
	@echo "  LaTeX: XeLaTeX ($(TEX_PATH))"
	@echo ""
	@echo "Files:"
	@echo "  Config: $(YAML_CONFIG)"
	@echo "  Script: $(PYTHON_SCRIPT)"
	@echo "  Generated: $(GENERATED_TEX)"
	@echo "  Output: $(DIST_DIR)/$(OUTPUT_NAME).pdf"