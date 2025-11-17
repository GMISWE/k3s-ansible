#!/bin/bash

# Exit on error
set -e

# Function to detect OS
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VERSION=$VERSION_ID
    else
        echo "Cannot detect OS"
        exit 1
    fi
}

# Function to install dependencies for Ubuntu/Debian
install_ubuntu_deps() {
    echo "Installing dependencies for Ubuntu/Debian..."
    sudo apt-get update
    sudo apt-get install -y python3 python3-pip sshpass openssh-client python3-venv
}

# Function to install dependencies for RHEL/CentOS
install_rhel_deps() {
    echo "Installing dependencies for RHEL/CentOS..."
    sudo yum -y update
    sudo yum install -y python3 python3-pip sshpass openssh-clients python3-venv
}

# Main installation
echo "Setting up Ansible environment..."

# Detect OS
detect_os

# Install OS-specific dependencies
case $OS in
    "Ubuntu"|"Debian GNU/Linux")
        install_ubuntu_deps
        ;;
    "Red Hat Enterprise Linux"|"CentOS Linux")
        install_rhel_deps
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac
# Create and activate Python virtual environment
echo "Creating Python virtual environment..."
python3 -m venv ansible-venv
source ansible-venv/bin/activate

# Upgrade pip in virtual environment
python3 -m pip install --upgrade pip

# Install Ansible and required collections
echo "Installing Ansible and required collections..."
python3 -m pip install ansible

export PATH=$HOME/.local/bin:$PATH
# Install required Ansible collections
ansible-galaxy collection install -r collections/requirements.yml

echo "Installation complete!"
echo "Please ensure your SSH keys are properly configured for passwordless access to target hosts."

# Generate SSH key pair if it doesn't exist
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "Generating SSH key pair..."
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
    echo "SSH key pair generated."
fi

echo ""
echo "Your public SSH key is:"
cat ~/.ssh/id_rsa.pub
echo ""
echo "Add this public key to the authorized_keys file on each target host"
echo "You can do this manually or use ssh-copy-id <hostname> for each host"


