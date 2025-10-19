# 🪶 Rura

A simple zsh plugin to save and jump to directories.

## Installation

### Manual installation

```sh
git clone https://github.com/kiki-ki/rura.git ~/.zsh/rura
echo "source ~/.zsh/rura/rura.plugin.zsh" >> ~/.zshrc
```

## Usage

### Commands

- `rura @<name>` - Jump to a saved directory
- `rura add <dir> <name>` - Save a directory with a name
- `rura delete <name>` - Remove a savepoint
- `rura list` - Show all savepoints
- `rura help` - Show help message
- `rura version` - Show version

### Examples

```sh

rura add . docs             # Save current directory
rura add ~/Documents docs   # Save specific directory
rura @docs                  # Jump to saved directory
rura list                   # List all savepoints
rura delete docs            # Delete a savepoint
```

## Configuration

Environment variable:

- `RURA_SAVEPOINT_DIR` - Savepoint storage directory (default: `~/.rura`)

```zsh
export RURA_SAVEPOINT_DIR="$HOME/.config/rura"
```

## License

MIT License - see the [LICENSE](LICENSE) file for details.
