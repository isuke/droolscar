DROOLSCAR_DATE_FORMAT=${DROOLSCAR_DATE_FORMAT:-"+%m/%d %H:%M:%S"}

DROOLSCAR_SHOW_LANGS=${DROOLSCAR_SHOW_LANGS:-true}
DROOLSCAR_SHOW_ABSOLUTE_PATH=${DROOLSCAR_SHOW_ABSOLUTE_PATH:-true}

DROOLSCAR_LANGS=${DROOLSCAR_LANGS:-()}

DROOLSCAR_SEGMENT_SEPARATOR=${DROOLSCAR_SEGMENT_SEPARATOR:-''}
DROOLSCAR_SEGMENT_SEPARATOR_R=${DROOLSCAR_SEGMENT_SEPARATOR_R:-''}

DROOLSCAR_CURRENT_DIR_ICON=${DROOLSCAR_CURRENT_DIR_ICON:-'󰉖'}
DROOLSCAR_ABSOLUTE_PATH_ICON=${DROOLSCAR_ABSOLUTE_PATH_ICON:-'󰉋'}
DROOLSCAR_GIT_AUTHOR_ICON=${DROOLSCAR_GIT_AUTHOR_ICON:-'󰏪'}
DROOLSCAR_GIT_BRANCH_ICON=${DROOLSCAR_GIT_BRANCH_ICON:-'󰘬'}
DROOLSCAR_GIT_STASH_ICON=${DROOLSCAR_GIT_STASH_ICON:-'󰠔'}
DROOLSCAR_GIT_REMOTE_ICON=${DROOLSCAR_GIT_REMOTE_ICON:-'󰲁'}
DROOLSCAR_TIME_ICON=${DROOLSCAR_TIME_ICON:-''}

DROOLSCAR_APPLE_ICON=""
DROOLSCAR_LINUX_ICON=""
DROOLSCAR_PYTHON_ICON=""
DROOLSCAR_RUBY_ICON=""
DROOLSCAR_NODE_ICON=""
DROOLSCAR_RUST_ICON=""
DROOLSCAR_GO_ICON=""

setopt promptsubst
setopt transient_rprompt

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

  time=`date ${DROOLSCAR_DATE_FORMAT}`

  if [[ $RETVAL -eq 0 ]]; then
    bg=white
    fg=black
  else
    bg=red
    fg=white
  fi

  CURRENT_BG=$bg

  prompt_segment $bg $fg "$DROOLSCAR_TIME_ICON $time"
}

prompt_name() {
  local os_icon
  local bg

  case $OSTYPE in
    darwin*)
      os_icon=$DROOLSCAR_APPLE_ICON ;;
    linux*)
      os_icon=$DROOLSCAR_LINUX_ICON ;;
  esac

  if [[ $UID -eq 0 ]]; then
    bg=red
  else
    bg=magenta
  fi
  CURRENT_BG=$bg

  prompt_segment $bg white "$os_icon %n"
}

prompt_dir() {
  prompt_segment blue white "$DROOLSCAR_CURRENT_DIR_ICON %1d"
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

  test $author_name && prompt_segment yellow black "$DROOLSCAR_GIT_AUTHOR_ICON $author_name"
  test $committer_name && prompt_segment yellow black "$DROOLSCAR_GIT_AUTHOR_ICON $committer_name"
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
  local bg

  # FIXME
  if [[ $RETVAL -eq 0 ]]; then
    bg=white
  else
    bg=red
  fi

  CURRENT_BG=$bg
  prompt_segment $bg default ""
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

rprompt_langs() {
  if $(mise --version >/dev/null 2>&1); then
    local segment
    local langs

    langs=()

    for lang in $DROOLSCAR_LANGS; do
      local version=`mise ls --current --no-header $lang 2> /dev/null | awk '{print $2}'`
      local icon=""

      if [[ -n $version ]]; then
        case $lang in
          python)
            icon=$DROOLSCAR_PYTHON_ICON ;;
          ruby)
            icon=$DROOLSCAR_RUBY_ICON ;;
          node)
            icon=$DROOLSCAR_NODE_ICON ;;
          rust)
            icon=$DROOLSCAR_RUST_ICON ;;
          go)
            icon=$DROOLSCAR_GO_ICON ;;
        esac

        langs+="[$icon $version]"
      fi
    done

    # HACK: implement rprompt_segment
    CURRENT_BG_R=magenta
    segment="%F{magenta}$DROOLSCAR_SEGMENT_SEPARATOR_R%f"
    echo -n "${segment}%K{magenta}%F{white} $langs %f%k"
  fi
}

rprompt_dir_path() {
  local max_length
  local segment

  # HACK: implement rprompt_segment
  if [[ -n $CURRENT_BG_R ]]; then
    segment="%K{$CURRENT_BG_R}%F{blue}$DROOLSCAR_SEGMENT_SEPARATOR_R%f"
  else
    segment="%F{blue}$DROOLSCAR_SEGMENT_SEPARATOR_R%f"
  fi

  max_length=`echo $(( COLUMNS * 0.1 )) | awk '{printf("%d\n", $1)}'`

  echo -n "${segment}%K{blue}%F{white} $DROOLSCAR_ABSOLUTE_PATH_ICON %$max_length>...>%~%<< %f%k"
}

build_rprompot() {
  test $DROOLSCAR_SHOW_LANGS         = true && rprompt_langs
  test $DROOLSCAR_SHOW_ABSOLUTE_PATH = true && rprompt_dir_path
}

prompt_precmd() {
  PROMPT='$(build_prompt)'
  PROMPT2='$(build_prompt2)'
  RPROMPT='$(build_rprompot)'
}

add-zsh-hook precmd prompt_precmd
