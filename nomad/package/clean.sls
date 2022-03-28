{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import nomad as n %}

include:
  - {{ tplroot }}.shell_completion.bash.clean
  - {{ tplroot }}.service.clean

nomad_package_clean:
  pkg.removed:
    - pkgs:
    {%- for pkg in n.package.pkgs %}
      - {{ pkg }}
    {%- endfor %}

{#- Remove user and group #}
nomad_package_clean_user:
  user.absent:
    - name: {{ n.user }}

nomad_package_clean_group:
  group.absent:
    - name: {{ n.group }}
