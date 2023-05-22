{% if grains.get('os') == 'SUSE' and (
      grains.get('roles') is not none and 'controller' in grains.get('roles') or
      grains.get('roles') is not none and 'grafana' in grains.get('roles') or
      grains.get('roles') is not none and 'mirror' in grains.get('roles') or
      grains.get('evil_minion_count') or
      grains.get('monitored')
) %}

{% if grains.get('osfullname') == 'Leap' %}
{% set path = 'openSUSE_Leap_' + grains.get('osrelease') %}
{% endif %}

{% if grains.get('osfullname') != 'Leap' %}
{% if grains.get('osrelease') == '11.4' %}
{% set path = 'SLE_11_SP4' %}
{% elif grains.get('osrelease') == '12.3' %}
{% set path = 'SLE_12_SP3' %}
{% elif grains.get('osrelease') == '12.4' %}
{% set path = 'SLE_12_SP4' %}
{% elif grains.get('osrelease') == '15.1' %}
{% set path = 'SLE_15_SP1' %}
{% elif grains.get('osrelease') == '15.2' %}
{% set path = 'SLE_15_SP2' %}
{% elif grains.get('osrelease') == '15.3' %}
{% set path = 'SLE_15_SP3' %}
{% elif grains.get('osrelease') == '15.4' %}
{% set path = 'SLE_15_SP4' %}
{% elif grains.get('osrelease') == '15.5' %}
{% set path = 'SLE_15_SP5' %}
{% endif %}
{% endif %}

tools_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/sumaform:/tools/{{path}}/
    - refresh: True
    - gpgcheck: 1
    - gpgkey: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/sumaform:/tools/{{path}}/repodata/repomd.xml.key

{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []
