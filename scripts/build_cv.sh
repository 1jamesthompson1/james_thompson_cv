#!/usr/bin/env bash
set -euo pipefail

echo "pre-commit(build-cv): Compiling CV.tex -> output/CV.pdf"

mkdir -p output

if command -v make >/dev/null 2>&1 && [[ -f Makefile ]]; then
  make pdf
else
  if command -v latexmk >/dev/null 2>&1; then
    latexmk -pdf -interaction=nonstopmode -halt-on-error -shell-escape -output-directory=output CV.tex
  else
    if ! command -v pdflatex >/dev/null 2>&1; then
      echo "pre-commit(build-cv): Missing TeX toolchain (latexmk/pdflatex)." >&2
      exit 1
    fi
    echo "pre-commit(build-cv): latexmk not found; using pdflatex (twice)"
    pdflatex -interaction=nonstopmode -halt-on-error -output-directory=output CV.tex
    pdflatex -interaction=nonstopmode -halt-on-error -output-directory=output CV.tex
  fi
fi

if [[ ! -f output/CV.pdf ]]; then
  echo "pre-commit(build-cv): Build did not produce output/CV.pdf" >&2
  exit 1
fi

# Ensure the generated PDF is staged in the commit
git add -f output/CV.pdf

echo "pre-commit(build-cv): Staged output/CV.pdf"
