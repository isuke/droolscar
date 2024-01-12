DROOLSCAR_DATE_FORMAT=${DROOLSCAR_DATE_FORMAT:-"+%m/%d %H:%M:%S"}
DROOLSCAR_SEGMENT_SEPARATOR=${DROOLSCAR_SEGMENT_SEPARATOR:-''}
DROOLSCAR_DIR_ICON=${DROOLSCAR_DIR_ICON:-''}
DROOLSCAR_GIT_AUTHOR_ICON=${DROOLSCAR_GIT_AUTHOR_ICON:-'󰏪'}
DROOLSCAR_GIT_BRANCH_ICON=${DROOLSCAR_GIT_BRANCH_ICON:-'󰘬'}
DROOLSCAR_GIT_STASH_ICON=${DROOLSCAR_GIT_STASH_ICON:-'󰠔'}
DROOLSCAR_GIT_REMOTE_ICON=${DROOLSCAR_GIT_REMOTE_ICON:-'󰲁'}
DROOLSCAR_TIME_ICON=${DROOLSCAR_TIME_ICON:-''}

setopt promptsubst

if $(git --version >/dev/null 2>&1); then
  autoload -Uz vcs_info
  zstyle ':vcs_info:*' enable git
  zstyle ':vcs_info:*' get-revision true
  zstyle ':vcs_info:*' check-for-changes true
  zstyle ':vcs_info:*' stagedstr '✚ '
  zstyle ':vcs_info:*' unstagedstr '● '
  zstyle ':vcs_info:*' formats "%{$DROOLSCAR_GIT_BRANCH_ICON %F{black}%}%b %{%F{black}%}%u%c"
  zstyle ':vcs_info:*' actionformats "$DROOLSCAR_GIT_BRANCH_ICON %{%F{red}%}%b %{%F{black}%}%u%c"
fi

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

  prompt_segment $bg $fg "$DROOLSCAR_TIME_ICON $time $symbols"
}

prompt_name() {
  local bg

  if [[ $UID -eq 0 ]]; then
    bg=red
  else
    bg=magenta
  fi
  CURRENT_BG=$bg

  prompt_segment $bg white "%n"
}

prompt_dir() {
  prompt_segment blue white "$DROOLSCAR_DIR_ICON %~"
}

prompt_git_name() {
  if $(git config --get duet.env.git-author-name >/dev/null 2>&1); then
    prompt_git_duet_name
  else
    prompt_git_normal_name
  fi
}

prompt_git_normal_name() {
  local name=`git config --get user.name`

  prompt_segment yellow black "$DROOLSCAR_GIT_AUTHOR_ICON $name"
}

prompt_git_duet_name() {
  local author_name=`git config --get duet.env.git-author-name`
  local committer_name=`git config --get duet.env.git-committer-name`

  [[ $author_name ]] && prompt_segment yellow black "$DROOLSCAR_GIT_AUTHOR_ICON $author_name"
  [[ $committer_name ]] && prompt_segment yellow black "$DROOLSCAR_GIT_AUTHOR_ICON $committer_name"
}

prompt_git_current_branch() {
  vcs_info
  prompt_segment green black $vcs_info_msg_0_
}

prompt_git_remotes() {
  eval "remotes=(`git remote | sed 's/\n/ /'`)"
  for remote in $remotes; do
    prompt_git_remote $remote
  done
}

prompt_git_remote() {
  local fg
  local current_branch
  local remote
  local ahead behind
  local remote_status
  local remote=${1:-"origin"}

  fg=black

  current_branch=${$(git rev-parse --abbrev-ref HEAD)}
  remote_path=${$(git rev-parse --verify remotes\/${remote}\/${current_branch} --symbolic-full-name 2> /dev/null)}

  if [[ -n ${remote_path} ]] ; then
    ahead=$(git rev-list ${remote_path}..HEAD 2> /dev/null | wc -l | tr -d ' ')
    behind=$(git rev-list HEAD..${remote_path} 2> /dev/null | wc -l | tr -d ' ')

    if [[ $ahead -eq 0 && $behind -eq 0 ]] ; then
      remote_status="○ "
    else
      if [[ $ahead -gt 0 ]] ; then
        fg=yellow
      fi

      if [[ $behind -gt 0 ]] ; then
        fg=red
      fi

      remote_status="+${ahead} -${behind}"
    fi
  else
    remote_status="--"
  fi

  prompt_segment cyan $fg "$DROOLSCAR_GIT_REMOTE_ICON $remote $remote_status"
}

prompt_git_stash() {
  local fg
  local stash_size

  if $(git reflog exists refs/stash >/dev/null 2>&1); then
    stash_size=$(git reflog refs/stash | wc -l | tr -d ' ')
    if [[ stash_size -eq 0 ]]; then
      fg=black
    else
      fg=red
    fi
  else
    stash_size=0
    fg=black
  fi
  prompt_segment white $fg "$DROOLSCAR_GIT_STASH_ICON stash +$stash_size"
}

prompt_none() {
  CURRENT_BG=white
  prompt_segment white default ""
}

build_prompt() {
  RETVAL=$?
  prompt_name
  prompt_dir
  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    prompt_git_name
    prompt_git_current_branch
    prompt_git_stash
    prompt_git_remotes
  fi
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
