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
