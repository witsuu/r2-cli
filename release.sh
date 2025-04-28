#!/bin/bash

set -e

if [ -z "$1" ]; then
  echo "❌ Usage: $0 <version>"
  echo "Contoh: $0 0.2.0"
  exit 1
fi

VERSION=$1
TAG="v$VERSION"

# Pastikan branch bersih
if [ -n "$(git status --porcelain)" ]; then
  echo "⚠️ Ada perubahan yang belum di-commit."
else
  echo "✅ Working directory bersih."
fi

# Konfirmasi dulu
read -p "❓ Apakah kamu yakin mau membuat rilis versi $TAG? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  echo "❌ Release dibatalkan."
  exit 1
fi

# Add dan commit semua perubahan
echo "📦 Menambahkan semua perubahan..."
git add .

echo "📦 Membuat commit release..."
git commit -m "Release: v$VERSION"

# Buat tag
echo "🏷️ Membuat Git tag $TAG..."
git tag "$TAG"

# Push commit dan tag
echo "🚀 Push commit dan tag ke GitHub..."
git push origin HEAD
git push origin "$TAG"

echo "✅ Release $TAG sukses dibuat dan dikirim ke GitHub!"
echo "🎯 Workflow release akan otomatis berjalan di GitHub Actions."