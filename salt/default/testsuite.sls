{% if grains.get('testsuite') | default(false, true) %}
{% if grains.get('roles') is not none and 'client' in grains.get('roles') or grains.get('roles') is not none and 'minion' in grains.get('roles') or grains.get('roles') is not none and 'sshminion' in grains.get('roles') %}

include:
  - scc
  - repos

{% if grains.get('os') == 'SUSE' %}

default_cucumber_requisites:
  pkg.installed:
    - pkgs:
      - andromeda-dummy
      - milkyway-dummy
      - virgo-dummy
    - require:
      - sls: repos

{% elif grains.get('os_family') == 'RedHat' %}

default_cucumber_requisites:
  pkg.installed:
    - pkgs:
      - andromeda-dummy
      - milkyway-dummy
      - virgo-dummy
    - require:
      - pkgrepo: test_repo_rpm_pool

{% endif %}
{% endif %}
{% endif %}
