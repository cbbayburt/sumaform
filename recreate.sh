#!/bin/bash

if [ "$1" = "-u" -o "$1" = "--undo" ]
then
    CMD=untaint
    RESOURCES=$2
else
    CMD=taint
    RESOURCES=$1
fi

if [ -z $RESOURCES ]
then
# Only test:    RESOURCES=$(terraform state list | grep "module\..*\-test\." | cut -d. -f 2,4 | sort -u)
    RESOURCES=$(terraform state list | grep "^module\..*\.libvirt_domain.domain$" | cut -d. -f2,4)
fi

for RES in $RESOURCES
do
    terraform $CMD -module $RES libvirt_domain.domain && \
    terraform $CMD -module $RES libvirt_volume.main_disk
done


# TODO: Better argument parsing and recreate all
# (when no resource names given) option
# recreate [-u|--undo] [-f|--filter FILTER] [resource [...]]
