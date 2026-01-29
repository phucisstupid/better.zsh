# ────────────────────────────────────────────────────────────
# 🔌 Plugin Configurations
# ────────────────────────────────────────────────────────────
# 🍺 `brew`
export HOMEBREW_NO_ANALYTICS=1

#  `eza` (Enhanced `ls`)
zstyle ':omz:plugins:eza' 'show-group' no  
zstyle ':omz:plugins:eza' 'git-status' yes  
zstyle ':omz:plugins:eza' 'icons' yes  

#  `alias-finder`
zstyle ':omz:plugins:alias-finder' autoload yes  
zstyle ':omz:plugins:alias-finder' longer yes  
zstyle ':omz:plugins:alias-finder' exact yes  
zstyle ':omz:plugins:alias-finder' cheaper yes  

# `fzf` 
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=selected-bg:#45475A \
--color=border:#6C7086,label:#CDD6F4"

# `magic-enter`
MAGIC_ENTER_OTHER_COMMAND='ls -a .'

# `yazi`
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# ────────────────────────────────────────────────────────────
# 🔧 Shell Options - Smarter Navigation
# ────────────────────────────────────────────────────────────

setopt auto_cd             # Auto change dir without `cd`
setopt auto_pushd          # Push prev dir to stack on `cd`
setopt pushd_ignore_dups   # No duplicate dirs in stack
setopt pushdminus          # Reverse pushd behavior

# ────────────────────────────────────────────────────────────
# 📂 Navigation & Zoxide
# ────────────────────────────────────────────────────────────

alias cd="z"               # Use Zoxide for quick jumps
# Shortcuts to move up levels
alias -g ...="../.."     
alias -g ....="../../.."

# Quick access to recent directories
for i in {1..9}; do
  alias "$i"="cd -$i"
done

# List recent directories
d() {
  if [[ -n $1 ]]; then
    dirs "$@"
  else
    dirs -v | head -n 10
  fi
}
compdef _dirs d  

# ────────────────────────────────────────────────────────────
# 📁 Directory Handling
# ────────────────────────────────────────────────────────────

mkcd() { 
  [[ -n "$1" ]] || { echo "Usage: mkcd <directory>"; return 1; }
  mkdir -p "$1" && cd "$1"
}

# Create, clone, or extract based on input
take() {
  [[ -z "$1" ]] && { echo "Usage: take <dir|URL>"; return 1; }

  case "$1" in
    *github.com/* | *gitlab.com/* | *bitbucket.org/*)
      repo_url="${1%.git}.git" 
      git clone "$repo_url" && cd "$(basename "$repo_url" .git)"
      ;;
    *.tar.gz|*.tgz|*.tar.bz2|*.tbz2|*.tar.xz|*.txz|*.zip|*.rar)
      filename=$(basename "$1")
      wget "$1" -O "$filename" || { echo "Download failed!"; return 1; }
      
      case "$filename" in
        *.tar.gz|*.tgz)   tar -xvzf "$filename" ;;
        *.tar.bz2|*.tbz2) tar -xvjf "$filename" ;;
        *.tar.xz|*.txz)   tar -xvJf "$filename" ;;
        *.zip)            unzip "$filename" ;;
        *.rar)            unrar x "$filename" ;;
      esac

      extracted_dir=$(tar -tf "$filename" 2>/dev/null | head -1 | cut -d/ -f1)
      [[ -d "$extracted_dir" ]] && cd "$extracted_dir"
      ;;
    *) mkcd "$1" ;;
  esac
}

# ────────────────────────────────────────────────────────────
# ⚙️ Aliases - Improved Commands
# ────────────────────────────────────────────────────────────

alias mkdir="mkdir -pv"      
alias cp="cp -v"             # Verbose copy
