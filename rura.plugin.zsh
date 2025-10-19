#!/usr/bin/env zsh
# ⚡ Rura - A simple zsh plugin to save and jump to directories

RURA_SAVEPOINT_DIR="${RURA_SAVEPOINT_DIR:-$HOME/.rura}"
RURA_VERSION="0.3.0"

[[ ! -d "$RURA_SAVEPOINT_DIR" ]] && mkdir -p "$RURA_SAVEPOINT_DIR"

# Get all savepoint names (without @ prefix)
_rura_get_savepoints() {
  local -a names
  for sp in "$RURA_SAVEPOINT_DIR"/@*(N); do
    [[ -L "$sp" ]] && names+=(${${sp:t}#@})
  done
  echo "${names[@]}"
}

_rura_jump() {
  local name="${1#@}"
  local sp_path="$RURA_SAVEPOINT_DIR/@$name"

  if [[ ! -L "$sp_path" ]]; then
    echo "Error: Savepoint not found: $name" >&2
    echo "Run 'rura list' to see available savepoints" >&2
    return 1
  fi

  local target="$(readlink "$sp_path")"
  if [[ ! -d "$target" ]]; then
    echo "Error: Target directory does not exist: $target" >&2
    return 1
  fi

  cd "$target"
}

_rura_add() {
  local dir="$1" name="$2"
  local sp_path="$RURA_SAVEPOINT_DIR/@$name"

  if [[ -z "$dir" || -z "$name" ]]; then
    echo "Error: Both directory and savepoint name are required" >&2
    echo "Usage: rura add <directory> <name>" >&2
    return 1
  fi

  if [[ ! -d "$dir" ]]; then
    echo "Error: Directory not found: $dir" >&2
    return 1
  fi

  if [[ -e "$sp_path" ]]; then
    echo "Error: Savepoint already exists: $name" >&2
    echo "Use 'rura delete $name' first to replace it" >&2
    return 1
  fi

  ln -s "${dir:A}" "$sp_path"
  echo "⚡ Saved: @$name -> ${dir:A}"
}

_rura_delete() {
  local name="$1"
  local sp_path="$RURA_SAVEPOINT_DIR/@$name"

  if [[ -z "$name" ]]; then
    echo "Error: Savepoint name is required" >&2
    echo "Usage: rura delete <name>" >&2
    return 1
  fi

  if [[ ! -L "$sp_path" ]]; then
    echo "Error: Savepoint not found: $name" >&2
    return 1
  fi

  local target="$(readlink "$sp_path")"
  echo -n "Remove savepoint '$name' -> $target? [y/N]: "
  read -r yn
  [[ "$yn" != [yY] ]] && echo "Cancelled" && return 0

  unlink "$sp_path"
  echo "⚡ Removed: @$name"
}

_rura_list() {
  local -a names
  names=($(_rura_get_savepoints))

  if (( ${#names[@]} == 0 )); then
    echo "No savepoints found"
    return 0
  fi

  for name in "${names[@]}"; do
    local sp_path="$RURA_SAVEPOINT_DIR/@$name"
    local target="$(readlink "$sp_path")"
    local marker="o"
    [[ ! -d "$target" ]] && marker="x"
    printf "  %s %-20s -> %s\n" "$marker" "@$name" "$target"
  done
}

_rura_help() {
  cat << 'EOF'
⚡ Rura - A simple zsh plugin to save and jump to directories.

Usage:
  rura @<name>                     # Jump to savepoint
  rura add|a <directory> <name>    # Add a savepoint
  rura delete|d <name>             # Delete a savepoint
  rura list|l                      # List all savepoints
  rura help|h                      # Show this help message
  rura version|v                   # Show version

Examples:
  rura @work                       # Jump to 'work' directory
  rura add . work                  # Save current directory as 'work'
  rura add /path/to/dir myproject  # Save specific directory
  rura delete work                 # Delete 'work' savepoint
  rura list                        # List all savepoints
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
      echo "Run 'rura help' for usage information" >&2
      return 1
      ;;
  esac
}

# Tab completion
_rura_completion() {
  local -a commands savepoints names
  commands=(
    'add:Add a savepoint'
    'delete:Delete a savepoint'
    'list:List savepoints'
    'help:Show help'
    'version:Show version'
  )

  # Get savepoint names using the common function
  names=($(_rura_get_savepoints))
  for name in "${names[@]}"; do
    savepoints+=("@$name:Jump to savepoint")
  done

  _arguments -C '1: :->cmd' '*: :->args'

  case $state in
    cmd)
      _describe 'commands' commands
      _describe 'savepoints' savepoints
      ;;
    args)
      case $words[2] in
        delete|d) _describe 'savepoint names' names ;;
        add|a) [[ $CURRENT -eq 3 ]] && _directories ;;
      esac
      ;;
  esac
}

# Register completion if available
if (( $+functions[compdef] )); then
  compdef _rura_completion rura
fi
