#!/bin/bash
#
# A utility script to taint/untaint arbitrary resources in terraform.
#
# Author: Can Bayburt <cbbayburt@suse.com>
#
# Usage:
#   recreate [-u|--undo] [-f|--filter <filter>] [-s|--state <tfstate file>] [<resource>...]

RESOURCES=()
while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        -u|--undo)
            UNDO=1
            shift
            ;;
        -f|--filter)
            FILTER="$2"
            shift
            shift
            ;;
        -s|--state)
            STATEPATH="$2"
            shift
            shift
            ;;
        *)
            RESOURCES+=("$1")
            shift
            ;;
    esac
done
set -- "${RESOURCES[@]}"

# Process undo option
if [ -n "$UNDO" ]
then
    CMD=untaint
else
    CMD=taint
fi

# Process state option
if [ -n "$STATEPATH" ]
then
    STATEOPT="-state=$STATEPATH"
fi

# Process resource array
# Probe all resources if the array is empty
if [ ${#RESOURCES[@]} -eq 0 ]
then
    RESOURCES=($(terraform state list | grep "^module\..*\.libvirt_domain.domain$" | cut -d. -f2,4 | sed s/.domain// ))
fi

# Perform taint/untaint
for RES in ${RESOURCES[@]}
do
    if [[ $RES = *"$FILTER"* ]]
    then
        terraform $CMD -module $RES $STATEOPT libvirt_domain.domain && \
        terraform $CMD -module $RES $STATEOPT libvirt_volume.main_disk
    fi
done
