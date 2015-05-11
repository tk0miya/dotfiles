#!/bin/sh

if [ `hostname` = "deneb" ]; then
    REGULAR_PYTHON_VERSIONS="2.7.9 2.5.6 2.6.9 3.2.6 3.3.6 3.4.2"
elif [ `hostname` = "capella" ]; then
    REGULAR_PYTHON_VERSIONS="2.7.9 3.4.2"
else
    REGULAR_PYTHON_VERSIONS="2.7.9"
fi

mkdir -p $HOME/bin

if [ `uname -s` = "Darwin" ]; then
    echo ""
    echo "Setup Homebrew ..."
    if [ -x /usr/local/bin/brew ]; then
        (cd `brew --prefix` && git pull origin master)
    else
        ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
    fi

    brew tap homebrew/boneyard
    brew bundle
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
echo "Setup zsh ..."
curl -L -o _zsh/completion/_git https://raw.github.com/git/git/master/contrib/completion/git-completion.zsh
curl -L -o _zsh/completion/git-completion.bash https://raw.github.com/git/git/master/contrib/completion/git-completion.bash
curl -L -o _zsh/completion/_hub https://raw.githubusercontent.com/github/hub/master/etc/hub.zsh_completion

echo ""
echo "Setup vim extensions ..."
_vim/bundle/neobundle.vim/bin/neoinstall

echo ""
echo "Setup rbenv ..."
if [ -d $HOME/.rbenv ]; then
    (cd $HOME/.rbenv && git pull)
    (cd $HOME/.rbenv/plugins/ruby-build && git pull)
    (cd $HOME/.rbenv/plugins/rbenv-ctags && git pull)
else
    git clone https://github.com/sstephenson/rbenv $HOME/.rbenv
    git clone https://github.com/sstephenson/ruby-build $HOME/.rbenv/plugins/ruby-build
    git clone https://github.com/tpope/rbenv-ctags $HOME/.rbenv/plugins/rbenv-ctags

    PATH=$HOME/.rbenv/bin:$PATH
    eval "$(rbenv init -)"
fi
for version in 1.9.3-p550 2.2.1; do
    if [ ! -d "$HOME/.rbenv/versions/$version" ]; then
        rbenv install $version
    fi
done
rbenv global 2.2.1
gem install bundler gist refe2
gem update
bitclust update

echo ""
echo "Setup pyenv ..."
if [ -d $HOME/.pyenv ]; then
    (cd $HOME/.pyenv && git pull)
    (cd $HOME/.pyenv/plugins/python-virtualenv && git pull)
else
    git clone git://github.com/yyuu/pyenv.git $HOME/.pyenv
    git clone git://github.com/yyuu/python-virtualenv.git $HOME/.pyenv/plugins/python-virtualenv

    PATH=$HOME/.pyenv/bin:$PATH
    eval "$(pyenv init -)"
fi
for version in $REGULAR_PYTHON_VERSIONS; do
    if [ ! -d "$HOME/.pyenv/versions/$version" ]; then
        pyenv install $version
    fi
done
pyenv global $REGULAR_PYTHON_VERSIONS

echo ""
echo "Setup plenv ..."
if [ -d $HOME/.plenv ]; then
    (cd $HOME/.plenv && git pull)
    (cd $HOME/.plenv/plugins/perl-build && git pull)
else
    git clone https://github.com/tokuhirom/plenv $HOME/.plenv
    git clone https://github.com/tokuhirom/Perl-Build $HOME/.plenv/plugins/perl-build

    PATH=$HOME/.plenv/bin:$PATH
    eval "$(plenv init -)"
fi
for version in 5.21.5; do
    if [ ! -d "$HOME/.plenv/versions/$version" ]; then
        plenv install $version -Dusethreads
        plenv global $version
        plenv install-cpanm
    fi
done
plenv global 5.21.5

echo ""
echo "Setup ndenv ..."
if [ -d $HOME/.ndenv ]; then
    (cd $HOME/.ndenv && git pull)
    (cd $HOME/.ndenv/plugins/node-build && git pull)
else
    git clone https://github.com/riywo/ndenv $HOME/.ndenv
    git clone https://github.com/riywo/node-build.git $HOME/.ndenv/plugins/node-build

    PATH=$HOME/.ndenv/bin:$PATH
    eval "$(ndenv init -)"
fi
for version in v0.10.28; do
    if [ ! -d "$HOME/.ndenv/versions/$version" ]; then
        ndenv install $version
    fi
done
ndenv global v0.10.28

echo ""
echo "Setup $HOME/bin ..."
if [ ! -d $HOME/bin ]; then
    mkdir -p $HOME/bin
fi

echo ""
echo "Setup python environments ..."
if [ ! -e $HOME/.pip ]; then
    echo "Creating $HOME/.pip ..."
    ln -s "$PWD/_pip" $HOME/.pip
fi
pip install --upgrade setuptools
pip install --upgrade pip mercurial detox flake8 diff-highlight wheel docutils

echo ""
echo "Setup hg extensions ..."
if [ -d _hgext/hgbb ]; then
    (cd _hgext/hgbb && hg update)
else
    (cd _hgext && hg clone https://bitbucket.org/birkenfeld/hgbb)
fi

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
