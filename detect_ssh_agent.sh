#!/bin/bash
# Detects a running SSH agent and sets up the environment such that it is used
# Use it as follows in BASH: . detect_ssh_agent.sh
#
# Author:  Stephan Diestelhorst <stephan.diestelhorst@gmail.com>
# Date:    2015-08-15
# License: MIT
#
SSH_AGENT_PID=$(pgrep -u $USER ssh-agent)
if [ "x$SSH_AGENT_PID" = "x" ]; then
    echo SSH Agent not found.
    exit -1;
fi
T=$((SSH_AGENT_PID - 1 ))
SSH_AUTH_SOCK=$(ls /tmp/ssh-*/agent.$T|head -n1)
echo "export SSH_AGENT_PID=$SSH_AGENT_PID"
echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK"
