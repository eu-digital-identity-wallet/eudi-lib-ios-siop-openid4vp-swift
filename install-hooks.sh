#!/bin/bash
GIT_DIR=$(git rev-parse --git-dir)
echo "Installing hooks…"
ln -s ../../pre-push.sh $GIT_DIR/hooks/pre-push
echo “Done!”