{% if grains.get('roles') is not none and 'build_host' in grains.get('roles') and grains.get('sles_registration_code') and grains.get('osrelease') is not none and '15' in grains.get('osrelease') %}

register_sles_server:
   cmd.run:
     - name: SUSEConnect --url https://scc.suse.com -r {{ grains.get("sles_registration_code") }} -p SLES/{{ grains.get('osrelease') }}/x86_64

basesystem_activation:
   cmd.run:
     - name: SUSEConnect -p sle-module-basesystem/{{ grains.get('osrelease') }}/x86_64

containers_activation:
   cmd.run:
     - name: SUSEConnect -p sle-module-containers/{{ grains.get('osrelease') }}/x86_64

desktop_activation:
   cmd.run:
     - name: SUSEConnect -p sle-module-desktop-applications/{{ grains.get('osrelease') }}/x86_64

devel_activation:
   cmd.run:
     - name: SUSEConnect -p sle-module-development-tools/{{ grains.get('osrelease') }}/x86_64

{% endif %}
