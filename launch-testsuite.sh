#!/bin/bash

# TODO: Add state file path option
# TODO: Add option: --core-only

if [ -z "$(terraform show | grep module\\.)" ]
then
    terraform init
else
    ./recreate.sh
fi

terraform get
terraform apply

CTRL_NAME=$(terraform state show $(terraform state list | grep controller.libvirt_domain) |\
    grep ^name | sed -r s/\\s+//g | cut -d= -f2)
CTRL_FQDN=$CTRL_NAME.tf.local

ssh-keygen -R $CTRL_FQDN
ssh-keyscan $CTRL_FQDN >> ~/.ssh/known_hosts

ssh root@$CTRL_FQDN screen -d -m run-testsuite

echo "Testsuite run is started in a screen session."
echo "Run 'ssh -t root@$CTRL_FQDN screen -r' to attach to it."
