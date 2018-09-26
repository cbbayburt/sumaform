#!/bin/bash
#
# Author: Can Bayburt <cbbayburt@suse.com>
#
#
# Usage: launch-testsuite [OPTION]...
#
# A utility script to create/reset required resources and launch the testsuite
# when the resources are ready. Unless the --keep option is set, all resources
# are destroyed after the run. Therefore, the script can be run consequently.
#
#   -c, --core-only            only run the core features
#   -s, --state FILE           tfstate file to read from / write to (if the file
#                                does not exist, a new one will be created)
#       --spacewalk-dir DIR    compile and deploy the java application in the
#                                spacewalk repository DIR with ant prior
#                                to the test run. Useful to test fixes
#                                on-the-fly
#       --keep                 just taint and keep the resources instead of
#                                destroying them after the test run. Useful for
#                                post-mortem debugging
#   -o, --output-dir DIR       store the generated Cucumber log files in DIR
#                                (the default is the current directory)
#
# TODO:
#   - Break if a command fails

OUTPUTDIR=.

while [[ $# -gt 0 ]]
do key="$1"
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
        --spacewalk-dir)
            SPACEWALKDIR="$2"
            shift
            shift
            ;;
        -o|--output-dir)
            OUTPUTDIR="$2"
            shift
            shift
            ;;
        --keep)
            KEEP=1
            shift
            ;;
    esac
done

if [ -n "$STATEPATH" ]
then
    TFSTATEARG="-state=$STATEPATH -state-out=$STATEPATH"
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
    fi
fi

terraform get
terraform apply $TFSTATEARG

if [ -n "$SPACEWALKDIR" ]
then
    sleep 10

    SRV_NAME=$(terraform state show $TFSTATEARG $(terraform state list $TFSTATEARG | grep suse_manager.libvirt_domain) |\
        grep ^name | sed -r s/\\s+//g | cut -d= -f2)
    SRV_FQDN=$SRV_NAME.tf.local
    ssh-keygen -R $SRV_FQDN
    ssh-keyscan $SRV_FQDN >> ~/.ssh/known_hosts

    # Deploy java
    CURDIR=$(pwd)
    cd $SPACEWALKDIR/java
    ant -f manager-build.xml -Dprecompiled=true -Ddeploy.host=$SRV_FQDN refresh-branding-jar deploy

    sleep 120

    cd $CURDIR
fi

CTRL_NAME=$(terraform state show $TFSTATEARG $(terraform state list $TFSTATEARG | grep controller.libvirt_domain) |\
    grep ^name | sed -r s/\\s+//g | cut -d= -f2)
CTRL_FQDN=$CTRL_NAME.tf.local
CTRL_IP=$(getent hosts $CTRL_FQDN | awk '{ print $1 }')

ssh-keygen -R $CTRL_FQDN
ssh-keygen -R $CTRL_IP
ssh-keyscan $CTRL_FQDN >> ~/.ssh/known_hosts
ssh-keyscan $CTRL_IP >> ~/.ssh/known_hosts

# Remove non-core features from the run set
if [ -n "$CORE_ONLY" ]
then
    ssh root@$CTRL_FQDN sed -i /core_.*\.feature/\!d spacewalk/testsuite/run_sets/testsuite.yaml
fi

# Run the testsuite
ssh -t root@$CTRL_FQDN run-testsuite

# Download output files
scp root@$CTRL_FQDN:/root/spacewalk/testsuite/output.html $OUTPUTDIR/output-$(date +%Y-%m-%d-%H-%M-%S).html
scp root@$CTRL_FQDN:/root/spacewalk/testsuite/spacewalk-debug.tar.bz2 $OUTPUTDIR/spacewalk-debug-$(date +%Y-%m-%d-%H-%M-%S).tar.bz2

# Cleanup: destroy resources
if [ -z "$KEEP" ]
then
    ./recreate.sh $STATEARG -d --force-destroy
else
    # Just taint all resources
    ./recreate.sh $STATEARG
fi
