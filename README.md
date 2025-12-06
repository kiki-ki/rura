# 🪶 Rura

Memorize and jump to directories instantly.<br>
A simple zsh plugin. Requires 0 MP.

## Installation

### Manual installation

```sh
git clone https://github.com/kiki-ki/rura.git ~/.zsh/rura
echo "source ~/.zsh/rura/rura.plugin.zsh" >> ~/.zshrc
```

*Note: Rura automatically adds itself to `fpath` for completions.*

### Plugin Managers

Rura follows the standard zsh plugin structure.
You can install it with your favorite plugin manager (Sheldon, zinit, zplug, etc.) by referencing: `kiki-ki/rura`.

## Usage

### Commands

- `rura @<name>` - Jump to a memory
- `rura add <dir> <name>` - Memorize a directory
- `rura delete <name>` - Forget a memory
- `rura list` - List all memories
- `rura help` - Show help message
- `rura version` - Show version

### Examples

```sh

rura add . docs # Memorize current directory as 'docs'
rura add ~/work/project my-project # Memorize specific directory
rura @docs # Jump to 'docs'
rura delete docs # Forget 'docs'

# Tab completion works
rura @<TAB>
# ⚡ Memories
# @docs        -- ~/Documents
# @my-project  -- ~/work/project
```

## Configuration

### Environment Variable

- `RURA_MEMORY_DIR` - Directory where memories (symlinks) are stored. (Default: `~/.rura`)

## License

MIT License
