#!/bin/sh
# ~/.local/bin/mbsync-pass.sh
gpg -q --for-your-eyes-only --no-tty -d ~/.authinfo.gpg | \
  sed -n "/^machine $1 login $2/ s/.*password \"\([^\"]*\)\".*/\1/p"
