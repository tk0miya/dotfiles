#!/bin/sh

if [ `hostname` = "deneb.local" ]; then
    REGULAR_PYTHON_VERSIONS="2.7.13 2.6.9 3.6.0 3.5.2 3.4.5 3.3.6"
elif [ `hostname` = "capella" ]; then
    REGULAR_PYTHON_VERSIONS="2.7.13 3.6.0 3.5.2"
else
    REGULAR_PYTHON_VERSIONS="2.7.13"
fi

mkdir -p $HOME/bin
mkdir -p $HOME/.pip/wheel

if [ `uname -s` = "Darwin" ]; then
    echo ""
    echo "Setup Homebrew ..."
    if [ -x /usr/local/bin/brew ]; then
        (cd `brew --prefix` && git pull origin master)
    else
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi

    brew tap homebrew/boneyard
    brew bundle-old
    PATH=/usr/local/bin:$PATH

    echo ""
    echo "Setup fonts ..."
    if [ ! -e "$HOME/Library/Fonts/Monaco for Powerline.otf" ]; then
        curl -L https://gist.github.com/baopham/1838072/raw/5fa73caa4af86285f11539a6b4b6c26cfca2c04b/Monaco%20for%20Powerline.otf \
            -o "$HOME/Library/Fonts/Monaco for Powerline.otf"
    fi
elif [ -e '/etc/redhat-release' ]; then
    sudo yum install curl git screen vim
    curl -LO https://github.com/github/hub/releases/download/v2.2.1/hub-linux-amd64-2.2.1.tar.gz
    tar xf hub-linux-amd64-2.2.1.tar.gz
    cp hub-linux-amd64-2.2.1/hub $HOME/bin
    rm -rf hub-linux-amd64-2.2.1*
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
vim -N -u $HOME/.vimrc -c 'qall!' -U NONE -i NONE -V1 -e -s

echo ""
echo "Setup rbenv ..."
mkdir -p _rbenv/plugins
ln -sF $PWD/lib/rbenv/plugins/ruby-build _rbenv/plugins
ln -sF $PWD/lib/rbenv/plugins/rbenv-ctags _rbenv/plugins

PATH=$HOME/.rbenv/bin:$PATH
eval "$(rbenv init -)"
for version in 1.9.3-p551 2.3.1; do
    if [ ! -d "$HOME/.rbenv/versions/$version" ]; then
        rbenv install $version
    fi
done
rbenv global 2.3.1
gem install bundler gist refe2 rubocop
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
echo "Setup plenv ..."
mkdir -p _plenv/plugins
ln -sF $PWD/lib/plenv/plugins/perl-build _plenv/plugins

PATH=$HOME/.plenv/bin:$PATH
eval "$(plenv init -)"
for version in 5.23.9; do
    if [ ! -d "$HOME/.plenv/versions/$version" ]; then
        plenv install $version -Dusethreads
        plenv install-cpanm
    fi
done
plenv global 5.23.9

echo ""
echo "Setup ndenv ..."
mkdir -p _ndenv/plugins
ln -sF $PWD/lib/ndenv/plugins/node-build _ndenv/plugins

PATH=$HOME/.ndenv/bin:$PATH
eval "$(ndenv init -)"
for version in v0.12.9 v6.1.0; do
    if [ ! -d "$HOME/.ndenv/versions/$version" ]; then
        ndenv install $version
    fi
done
ndenv global v6.1.0

echo ""
echo "Setup python environments ..."
pip install --upgrade setuptools
pip install --upgrade pip mercurial detox flake8 diff-highlight wheel docutils

echo ""
echo "Setup hg extensions ..."
if [ -d _hgext/hgbb ]; then
    (cd _hgext/hgbb && hg update)
else
    (cd _hgext && hg clone https://bitbucket.org/seanfarley/hgbb)
fi

echo ""
echo "Setup go environments ..."
go get -u github.com/golang/lint/golint
go get -u github.com/nsf/gocode
