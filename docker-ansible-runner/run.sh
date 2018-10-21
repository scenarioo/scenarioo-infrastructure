#!/bin/bash
# Wrapper to correct permissions of .ssh folder and files
chmod 700 /root/.ssh
chmod 600 /root/.ssh/*

if [[ -f requirements.yml ]]; then
   ansible-galaxy install -r requirements.yml
fi
ansible-playbook "$@"