#!/bin/sh
sudo mkdir -p /command/
export PATH=/command/:$PATH:`pwd`
sudo mkdir -p /usr/local/package
sudo ln -sfv /usr/local/package /
sudo chmod +t /package/.
sudo mkdir -p /usr/local/src/package
sudo chown $USER /usr/local/src/package
sudo chown $USER /usr/local/package
sudo chown $USER /command

