####################################################################################################
#
# bash の設定ファイルロードに関する設定です。
#
####################################################################################################

# /etc/bashrc をロードします。
if [ -f "/etc/bashrc" ]; then
    source "/etc/bashrc"
fi

# 対話的シェルでない場合、これ以降はロードしません。
case $- in
  *i*) ;;
    *) return;;
esac

# XDG Base Directory 対応に関する環境変数を定義し、ディレクトリを作成します。
export XDG_CACHE_HOME="$HOME/.cache"  
export XDG_CONFIG_HOME="$HOME/.config"  
export XDG_DATA_HOME="$HOME/.local/share"  
export XDG_RUNTIME_DIR="$HOME/.xdg"  
export BCACHEDIR="$XDG_CACHE_HOME/bash"
export BDATADIR="$XDG_DATA_HOME/bash"  
export BDOTDIR="$XDG_CONFIG_HOME/bash"  
mkdir -p $BCACHEDIR
mkdir -p $BDATADIR
mkdir -p $BDOTDIR
mkdir -p $XDG_RUNTIME_DIR

# 履歴ファイルの出力先を変更します。
export HISTFILE="$BCACHEDIR/.bash_history"

####################################################################################################
#
# 実装分岐に使用する変数とユーティリティです。
#
####################################################################################################

# 環境変数 $OS にオペレーティングシステム osx, linux or windows を格納
case $(uname -s) in
  'Darwin'*)
    export OS='osx'
    ;;
  'Linux'*)
    export OS='linux'
    ;;
  'MINGW'*)
    export OS='windows'
    ;;
  'MSYS'*)
    export OS='windows'
    ;;
esac

# 一時ファイルの出力先を環境変数 $TMPDIR に格納
if [ -z "$TMPDIR" ]; then
  if [ -n "$TMP" ]; then
    export TMPDIR=$TMP/
  elif [ -n "$TEMP" ]; then
    export TMPDIR=$TEMP/
  elif [ -w /tmp/$USER ]; then
    export TMPDIR=/tmp/$USER/
  elif [ -w /tmp ]; then
    export TMPDIR=/tmp/
  else
    mkdir $HOME/tmp
    export TMPDIR=$HOME/tmp/
  fi
fi

# コマンドの存在を確認します。
function has() {
  type $1 &> /dev/null
}

# 文字に対応する ASCII コードを取得します。
function ord() {
  echo $(printf '%d' \'$1)
}

# ASCII コードに対応する文字を取得します。
function char() {
  local hex=$(printf '%x' $1)
  echo $(printf "\x${hex}")
}

####################################################################################################
#
# プロンプトに関する設定です。
#
####################################################################################################

# 左端プロンプトを以下の書式に設定します。
# [user@host: /path/to/dir]
# % 
export PS1='
\[\e[1;36m\][\u@\h: \w]\[\e[m\]
% '

####################################################################################################
#
# エイリアスの設定です。
#
####################################################################################################

# N 個の . で (N-1) 個上のディレクトリに移動します。
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# cp コマンドのエイリアスです。
#   -i, --interactive: 上書き前に確認メッセージを表示します。
alias cp="cp -i"

# df コマンドのエイリアスです。
#   -h, --human-readable: サイズ表記に K, M, G, T を使用します。
alias df='df -h'

# grep の色付けを有効にします。
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# less コマンドのエイリアスです。
#   -R, --RAW-CONTROL-CHARS: ANSI Color を解釈して色付きで表示します。
alias less="less -R"

# ls コマンドのエイリアスです。
#   -A, --almost-all: . と .. を除く全てのファイルを表示します。
#   -F, --classify: ファイル名の末尾にファイルの種類を表す記号 (*/=>@|) を付与します。
#   -h, --human-readable: ファイルサイズを読みやすい形式で出力します。
#   -l: 詳細情報を表示します。
alias ls='ls -AFhl --color=auto'

# mkdir コマンドのエイリアスです。
#   -p, --parents: 中間ディレクトリを自動的に作成します。
alias mkdir="mkdir -p"

# mv コマンドのエイリアスです。
#   -i, --interactive: 上書き前に確認メッセージを表示します。
alias mv="mv -i"

# ps コマンドのエイリアスです。
alias ps="ps ax -o user,pid,pcpu,pmem,command"

# rm コマンドのエイリアスです。
#   -i: 削除前に確認メッセージを表示します。
alias rm="rm -i"

####################################################################################################
#
# 特定の環境やソフトウェアに関する設定です。
#
####################################################################################################

if [ "$OS" = "osx" ]; then
  # Linux とコマンドを統一するために MAC でも GNU Core Utilities を優先的に使用します。
  # MAC には BSD 由来のコマンドが多く含まれていますが GNU/Linux のコマンドと互換性がありません。
  export PATH=/usr/local/opt/coreutils/libexec/gnubin:$PATH
  export MANPATH=/usr/local/opt/coreutils/libexec/gnuman:$MANPATH
fi

if $(has direnv); then
  # direnv による環境変数の設定を有効にするため、フックを設定します。
  eval "$(direnv hook bash)"
fi

if $(has fd); then
  # fd でファイルを検索するエイリアスです。
  #   -L, --follow: シンボリックリンクを辿って検索します。
  #   -H, --hidden: 隠しファイル (dotfiles) を検索対象に含めます。
  #   -E, --exclude: 指定したパターンに一致するファイルを除外します。
  alias fd='fd -LH -E .git'

  # fzf で find の代わりに fd を優先的に使用します。
  #   -L, --follow: シンボリックリンクを辿ります。
  #   -H, --hidden: dotfiles を検索対象に含めます。
  #   -I, --no-ignore: ファイルを無視しません。
  #   -E, exclude: 指定したパターンに一致するファイルを除外します。
  #   -t, --type: 指定したファイル種別だけを検索対象にします。
  export FZF_DEFAULT_COMMAND='fd -LHI -E ".git" --type f'
fi

if $(has fzf); then
  # ** を補完すると fzf でファイルを検索できるようにします。
  source '/usr/local/opt/fzf/shell/completion.bash' 2> /dev/null

  # C-r で history から fzf を使ってコマンドを検索できるようにします。
  source '/usr/local/opt/fzf/shell/key-bindings.bash'

  # fzf を使って選択したプロセスを終了します。
  alias fkill="\ps ax -o user,pid,pcpu,pmem,command | fzf -m | awk '{ print \$2 }' | xargs kill -9"
fi

if $(has git); then
  # git リポジトリのルートディレクトリに移動するエイリアスです。
  alias rt='cd $(git rev-parse --show-superproject-working-tree --show-toplevel | head -1)'
fi

if $(has go); then
  export GOPATH="$XDG_DATA_HOME/go"
  export PATH="$GOPATH/bin:$PATH"
fi

if $(has less); then
  export LESSKEY="$XDG_CONFIG_HOME/less/lesskey"
  export LESSHISTFILE="$XDG_CACHE_HOME/less/history"
  mkdir -p "$XDG_CACHE_HOME/less"
fi

if $(has nodebrew); then
  export NODEBREW_ROOT="$XDG_DATA_HOME/nodebrew"
  export PATH="$NODEBREW_ROOT/current/bin:$PATH"
fi

if $(has npm); then
  export NODE_REPL_HISTORY="$XDG_CACHE_HOME/node_repl_history"
  export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
  export PATH="$XDG_DATA_HOME/npm/bin:$PATH"
fi

if $(has pyenv); then
  export PYENV_ROOT="$XDG_DATA_HOME/pyenv"
  eval "$(pyenv init -)"
fi

if $(has python); then
  export PYLINTHOME="$XDG_CACHE_HOME/pylint"
fi

if $(has rbenv); then
  export RBENV_ROOT="$XDG_DATA_HOME/rbenv"
  eval "$(rbenv init -)"
fi

if $(has rg); then
  # ripgrep でファイル内容を検索するためのエイリアスです。
  #   -L, --follow: シンボリックリンクを辿って検索します。
  #   --hidden: 隠しファイル (dotfiles) を検索対象に含めます。
  #   --no-heading: ヘッダ行は作成せず、各行にファイルパスを表示します。
  alias rg='rg -L --hidden --no-heading'
fi

if $(has ruby); then
  export GEM_HOME="$XDG_DATA_HOME/gem"
  export GEM_SPEC_CACHE="$XDG_CACHE_HOME/gem"
fi

####################################################################################################
#
# 拡張機能です。
#
####################################################################################################

# このローカル環境専用の設定ファイルをロードします。
[ -f "$HOME/.bashrc.local" ] && source "$HOME/.bashrc.local"
[ -f "$BDOTDIR/.bashrc.local" ] && source "$BDOTDIR/.bashrc.local"
