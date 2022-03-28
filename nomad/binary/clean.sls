{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import nomad as n %}
{#- Find all nomad binaries with version i.e. /usr/local/bin/nomad-1.11.2 etc. #}
{%- set nomad_versions = salt['file.find'](n.bin ~ '-*',type='fl') %}

include:
  - {{ tplroot }}.shell_completion.bash.clean
  - {{ tplroot }}.service.clean

{#- Remove symlink into system bin dir #}
nomad_binary_clean_bin_symlink:
  file.absent:
    - name: {{ n.bin }}

{%- for binary in nomad_versions %}
  {%- set version = binary.split('-')[-1] %}
nomad_binary_clean_bin_v{{ version }}:
  file.absent:
    - name: {{ binary }}
    - require:
      - file: nomad_binary_clean_bin_symlink

{%- endfor %}

{#- Remove user and group #}
nomad_binary_clean_user:
  user.absent:
    - name: {{ n.user }}

nomad_binary_clean_group:
  group.absent:
    - name: {{ n.group }}
