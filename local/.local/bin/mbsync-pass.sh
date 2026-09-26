#!/bin/sh
# ~/.local/bin/mbsync-pass.sh
cat ~/.authinfo | \
  sed -n "/^machine $1 login $2/ s/.*password \"\([^\"]*\)\".*/\1/p"
