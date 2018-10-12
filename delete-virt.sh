#!/bin/bash
#
# Author: Can Bayburt <cbbayburt@suse.com>
#
#
# Usage: delete-virt PREFIX
#
# A utility script to remove multiple VMs and volumes by specifying a prefix.
# Remember to delete terraform.tfstate file afterwards for a fresh start.
#
#   PREFIX     the name prefix of the VMs
#

CONNSTR="qemu:///system"
POOL="default"
PREFIX=$1

if [ -z $PREFIX ]
then
    echo "No prefix specified.";
    exit;
fi

for f in `virsh -c $CONNSTR vol-list default | grep $PREFIX | sed -r s/\\\s+/' '/g | sed s/^' '// | cut -d' ' -f1`; do virsh -c $CONNSTR vol-delete --pool $POOL $f; done;

for f in `virsh -c $CONNSTR list --all | grep $PREFIX | sed -r s/\\\s+/' '/g | sed s/^' '// | cut -d' ' -f2`; do virsh -c $CONNSTR undefine $f; done;

for f in `virsh -c $CONNSTR list --all | grep $PREFIX | sed -r s/\\\s+/' '/g | sed s/^' '// | cut -d' ' -f2`; do virsh -c $CONNSTR shutdown $f; done;
