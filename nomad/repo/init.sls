{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import nomad as n %}
{%- from tplroot ~ '/macros.jinja' import format_kwargs %}

{%- if n.install %}
  {#- If nomad:use_upstream is 'repo' or 'package' official repo will be configured #}
  {%- if n.use_upstream in ('repo', 'package') %}

    {#- Install required packages if defined #}
    {%- if n.repo.prerequisites %}
nomad_repo_prerequisites:
  pkg.installed:
    - pkgs: {{ n.repo.prerequisites|tojson }}
    {%- endif %}

    {#- If only one repo configuration is present - convert it to list #}
    {%- if n.repo.config is mapping %}
      {%- set configs = [n.repo.config] %}
    {%- else %}
      {%- set configs = n.repo.config %}
    {%- endif %}
    {%- for config in configs %}
nomad_repo_{{ loop.index0 }}:
  pkgrepo.managed:
    {{- format_kwargs(config) }}
    {%- endfor %}

  {#- Another installation method is selected #}
  {%- else %}
nomad_repo_install_method:
  test.show_notification:
    - name: nomad_repo_install_method
    - text: |
        Another installation method is selected. Repo configuration is not required.
        If you want to configure repository set 'nomad:use_upstream' to 'repo' or 'package'.
        Current value of nomad:use_upstream: '{{ n.use_upstream }}'
  {%- endif %}

{#- Nomad is not selected for installation #}
{%- else %}
nomad_repo_install_notice:
  test.show_notification:
    - name: nomad_repo_install
    - text: |
        Nomad is not selected for installation, current value
        for 'nomad:install': {{ n.install|string|lower }}, if you want to install Nomad
        you need to set it to 'true'.

{%- endif %}
