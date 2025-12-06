#!/usr/bin/env zsh

TMP_HOME=$(mktemp -d)
PLUGIN_DIR=$PWD

cat <<EOF > "$TMP_HOME/.zshrc"
fpath=("$PLUGIN_DIR" \$fpath)
autoload -Uz compinit
compinit

zstyle ':completion:*' format '%B%d%b'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:default' list-colors \${(s.:.)LS_COLORS}

export RURA_MEMORY_DIR="$TMP_HOME/.config/rura"
source "$PLUGIN_DIR/rura.plugin.zsh"
PS1="%F{yellow}[RURA TEST]%f %~ %# "

echo "🧪 Rura Sandbox Shell Started!"
echo "   Memories are isolated in: \$RURA_MEMORY_DIR"
echo "   Type 'exit' or Ctrl+D to finish."
EOF

ZDOTDIR="$TMP_HOME" zsh -i

rm -rf "$TMP_HOME"
echo "🧹 Cleaned up."
