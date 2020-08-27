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
# 色に関する設定です。
#
####################################################################################################

# 名前で色を付けられるようにします。
autoload -Uz colors
colors

# ls の色を設定します。
() {
  # 色を付けられる対象です。
  # di: directory
  # ln: symbolic link
  # so: socket
  # pi: pipe
  # ex: executable
  # bd: block special
  # cd: character special
  # su: executable with setuid bit set
  # sg: executable with setgid bit set
  # tw: directory writable to others, with sticky bit
  # ow: directory writable to others, without sticky bit
  local -a attributes
  attributes=(di ln so pi ex bd cd su sg tw ow)

  # ls コマンドや自動補完で使用する色を指定します。
  local -A bg_colors
  local -A fg_colors
  fg_colors[di]=cyan
  bg_colors[di]=black
  fg_colors[ln]=magenta
  bg_colors[ln]=black
  fg_colors[so]=green
  bg_colors[so]=black
  fg_colors[pi]=green
  bg_colors[pi]=black
  fg_colors[ex]=red
  bg_colors[ex]=black
  fg_colors[bd]=yellow
  bg_colors[bd]=black
  fg_colors[cd]=yellow
  bg_colors[cd]=black
  fg_colors[su]=red
  bg_colors[su]=cyan
  fg_colors[sg]=red
  bg_colors[sg]=cyan
  fg_colors[tw]=cyan
  bg_colors[tw]=red
  fg_colors[ow]=cyan
  bg_colors[ow]=red

  # mac の ls コマンド用の色を生成します。
  export LSCOLORS=''
  for a in $attributes; do
    local fgcode=$(expr ${color[$fg_colors[$a]]} + 67)
    local bgcode=$(expr ${color[$bg_colors[$a]]} + 67)
    LSCOLORS=${LSCOLORS}$(char $fgcode)$(char $bgcode)
  done

  # GNU の ls や auto complete 用の色を生成します。
  export LS_COLORS=''
  for a in $attributes; do
    LS_COLORS="$LS_COLORS$a=${color[$fg_colors[$a]]};${color[bg-$bg_colors[$a]]}:"
  done
}

####################################################################################################
#
# 自動補完に関する設定です。
#
####################################################################################################

# .config/zsh/completion 以下に自動補完の定義ファイルを置きます。
fpath=($ZDOTDIR/completion $fpath)

# コマンド補完を有効にします。
autoload -Uz compinit
compinit -i -d "$ZCACHEDIR/.zcompdump"

# コマンド補完では大文字・小文字は区別しません。
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# 補完時、現在選択している項目をハイライト表示し、カーソル移動で選択できるようにします。
zstyle ':completion:*:default' menu select=2
zstyle ':completion:*:default' list-colors $LS_COLORS

# 辞書順ではなく数値順でソートします。
setopt NUMERIC_GLOB_SORT

####################################################################################################
#
# コマンド履歴に関する設定です。
#
####################################################################################################

# コマンド履歴 (history) の出力先です。
HISTFILE="$ZCACHEDIR/.zsh_history"

# history の最大保存数を増やします。
HISTSIZE=1048576
SAVEHIST=$HISTSIZE

# history ファイルに実行時刻と所要時間を保存します。
setopt EXTENDED_HISTORY

# history は古いものから順に削除されるようにします。
setopt HIST_EXPIRE_DUPS_FIRST

# history を他のターミナルとも共有できるようにします。
setopt APPEND_HISTORY
setopt SHARE_HISTORY

# 同じコマンドは 1 つしか history に残しません。
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS

# 無駄なスペースは削除します。
setopt HIST_REDUCE_BLANKS

# history コマンド自身は history に追加しません。
setopt HIST_NO_STORE

# コマンドラインの先頭がスペースから始まる場合は history に追加しません。
setopt HIST_IGNORE_SPACE

# history をインクリメンタルに追加します。
setopt INC_APPEND_HISTORY

####################################################################################################
#
# プロンプトに関する設定です。
#
####################################################################################################

# プロンプトの表示前にバージョン管理システムの情報を取得できるようにします。
autoload -Uz vcs_info
precmd () { vcs_info }

# バージョン管理システムに関する情報の出力フォーマットを指定します。
# e.g. (git)[master], (git)[master|merge]
zstyle ':vcs_info:*' formats '(%s)[%b]'
zstyle ':vcs_info:*' actionformats '(%s)[%b|%a]'

