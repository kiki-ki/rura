#!/usr/bin/env zsh
# ⚡ Rura - A simple zsh plugin to memorize and jump to directories

fpath+=( "${0:h}" ) # _rura completion

RURA_MEMORY_DIR="${RURA_MEMORY_DIR:-$HOME/.rura}"
RURA_VERSION="0.1.0"
[[ ! -d "$RURA_MEMORY_DIR" ]] && mkdir -p "$RURA_MEMORY_DIR"

_rura_get_memories() {
  local -a names
  for mem in "$RURA_MEMORY_DIR"/@*(N); do
    [[ -L "$mem" ]] && names+=(${${mem:t}#@})
  done
  echo "${names[@]}"
}

_rura_jump() {
  local name="${1#@}"
  local mem_path="$RURA_MEMORY_DIR/@$name"

  if [[ ! -L "$mem_path" ]]; then
    echo "Error: No memory of @$name" >&2
    echo "Run 'rura list' to recall available memories" >&2
    return 1
  fi

  local target="$(readlink "$mem_path")"
  if [[ ! -d "$target" ]]; then
    echo "Error: The location for memory @$name no longer exists: $target" >&2
    return 1
  fi

  cd "$target"
}

_rura_add() {
  local dir="$1" name="$2"
  local mem_path="$RURA_MEMORY_DIR/@$name"

  if [[ -z "$dir" || -z "$name" ]]; then
    echo "Error: Both directory and memory name are required" >&2
    echo "Usage: rura add <directory> <name>" >&2
    return 1
  fi

  if [[ ! -d "$dir" ]]; then
    echo "Error: Directory not found: $dir" >&2
    return 1
  fi

  if [[ -e "$mem_path" ]]; then
    echo "Error: Memory @$name already exists" >&2
    echo "Use 'rura delete $name' first to overwrite it" >&2
    return 1
  fi

  ln -s "${dir:A}" "$mem_path"
  echo "⚡ Memorized: @$name -> ${dir:A}"
}

_rura_delete() {
  local name="$1"
  local mem_path="$RURA_MEMORY_DIR/@$name"

  if [[ -z "$name" ]]; then
    echo "Error: Memory name is required" >&2
    echo "Usage: rura delete <name>" >&2
    return 1
  fi

  if [[ ! -L "$mem_path" ]]; then
    echo "Error: No memory of @$name" >&2
    return 1
  fi

  local target="$(readlink "$mem_path")"
  echo -n "Forget memory '@$name' -> $target? [y/N]: "
  read -r yn
  [[ "$yn" != [yY] ]] && echo "Cancelled" && return 0

  unlink "$mem_path"
  echo "⚡ Forgot: @$name"
}

_rura_list() {
  local -a names
  names=($(_rura_get_memories))

  if (( ${#names[@]} == 0 )); then
    echo "No memories found."
    return 0
  fi

  for name in "${names[@]}"; do
    local mem_path="$RURA_MEMORY_DIR/@$name"
    local target="$(readlink "$mem_path")"

    local marker=" "
    local color_start=""
    local color_end=""

    if [[ ! -d "$target" ]]; then
      marker="✖"
      [[ -t 1 ]] && color_start=$(tput setaf 1) && color_end=$(tput sgr0)
    else
      [[ -t 1 ]] && color_start=$(tput setaf 2) && color_end=$(tput sgr0)
    fi

    printf " %s%s %-12s%s -> %s\n" "$color_start" "$marker" "@$name" "$color_end" "$target"
  done
}

_rura_help() {
  cat << 'EOF'
⚡ Rura - Memorize and jump to directories.

Usage:
  rura @<name>                   # Jump to a memory
  rura add|a <directory> <name>  # Memorize a directory
  rura delete|d <name>           # Forget a memory
  rura list|l                    # List all memories
  rura help|h                    # Show this help message
  rura version|v                 # Show version

Examples:
  rura @work                       # Jump to 'work'
  rura add . work                  # Memorize current dir as 'work'
  rura add /path/to/dir myproject  # Memorize specific directory
  rura delete work                 # Forget 'work' memory
  rura list                        # List all memories
EOF
}

rura() {
  case "$1" in
    @*)
      _rura_jump "$1" ;;
    add|a)
      shift; _rura_add "$@" ;;
    delete|d)
      shift; _rura_delete "$@" ;;
    list|l)
      _rura_list ;;
    version|v)
      echo "rura version $RURA_VERSION" ;;
    help|h|"")
      _rura_help ;;
    *)
      echo "Error: Unknown command: $1" >&2
      _rura_help
      return 1
      ;;
  esac
}
