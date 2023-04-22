#!/bin/sh

cd $(dirname $0)
./rss.sh "$@"
sudo shutdown +0
