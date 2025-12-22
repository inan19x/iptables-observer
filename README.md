Monitor forwarded traffic on a simple Linux box that acts as a router.<br/><br/>
-Log traffic involving internal network 172.16.1.0/24.<br/>
-Exclude HTTP (80) / HTTPS (443) traffic.<br/>
-Store logs in a dedicated file /var/log/iptables-observer.log.<br/>
-Forward logs to a SIEM host via TCP 514.<br/>
-Rotate logs weekly to maintain storage capacity.
