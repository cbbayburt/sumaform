{% if grains.get('roles') is not none and 'jenkins' in grains.get('roles') %}
  {% if grains.get('os') == 'SUSE' %}
    {% if grains.get('osfullname') == 'Leap' %}
      {% set repo = 'openSUSE_Leap_' + grains.get('osrelease') %}
    {% elif grains.get('osfullname') == 'SLES' %}
      {% set slemajorver = grains.get('osrelease').split('.')[0] %}
      {% set slesp = grains.get('osrelease').split('.')[1] %}
      {% if slesp == '0' %}
        {% set slever = 'SLE_' + slemajorver %}
      {% else %}
        {% set slever = 'SLE_' + slemajorver + '_' + slesp %}
      {% endif %}
    {% endif %}
  {% endif %}
jenkins_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org/", true) }}/repositories/devel:/tools:/building/{{ repo }}
    - refresh: True
    - gpgcheck: 1
    - gpgkey: http://{{ grains.get("mirror") | default("download.opensuse.org/", true) }}/repositories/devel:/tools:/building//{{ repo }}/repodata/repomd.xml.key
{% endif %}