# ブランチの状態に応じた色を取得します。
#   red: ワークツリーに変更あるいは削除がある場合
#   yellow: リポジトリで管理されていないファイルが存在する場合
#   green: インデックスにファイルが登録されている場合
#   white: 上記以外
function get_branch_status_color {
  local color=''
  local output=`git status --ignore-submodules --short 2> /dev/null`
  if [[ $output =~ "\n?.[DM] " ]]; then
    color='red'
  elif [[ $output =~ "\n?\?\? " ]]; then
    color='yellow'
  elif [[ $output =~ "^\n?[ACDMR]. " ]]; then
    color='green'
  else
    color='white'
  fi
  echo $color
}

# 左端プロンプトを以下の書式に設定します。
# [user@host: /path/to/dir] (git)[branch] <exitCode>
# %
setopt PROMPT_SUBST
PROMPT='
%{${fg[cyan]}%}[%n@%m: %d]%{$reset_color%} %{${fg[$(get_branch_status_color)]}%}$vcs_info_msg_0_%{$reset_color%} %{%(?.${fg[white]}.${fg[red]})%}<%?>%{$reset_color%}
%% '
RPROMPT=''

####################################################################################################
#
# zsh のその他の設定です。
#
####################################################################################################

# cd で移動しても pushd と同じようにディレクトリスタックにパスを積みます。
setopt AUTO_PUSHD

# ディレクトリスタックに同じディレクトリを複数登録しません。
setopt PUSHD_IGNORE_DUPS

# Ctrl+D で zsh を終了しません。
setopt IGNORE_EOF

# ターミナル上でも # 以降をコメントとみなします。
setopt INTERACTIVE_COMMENTS

# バックグラウンドジョブが終了したらすぐに通知します。
setopt NO_TIFY

# Delete キーを使えるようにします。
bindkey "^[[3~" delete-char

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
alias ls='ls -AFhl --color=auto --time-style="+%Y-%m-%d %H:%M"'

# mkdir コマンドのエイリアスです。
#   -p, --parents: 中間ディレクトリを自動的に作成します。
alias mkdir="mkdir -p"

# mv コマンドのエイリアスです。
#   -i, --interactive: 上書き前に確認メッセージを表示します。
alias mv="mv -i"

# ps コマンドのエイリアスです。
alias ps="ps ax -o user,pid,pcpu,pmem,command"

# zsh をリロードするエイリアスです。
alias reload='exec $SHELL -l'

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

if $(has code); then
  alias code='code \
    --user-data-dir "$XDG_CONFIG_HOME/vscode" \
    --extensions-dir "$XDG_DATA_HOME/vscode/extensions"'
fi

if $(has curl); then
  # 現在地の天気を表示します。
  alias wttr='curl -s "https://wttr.in?format=%l:+%C+(%t+%p)"'
fi

if $(has direnv); then
  # direnv による環境変数の設定を有効にするため、フックを設定します。
  eval "$(direnv hook zsh)"
fi

if $(has docker); then
  alias dk='docker'
  alias dkc='docker-compose'
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
  # また、C-r で history から fzf を使ってコマンドを検索できるようにします。
  if [ "$OS" = "osx" ]; then
    source '/usr/local/opt/fzf/shell/completion.zsh' 2> /dev/null
    source '/usr/local/opt/fzf/shell/key-bindings.zsh'
  elif [ "$OS" = "linux" ]; then
    source '/usr/share/fzf/completion.zsh' 2> /dev/null
    source '/usr/share/fzf/key-bindings.zsh'
  fi

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

if $(has tmux); then
  # 設定ファイルとして XDG Directory Base を利用するための設定です。
  alias tmux='tmux -f $XDG_CONFIG_HOME/tmux/tmux.conf'
  export TMUX_TMPDIR="$XDG_RUNTIME_DIR"
fi

####################################################################################################
#
# 拡張機能です。
#
####################################################################################################

# このローカル環境専用の設定ファイルをロードします。
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
[ -f "$ZDOTDIR/.zshrc.local" ] && source "$ZDOTDIR/.zshrc.local"

# PATH の重複を取り除きます。
typeset -gU path PATH
