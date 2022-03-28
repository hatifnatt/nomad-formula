{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import nomad as n %}

{%- if n.install %}
  {#- Manage on boot service state in dedicated state to ensure watch trigger properly in service.running state #}
nomad_service_{{ n.service.on_boot_state }}:
  service.{{ n.service.on_boot_state }}:
    - name: {{ n.service.name }}

nomad_service_{{ n.service.status }}:
  service:
    - name: {{ n.service.name }}
    - {{ n.service.status }}
  {%- if n.service.status == 'running' %}
    - reload: {{ n.service.reload }}
  {%- endif %}
    - require:
        - service: nomad_service_{{ n.service.on_boot_state }}
    - order: last

{#- Nomad is not selected for installation #}
{%- else %}
nomad_service_notice:
  test.show_notification:
    - name: nomad_service_notice
    - text: |
        Nomad is not selected for installation, current value
        for 'nomad:install': {{ n.install|string|lower }}, if you want to install Nomad
        you need to set it to 'true'.

{%- endif %}
