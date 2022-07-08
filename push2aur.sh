#!/usr/bin/env bash

set -e

if [[ ! -d "$1" ]]; then
  echo "ERR: Directory '$1' does not exists."
  exit 1
fi

rm -rf /tmp/aur-$1

git clone ssh://aur@aur.archlinux.org/$1.git /tmp/aur-$1
git clean -xf $1
cp -r $1/* /tmp/aur-$1
git -C /tmp/aur-$1 add /tmp/aur-$1/*

old_wd=$(pwd)
cd /tmp/aur-$1
makepkg --printsrcinfo > /tmp/aur-$1/.SRCINFO
cd "$old_wd"
git -C /tmp/aur-$1 add /tmp/aur-$1/.SRCINFO

git -C /tmp/aur-$1 commit
git -C /tmp/aur-$1 push
