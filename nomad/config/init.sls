{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import nomad as n %}
{%- from tplroot ~ '/macros.jinja' import format_kwargs %}
{%- set conf_dir = salt['file.dirname'](n['params']['config'][0]) %}

{%- if n.install %}
  {#- Manage Nomad configuration #}
include:
  - {{ tplroot }}.install
  - {{ tplroot }}.service
  - {{ tplroot }}.config.tls

  {#- Create parameters / environment file #}
nomad_config_env_file:
  file.managed:
    - name: {{ n.config.env_file }}
    - source: salt://{{ tplroot }}/files/env_params.jinja
    - template: jinja
    - context:
        tplroot: {{ tplroot }}
        params: {{ n.params|tojson }}
    - watch_in:
      - service: nomad_service_{{ n.service.status }}

  {#- Create data dir #}
nomad_config_directory:
  file.directory:
    - name: {{ conf_dir }}
    - user: {{ n.user }}
    - group: {{ n.group }}
    - dir_mode: 755
    - require_in:
      - sls: {{ tplroot }}.config.tls

  {#- Put config file in place #}
nomad_config_file:
  file.managed:
  {#- Write configuration to first provided config file #}
    - name: {{ n['params']['config'][0] }}
    - source: salt://{{ tplroot }}/files/{{ n.config.source }}
    - user: {{ n.user }}
    - group: {{ n.group }}
    - mode: 640
    - template: jinja
    - context:
        tplroot: {{ tplroot }}
    {#- By default don't show changes to don't reveal tokens. #}
    - show_changes: {{ n.config.show_changes }}
    - require:
        - file: nomad_config_directory
        - sls: {{ tplroot }}.config.tls
    - watch_in:
      - service: nomad_service_{{ n.service.status }}

  {#- Create data dir #}
nomad_config_data_directory:
  file.directory:
    - name: {{ n.config.data.data_dir }}
    - user: {{ n.user }}
    - group: {{ n.group }}
    - dir_mode: 750
    - makedirs: True
    - require_in:
      - service: nomad_service_{{ n.service.status }}

{#- Nomad is not selected for installation #}
{%- else %}
nomad_config_install_notice:
  test.show_notification:
    - name: nomad_config_install_notice
    - text: |
        Nomad is not selected for installation, current value
        for 'nomad:install': {{ n.install|string|lower }}, if you want to install Nomad
        you need to set it to 'true'.

{%- endif %}
