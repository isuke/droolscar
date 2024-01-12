# Droolscar [![git-consistent friendly](https://img.shields.io/badge/git--consistent-friendly-brightgreen.svg)](https://github.com/isuke/git-consistent)

![](https://raw.githubusercontent.com/isuke/droolscar/images/image1.png)

**Droolscar** is zsh theme.

You need to set [Powerline](https://github.com/powerline/powerline) font.
The following fonts are recommended for Japanese.

- [白源 (はくげん／HackGen)](https://github.com/yuru7/HackGen)
- [PlemolJP](https://github.com/yuru7/PlemolJP)


## Features

![](https://raw.githubusercontent.com/isuke/droolscar/images/features.png)

### user id

Show user id.

### dir path

Show current directory path.

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

If exist background job, show `✱` mark.

## Usage

### By [zplug](https://github.com/zplug/zplug)

.zshrc
```sh
zplug "isuke/droolscar", as:theme
```

### By [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)

TODO

### Plain

```sh
$ git clone git@github.com:isuke/droolscar.git
$ source droolscar/droolscar.zsh-theme
```

## Options

| Environment Variable          | Default Value       | Description                         |
| ----------------------------- | ------------------- | ----------------------------------- |
| `DROOLSCAR_DATE_FORMAT`       | `"+%m/%d %H:%M:%S"` | current date time format.           |
| `DROOLSCAR_SEGMENT_SEPARATOR` | `""` (U+E0B0)      | separate character of each segment. |

### Recommended Separator Characters

- `""` (U+E0B0)
- `""` (U+E0C0)
- `""` (U+E0C8)
- `""` (U+E0B8)
- `""` (U+E0BC)
- `""` (U+E0B4)
