#!/usr/bin/env zsh
# ⚡ Rura - A simple zsh plugin to memorize and jump to directories

(( $fpath[(I)${0:h}] )) || fpath+=( "${0:h}" ) # _rura completion

RURA_MEMORY_DIR="${RURA_MEMORY_DIR:-$HOME/.rura}"
RURA_VERSION="0.2.0"
[[ ! -d "$RURA_MEMORY_DIR" ]] && mkdir -p "$RURA_MEMORY_DIR"

# Stores names into the caller's `memories` array. Returning them as a string
# would split names containing spaces into separate entries.
_rura_get_memories() {
  local mem
  memories=()
  for mem in "$RURA_MEMORY_DIR"/@*(N); do
    [[ -L "$mem" ]] && memories+=("${${mem:t}#@}")
  done
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

  builtin cd "$target"
}

_rura_add() {
  local dir="$1" name="$2"
  local mem_path="$RURA_MEMORY_DIR/@$name"

  if [[ -z "$dir" || -z "$name" ]]; then
    echo "Error: Both directory and memory name are required" >&2
    echo "Usage: rura add <directory> <name>" >&2
    return 1
  fi

  # A name becomes a symlink filename, and jumping strips one leading '@'
  if [[ "$name" == */* || "$name" == @* || "$name" == "." || "$name" == ".." ]]; then
    echo "Error: Invalid memory name: $name" >&2
    echo "A name cannot contain '/', start with '@', or be '.' or '..'" >&2
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

  if ! ln -s "${dir:A}" "$mem_path"; then
    echo "Error: Failed to memorize @$name" >&2
    return 1
  fi
  echo "⚡ Memorized: @$name -> ${dir:A}"
}

_rura_delete() {
  local name="$1"
  local mem_path="$RURA_MEMORY_DIR/@$name"
  local yn

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

_rura_prune() {
  local -a memories broken
  local name yn

  _rura_get_memories
  for name in "${memories[@]}"; do
    [[ -d "$RURA_MEMORY_DIR/@$name" ]] || broken+=("$name")
  done

  if (( ${#broken[@]} == 0 )); then
    echo "No broken memories found."
    return 0
  fi

  echo "These memories point to locations that no longer exist:"
  for name in "${broken[@]}"; do
    echo "  @$name -> $(readlink "$RURA_MEMORY_DIR/@$name")"
  done

  echo -n "Forget them all? [y/N]: "
  read -r yn
  [[ "$yn" != [yY] ]] && echo "Cancelled" && return 0

  for name in "${broken[@]}"; do
    unlink "$RURA_MEMORY_DIR/@$name"
    echo "⚡ Forgot: @$name"
  done
}

_rura_list() {
  local -a memories
  local name mem_path target marker color_start color_ok color_ng color_end
  _rura_get_memories

  if (( ${#memories[@]} == 0 )); then
    echo "No memories found."
    return 0
  fi

  if [[ -t 1 ]]; then
    color_ok="$(tput setaf 2)"
    color_ng="$(tput setaf 1)"
    color_end="$(tput sgr0)"
  fi

  for name in "${memories[@]}"; do
    mem_path="$RURA_MEMORY_DIR/@$name"
    target="$(readlink "$mem_path")"

    if [[ -d "$target" ]]; then
      marker=" "
      color_start="$color_ok"
    else
      marker="✖"
      color_start="$color_ng"
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
  rura prune|p                   # Forget every memory whose location is gone
  rura help|h                    # Show this help message
  rura version|v                 # Show version

Examples:
  rura @work                       # Jump to 'work'
  rura add . work                  # Memorize current dir as 'work'
  rura add /path/to/dir myproject  # Memorize specific directory
  rura delete work                 # Forget 'work' memory
  rura list                        # List all memories
  rura prune                       # Forget all broken memories
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
    prune|p)
      _rura_prune ;;
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
