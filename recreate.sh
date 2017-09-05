#!/bin/bash

terraform taint -module $1 libvirt_domain.domain && \
terraform taint -module $1 libvirt_volume.main_disk
