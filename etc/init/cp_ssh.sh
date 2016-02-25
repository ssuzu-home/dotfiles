#!/bin/bash

trap 'echo Error: $0: stopped; exit 1' ERR INT
set -eu

. $DOTPATH/etc/lib/vital.sh
. $DOTPATH/etc/lib/standard.sh

cd ~/.dotfiles
if [[ ! -d ../.ssh ]] ; then
  mkdir ../.ssh
fi
cp -a .ssh ../.ssh
