# set the hostname in the kernel, this is needed for Red Hat systems
# and does not hurt in others
kernel_hostname:
  cmd.run:
    - name: sysctl kernel.hostname={{ grains.get('hostname') }}
    - unless: sysctl --values kernel.hostname | grep -w {{ grains.get('hostname') }}

# set the hostname in userland. There is no consensus among distros
# but Debian prefers the short name, SUSE demands the short name,
# Red Hat suggests the FQDN but works with the short name.
# Bottom line: short name is used here
temporary_hostname:
  cmd.run:
    {% if grains.get('init') == 'systemd' %}
    - name: hostnamectl set-hostname {{ grains.get('hostname') }}
    {% else %}
    - name: hostname {{ grains.get('hostname') }}
    {% endif %}

# set the hostname in the filesystem, matching the temporary hostname
permanent_hostname:
  file.managed:
    - name: /etc/hostname
    - contents: {{ grains.get('hostname') }}

# /etc/HOSTNAME is supposed to always contain the FQDN
legacy_permanent_hostname:
  file.managed:
    - name: /etc/HOSTNAME
    - follow_symlinks: False
    - contents: {{ grains.get('hostname') }}.{{ grains.get('domain') }}

{% if grains.get('os_family') == 'Suse' %}
change_searchlist:
  file.replace:
    - name: /etc/sysconfig/network/config
    - pattern: NETCONFIG_DNS_STATIC_SEARCHLIST=.*
    - repl: NETCONFIG_DNS_STATIC_SEARCHLIST="{{ grains.get('domain') }}"

netconfig_update:
  cmd.run:
    - name: netconfig update
    - require:
      - file: change_searchlist
{% else %}
change_searchlist:
  file.append:
    - name: /etc/resolv.conf
    - text: search {{ grains.get('domain') }}
{% endif %}

# set the hostname and FQDN name in /etc/hosts
# this is not needed if a proper DNS server is in place, but when using avahi this
# might not be the case. The script tries to to use real IP addresses in order not
# to break round-robin DNS resolution and only uses 127.0.1.1 as a last resort.
{% if grains.get('use_avahi') %}
hosts_file_hack:
  cmd.script:
    - name: salt://default/set_ip_in_etc_hosts.py
    {% if grains.get('ipv6:enable') %}
    - args: "{{ grains.get('hostname') }} {{ grains.get('domain') }}"
    {% else %}
    - args: "--no-ipv6 {{ grains.get('hostname') }} {{ grains.get('domain') }}"
    {% endif %}
    - template: jinja
{% endif %}
