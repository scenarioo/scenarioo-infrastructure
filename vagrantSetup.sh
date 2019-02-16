#!/bin/bash
echo
echo
echo "INSTALLING: jq, bats & ansible ... (may take a minute)"

# Install jq, bats and ansible in vagrant VM
apt-get -y update > /dev/null
apt-get install -y jq bats libffi-dev libssl-dev python-pip > /dev/null

pip install 'ansible==2.5.0' > /dev/null

echo
echo "Vagrant VM ready. To deploy demoserver with ansible execute:"
echo
echo "  ./infra.sh runAnsible vagrant"
echo