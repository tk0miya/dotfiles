#!/bin/sh

if [ `hostname` = "tarf.localdomain" -o `hostname` = "Alrescha.local" ]; then
    REGULAR_PYTHON_VERSIONS="3.12.5 3.11.10 3.10.15 3.9.20"
else
    REGULAR_PYTHON_VERSIONS="3.12.5"
fi

mkdir -p $HOME/bin
mkdir -p $HOME/.pip/wheel

if [ ! -z $CODESPACES ]; then
    exec .github/install.sh
elif [ `uname -s` = "Darwin" ]; then
    echo ""
    echo "Setup Homebrew ..."
    if [ ! -x /usr/local/bin/brew ]; then
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi

    brew update
    brew upgrade
    brew bundle
    brew cu -a -y
    brew cleanup
    PATH=/usr/local/bin:$PATH

    echo ""
    echo "Setup fonts ..."
    if [ ! -e "$HOME/Library/Fonts/Monaco for Powerline.otf" ]; then
        curl -L https://gist.github.com/baopham/1838072/raw/5fa73caa4af86285f11539a6b4b6c26cfca2c04b/Monaco%20for%20Powerline.otf \
            -o "$HOME/Library/Fonts/Monaco for Powerline.otf"
    fi

    echo ""
    echo "Setup VSCode (vim plugin) ..."
    defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
elif [ -e '/etc/redhat-release' ]; then
    sudo yum install curl git screen vim
    curl -LO https://github.com/github/hub/releases/download/v2.11.1/hub-linux-amd64-2.11.1.tgz
    tar xf hub-linux-amd64-2.11.1.tgz
    cp hub-linux-amd64-2.11.1/bin/hub $HOME/bin
    rm -rf hub-linux-amd64-2.11.1*
fi

echo ""
echo "Setup submodules ..."
git submodule update --init
git submodule foreach git checkout master
git submodule foreach git pull

echo ""
echo "Creating dotfile symlinks ..."
for dotfile in _?*
do
    dotname=`echo $dotfile | sed -e "s/^_/./"`
    if [ $dotfile != '..' ] && [ $dotfile != '.hg' ]; then
        if [ -L $HOME/$dotname ]; then
            cat /dev/null  # noop
        elif [ -e $HOME/$dotname ]; then
            echo "Ignore $HOME/$dotname (already exists)"
        else
            echo "Creating $HOME/$dotname ..."
            ln -s "$PWD/$dotfile" $HOME/$dotname
        fi
    fi
done

echo ""
echo "Setup zsh ..."
curl -sS -L -o _zsh/completion/_git https://raw.github.com/git/git/master/contrib/completion/git-completion.zsh
curl -sS -L -o _zsh/completion/git-completion.bash https://raw.github.com/git/git/master/contrib/completion/git-completion.bash
curl -sS -L -o _zsh/completion/_hub https://raw.githubusercontent.com/github/hub/master/etc/hub.zsh_completion

echo ""
echo "Setup vim extensions ..."
vim -N -u $HOME/.vimrc -c 'call dein#update()' -c 'qall!' -U NONE -i NONE -V1 -e -s

echo ""
echo "Setup rbenv ..."
mkdir -p _rbenv/plugins
ln -sF $PWD/lib/rbenv/plugins/ruby-build _rbenv/plugins
ln -sF $PWD/lib/rbenv/plugins/rbenv-ctags _rbenv/plugins

PATH=$HOME/.rbenv/bin:$PATH
eval "$(rbenv init -)"
for version in 2.7.5 3.1.6 3.2.4 3.3.2; do
    if [ ! -d "$HOME/.rbenv/versions/$version" ]; then
        rbenv install $version
    fi
done
rbenv global 3.3.2
gem install -N bundler ec2ssh rubocop
gem update
bitclust update

echo ""
echo "Setup pyenv ..."
PATH=$HOME/.pyenv/bin:$PATH
eval "$(pyenv init -)"
for version in $REGULAR_PYTHON_VERSIONS; do
    if [ ! -d "$HOME/.pyenv/versions/$version" ]; then
        pyenv install $version
    fi
done
pyenv global $REGULAR_PYTHON_VERSIONS

echo ""
echo "Setup nodenv ..."
PATH=$HOME/.nodenv/bin:$PATH
eval "$(nodenv init -)"
for version in 16.20.2 18.18.0 20.7.0; do
    if [ ! -d "$HOME/.nodenv/versions/$version" ]; then
        nodenv install $version
    fi
done
nodenv global 20.7.0

echo ""
echo "Setup python environments ..."
pip install --upgrade setuptools
pip install --upgrade pip babel flake8 wheel docutils docutils-stubs requests mypy tox transifex-client twine pynvim neovim types-requests types-typed-ast

echo ""
echo "Setup go environments ..."
go install golang.org/x/tools/gopls@latest

echo ""
echo "Setup misc scripts ..."
curl -sS -L -o $HOME/bin/git-blame-pr https://gist.githubusercontent.com/kazuho/eab551e5527cb465847d6b0796d64a39/raw/0556a3c9f1c95aa630d6801c6d3e25865a6e18c5/git-blame-pr.pl
chmod 755 $HOME/bin/git-blame-pr
chmod 755 $HOME/bin/git-blame-pr
ln -sF $PWD/bin/git-fixup $HOME/bin/git-fixup
