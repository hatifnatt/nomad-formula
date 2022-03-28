{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import nomad as n %}
include:
{%- if n.use_upstream in ('binary', 'archive') %}
  - .binary.install
{%- elif n.use_upstream in ('repo', 'package') %}
  - .package.install
{%- endif %}
