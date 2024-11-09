# buniatko
Secure shell misconfiguration script
Will check for open ports on an IP address, check whether weak SSH ciphers are being used, checks whether root login is possible and tries to bruteforce the SSH with hydra.

Prerequisites :

Before running this script, ensure the following tools are installed on your system:
- nmap - for port scanning
- hydra - for brute-force testing
- ssh - for SSH connections

- To install the required tools on Ubuntu or Debian-based systems, run:
sudo apt update
sudo apt install -y nmap hydra openssh-client

For CentOS or RHEL-based systems, run the following:

bash
sudo yum install -y epel-release
sudo yum install -y nmap hydra openssh-clients


If you're using macOS, install the required tools using Homebrew:

brew install nmap hydra openssh

Verifying successful prerequisite installation : 
nmap --version
hydra -h
ssh -V
