{% if grains.get('roles') is not none and 'server' in grains.get('roles') %}

include:
  {%- if grains.get('product_version') is not none and '4.2' in grains.get('product_version') %}
  - repos.server42
  {%- elif grains.get('product_version') is not none and '4.3' in grains.get('product_version') %}
  - repos.server43
  {%- elif grains.get('product_version') is not none and 'head' in grains.get('product_version') %}
  - repos.serverHead
  {%- else %}
  - repos.serverUyuni
  {%- endif %}

{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []
