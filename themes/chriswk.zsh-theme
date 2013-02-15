precmd() {
  vcs_info
}
autoload -Uz vcs_info
autoload -U colors && colors
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' get-revision true
zstyle ':vcs_info:*' unstagedstr '%F{red}*'   # display this when there are unstaged changes
zstyle ':vcs_info:*' stagedstr '%F{yellow}+'  # display this when there are staged changes
zstyle ':vcs_info:*' actionformats \
    '%F{5}%F{5}[%F{2}%b%F{3}|%F{1}%a%c%u%F{5}]%f '
zstyle ':vcs_info:*' formats       \
    '%F{yellow}%s:%F{5}[%F{2}%b%c%u%m%F{5}]%f '
zstyle ':vcs_info:git:*' formats \
       '%F{yellow}%s:%F{8}(%F{2}%9.9i%F{8})%F{5}%F{5}[%F{2}%b%c%u%F{5}]%F{red}%m %f'
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'
zstyle ':vcs_info:*' enable git cvs svn hg bzr
zstyle ':vcs_info:*' max-exports 5
### git: Show remote branch name for remote-tracking branches
zstyle ':vcs_info:git*+set-message:*' hooks git-remotebranch

function +vi-git-remotebranch() {
    local remote

    # Are we on a remote-tracking branch?
    remote=${$(git rev-parse --verify ${hook_com[branch]}@{upstream} \
        --symbolic-full-name 2>/dev/null)/refs\/remotes\/}

    if [[ -n ${remote} ]] ; then
        hook_com[branch]="${hook_com[branch]} [${remote}]"
    fi
}

zstyle ':vcs_info:git*+set-message:*' hooks git-st
function +vi-git-st() {
    local ahead behind
    local -a gitstatus
    ahead=$(git rev-list ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null | wc -l)
    (( $ahead )) && gitstatus+=( "+${ahead}" )

    behind=$(git rev-list HEAD..${hook_com[branch]}@{upstream} 2>/dev/null | wc -l)
    (( $behind )) && gitstatus+=( "-${behind}" )

    hook_com[misc]+=${(j:/:)gitstatus}
}

theme_precmd () {
    vcs_info
}


# hg:
# First, remove the hash from the default 'branchformat':
zstyle ':vcs_info:hg:*' branchformat '%b'
# Then add the hash to 'formats' as %i and truncate it to 9 chars:
zstyle ':vcs_info:hg:*' formats '%F{yellow}%s:%F{8}(%F{2}%9.9i%F{8})%F{5}%F{5}[%F{2}%b%c%u%F{5}]%m %f'

### hg: Truncate long hash to 12-chars but also allow for multiple parents
# Hashes are joined with a + to mirror the output of `hg id`.
zstyle ':vcs_info:hg+set-hgrev-format:*' hooks hg-shorthash
function +vi-hg-shorthash() {
    local -a parents

    parents=( ${(s:+:)hook_com[hash]} )
    parents=( ${(@r:12:)parents} )
    hook_com[rev-replace]=${(j:+:)parents}

    ret=1
}



local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"

local user_host='%{$terminfo[bold]$fg[green]%}%n@%m%{$reset_color%}'
local current_dir='%{$terminfo[bold]$fg[blue]%} %~%{$reset_color%}'

local rvm_ruby=''
if which rvm-prompt &> /dev/null; then
  rvm_ruby='%{$fg[red]%}‹$(rvm-prompt i v g)›%{$reset_color%}'
else
  if which rbenv &> /dev/null; then
    rvm_ruby='%{$fg[red]%}‹$(rbenv version | sed -e "s/ (set.*$//")›%{$reset_color%}'
  fi
fi

local git_branch='$(git_prompt_info)%{$reset_color%}'
local vcs_info='%{$reset_color%}${vcs_info_msg_0_}%{$reset_color%}'
local java_version='%{$fg[magenta]%}‹j:$(java -version 2>&1 | awk "/version/ {print $3}" | egrep -o "[0-9]+\.[0-9]+\.[_0-9]+")›%{$reset_color%}'
local date_prompt='%{$fg[blue]%}%D{[%I:%M]} %{$reset_color%}'


PROMPT="╭─${user_host} ${date_prompt} ${current_dir} ${vcs_info}
╰─%B$%b "
RPROMPT="${java_version} - ${rvm_ruby}"

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[yellow]%}‹"
ZSH_THEME_GIT_PROMPT_SUFFIX="› %{$reset_color%}"
