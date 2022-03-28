{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import nomad as n %}
{%- set conf_dir = salt['file.dirname'](n['params']['config'][0]) -%}

{%- if n.install %}
  {#- Install Nomad from precompiled binary #}
  {%- if n.use_upstream in ('binary', 'archive') %}
include:
  - {{ tplroot }}.shell_completion.bash.install
  - {{ tplroot }}.service.install

    {#- Install prerequisies #}
nomad_binary_install_prerequisites:
  pkg.installed:
    - pkgs: {{ n.binary.prereq_pkgs|tojson }}

    {#- Create group and user #}
nomad_binary_install_group:
  group.present:
    - name: {{ n.group }}
    - system: True

nomad_binary_install_user:
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
      - group: nomad_binary_install_group
    - require_in:
      - sls: {{ tplroot }}.service.install

    {#- Create directories #}
nomad_binary_install_bin_dir:
  file.directory:
    - name: {{ salt['file.dirname'](n.bin) }}
    - makedirs: True

    {#- Download archive, extract archive install binary to it's place #}
    {#- TODO: Download and validate SHA file with gpg? https://www.hashicorp.com/security.html #}
nomad_binary_install_download_archive:
  file.managed:
    - name: {{ n.binary.temp_dir }}/{{ n.version }}/nomad_{{ n.version }}_linux_amd64.zip
    - source: {{ n.binary.download_remote }}{{ n.version }}/nomad_{{ n.version }}_linux_amd64.zip
    {%- if n.binary.skip_verify %}
    - skip_verify: True
    {%- else %}
    - source_hash: {{ n.binary.source_hash_remote }}{{ n.version }}/nomad_{{ n.version }}_SHA256SUMS
    {%- endif %}
    - makedirs: True
    - unless: test -f {{ n.bin }}-{{ n.version }}

nomad_binary_install_extract_bin:
  archive.extracted:
    - name: {{ n.binary.temp_dir }}/{{ n.version }}
    - source: {{ n.binary.temp_dir }}/{{ n.version }}/nomad_{{ n.version }}_linux_amd64.zip
    - skip_verify: True
    - enforce_toplevel: False
    - require:
      - file: nomad_binary_install_download_archive
    - unless: test -f {{ n.bin }}-{{ n.version }}

nomad_binary_install_install_bin:
  file.rename:
    - name: {{ n.bin }}-{{ n.version }}
    - source: {{ n.binary.temp_dir }}/{{ n.version }}/{{ salt['file.basename'](n.bin) }}
    - require:
      - file: nomad_binary_install_bin_dir
    - watch:
      - archive: nomad_binary_install_extract_bin

    {#- Create symlink into system bin dir #}
nomad_binary_install_bin_symlink:
  file.symlink:
    - name: {{ n.bin }}
    - target: {{ n.bin }}-{{ n.version }}
    - force: True
    - require:
      - archive: nomad_binary_install_extract_bin
      - file: nomad_binary_install_install_bin
    - require_in:
      - sls: {{ tplroot }}.shell_completion.bash.install

    {#- Fix problem with service startup due SELinux restrictions on RedHat falmily OS-es
        thx. https://github.com/saltstack-formulas/nomad-formula/issues/49 for idea #}
    {%- if grains['os_family'] == 'RedHat' %}
nomad_binary_install_bin_restorecon:
  module.run:
      {#- Workaround for deprecated `module.run` syntax, subject to change in Salt 3005 #}
      {%- if 'module.run' in salt['config.get']('use_superseded', [])
              or grains['saltversioninfo'] >= [3005] %}
    - file.restorecon:
        - {{ n.bin }}-{{ n.version }}
      {%- else %}
    - name: file.restorecon
    - path: {{ n.bin }}-{{ n.version }}
      {%- endif %}
    - require:
      - file: nomad_binary_install_install_bin
    - require_in:
      - sls: {{ tplroot }}.shell_completion.bash.install
    - onlyif: "LC_ALL=C restorecon -vn {{ n.bin }}-{{ n.version }} | grep -q 'Would relabel'"
    {% endif -%}

    {#- Remove temporary files #}
nomad_binary_install_cleanup:
  file.absent:
    - name: {{ n.binary.temp_dir }}
    - require_in:
      - sls: {{ tplroot }}.service.install

  {#- Another installation method is selected #}
  {%- else %}
nomad_binary_install_method:
  test.show_notification:
    - name: nomad_binary_install_method
    - text: |
        Another installation method is selected. If you want to use binary
        installation method set 'nomad:use_upstream' to 'binary' or 'archive'.
        Current value of nomad:use_upstream: '{{ n.use_upstream }}'
  {%- endif %}

{#- Nomad is not selected for installation #}
{%- else %}
nomad_binary_install_notice:
  test.show_notification:
    - name: nomad_binary_install
    - text: |
        Nomad is not selected for installation, current value
        for 'nomad:install': {{ n.install|string|lower }}, if you want to install Nomad
        you need to set it to 'true'.

{%- endif %}
