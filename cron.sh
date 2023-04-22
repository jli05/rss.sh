#!/bin/sh

cd $(dirname $0)
./rss.sh -2d
sudo shutdown +0
