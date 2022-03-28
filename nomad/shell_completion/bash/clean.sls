{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import nomad as n %}

{#- Remove systemwide bash autocomplete for nomad #}
nomad_shell_completion_bash_install_completion:
  file.absent:
    - name: {{  salt['file.join'](n.shell_completion.bash.dir, 'nomad') }}
