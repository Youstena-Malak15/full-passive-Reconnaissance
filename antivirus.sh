#!/bin/bash
OUTDIR="recon-$1"
mkdir -p "$OUTDIR"
# Then save files like:
echo "some data" > "$OUTDIR/emails.txt"

# === Argument & Setup ===
TARGET="$1"
[ -z "$TARGET" ] && { echo "Usage: $0 <domain>"; exit 1; }

OUTDIR="recon-$TARGET"
mkdir -p "$OUTDIR"
# Then save files like:
echo "some data" > "$OUTDIR/emails.txt"
echo -e "\n# === Header Misconfiguration & AV Fingerprint Check for: $TARGET ==="

# === Curl Basic Headers Check ===
echo -e "\n[+] Fetching HTTP response headers from https://$TARGET..."
curl -s -I -H "User-Agent: Mozilla" "https://$TARGET" \
| grep -Ei "Server:|X-Powered-By|X-AV-Detected|X-AspNet-Version|X-Content-Type-Options|Strict-Transport-Security|X-Frame-Options|X-XSS-Protection" \
| tee "$OUTDIR/basic_headers.txt"

# === Run shcheck.py ===
echo -e "\n[+] Running shcheck.py on https://$TARGET..."
if ! command -v shcheck.py &> /dev/null; then
    echo "[-] Error: shcheck.py not found. Install it with: pipx install shcheck"
    exit 1
fi

shcheck.py "https://$TARGET" | tee "$OUTDIR/shcheck_headers.txt"

echo -e "\n[✔] Antivirus / Header check complete. Results saved in: $OUTDIR\n"
