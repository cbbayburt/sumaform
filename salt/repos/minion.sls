{% if grains.get('roles') is not none and 'minion' in grains.get('roles') and grains.get('testsuite') | default(false, true) and grains.get('osfullname') == 'SLES' and not grains.get('sles_registration_code') %}

{% if grains.get('osrelease') is not none and '15' in grains.get('osrelease') %}

{% if grains.get('osrelease') == '15' %}
{% set sle_version_path = '15' %}
{% elif grains.get('osrelease') == '15.1' %}
{% set sle_version_path = '15-SP1' %}
{% elif grains.get('osrelease') == '15.2' %}
{% set sle_version_path = '15-SP2' %}
{% elif grains.get('osrelease') == '15.3' %}
{% set sle_version_path = '15-SP3' %}
{% elif grains.get('osrelease') == '15.4' %}
{% set sle_version_path = '15-SP4' %}
{% endif %}

{% endif %}


{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
default_nop:
  test.nop: []
