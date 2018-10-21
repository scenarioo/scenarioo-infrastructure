#!/bin/bash
# Helper to run Ansible on Vagrant box
docker run --rm -it \
  -v /Users/chrgro/.ssh/aws_zuehlke.pem:/root/.ssh/id_rsa \
  -v /var/log/ansible/ansible.log \
  -v $(pwd):/ansible/playbooks \
  -e CIRLCE_TOKEN=$CIRLCE_TOKEN \
  -e TOMCAT_USER_PASSWORD=$TOMCAT_USER_PASSWORD \
  docker-ansible-runner site.yml -i ./ansible/hosts_aws