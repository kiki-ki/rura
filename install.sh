#!/bin/sh

set -e

BIN_DIR="${BIN_DIR:-/usr/local/bin}"
RURA_VERSION="${RURA_VERSION:-main}"
REPO_URL="https://raw.githubusercontent.com/kiki-ki/rura/${RURA_VERSION}"

# Download rura
echo "Downloading rura..."
SOURCE_FILE="/tmp/rura.$$"
curl -fsSL --proto '=https' --tlsv1.2 "$REPO_URL/rura" -o "$SOURCE_FILE" || {
  echo "Error: Failed to download rura" >&2
  exit 1
}
chmod +x "$SOURCE_FILE"
trap 'rm -f "$SOURCE_FILE"' EXIT

# Create directory if needed
if [ ! -d "$BIN_DIR" ]; then
  echo "Directory $BIN_DIR does not exist"
  printf "Create it? [y/N]: "
  read -r yn
  if [ "$yn" = "Y" ] || [ "$yn" = "y" ]; then
    mkdir -p "$BIN_DIR"
  else
    echo "Installation cancelled"
    exit 1
  fi
fi

# Check if we need sudo
if [ ! -w "$BIN_DIR" ]; then
  echo "Note: Installation requires elevated privileges"
  SUDO="sudo"
else
  SUDO=""
fi

# Install
echo "Installing rura to $BIN_DIR/rura..."
if [ -n "$SUDO" ]; then
  $SUDO install -m 755 "$SOURCE_FILE" "$BIN_DIR/rura"
else
  install -m 755 "$SOURCE_FILE" "$BIN_DIR/rura"
fi

echo "✓ Installed successfully!"
echo ""
echo "Try: rura help"
