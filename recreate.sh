#!/bin/bash
#
# A utility script to taint/untaint arbitrary resources in terraform.
#
# Author: Can Bayburt <cbbayburt@suse.com>
#
# Usage:
#   recreate [-d|--destroy] [-u|--undo] [-f|--filter <filter>]
#       [-s|--state <tfstate file>] [--force-destroy] [<module>...]

MODULES=()
while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        -d|--destroy)
            DESTROY=1
            shift
            ;;
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
        --force-destroy)
            FORCEOPT="-force"
            shift
            ;;
        *)
            MODULES+=("$1")
            shift
            ;;
    esac
done
set -- "${MODULES[@]}"

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

# Process module array
# Probe all resources if the array is empty
if [ ${#MODULES[@]} -eq 0 ]
then
    MODULES=($( terraform state list | grep "^module\..*\.libvirt_domain.domain$" | cut -d. -f2 ))
fi

# Perform destroy
if [ -n "$DESTROY" ]
then
    DESTROY_TARGETS=()
    for MOD in ${MODULES[@]}
    do
        if [[ $MOD = *"$FILTER"* ]]
        then
            DESTROY_TARGETS+=("-target module.$MOD")
        fi
    done

    terraform destroy ${DESTROY_TARGETS[@]} $STATEOPT $FORCEOPT
    exit
fi

# Perform taint/untaint
for MOD in ${MODULES[@]}
do
    if [[ $MOD = *"$FILTER"* ]]
    then
        MODNAME=$(terraform state list module.$MOD | head -n1 | cut -d. -f2,4 | sed s/\.domain//)
        echo $MODNAME
        terraform $CMD -module $MODNAME $STATEOPT libvirt_domain.domain && \
        terraform $CMD -module $MODNAME $STATEOPT libvirt_volume.main_disk
    fi
done
