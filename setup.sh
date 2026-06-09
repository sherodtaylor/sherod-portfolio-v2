#!/bin/bash

# Resume Generation Setup Script
# Installs all dependencies needed for YAML-to-LaTeX resume generation

set -e

echo "🚀 Setting up resume generation environment..."

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is required but not installed."
    echo "Please install Python 3 first:"
    echo "  macOS: brew install python3"
    echo "  Ubuntu/Debian: sudo apt-get install python3 python3-pip python3-venv"
    exit 1
fi

echo "✅ Python 3 found: $(python3 --version)"

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "📦 Creating Python virtual environment..."
    python3 -m venv venv
    echo "✅ Virtual environment created"
else
    echo "✅ Virtual environment already exists"
fi

# Activate virtual environment and install Python dependencies
echo "📦 Installing Python dependencies..."
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
echo "✅ Python dependencies installed"

# Check for XeLaTeX
if ! command -v xelatex &> /dev/null; then
    echo "⚠️  XeLaTeX not found. LaTeX is required for PDF generation."
    echo "Install MacTeX or TeX Live:"
    echo "  macOS: brew install --cask mactex"
    echo "  Ubuntu/Debian: sudo apt-get install texlive-xetex texlive-fonts-extra"
    echo "  Or download from: https://www.tug.org/texlive/"
else
    echo "✅ XeLaTeX found: $(xelatex --version | head -1)"
fi

# Check for required font
if command -v fc-list &> /dev/null; then
    if fc-list | grep -q "FiraCode Nerd Font Mono"; then
        echo "✅ FiraCode Nerd Font Mono found"
    else
        echo "⚠️  FiraCode Nerd Font Mono not found"
        echo "Install with: brew install font-fira-code-nerd-font"
        echo "Or download from: https://github.com/ryanoasis/nerd-fonts"
    fi
else
    echo "⚠️  fontconfig not found, cannot check for required font"
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "To generate your resume:"
echo "  make all              # Generate PDF from config.yaml"
echo "  make help             # Show all available commands"
echo ""
echo "To activate the Python environment manually:"
echo "  source venv/bin/activate"