{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import nomad as n %}
{%- set conf_dir = salt['file.dirname'](n['params']['config'][0]) -%}

{%- if n.install %}
  {#- Install Nomad from packages #}
  {%- if n.use_upstream in ('repo', 'package') %}
include:
  - {{ tplroot }}.repo
  - {{ tplroot }}.shell_completion.bash.install
  - {{ tplroot }}.service.install

    {#- Install packages required for further execution of 'package' installation method #}
    {%- if 'prereq_pkgs' in n.package and n.package.prereq_pkgs %}
nomad_package_install_prerequisites:
  pkg.installed:
    - pkgs: {{ n.package.prereq_pkgs|tojson }}
    - require:
      - sls: {{ tplroot }}.repo
    - require_in:
      - pkg: nomad_package_install
    {%- endif %}

    {%- if 'pkgs_extra' in n.package and n.package.pkgs_extra %}
nomad_package_install_extra:
  pkg.installed:
    - pkgs: {{ n.package.pkgs_extra|tojson }}
    - require:
      - sls: {{ tplroot }}.repo
    - require_in:
      - pkg: nomad_package_install
    {%- endif %}

nomad_package_install:
  pkg.installed:
    - pkgs:
    {%- for pkg in n.package.pkgs %}
      - {{ pkg }}{% if n.version is defined and 'nomad' in pkg %}: '{{ n.version }}'{% endif %}
    {%- endfor %}
    - hold: {{ n.package.hold }}
    - update_holds: {{ n.package.update_holds }}
    {%- if salt['grains.get']('os_family') == 'Debian' %}
    - install_recommends: {{ n.package.install_recommends }}
    {%- endif %}
    - watch_in:
      - service: nomad_service_{{ n.service.status }}
    - require:
      - sls: {{ tplroot }}.repo
    - require_in:
      - sls: {{ tplroot }}.service.install

    {#- Create group and user #}
nomad_package_install_group:
  group.present:
    - name: {{ n.group }}
    - system: True
    - require:
      - pkg: nomad_package_install

nomad_package_install_user:
  user.present:
    - name: {{ n.user }}
    - gid: {{ n.group }}
    - system: True
    - password: '*'
    - home: {{ conf_dir }}
    - createhome: False
    - shell: /usr/sbin/nologin
    - fullname: Nomad daemon
    - require:
      - group: nomad_package_install_group
    - require_in:
      - sls: {{ slsdotpath }}.service.install

  {#- Another installation method is selected #}
  {%- else %}
nomad_package_install_method:
  test.show_notification:
    - name: nomad_package_install_method
    - text: |
        Another installation method is selected. If you want to use package
        installation method set 'nomad:use_upstream' to 'package' or 'repo'.
        Current value of nomad:use_upstream: '{{ n.use_upstream }}'
  {%- endif %}

{#- Nomad is not selected for installation #}
{%- else %}
nomad_package_install_notice:
  test.show_notification:
    - name: nomad_package_install
    - text: |
        Nomad is not selected for installation, current value
        for 'nomad:install': {{ n.install|string|lower }}, if you want to install Nomad
        you need to set it to 'true'.

{%- endif %}
