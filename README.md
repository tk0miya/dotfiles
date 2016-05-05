# dotfiles

## for MacOS

```
$ chsh -s /bin/zsh
$ ssh-keygen -b 4096
$ xcode-select --install
$ hash -r
$ git clone http://github.com/tk0miya/dotfiles $HOME/.dotfiles
$ cd $HOME/.dotfiles
$ git remote set-url origin git@github.com:tk0miya/dotfiles.git
$ exec zsh
$ sh setup.sh
$ exec zsh
$ sh setup.sh
```

### Manually settings

iTerm2
------

In `[Preferences] > [General]`, put `/path/to/.iTerm2` to custom folder for preferences
