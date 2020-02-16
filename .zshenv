# XDG Base Directory 対応に関する環境変数を定義し、ディレクトリを作成します。
export XDG_CACHE_HOME="$HOME/.cache"  
export XDG_CONFIG_HOME="$HOME/.config"  
export XDG_DATA_HOME="$HOME/.local/share"  
export XDG_RUNTIME_DIR="$HOME/.xdg"  
export ZCACHEDIR="$XDG_CACHE_HOME/zsh"
export ZDATADIR="$XDG_DATA_HOME/zsh"  
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"  
mkdir -p $ZCACHEDIR
mkdir -p $ZDATADIR
mkdir -p $ZDOTDIR
mkdir -p $XDG_RUNTIME_DIR

# このローカル環境専用の設定ファイルをロードします。
[ -f "$HOME/.zshenv.local" ] && source "$HOME/.zshenv.local"
[ -f "$ZDOTDIR/.zshunv.local" ] && source "$ZDOTDIR/.zshenv.local"
