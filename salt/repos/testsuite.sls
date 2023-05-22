{% if grains.get('testsuite') | default(false, true) %}
{% if grains.get('roles') is not none and 'client' in grains.get('roles') or grains.get('roles') is not none and 'minion' in grains.get('roles') or grains.get('roles') is not none and 'sshminion' in grains.get('roles') %}

{% if (grains.get('os') == 'SUSE') or (grains.get('os_family') == 'RedHat') %}

uyuni_key_for_fake_packages:
{% if not grains.get('osfullname') == 'SLE Micro' %}
  file.managed:
    - name: /tmp/uyuni.key
    - source: salt://default/gpg_keys/uyuni.key
  cmd.wait:
    - name: rpm --import /tmp/uyuni.key
    - watch:
      - file: uyuni_key_for_fake_packages
{% else %}
  cmd.run:
    - name: transactional-update -c run rpm --import http://{{ grains.get("mirror") | default("minima-mirror.mgr.prv.suse.net", true) }}/uyuni.key
{% endif %}

test_repo_rpm_pool:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Test-Packages:/Pool/rpm/
    - refresh: True
    - gpgcheck: 1
    - gpgkey: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Test-Packages:/Pool/rpm/repodata/repomd.xml.key

{% elif grains.get('os_family') == 'Debian' %}

test_repo_deb_pool:
  pkgrepo.managed:
    - name: deb http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Test-Packages:/Pool/deb/ /
    - refresh: True
    - file: /etc/apt/sources.list.d/test_repo_deb_pool.list
    - key_url: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Test-Packages:/Pool/deb/Release.key

{% endif %}
{% endif %}
{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []
