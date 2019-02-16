#!/bin/bash
# DESCRIPTION: <target> <alternativeSSHKey> Run ansible on aws / vagrant / demoserver.

# INPUT DATA
TARGET=$1
ALTERNATIVE_SSH_KEY=$2
ENVIRONMENT=""

# Warn if CIRLCE_TOKEN is empty
if [[ $CIRLCE_TOKEN == "" ]]; then
    echo "WARNING: CIRLCE_TOKEN is not set. Without it we might not be able to fetch artifacts from builds!"
fi

case $TARGET in
    demoserver)
        TARGET_HOST_FILE=./hosts/hosts_demoserver_ovh
        SSH_KEY=$HOME/.ssh/id_rsa               # Use default ssh key
        ENVIRONMENT="demoserver"
    ;;
    aws)
        TARGET_HOST_FILE=./hosts/hosts_aws
        SSH_KEY=$HOME/.ssh/id_rsa               # Use default ssh key
        ENVIRONMENT="aws"
    ;;
    vagrant)
        TARGET_HOST_FILE=/vagrant/hosts/hosts_vagrant
        ENVIRONMENT="dev"
        # To avoid installing docker or ansible on dev machine we run ansible directly inside vagrant
        vagrant ssh -c "CIRLCE_TOKEN=$CIRLCE_TOKEN;TOMCAT_USER_PASSWORD=$TOMCAT_USER_PASSWORD;ENVIRONMENT=$ENVIRONMENT ansible-playbook /vagrant/site.yml -v -i $TARGET_HOST_FILE"
        exit 0
    ;;
    *)
    echo "Please provide a target. Possible values: aws, vagrant"
    exit 1
esac

# Give option to provide different SSH_KEY
if [[ ! $ALTERNATIVE_SSH_KEY == "" ]]; then
    echo "Using SSH key: $ALTERNATIVE_SSH_KEY"
    SSH_KEY="$ALTERNATIVE_SSH_KEY"
fi

# Make a SSH test connection if we are not using vagrant
HOST_PORT=`cat $TARGET_HOST_FILE | grep -A 1 mainserver | grep -v mainserver`
HOST=`echo $HOST_PORT | sed -n -E 's/([a-zA-Z0-9\.]*):?.*/\1/p'`
PORT=`echo $HOST_PORT | sed -n -E 's/.*:(.*)/\1/p'`
USER=`cat $TARGET_HOST_FILE | sed -n -E 's/ansible_user=(.*)/\1/p'`
if [[ ! $PORT == "" ]]; then
    SSH_PORT="-P$PORT"
fi
SSH_ARGS="$SSH_PORT -i $SSH_KEY  $USER@$HOST exit;"
ssh $SSH_ARGS
if [[ $? -ne 0 ]]; then
    echo "Test connection to AWS host failed (exit code=$?): ssh $SSH_ARGS"
    echo "Provide path to ssh key as second param."
    exit 1;
fi

# Check if ansible image was already built
docker inspect --type=image docker-ansible-runner &>/dev/null
if [[ $? -eq 1 ]]; then
    echo "Please build docker image first: docker build -t docker-ansible-runner docker-ansible-runner"
    exit 1;
fi

docker run --rm -it \
  -v $SSH_KEY:/root/.ssh/id_rsa \
  -v /var/log/ansible/ansible.log \
  -v $(pwd):/ansible/playbooks \
  -e CIRLCE_TOKEN=$CIRLCE_TOKEN \
  -e TOMCAT_USER_PASSWORD=$TOMCAT_USER_PASSWORD \
  -e ENVIRONMENT=$ENVIRONMENT \
  docker-ansible-runner site.yml  -v -i $TARGET_HOST_FILE




