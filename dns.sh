#!/bin/bash

# -------- Configuration --------
DOMAIN="$1"
DATE=$(date)
OUTDIR="recon-$DOMAIN"
REPORT="final-dns-report-$DOMAIN.txt"
TMPDIR="/tmp/dnsrecon_$RANDOM"
DNS="8.8.8.8"
mkdir -p "$OUTDIR" "$TMPDIR"

# -------- Helper Functions --------
print_or_fallback() {
    if [[ -z "$1" ]]; then
        echo "[-] No $2 records found."
    else
        echo "$1"
    fi
}

safe_dig() {
    local record_type="$1"
    local domain="$2"
    local output=""
    for attempt in {1..3}; do
        output=$(dig @"$DNS" "$record_type" "$domain" +short 2>&1 | grep -v '^;;')
        [[ -n "$output" ]] && break
        sleep 1
    done
    echo "$output"
}

# -------- Main Logic --------
{
echo "=== DNS Final Recon Report for: $DOMAIN ==="
echo "Generated: $DATE"

# ---------- NS ----------
echo -e "\n=== Name Servers (NS) ==="
ns_records=$(safe_dig NS "$DOMAIN")
[[ -z "$ns_records" ]] && ns_records=$(host -t ns "$DOMAIN" 2>/dev/null | awk '{print $NF}' | sort -u)
print_or_fallback "$ns_records" "NS"

# ---------- MX ----------
echo -e "\n=== Mail Servers (MX) ==="
mx_records=$(safe_dig MX "$DOMAIN")
[[ -z "$mx_records" ]] && mx_records=$(host -t mx "$DOMAIN" 2>/dev/null | awk '{print $NF}' | sort -u)
print_or_fallback "$mx_records" "MX"

# ---------- CNAME ----------
echo -e "\n=== Canonical Names (CNAME) ==="
cname_records=$(safe_dig CNAME "$DOMAIN" | sort -u)
print_or_fallback "$cname_records" "CNAME"

# ---------- TXT ----------
echo -e "\n=== TXT Records ==="
txt_records=$(safe_dig TXT "$DOMAIN" | sed -E 's/^"//; s/"$//' | sort -u)
print_or_fallback "$txt_records" "TXT"

# ---------- WHOIS ----------
echo -e "\n=== WHOIS IP Ranges ==="
a_records=$(safe_dig A "$DOMAIN" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}')
if [[ -z "$a_records" ]]; then
    echo "No A records found."
else
    for ip in $a_records; do
        cidr=$(whois "$ip" 2>/dev/null | grep -i '^CIDR' | head -n1 | cut -d':' -f2 | xargs)
        netrange=$(whois "$ip" 2>/dev/null | grep -i '^NetRange' | head -n1 | cut -d':' -f2 | xargs)
        if [[ -n "$cidr" || -n "$netrange" ]]; then
            echo "$ip -> CIDR: ${cidr:-N/A}  NetRange: ${netrange:-N/A}"
        else
            echo "$ip -> No WHOIS info found."
        fi
    done
fi

# ---------- Debug ----------
echo -e "\n=== Debug Info ==="
echo "Temp files in: $TMPDIR"

} | tee "$OUTDIR/$REPORT"
