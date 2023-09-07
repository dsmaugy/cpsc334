#!/bin/bash


cd /home/student334/cpsc334/rasberrypi

hostname -I >> ip.md

git add ip.md
git commit -m "IP Update"
git push
