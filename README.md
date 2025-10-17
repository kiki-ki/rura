# 🪶 Rura

A simple CLI tool to save and jump to directories.

## Features

- 📌 **Add savepoint** - Save frequently used directories with memorable names
- 🗑️ **Delete savepoint** - Remove savepoints you no longer need
- 📋 **List savepoints** - View all your saved bookmarks at a glance
- 🚀 **Quick navigation** - Jump to bookmarked directories instantly

## Installation

```sh
curl -fsSL https://raw.githubusercontent.com/kiki-ki/rura/main/install.sh | sh
```

### Installation Options

Environment variables:

- `RURA_VERSION` - Version/branch/tag to install (default: `main`)
- `BIN_DIR` - Custom installation directory (default: `/usr/local/bin`)

```sh
curl -fsSL https://raw.githubusercontent.com/kiki-ki/rura/main/install.sh | \
  RURA_VERSION=v0.1.0 \
  BIN_DIR=~/.local/bin \
  sh
```

## Usage

```sh
rura add|a <directory> <name>    # Add a savepoint
rura delete|d <name>             # Delete a savepoint
rura list|l                      # List all savepoints
rura jump|j <name>               # Jump to savepoint
rura help|h                      # Show this help message
rura version|v                   # Show version
```

### Examples

```sh
rura add . work                  # Save current directory as 'work'
rura add /path/to/dir work       # Save specific directory as 'work'
rura delete work                 # Delete 'work' savepoint
rura list                        # List all savepoints
rura jump work                   # Jump to 'work' directory
```

## Configuration

- `RURA_SAVEPOINT_DIR` - Directory where savepoints are stored (default: `~/.rura`)

## Development

### Test

```sh
bats ./test.bats
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
