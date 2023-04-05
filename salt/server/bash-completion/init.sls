cli_bash_completion:
  file.managed:
    - names:
      - /etc/bash_completion.d/mgr-create-bootstrap-repo.bash:
        - source: salt://server/bash-completion/mgr-create-bootstrap-repo.bash
      - /etc/bash_completion.d/mgr-sync.bash:
        - source: salt://server/bash-completion/mgr-sync.bash
      - /etc/bash_completion.d/spacewalk-common-channels.bash:
        - source: salt://server/bash-completion/spacewalk-common-channels.bash
      - /etc/bash_completion.d/spacewalk-remove-channel.bash:
        - source: salt://server/bash-completion/spacewalk-remove-channel.bash
