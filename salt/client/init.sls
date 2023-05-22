include:
  - scc.client
  - client.testsuite

wget:
  pkg.installed:
    - require:
      - sls: default

{% if grains.get('auto_register') %}

base_bootstrap_script:
  file.managed:
    - name: /root/bootstrap.sh
    - source: http://{{grains.get('server')}}/pub/bootstrap/bootstrap.sh
    - source_hash: http://{{grains.get('server')}}/pub/bootstrap/bootstrap.sh.sha512
    - mode: 755

bootstrap_script:
  file.replace:
    - name: /root/bootstrap.sh
    - pattern: ^PROFILENAME="".*$
    {% if grains.get('hostname') and grains.get('domain') %}
    - repl: PROFILENAME="{{ grains.get('hostname') }}.{{ grains.get('domain') }}"
    {% else %}
    - repl: PROFILENAME="{{grains.get('fqdn')}}"
    {% endif %}
    - require:
      - file: base_bootstrap_script
  cmd.run:
    - name: /root/bootstrap.sh
    - require:
      - file: bootstrap_script
      - pkg: wget

{% endif %}
