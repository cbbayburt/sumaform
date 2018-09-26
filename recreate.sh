#!/bin/bash
#
# Author: Can Bayburt <cbbayburt@suse.com>
#
#
# Usage: recreate [OPTION]... [MODULE]...
#
# A utility script to taint/untaint/destroy arbitrary resources in terraform.
# By default, the script operates on every module defined in the state file.
#
#   -d, --destroy              destroy the modules completely
#   -u, --undo                 untaint previously tainted resources
#   -f, --filter STR           operate only on modules matched by STR
#   -s, --state FILE           use FILE tfstate file to read from / write to
#                                (the default is 'terraform.tfstate')
#       --force-destroy        add '--force' option to Terraform's destroy
#                                command (only used with -d option)
#

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
    MODULES=($( terraform state list | grep "^module\..*\..*\(domain\)\|\(main_disk\)$" | cut -d. -f2 | sort -u ))
fi

# Perform destroy
if [ -n "$DESTROY" ]
then
    if [ ${#MODULES[@]} -eq 0 ]
    then
        echo "Nothing to destroy." && exit
    fi

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
        MODNAME=$(terraform state list module.$MOD | head -n1 | cut -d. -f2,4 | sed -r s/\.\(main_disk\)\|\(domain\)//)
        echo $MODNAME
        terraform $CMD -module $MODNAME $STATEOPT libvirt_domain.domain; \
        terraform $CMD -module $MODNAME $STATEOPT libvirt_volume.main_disk
    fi
done
