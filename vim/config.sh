CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

DOT_VIMRC="$HOME/.vimrc"

# will put into ~/.vimrc
SOURCE_VIMRC="source $CUR_DIR/vimrc"

# match with backupdir, directory, and undodir in vimrc
VIM_DIRS=("$HOME/.vim/.backup" "$HOME/.vim/.swp" "$HOME/.vim/.undo")