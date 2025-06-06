#!/bin/sh

cd `dirname ${0}`/..  # Move dotfiles directory

# fetch the latest dotfiles (if cached)
git checkout .; git pull

rm -f $HOME/.zshrc  # Remove .zshrc generated by features/common-utils
sudo rm -f /etc/apt/apt.conf.d/docker-clean  # Remove this file to make apt cache mechanism available

sudo apt update
sudo apt install -y git jq less vim zsh

if [ ! -e /usr/share/doc/git/contrib/diff-highlight/diff-highlight ]; then
    (cd /usr/share/doc/git/contrib/diff-highlight; make)
fi
if [ ! -e /usr/local/bin/diff-highlight ]; then
    ln -s /usr/share/doc/git/contrib/diff-highlight/diff-highlight /usr/local/bin/diff-highlight
fi

if [ ! -e /usr/bin/pbcopy ]; then
    curl -s -L https://github.com/tk0miya/rpbcopyd/releases/download/v1.0.0/rpbcopy-v1.0.0-`uname -m`-unknown-linux-musl -o /tmp/pbcopy
    curl -s -L https://github.com/tk0miya/rpbcopyd/releases/download/v1.0.0/rpbpaste-v1.0.0-`uname -m`-unknown-linux-musl -o /tmp/pbpaste
    sudo install -m 755 /tmp/pbcopy /tmp/pbpaste /usr/bin
fi

echo ""
echo "Setup \$HOME/bin ..."
ln -s $PWD/bin $HOME/bin

if [ ! -z $GIT_EMAIL ]; then
    echo ""
    echo "Setup .gitconfig ..."
    cp $PWD/_gitconfig $HOME/.gitconfig
    echo '[user]' >> $HOME/.gitconfig
    echo '    email = ' $GIT_EMAIL >> $HOME/.gitconfig

    # bullseye does not support "autocorrect = prompt"
    if grep bullseye /etc/os-release > /dev/null; then
        sed -i -e 's/autocorrect = prompt/autocorrect = 1/' ~/.gitconfig
    fi
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

echo ""
echo "Setup vim extensions ..."
vim -N -u $HOME/.vimrc -c 'call dein#update()' -c 'qall!' -U NONE -i NONE -V1 -e -s

