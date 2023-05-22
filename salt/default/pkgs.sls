include:
  - scc

{% if grains.get('additional_packages') %}
install_additional_packages:
  pkg.latest:
    - pkgs:
{% for package in grains.get('additional_packages') %}
      - {{ package }}
{% endfor %}
    - require:
      - sls: repos
      {% if grains.get('server_registration_code') or grains.get('proxy_registration_code') or grains.get('sles_registration_code') %}
      - sls: scc
      {% endif %}
{% endif %}
