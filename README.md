# Full Passive Reconnaissance Tool

A modular Bash-based framework that performs comprehensive passive reconnaissance on a target domain. It automates subdomain enumeration, DNS info gathering, email harvesting,application and antivirus enumerat>

## Features

- Enumerates subdomains using multiple industry tools (subfinder, assetfinder, amass)  
- Resolves subdomains to IP addresses  
- Gathers DNS records (A, MX, NS, TXT, CNAME), WHOIS data, ASN info  
- Harvests emails via theHarvester and Hunter.io API  
- get application and antivirus info
- Saves all output in organized folders per target  

```
## Folder Structure

full-passive-reconnaissance/
├── modules/
│ ├── sub.sh           # Subdomain enumeration
│ ├── dns.sh           # DNS and network info
│ ├── email.sh         # Email harvesting
│ ├── antivirus.sh     # Antivirus info 
│ ├── application.sh   # Application info 
├── ultimate-recon.sh  # Main script to run the full recon
├── README.md          # This documentation
```

## Requirements

Install these tools before running the framework:
1) sudo apt update
2) sudo apt install -y golang whois dnsutils dnsrecon theharvester
3) go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
4) go install -v github.com/tomnomnom/assetfinder@latest    
5) go install -v github.com/owasp-amass/amass/v4/...@latest
6) Make sure Go binaries are in your PATH: export PATH=$PATH:$(go env GOPATH)/bin
7) Hunter.io API Key (Required for email.sh) so Register at hunter.io to get your API
8) put your API key in this line: API_KEY="YOUR_API_KEY_HERE", If no key is provided, the Hunter.io part of the email module will be skipped.

## How to Run
1) Make scripts executable by chmod +x /*.sh
2) ./ultimate-recon.sh 
