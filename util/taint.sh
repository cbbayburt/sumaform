#!/bin/bash
#
# Author: Can Bayburt <cbbayburt@suse.com>
#
#
# Usage: taint [-u|--untaint] resource [resource...]
#
# A utility script to taint/untaint arbitrary resources in terraform.
#
#   -u, --untaint  untaint previously tainted resources
#


# Get the type of a resource to call 'taint' with
function getType() {
    terraform show | grep "# module.$1.module." | head -1 |
        sed 's/^[^.]*\.[^.]*\.[^.]*\.\([^.]*\).*$/\1/'
}

# Parse args
resources=()
while [[ $# -gt 0 ]]; do
    case $1 in
        -u|--untaint)
            untaint=1
            shift
            ;;
        *)
            resources+=("$1")
            shift
            ;;
    esac
done

if [ ${#resources[@]} -eq 0 ]; then
    echo "Usage: $0 [-u|--untaint] <resource> [<resource>...]"
    exit
fi

[ -z $untaint ] && cmd=taint || cmd=untaint

# Run the command on each resource
result=0
for r in ${resources[@]}; do
    type=$(getType $r)
    if [ -z $type ]; then
        echo "Resource \"$r\" cannot be found."
    else
        echo "Marking $r ($type) as ${cmd}ed..."
        terraform $cmd module.$r.module.$type.module.host.libvirt_domain.domain[0] &&
        terraform $cmd module.$r.module.$type.module.host.libvirt_volume.main_disk[0] &&
        terraform $cmd module.$r.module.$type.module.host.null_resource.provisioning[0]
        if [ $? -eq 0 ]; then
            ((result++))
        fi
    fi
done

if [ -z $untaint ] && [ $result -gt 0 ]; then
    echo
    echo "$result resource(s) successfully tainted. Run 'terraform apply' to reset resources."
fi
