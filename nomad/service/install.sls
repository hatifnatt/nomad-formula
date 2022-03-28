{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import nomad as n %}

{%- if n.install %}
  {#- Install systemd service file #}
  {%- if grains.init == 'systemd' %}
include:
  - {{ tplroot }}.service

nomad_service_install_systemd_unit:
  file.managed:
    - name: {{ salt['file.join'](n.service.systemd.unit_dir,n.service.name ~ '.service') }}
    - source: salt://{{ tplroot }}/files/nomad.service.jinja
    - user: {{ n.root_user }}
    - group: {{ n.root_group }}
    - mode: 644
    - template: jinja
    - context:
        tplroot: {{ tplroot }}
    - require_in:
      - sls: {{ tplroot }}.service
    - watch_in:
      - module: nomad_service_install_reload_systemd

    {#- Reload systemd after new unit file added, like `systemctl daemon-reload` #}
nomad_service_install_reload_systemd:
  module.wait:
    {#- Workaround for deprecated `module.run` syntax, subject to change in Salt 3005 #}
    {%- if 'module.run' in salt['config.get']('use_superseded', [])
    or grains['saltversioninfo'] >= [3005] %}
    - service.systemctl_reload: {}
    {%- else %}
    - name: service.systemctl_reload
    {%- endif %}
    - require_in:
      - sls: {{ tplroot }}.service

  {%- else %}
nomad_service_install_warning:
  test.configurable_test_state:
    - name: nomad_service_install
    - changes: false
    - result: false
    - comment: |
        Your OS init system is {{ grains.init }}, currently only systemd init system is supported.
        Service for Nomad is not installed.

  {%- endif %}

{#- Nomad is not selected for installation #}
{%- else %}
nomad_service_install_notice:
  test.show_notification:
    - name: nomad_service_install
    - text: |
        Nomad is not selected for installation, current value
        for 'nomad:install': {{ n.install|string|lower }}, if you want to install Nomad
        you need to set it to 'true'.

{%- endif %}
