# .bashrc をロードします。
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"

# このローカル環境専用の設定ファイルをロードします。
[ -f "$HOME/.bash_profile.local" ] && source "$HOME/.bash_profile.local"
[ -f "$BDOTDIR/.bash_profile.local" ] && source "$BDOTDIR/.bash_profile.local"
