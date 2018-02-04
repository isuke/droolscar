DROOLSCAR_DATE_FORMAT=${DROOLSCAR_DATE_FORMAT:-"+%m/%d %H:%M:%S"}
DROOLSCAR_SEGMENT_SEPARATOR=''

prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$DROOLSCAR_SEGMENT_SEPARATOR%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$DROOLSCAR_SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%} "
  CURRENT_BG=''
}

prompt_status_and_time() {
  local bg fg
  local time
  local symbols

  time=`date ${DROOLSCAR_DATE_FORMAT}`

  symbols=()

  if [[ $RETVAL -eq 0 ]]; then
    bg=white
    fg=black
  else
    bg=red
    fg=white
  fi

  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{red}%}✱ "

  CURRENT_BG=$bg

  prompt_segment $bg $fg "$time $symbols"
}

prompt_name() {
  local bg

  if [[ $UID -eq 0 ]]; then
    bg=red
  else
    bg=magenta
  fi
  CURRENT_BG=$bg

  prompt_segment $bg white '%n'
}

prompt_dir() {
  prompt_segment blue white '%~'
}

prompt_git_name() {
  local name

  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    name=`git config --get user.name`

    prompt_segment yellow black "✏ $name"
  fi
}

prompt_git_current_branch() {
  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    setopt promptsubst
    autoload -Uz vcs_info

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' get-revision true
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' stagedstr '✚ '
    zstyle ':vcs_info:*' unstagedstr '● '
    zstyle ':vcs_info:*' formats "%{ %F{black}%}%b %{%F{black}%}%u%c"
    zstyle ':vcs_info:*' actionformats " %{%F{red}%}%b %{%F{black}%}%u%c"
    vcs_info

    prompt_segment green black $vcs_info_msg_0_
  fi
}

prompt_git_remote_branch() {
  local current_branch
  local remote
  local ahead behind num

  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    current_branch=${$(git rev-parse --abbrev-ref HEAD)}
    remote=${$(git rev-parse --verify remotes\/origin\/${current_branch} --symbolic-full-name 2> /dev/null)}
    if [[ -n ${remote} ]] ; then
      ahead=$(git rev-list ${remote}..HEAD 2> /dev/null | wc -l | tr -d ' ')
      behind=$(git rev-list HEAD..${remote} 2> /dev/null | wc -l | tr -d ' ')

      if [[ $ahead -eq 0 && $behind -eq 0 ]] ; then
        num="○ "
      else
        if [[ $ahead -gt 0 ]] ; then
          num="%{%F{black}%}+${ahead}"
        else
          num="%{%F{red}%}-${behind}"
        fi
      fi
    else
      num="--"
    fi

    prompt_segment cyan white "⏏ remote $num"
  fi
}

prompt_git_stash() {
  local fg
  local stash_size

  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    stash_size=$(git stash list | wc -l | tr -d ' ')
    if [[ stash_size -eq 0 ]]; then
      fg=black
    else
      fg=red
    fi

    prompt_segment white $fg "❒ stash +$stash_size"
  fi
}

prompt_none() {
  CURRENT_BG=white
  prompt_segment white default ""
}

build_prompt() {
  RETVAL=$?
  prompt_name
  prompt_dir
  prompt_git_name
  prompt_git_current_branch
  prompt_git_stash
  prompt_git_remote_branch
  prompt_end

  echo

  prompt_status_and_time
  prompt_end
}

build_prompt2() {
  prompt_none
  prompt_end
}

PROMPT='$(build_prompt)'
PROMPT2='$(build_prompt2)'
