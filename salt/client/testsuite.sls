{% if grains.get('testsuite') | default(false, true) %}

include:
  - repos
  - client

client_cucumber_requisites:
  pkg.installed:
    - pkgs:
      - spacewalk-client-setup
      - spacewalk-check
      - mgr-cfg-actions
      - wget
    - require:
      - sls: default

{% if grains.get('os') == 'SUSE' and grains.get('osrelease') is not none and '12' in grains.get('osrelease') %}

suse_client_cucumber_requisites:
  pkg.installed:
    - pkgs:
      - aaa_base-extras
    - require:
      - sls: repos

{% endif %}

{% endif %}
