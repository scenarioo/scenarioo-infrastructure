#!/bin/bash
# Helper to run Ansible on Vagrant box
docker run --rm -it \
  -v $(pwd)/docker-ansible-runner/vagrant.key:/root/.ssh/id_rsa \
  -v $(pwd)/docker-ansible-runner/vagrant.pub:/root/.ssh/id_rsa.pub \
  -v /var/log/ansible/ansible.log \
  -v $(pwd):/ansible/playbooks \
  -e CIRLCE_TOKEN=$CIRLCE_TOKEN \
  -e TOMCAT_USER_PASSWORD=$TOMCAT_USER_PASSWORD \
  docker-ansible-runner site.yml -i ./ansible/hosts_vagrant_docker -v