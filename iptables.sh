#!/bin/bash
# ======================================================
# iptables-observer deployment script
# Logs non-HTTP/HTTPS traffic involving 172.16.1.0/24
# ======================================================

# Variables
INTERNAL_NET="172.16.1.0/24"
CHAIN_NAME="IPTABLES_OBSERVER_LOG"
LOG_PREFIX="IPTABLES-OBSERVER "
LOG_LIMIT="10/min"
LOG_BURST="20"

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# ========================
# 1. Create custom chain
# ========================
if ! iptables -L $CHAIN_NAME -n &> /dev/null; then
    iptables -N $CHAIN_NAME
    echo "Created chain $CHAIN_NAME"
else
    echo "Chain $CHAIN_NAME already exists"
fi

# Flush existing rules in chain to avoid duplicates if needed
#iptables -F $CHAIN_NAME

# Add logging with rate limiting
iptables -A $CHAIN_NAME -m limit --limit $LOG_LIMIT --limit-burst $LOG_BURST -j LOG --log-prefix "$LOG_PREFIX" --log-level 4
iptables -A $CHAIN_NAME -j RETURN

# ========================
# 2. Exclude HTTP/HTTPS
# ========================
# TCP 80, 443
iptables -A FORWARD -p tcp -m multiport --dports 80,443 -j RETURN
# UDP 443 (QUIC)
iptables -A FORWARD -p udp --dport 443 -j RETURN

# ========================
# 3. Apply logging to FORWARD chain
# ========================
# Source internal subnet
iptables -A FORWARD -s $INTERNAL_NET -j $CHAIN_NAME
# Destination internal subnet
iptables -A FORWARD -d $INTERNAL_NET -j $CHAIN_NAME

echo "iptables-observer rules applied successfully"

# ========================
# 4. Save rules (my CentOS 7)
# ========================
#if command -v service &> /dev/null; then
#    service iptables save
#    echo "iptables rules saved"
#fi
