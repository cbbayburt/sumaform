{% if grains.get('roles') is not none and 'client' in grains.get('roles') or grains.get('roles') is not none and 'minion' in grains.get('roles') or grains.get('roles') is not none and 'sshminion' in grains.get('roles') %}

sshd_change_challengeresponseauthentication:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: "^ChallengeResponseAuthentication.*"
    - repl: "ChallengeResponseAuthentication yes"

{% endif %}
