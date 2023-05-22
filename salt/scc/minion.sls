{% if ( grains.get('roles') is not none and 'minion' in grains.get('roles') or grains.get('roles') is not none and 'sshminion' in grains.get('roles') ) and grains.get('sles_registration_code') and grains.get('osrelease') is not none and '15' in grains.get('osrelease') %}

register_sles_server:
   cmd.run:
     - name: SUSEConnect --url https://scc.suse.com -r {{ grains.get("sles_registration_code") }} -p SLES/{{ grains.get('osrelease') }}/x86_64

basesystem_activation:
   cmd.run:
     - name: SUSEConnect -p sle-module-basesystem/{{ grains.get('osrelease') }}/x86_64

{% endif %}
