# WORKAROUND
# This file should already be excluded from SLE Micro with the 
# first few lines in salt/default/init.sls
{% if not grains.get('osfullname') == 'SLE Micro' %}
include:
  {% if grains.get('hostname') and grains.get('domain') %}
  - default.hostname
  {% endif %}
  - default.network
  - default.firewall
  - default.avahi
  {% if 'build_image' not in grains.get('product_version') | default('', true) %}
  - repos
  {% endif %}
  - default.time

minimal_package_update:
  pkg.latest:
    - pkgs:
{% if grains.get('install_salt_bundle') %}
      - venv-salt-minion
{% else %}
      - salt-minion
{% endif %}
{% if grains.get('os_family') == 'Suse' %}
      - zypper
      - libzypp
      # WORKAROUND: avoid a segfault on old versions
      {% if grains.get('osrelease') is not none and '12' in grains.get('osrelease') %}
      - libgio-2_0-0
      {% endif %}
{% endif %}
    - order: last
{% endif %}
