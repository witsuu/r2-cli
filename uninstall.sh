#!/bin/bash

set -e

# Config
BINARY_NAME="r2-cli"
INSTALL_DIR="/usr/local/bin"
INSTALL_DIR_WIN="$USERPROFILE/bin"

# Functions
detect_platform() {
  OS="$(uname -s)"

  case "$OS" in
    Linux)
      PLATFORM="linux"
      ;;
    Darwin)
      PLATFORM="darwin"
      ;;
    MINGW*|MSYS*|CYGWIN*|Windows_NT)
      PLATFORM="windows"
      ;;
    *)
      echo "❌ Unsupported OS: $OS"
      exit 1
      ;;
  esac
}

uninstall_linux_macos() {
  if [ -f "$INSTALL_DIR/$BINARY_NAME" ]; then
    echo "⚠️ Found $INSTALL_DIR/$BINARY_NAME"
    read -p "❓ Are you sure you want to uninstall r2-cli? [y/N]: " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      sudo rm "$INSTALL_DIR/$BINARY_NAME"
      echo "✅ r2-cli successfully uninstalled from $INSTALL_DIR"
    else
      echo "❌ Uninstallation cancelled."
    fi
  else
    echo "❌ r2-cli not found at $INSTALL_DIR"
    exit 1
  fi
}

uninstall_windows() {
  if [ -f "$INSTALL_DIR_WIN/$BINARY_NAME.exe" ]; then
    echo "⚠️ Found $INSTALL_DIR_WIN/$BINARY_NAME.exe"
    read -p "❓ Are you sure you want to uninstall r2-cli? [y/N]: " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      rm "$INSTALL_DIR_WIN/$BINARY_NAME.exe"
      echo "✅ r2-cli.exe successfully uninstalled from $INSTALL_DIR_WIN"

      # Check if folder is empty
      if [ -z "$(ls -A "$INSTALL_DIR_WIN")" ]; then
        echo "🧹 $INSTALL_DIR_WIN is empty. Cleaning up PATH..."

        # Remove from PATH using PowerShell
        powershell.exe -Command "
        \$currentPath = [Environment]::GetEnvironmentVariable('Path', 'User');
        \$newPath = (\$currentPath -split ';' | Where-Object { \$_ -ne '$INSTALL_DIR_WIN' }) -join ';';
        [Environment]::SetEnvironmentVariable('Path', \$newPath, 'User');
        "

        echo "✅ PATH environment variable cleaned up."
      else
        echo "ℹ️ $INSTALL_DIR_WIN still has other files. PATH left untouched."
      fi
    else
      echo "❌ Uninstallation cancelled."
    fi
  else
    echo "❌ r2-cli.exe not found at $INSTALL_DIR_WIN"
    exit 1
  fi
}

# Main
main() {
  detect_platform
  case "$PLATFORM" in
    linux|darwin)
      uninstall_linux_macos
      ;;
    windows)
      uninstall_windows
      ;;
  esac
}

main "$@"
