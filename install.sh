#!/bin/bash

set -e

# === Config ===
GITHUB_USER="witsuu"  # <-- Ganti 'username' dengan GitHub username kamu atau bisa override pakai ENV
REPO_NAME="r2-cli"
INSTALL_DIR="/usr/local/bin"
BINARY_NAME="r2-cli"

# === Functions ===

get_latest_version() {
  echo "🔍 Fetching latest release..."
  VERSION=$(curl --silent --fail "https://api.github.com/repos/$GITHUB_USER/$REPO_NAME/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
  if [ -z "$VERSION" ]; then
    echo "❌ Failed to fetch the latest version."
    exit 1
  fi
  echo "📦 Latest version: $VERSION"
  echo "$VERSION"
}

detect_platform() {
  OS="$(uname -s)"
  ARCH="$(uname -m)"

  case "$OS" in
    Linux)
      PLATFORM="x86_64-unknown-linux-musl"
      ;;
    Darwin)
      if [[ "$ARCH" == "arm64" ]]; then
        PLATFORM="aarch64-apple-darwin"
      else
        PLATFORM="x86_64-apple-darwin"
      fi
      ;;
    MINGW*|MSYS*|CYGWIN*|Windows_NT)
      PLATFORM="x86_64-pc-windows-gnu"
      ;;
    *)
      echo "❌ Unsupported OS: $OS ($ARCH)"
      exit 1
      ;;
  esac
  echo "🖥️ Platform detected: $PLATFORM"
}

download_and_install() {
  local VERSION=$1
  local FILE_NAME="$BINARY_NAME-$PLATFORM"
  [[ "$PLATFORM" == *"windows"* ]] && FILE_NAME="$FILE_NAME.exe"

  echo "This version: $VERSION"
  echo "This Filename: $FILE_NAME"

  local DOWNLOAD_URL="https://github.com/$GITHUB_USER/$REPO_NAME/releases/download/$VERSION/$FILE_NAME"

  echo "⬇️ Downloading from: $DOWNLOAD_URL ..."
  
  TMP_FILE=$(mktemp)
  curl -L --fail "$DOWNLOAD_URL" -o "$TMP_FILE"
  chmod +x "$TMP_FILE"

  if [[ "$PLATFORM" == *"windows"* ]]; then
    INSTALL_DIR_WIN="$USERPROFILE/bin"
    mkdir -p "$INSTALL_DIR_WIN"
    cp "$TMP_FILE" "$INSTALL_DIR_WIN/$BINARY_NAME.exe"
    
    echo "🚀 Installed to $INSTALL_DIR_WIN/$BINARY_NAME.exe"

    # Check if already in PATH
    if ! echo "$PATH" | grep -iq "$INSTALL_DIR_WIN"; then
      echo "⚙️ Adding $INSTALL_DIR_WIN to PATH..."
      powershell.exe -Command "[Environment]::SetEnvironmentVariable('Path', \$env:Path + ';$INSTALL_DIR_WIN', 'User')"
      echo "✅ PATH updated. Please restart your terminal!"
    fi

    echo "✅ Done! Now run: $BINARY_NAME"
  else
    echo "🚀 Installing to $INSTALL_DIR/$BINARY_NAME ..."
    if [ "$(id -u)" -ne 0 ]; then
      sudo mv "$TMP_FILE" "$INSTALL_DIR/$BINARY_NAME"
    else
      mv "$TMP_FILE" "$INSTALL_DIR/$BINARY_NAME"
    fi
    echo "✅ Installed! Now run: $BINARY_NAME"
  fi
}

main() {
  detect_platform
  VERSION=$(get_latest_version)
  download_and_install "$VERSION"
}

main "$@"
