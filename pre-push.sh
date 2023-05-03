#!/bin/bash
echo “Running pre-push hook”
fastlane tests
if [ $? -ne 0 ]; then
 echo “Tests must pass before commit!”
 exit 1
fi