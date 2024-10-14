#!/bin/bash


GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' 

function print_banner() {
    echo -e "${RED}"
    echo " 	██████╗ ██╗   ██╗███╗   ██╗██╗ █████╗ ████████╗██╗  ██╗ ██████╗ "
	echo "	██╔══██╗██║   ██║████╗  ██║██║██╔══██╗╚══██╔══╝██║ ██╔╝██╔═══██╗"
	echo "	██████╔╝██║   ██║██╔██╗ ██║██║███████║   ██║   █████╔╝ ██║   ██║"
	echo "	██╔══██╗██║   ██║██║╚██╗██║██║██╔══██║   ██║   ██╔═██╗ ██║   ██║"
	echo "	██████╔╝╚██████╔╝██║ ╚████║██║██║  ██║   ██║   ██║  ██╗╚██████╔╝"
	echo "	╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝ "
    echo -e "${NC}"
    echo -e "${GREEN}        --- pretoze richard je sedlak ---${NC}"
    echo ""
}


function scan_ports() {
    echo -e "${GREEN}[+] Scanning for open ports on $1...${NC}"
    nmap -p- --open -T4 $1 | grep "open" | awk '{print $1}' | sed 's/\/tcp//g'
}


function hydra_brute_force() {
    echo -e "${GREEN}[+] Running Hydra brute force on $1...${NC}"
    if [ -z "$USERLIST" ] || [ -z "$PASSLIST" ]; then
        echo -e "${YELLOW}[!] No custom wordlists provided, using default weak username/password lists...${NC}"
        echo -e "${YELLOW}[+] Default Username: root, admin${NC}"
        echo -e "${YELLOW}[+] Default Passwords: password, admin, 1234, root${NC}"
        echo -e "root\nadmin" > /tmp/default_usernames.txt
        echo -e "password\nadmin\n1234\nroot" > /tmp/default_passwords.txt
        USERLIST="/tmp/default_usernames.txt"
        PASSLIST="/tmp/default_passwords.txt"
    fi
    hydra -L $USERLIST -P $PASSLIST ssh://$1 -t 4 -V
}


function check_weak_ciphers() {
    echo -e "${GREEN}[+] Checking for weak SSH ciphers on $1...${NC}"
    WEAK_CIPHERS=("arcfour" "arcfour128" "arcfour256" "3des-cbc" "aes128-cbc" "aes256-cbc")
    for cipher in "${WEAK_CIPHERS[@]}"; do
        if ssh -o "Ciphers=$cipher" -p $2 $1 "exit" 2>/dev/null; then
            echo -e "${RED}[!] Weak cipher detected: $cipher on $1:${NC}"
        else
            echo -e "${GREEN}[+] Cipher $cipher not supported.${NC}"
        fi
    done
}


function check_root_login() {
    echo -e "${GREEN}[+] Checking if root login is enabled on $1...${NC}"
    if ssh -o StrictHostKeyChecking=no root@$1 "exit" 2>/dev/null; then
        echo -e "${RED}[!] Root login is enabled on $1!${NC}"
    else
        echo -e "${GREEN}[+] Root login is disabled.${NC}"
    fi
}


function usage() {
    echo "Usage: $0 <target_ip> [-u <username_list>] [-p <password_list>]"
    echo "Example: $0 192.168.1.10 -u users.txt -p passwords.txt"
    echo "Options:"
    echo "  -u <username_list>    Path to username wordlist for brute force"
    echo "  -p <password_list>    Path to password wordlist for brute force"
    exit 1
}


if [ "$#" -lt 1 ]; then
    usage
fi

TARGET=$1
USERLIST=""
PASSLIST=""


shift
while getopts "u:p:" OPTION; do
    case $OPTION in
    u) USERLIST=$OPTARG ;;
    p) PASSLIST=$OPTARG ;;
    *) usage ;;
    esac
done


print_banner


echo -e "${GREEN}[+] Starting Port Scan on $TARGET...${NC}"
open_ports=$(scan_ports $TARGET)
echo -e "${GREEN}[+] Open ports: $open_ports${NC}"


echo -e "${GREEN}[+] Checking weak SSH ciphers on default SSH port (22)...${NC}"
check_weak_ciphers $TARGET 22


check_root_login $TARGET


hydra_brute_force $TARGET

echo -e "${GREEN}[+] SSH Misconfiguration Check Completed.${NC}"
