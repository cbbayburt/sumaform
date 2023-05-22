{% if grains.get('testsuite') | default(false, true) %}

{% if not grains.get('osfullname') == 'SLE Micro' %}
# Dependencies already satisfied by the images
# https://build.opensuse.org/project/show/systemsmanagement:sumaform:images:microos
minion_cucumber_requisites:
  pkg.installed:
    - pkgs:
{% if grains.get('install_salt_bundle') %}
      - venv-salt-minion
{% else %}
      - salt-minion
{% endif %}
      - wget
    - require:
      - sls: default
{% endif %}

{% if grains.get('os') == 'SUSE' %}
{% if grains.get('osrelease') is not none and '12' in grains.get('osrelease') or grains.get('osrelease') is not none and '15' in grains.get('osrelease')%}

suse_minion_cucumber_requisites:
  pkg.installed:
    - pkgs:
      - aaa_base-extras
      - ca-certificates
    {% if 'build_image' not in grains.get('product_version') | default('', true) %}
    - require:
      - sls: repos
    {% endif %}

suse_certificate:
  file.managed:
    - name: /etc/pki/trust/anchors/SUSE_Trust_Root.crt.pem
    - source: salt://minion/certs/SUSE_Trust_Root.crt.pem
    - makedirs: True

update_ca_truststore:
  cmd.run:
    - name: /usr/sbin/update-ca-certificates
    - onchanges:
      - file: suse_certificate
    - require:
      - pkg: suse_minion_cucumber_requisites
    - unless:
      - fun: service.status
        args:
          - ca-certificates.path

{% endif %}
{% endif %}

{% endif %}
