{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import nomad as n %}
{%- from tplroot ~ '/macros.jinja' import format_kwargs, build_source %}

{%- if n.install %}
  {#- Manage Nomad TLS key and certificate #}
include:
  - {{ tplroot }}.service

  {%- if n.tls.self_signed
      and 'tls' in n.config.data
      and 'key_file' in n.config.data.tls
      and 'cert_file' in n.config.data.tls
  %}
    {#- Create self sifned TLS (SSL) certificate #}
nomad_config_tls_prereq_packages:
  pkg.installed:
    - pkgs: {{ n.tls.packages|json }}

nomad_config_tls_selfsigned_key:
  x509.private_key_managed:
    - name: {{ n.config.data.tls.key_file }}
    - user: {{ n.user }}
    - group: {{ n.group }}
    - mode: 640
    - makedirs: true
    - require:
      - pkg: nomad_config_tls_prereq_packages

nomad_config_tls_selfsigned_cert:
  x509.certificate_managed:
    - name: {{ n.config.data.tls.cert_file }}
    - signing_private_key: {{ n.config.data.tls.key_file }}
    {{- format_kwargs(n.tls.cert_params) }}
    - user: {{ n.user }}
    - group: {{ n.group }}
    - mode: 640
    - makedirs: true
    - require:
      - x509: nomad_config_tls_selfsigned_key
    - watch_in:
      - service: nomad_service_{{ n.service.status }}

  {%- elif not n.tls.self_signed
      and 'tls' in n.config.data
      and 'key_file' in n.config.data.tls
      and 'cert_file' in n.config.data.tls
  %}

nomad_config_tls_provided_key:
  file.managed:
    - name: {{ n.config.data.tls.key_file }}
    - source:
    {{- build_source(n.tls.key_file_source, path_prefix='files/tls') }}
    - user: {{ n.user }}
    - group: {{ n.group }}
    - mode: 640
    - makedirs: true
    - watch_in:
      - service: nomad_service_{{ n.service.status }}

nomad_config_tls_provided_cert:
  file.managed:
    - name: {{ n.config.data.tls.cert_file }}
    - source:
    {{- build_source(n.tls.cert_file_source, path_prefix='files/tls') }}
    - user: {{ n.user }}
    - group: {{ n.group }}
    - mode: 640
    - makedirs: true
    - watch_in:
      - service: nomad_service_{{ n.service.status }}

  {#- Not enough data to configure TLS #}
  {%- else %}
nomad_config_tls_skipped:
  test.show_notification:
    - name: nomad_config_tls_skipped
    - text: |
        Not enough data to configure TLS.
        You must provide values for `key_file` and `cert_file` in pillars
        Current values:
        nomad:config:data:tls:key_file: '{{ n.config.data|traverse('tls:key_file', '') }}'
        nomad:config:data:tls:cert_file: '{{ n.config.data|traverse('tls:cert_file', '') }}'
        
        Also you need to enable self signed certificate generation
        nomad:tls:self_signed: '{{ n.tls.self_signed|string|lower }}'
        
        OR provide existing key and certificate files
        nomad:tls:key_file_source: '{{ n.tls.get('key_file_source', '') }}'
        nomad:tls:cert_file_source: '{{ n.tls.get('cert_file_source', '') }}'
        Note, formula have default values 'tls.key', 'tls.crt' but actual files
        are not provided with formula, you neet to put them into folder 'nomad/files/tls'
        on salt file server.

{%- endif %}

{#- Nomad is not selected for installation #}
{%- else %}
nomad_config_tls_install_notice:
  test.show_notification:
    - name: nomad_config_tls_install_notice
    - text: |
        Nomad is not selected for installation, current value
        for 'nomad:install': {{ n.install|string|lower }}, if you want to install Nomad
        you need to set it to 'true'.

{%- endif %}
