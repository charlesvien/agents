#!/usr/bin/env bash
set -euo pipefail

EDITOR_BUNDLE_ID="dev.zed.Zed"

if ! command -v duti &>/dev/null; then
  echo "Installing duti..."
  brew install duti
fi

extensions=(
  .txt .md .mdx
  .json .jsonc .yaml .yml .toml .csv .xml .env .ini .cfg
  .sh .zsh .bash .fish
  .ts .tsx .js .jsx .mjs .cjs
  .css .scss .html .svg
  .rs .go .py .rb .lua .zig .c .h .cpp .hpp
  .sql .graphql .gql
  .dockerfile
  .gitignore .gitattributes .editorconfig
  .log
)

echo "Setting $EDITOR_BUNDLE_ID as default for ${#extensions[@]} extensions..."

for ext in "${extensions[@]}"; do
  duti -s "$EDITOR_BUNDLE_ID" "$ext" all
  echo "  $ext"
done

echo "Done."
