#!/bin/bash
#
# A utility script to create/reset required resources
# and launch the testsuite afterwards.
#
# Author: Can Bayburt <cbbayburt@suse.com>
#
# Usage:
#   launch-testsuite [-c|--core-only] [-s|--state <tfstate file>]
#
# TODO:
#   - Implement option: --core-only
#   - Break if a command fails

while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        -c|--core-only)
            CORE_ONLY=1
            shift
            ;;
        -s|--state)
            STATEPATH="$2"
            shift
            shift
            ;;
    esac
done

if [ -n "$STATEPATH" ]
then
    TFSTATEARG="-state=$STATEPATH"
    STATEARG="-s $STATEPATH"
    STATEDIR=$(dirname $STATEPATH)
fi

# Initialize terraform if running for the first time
if [ ! -f $STATEPATH ]
then
    terraform init $STATEDIR
else
    if [ -z "$(terraform show $STATEPATH | grep module\\.)" ]
    then
        terraform init $STATEDIR
    else
        ./recreate.sh $STATEARG
    fi
fi

terraform get
terraform apply $TFSTATEARG

CTRL_NAME=$(terraform state show $TFSTATEARG $(terraform state list $TFSTATEARG | grep controller.libvirt_domain) |\
    grep ^name | sed -r s/\\s+//g | cut -d= -f2)
CTRL_FQDN=$CTRL_NAME.tf.local

ssh-keygen -R $CTRL_FQDN
ssh-keyscan $CTRL_FQDN >> ~/.ssh/known_hosts

ssh root@$CTRL_FQDN screen -d -m run-testsuite

echo "Testsuite run is started in a screen session."
echo "Run 'ssh -t root@$CTRL_FQDN screen -r' to attach to it."
