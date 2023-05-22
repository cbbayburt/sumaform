{% if grains.get('roles') is not none and 'proxy' in grains.get('roles') %}
include:
  {%- if grains.get('product_version') is not none and '4.2' in grains.get('product_version') %}
  - repos.proxy42
  {%- elif grains.get('product_version') is not none and '4.3' in grains.get('product_version') %}
  - repos.proxy43
  {%- elif grains.get('product_version') is not none and 'head' in grains.get('product_version') %}
  - repos.proxyHead
  {%- else %}
  - repos.proxyUyuni
  {%- endif %}

{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []
