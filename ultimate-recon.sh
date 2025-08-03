#!/bin/bash

# === Colors ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# === Logo ===
echo -e "${BLUE}"
echo "   ____                      "
echo "  |  _ \\ ___  ___ ___  _ __  "
echo "  | |_) / _ \\/ __/ _ \\| '_ \\ "
echo "  |  _ <  __/ (_| (_) | | | |"
echo "  |_| \\_\\___|\\___\\___/|_| |_|  - Youstena's Recon Tool"
echo -e "${NC}"

# === Function to prompt for domain ===
set_domain() {
  read -p "🌐 Enter target domain: " DOMAIN
  if [ -z "$DOMAIN" ]; then
    echo -e "${RED}[-] Domain is required. Exiting.${NC}"
    exit 1
  fi
  OUTDIR="recon-$DOMAIN"
  mkdir -p "$OUTDIR"
  echo -e "${GREEN}[+] Target domain set to: $DOMAIN${NC}"
}

# Prompt domain for the first time
set_domain

# === Menu Loop ===
while true; do
  echo -e "\n${YELLOW}Select the recon module to run:${NC}"
  echo -e "${BLUE}1${NC}) Subdomain Enumeration"
  echo -e "${BLUE}2${NC}) Email Enumeration"
  echo -e "${BLUE}3${NC}) Application Enumeration"
  echo -e "${BLUE}4${NC}) Antivirus Enumeration"
  echo -e "${BLUE}5${NC}) DNS Enumeration"
  echo -e "${BLUE}6${NC}) Change Target Domain"
  echo -e "${BLUE}0${NC}) Exit"

  read -p "➡  Enter your choice: " CHOICE

  case $CHOICE in
    1)
      echo -e "${GREEN}[+] Running Subdomain Enumeration (sub.sh)...${NC}"
      bash sub.sh "$DOMAIN"
      ;;
    2)
      echo -e "${GREEN}[+] Running Email Enumeration (email.sh)...${NC}"
      bash email.sh "$DOMAIN"
      ;;
    3)
      echo -e "${GREEN}[+] Running Application Enumeration (apps.sh)...${NC}"
      bash apps.sh "$DOMAIN"
      ;;
    4)
      echo -e "${GREEN}[+] Running Antivirus Enumeration (antivirus.sh)...${NC}"
      bash antivirus.sh "$DOMAIN"
      ;;
    5)
      echo -e "${GREEN}[+] Running DNS Enumeration (dns.sh)...${NC}"
      bash dns.sh "$DOMAIN"
      ;;
    6)
      set_domain
      ;;
    0)
      echo -e "${YELLOW}[*] Exiting. Happy hacking!${NC}"
      exit 0
      ;;
    *)
      echo -e "${RED}[!] Invalid option. Try again.${NC}"
      ;;
  esac
done
