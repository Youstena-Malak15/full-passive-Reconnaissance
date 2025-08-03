#!/bin/bash
OUTDIR="recon-$1"
mkdir -p "$OUTDIR"
# Then save files like:
echo "some data" > "$OUTDIR/emails.txt"

# === Configuration ===
TARGET="$1"
[ -z "$TARGET" ] && { echo "Usage: $0 <domain>"; exit 1; }

echo -e "\n# === Web Application Recon for: $TARGET ==="

# === IP Resolution ===
IP=$(dig +short "$TARGET" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n 1)
if [ -z "$IP" ]; then
    echo "[!] Unable to resolve IP address for $TARGET"
else
    echo "[+] Resolved IP: $IP"
fi

# === WhatWeb Fingerprinting ===
echo -e "\n[+] Running WhatWeb on https://$TARGET..."
whatweb "https://$TARGET" --no-errors | head -n 10

# === Nmap HTTP Services Enumeration ===
echo -e "\n[+] Scanning Web Services with Nmap..."
nmap -sV -p 80,443 "$TARGET" --open --script=http-enum | grep -E "^\| |open|service|http" | head -n 20

# === Additional Tools (Optional) ===
# Uncomment to run wappalyzer CLI (install via: npm install -g wappalyzer)
# echo -e "\n[+] Wappalyzer Analysis:"
# wappalyzer "https://$TARGET"

echo -e "\n[✔] Application recon complete.\n"
