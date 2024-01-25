# Droolscar [![git-consistent friendly](https://img.shields.io/badge/git--consistent-friendly-brightgreen.svg)](https://github.com/isuke/git-consistent)

![](https://raw.githubusercontent.com/isuke/droolscar/images/image1.png)

**Droolscar** is zsh theme.

You need [Nerd Fonts](https://www.nerdfonts.com/).

The following fonts are recommended for Japanese.

- [白源 (はくげん／HackGen)](https://github.com/yuru7/HackGen)
- [PlemolJP](https://github.com/yuru7/PlemolJP)

## Features

![](https://raw.githubusercontent.com/isuke/droolscar/images/features.png)

### user id and os

Show user id and os icon (Linux or Mac).

### current directory

Show current directory name.

### git authors

Show current git author name.
If you use [git-duet](https://github.com/git-duet/git-duet), show all author names.

### git current branch and status

Show git current branch name.

Show git status as follows.

* `✚` : exist staged file(s).
* `●` : exist unstaged file(s).

### git stash num

Show git stash num.
If exist stash, text color is changed to red.

### git remote names and status

Show git remote names.
If exist multiple remote (ex, `master` and `heroku`), show all.

If exist 'not pushed commits', counted numbers show by negative.
And text color is changed to yellow.

If exist 'not pulled commits', counted numbers show by positive.
And text color is changed to red.

### current time and exit status

Show current time.

If prev command's exit code is not 0, background color is changed to red.

## Usage

### By [zinit](https://github.com/zdharma-continuum/zinit)

```sh
$ echo 'zinit light "isuke/droolscar"' >> ~/.zshrc
```

### By [zplug](https://github.com/zplug/zplug)

```sh
$ echo 'zplug "isuke/droolscar", as:theme' >> ~/.zshrc
```

### Plain

```sh
$ git clone git@github.com:isuke/droolscar.git
$ echo 'source /your/path/droolscar/droolscar.zsh-theme' >> ~/.zshrc
```

## Options

| Environment Variable            | Default Value       | Description                                      |
| ------------------------------- | ------------------- | ------------------------------------------------ |
| `DROOLSCAR_DATE_FORMAT`         | `"+%m/%d %H:%M:%S"` | current date time format.                        |
| `DROOLSCAR_LANGS`               | `()`                | which programming lang versions by [mise](https://mise.jdx.dev/) on right. ex) `(ruby node go)` |
| `DROOLSCAR_SHOW_ABSOLUTE_PATH`  | `true`              | show current absolute path on right.             |
| `DROOLSCAR_SEGMENT_SEPARATOR`   | `""` (U+E0B0)      | separate character of each segment for left.     |
| `DROOLSCAR_SEGMENT_SEPARATOR_R` | `""` (U+E0B2)      | separate character of each segment for right.    |

### Recommended Separator Characters

- hard_divider (default)
    - left: `""` (U+E0B0)
    - right: `""` (U+E0B2)
- triangle1
    - left: `""` (U+E0B8)
    - right: `""` (U+E0BE)
- triangle2
    - left: `""` (U+E0BC)
    - right: `""` (U+E0BA)
- half_circle_thick
    - left: `""` (U+E0B4)
    - right: `""` (U+E0B6)
- flame_thick
    - left: `""` (U+E0C0)
    - right: `""` (U+E0C2)
- ice_waveform
    - left: `""` (U+E0C8)
    - right: `""` (U+E0CA)
