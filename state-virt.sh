#!/bin/bash
#
# Author: Can Bayburt <cbbayburt@suse.com>
#
#
# Usage: state-virt STATE PREFIX
#
# A utility script to start/stop multiple VMs by specifying a prefix.
#
#   STATE      1 to start, 0 to shutdown
#   PREFIX     the name prefix of the VMs
#

CONNSTR="qemu:///system"
STATE=$1
PREFIX=$2

if [ -z $PREFIX ]
then
    echo "No prefix specified.";
    exit;
fi

if [ $STATE -eq 0 ]
then
    CMD="shutdown";
elif [ $STATE -eq 1 ]
then
    CMD="start";
fi

for f in `virsh -c $CONNSTR list --all | grep $PREFIX | sed -r s/\\\s+/' '/g | sed s/^' '// | cut -d' ' -f2`; do virsh -c $CONNSTR $CMD $f; done;
