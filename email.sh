#!/bin/bash
OUTDIR="recon-$1"
mkdir -p "$OUTDIR"
# Then save files like:
echo "some data" > "$OUTDIR/emails.txt"

# === Configuration ===
DOMAIN="$1"
OUTDIR="recon-$DOMAIN"
HUNTER_API_KEY=""  # Replace with your valid API key
TMP_DIR=$(mktemp -d)

# === Input Validation ===
if [ -z "$DOMAIN" ]; then
  echo "Usage: $0 <domain>"
  exit 1
fi

# === Create Output Directory ===
mkdir -p "$OUTDIR"

# === Run theHarvester ===
echo "[*] Gathering emails from theHarvester..."
theHarvester -d "$DOMAIN" -b all -l 200 > "$TMP_DIR/theharvester.txt" 2>/dev/null

# === Query Hunter.io API ===
echo "[*] Gathering emails from Hunter.io..."
HUNTER_RESPONSE=$(curl -s "https://api.hunter.io/v2/domain-search?domain=$DOMAIN&api_key=$HUNTER_API_KEY")
HUNTER_EMAILS=$(echo "$HUNTER_RESPONSE" | jq -r '.data.emails[].value' 2>/dev/null)

# === Extract emails from theHarvester output ===
HARVESTER_EMAILS=$(grep -E -o "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b" "$TMP_DIR/theharvester.txt" | sort -u)

# === Combine and Deduplicate Emails ===
echo -e "$HARVESTER_EMAILS\n$HUNTER_EMAILS" | sort -u > "$OUTDIR/all_emails.txt"

# === Output: Each email with HaveIBeenPwned check link ===
while IFS= read -r email; do
  echo "$email → Check: https://haveibeenpwned.com/account/$email"
done < "$OUTDIR/all_emails.txt"

# === Cleanup Temporary Files ===
rm -rf "$TMP_DIR"
