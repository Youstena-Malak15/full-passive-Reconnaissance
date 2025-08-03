#!/bin/bash

# Check for input
if [ -z "$1" ]; then
    echo "Usage: $0 domain.com"
    exit 1
fi

DOMAIN=$1
OUTDIR="recon-$DOMAIN"
SUBS_FILE="$OUTDIR/all_subs.txt"
IP_FILE="$OUTDIR/subs_ips.txt"

mkdir -p "$OUTDIR"

echo "[*] Running Subfinder ..."
subfinder -d "$DOMAIN" -silent > "$OUTDIR/subfinder.txt"

echo "[*] Running Amass ..."
timeout 1m amass enum -passive -d "$DOMAIN" -silent > "$OUTDIR/amass.txt"

echo "[*] Running Assetfinder ..."
assetfinder --subs-only "$DOMAIN" > "$OUTDIR/assetfinder.txt"

echo "[*] Merging and deduplicating subdomains ..."
cat "$OUTDIR"/*.txt | sort -u | grep -E '^([a-zA-Z0-9][-a-zA-Z0-9]*\.)+[a-zA-Z]{2,}$' > "$SUBS_FILE"
echo "[+] Unique subdomains saved to: $SUBS_FILE"

echo "[*] Resolving subdomains to IPv4 addresses using dig ..."
> "$IP_FILE"
while read -r sub; do
    [[ -z "$sub" ]] && continue

    ips=$(dig +short "$sub" | grep -E '^([0-9]{1,3}\.){3}[0-9]{1,3}$')

    if [[ -n "$ips" ]]; then
        for ip in $ips; do
            echo "$sub $ip" | tee -a "$IP_FILE"
        done
    fi
done < "$SUBS_FILE"

echo "[+] Resolution complete. Results saved to: $IP_FILE"
