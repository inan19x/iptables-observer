# Create a custom chain
iptables -N IPTABLES_OBSERVER_LOG

# Rate-limit logging to reduce noise (10/min, burst 20)
iptables -A IPTABLES_OBSERVER_LOG -m limit --limit 10/min --limit-burst 20 -j LOG --log-prefix "IPTABLES-OBSERVER " --log-level 4

# Let's start
iptables -A IPTABLES_OBSERVER_LOG -j RETURN

# Exclude TCP 80, 443 and UDP 443 (QUIC)
iptables -A FORWARD -p tcp -m multiport --dports 80,443 -j RETURN
iptables -A FORWARD -p udp --dport 443 -j RETURN

# And log forwarded traffic involving internal subnet
iptables -A FORWARD -s 172.16.1.0/24 -j IPTABLES_OBSERVER_LOG
iptables -A FORWARD -d 172.16.1.0/24 -j IPTABLES_OBSERVER_LOG

# Save the iptables config
# service iptables save
