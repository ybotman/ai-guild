#!/bin/bash

# === CONFIG ===
REPO_URL="https://github.com/ybotman/ai-guild.git"
SPARSE_PATH="Claude/3.7 with code/AI-Guild"
TARGET_DIR="public/AI-Guild"

# === START ===
echo "🔧 Setting up sparse checkout for AI-Guild..."

# Step 1: Make target directory if needed
mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR" || exit 1

# Step 2: Init git repo if not already
if [ ! -d ".git" ]; then
  git init
fi

# Step 3: Set remote (reset if already set)
git remote remove origin 2>/dev/null
git remote add origin "$REPO_URL"

# Step 4: Enable sparse checkout
git config core.sparseCheckout true
mkdir -p .git/info
echo "$SPARSE_PATH/" > .git/info/sparse-checkout

# Step 5: Pull the data
git pull origin main --depth=1

echo "✅ Done. AI-Guild synced into $TARGET_DIR"