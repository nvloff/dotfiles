#!/bin/sh
if  [ ! -d $HOME/.mutt ]; then
        mkdir ~/.mutt
fi

if [ ! -d ~/.mutt/config ]; then
        mkdir $HOME/.mutt/config
fi

if [ ! -d ~/.mutt/config ]; then
        mkdir $HOME/.mutt/config
fi

if [ ! -d ~/.mutt/cache ]; then
        mkdir $HOME/.mutt/config
fi

if [ ! -a ~/.mutt/alias ]; then
        touch $HOME/.mutt/alias
fi

cp muttrc $HOME/muttrc
cp config/muttrc_bindings_generic $HOME/.mutt/config/
cp config/muttrc_bindings_gmail $HOME/.mutt/config/
cp config/muttrc_colors $HOME/.mutt/config/
cp config/muttrc_goobook $HOME/.mutt/config/

echo "DONE"

