#!/bin/bash

# Clean DNF, remove unused packages and update 
echo 'Cleaning DNF...'
sudo dnf clean all
# echo 'Checking for duplication...'
# dnf check
# dnf check --duplicates
echo 'Autoremove unusused packages...'
sudo dnf autoremove
echo 'Update DNF...'
sudo dnf update
