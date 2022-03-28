{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import nomad as n %}

{#- Install systemwide bash autocomplete for nomad #}
{%- if n.shell_completion.bash.install %}
  {#- Install bash autocompletion package first #}
nomad_shell_completion_bash_install_package:
  pkg.installed:
    - name: {{ n.shell_completion.bash.package }}

nomad_shell_completion_bash_install_completion:
  file.managed:
    - name: {{  salt['file.join'](n.shell_completion.bash.dir, 'nomad') }}
    - mode: 644
    - makedirs: true
    - contents: |
        complete -C {{ n.bin }} nomad

{#- Bash autocompletion for nomad is not selected for installation #}
{%- else %}
nomad_shell_completion_bash_install_notice:
  test.show_notification:
    - name: nomad_shell_completion_bash_install
    - text: |
        Bash autocompletion for Nomad is not selected for installation, current value
        for 'nomad:shell_completion:bash:install': {{ n.shell_completion.bash.install|string|lower }},
        if you want to install Bash autocompletion for Nomad you need to set it to 'true'.

{%- endif %}
