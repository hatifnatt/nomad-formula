{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import nomad as n %}
{%- from tplroot ~ '/macros.jinja' import format_kwargs %}

{#- Remove any configured repo form the system, use with care if multiple HashiCorp porducts are installed #}
{#- If only one repo configuration is present - convert it to list #}
{%- if n.repo.config is mapping %}
  {%- set configs = [n.repo.config] %}
{%- else %}
  {%- set configs = n.repo.config %}
{%- endif %}
{%- for config in configs %}
nomad_repo_clean_{{ loop.index0 }}:
  pkgrepo.absent:
    - name: {{ config.name }}
{%- endfor %}
