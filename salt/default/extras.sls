aliases:
  file.managed:
    - name: /etc/profile.local
    - source: salt://default/profile.local
    - user: root
    - group: root
    - mode: 644
