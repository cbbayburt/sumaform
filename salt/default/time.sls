{% if not grains.get('osfullname') == 'SLE Micro' %}
# Dependencies already satisfied by the images
# https://build.opensuse.org/project/show/systemsmanagement:sumaform:images:microos
timezone_package:
  pkg.installed:
{% if grains.get('os_family') == 'Suse' %}
    - name: timezone
{% else %}
    - name: tzdata
{% endif %}
{% endif %}

timezone_symlink:
  file.symlink:
    - name: /etc/localtime
    - target: /usr/share/zoneinfo/{{ grains.get('timezone') }}
    - force: true
{% if not grains.get('osfullname') == 'SLE Micro' %}
    - require:
      - pkg: timezone_package
{% endif %}

{% if grains.get('timezone') is not none %}
timezone_setting:
  timezone.system:
    - name: {{ grains.get('timezone') }}
    - utc: True
    - require:
      - file: timezone_symlink
{% endif %}

{% if grains.get('use_ntp') %}

{% if ((grains.get('osfullname') == 'SLES') and (grains.get('osrelease') == '11.4'))
   or ((grains.get('os_family') == 'Debian') and (grains.get('osrelease') == '10'))
%}

ntp_pkg:
  pkg.installed:
    - name: ntp

ntp_conf_file:
  file.managed:
    - name: /etc/ntp.conf
    - source: salt://default/ntp.conf

ntp_enable_service:
  service.running:
    - name: ntp
    - enable: true

{% elif  grains.get('osfullname') == 'Leap' %}

ntp_pkg:
  pkg.installed:
    - name: ntp

ntp_conf_file:
  file.managed:
    - name: /etc/ntp.conf
    - source: salt://default/ntp.conf

ntpd_enable_service:
  service.running:
    - name: ntpd
    - enable: true

{% else %}

{% if not grains.get('osfullname') == 'SLE Micro' %}
# Dependencies already satisfied by SLE Micro itself
chrony_pkg:
  pkg.installed:
    - name: chrony
{% endif %}

chrony_conf_file:
  file.managed:
    - name: /etc/chrony.conf
    - source: salt://default/chrony.conf

chrony_enable_service:
  service.running:
    - name: chronyd
    - enable: true

{% endif %}
{% endif %}
