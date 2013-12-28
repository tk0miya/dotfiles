#!/bin/sh

echo ""
echo "Setup hg extensions ..."
if [ -d _hgext/hgbb ]; then
    (cd _hgext/hgbb && hg update)
else
    (cd _hgext && hg clone https://bitbucket.org/birkenfeld/hgbb)
fi

echo ""
echo "Setup vim extensions ..."
if [ -d _vim/bundle/neobundle.vim ]; then
    (cd _vim/bundle/neobundle.vim  && git pull)
else
    git clone https://github.com/Shougo/neobundle.vim _vim/bundle/neobundle.vim
fi

echo ""
echo "Setup rbenv ..."
if [ -d $HOME/.rbenv ]; then
    (cd $HOME/.rbenv && git pull)
    (cd $HOME/.rbenv/plugins/ruby-build && git pull)
else
    git clone https://github.com/sstephenson/rbenv $HOME/.rbenv
    git clone https://github.com/sstephenson/ruby-build $HOME/.rbenv/plugins/ruby-build

    PATH=$HOME/.rbenv/bin:$PATH
    eval "$(rbenv init -)"
fi
for version in 1.9.3-p484 2.1.0; do
    if [ ! -d "$HOME/.rbenv/versions/$version" ]; then
        rbenv install $version
    fi
done
rbenv global 2.1.0

echo ""
echo "Setup $HOME/bin ..."
if [ ! -d $HOME/bin ]; then
    mkdir -p $HOME/bin
fi

echo ""
echo "Setup python environments ..."
if [ ! -d $HOME/bin/python ]; then
    virtualenv $HOME/bin/python
fi
$HOME/bin/python/bin/pip install --upgrade pip mercurial detox flake8 hub diff-highlight

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
