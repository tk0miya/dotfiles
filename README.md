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

1. On the old machine, Run "Export All Settings and Data" at `[Settings] > [General] > [Settings]`.
2. On the new machine, Run "Import All Settings and Data" at `[Settings] > [General] > [settings]`.
