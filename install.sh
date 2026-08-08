#!/bin/bash

clear

# ==============================
#       ZAYROGOD PTERODACTYL
# ==============================

GREEN="\033[1;32m"
CYAN="\033[1;36m"
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
WHITE="\033[1;37m"
RESET="\033[0m"

echo -e "${CYAN}"
echo "╔════════════════════════════════════════════╗"
echo "║                                            ║"
echo "║              Z A Y R O G O D               ║"
echo "║        PTERODACTYL INSTALLER               ║"
echo "║                                            ║"
echo "╚════════════════════════════════════════════╝"
echo -e "${RESET}"

echo -e "${WHITE}1) ${GREEN}Install Pterodactyl Panel${RESET}"
echo -e "${WHITE}2) ${RED}Exit${RESET}"
echo

read -p "Select an option: " OPTION

if [ "$OPTION" = "2" ]; then
    echo "Goodbye!"
    exit 0
fi

if [ "$OPTION" != "1" ]; then
    echo -e "${RED}Invalid option.${RESET}"
    exit 1
fi

# ==============================
# REQUIRE ROOT
# ==============================

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run this installer as root.${RESET}"
    echo
    echo "Example:"
    echo "sudo bash install.sh"
    exit 1
fi

# ==============================
# ADMIN INFORMATION
# ==============================

clear

echo -e "${CYAN}"
echo "╔════════════════════════════════════════════╗"
echo "║          ZAYROGOD ADMIN SETUP              ║"
echo "╚════════════════════════════════════════════╝"
echo -e "${RESET}"

read -p "First Name: " FIRST_NAME
read -p "Last Name: " LAST_NAME
read -p "Admin Username: " USERNAME
read -s -p "Admin Password: " PASSWORD
echo
read -p "Admin Email: " EMAIL

echo
echo -e "${YELLOW}Please verify your information:${RESET}"
echo
echo "First Name : $FIRST_NAME"
echo "Last Name  : $LAST_NAME"
echo "Username   : $USERNAME"
echo "Email      : $EMAIL"
echo

read -p "Continue installation? [y/N]: " CONFIRM

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 0
fi

# ==============================
# BASIC VALIDATION
# ==============================

if [ -z "$FIRST_NAME" ] || \
   [ -z "$LAST_NAME" ] || \
   [ -z "$USERNAME" ] || \
   [ -z "$PASSWORD" ] || \
   [ -z "$EMAIL" ]; then

    echo -e "${RED}All fields are required.${RESET}"
    exit 1
fi

if [ ${#PASSWORD} -lt 8 ]; then
    echo -e "${RED}Password must contain at least 8 characters.${RESET}"
    exit 1
fi

# ==============================
# START
# ==============================

clear

echo -e "${GREEN}"
echo "╔════════════════════════════════════════════╗"
echo "║          ZAYROGOD INSTALLATION             ║"
echo "╚════════════════════════════════════════════╝"
echo -e "${RESET}"

echo -e "${CYAN}[1/4] Checking operating system...${RESET}"

if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "Detected: $PRETTY_NAME"
else
    echo -e "${RED}Unable to detect operating system.${RESET}"
    exit 1
fi

echo
echo -e "${CYAN}[2/4] Installing Pterodactyl...${RESET}"
echo

# Officially recommended third-party installer.
# It handles dependencies, database, nginx and panel setup.

bash <(curl -fsSL https://pterodactyl-installer.se)

INSTALLER_STATUS=$?

if [ $INSTALLER_STATUS -ne 0 ]; then
    echo
    echo -e "${RED}Pterodactyl installation failed.${RESET}"
    exit 1
fi

# ==============================
# ADMIN USER
# ==============================

echo
echo -e "${CYAN}[3/4] Creating administrator account...${RESET}"

cd /var/www/pterodactyl || exit 1

php artisan p:user:make \
    --email="$EMAIL" \
    --username="$USERNAME" \
    --name-first="$FIRST_NAME" \
    --name-last="$LAST_NAME" \
    --password="$PASSWORD" \
    --admin=1

USER_STATUS=$?

if [ $USER_STATUS -ne 0 ]; then
    echo
    echo -e "${YELLOW}The Panel installed, but automatic admin creation failed.${RESET}"
    echo "Run:"
    echo "cd /var/www/pterodactyl"
    echo "php artisan p:user:make"
    exit 1
fi

# ==============================
# FINISHED
# ==============================

echo
echo -e "${GREEN}"
echo "╔════════════════════════════════════════════╗"
echo "║                                            ║"
echo "║       ✓ INSTALLATION SUCCESSFUL             ║"
echo "║                                            ║"
echo "║       PTERODACTYL PANEL IS READY            ║"
echo "║                                            ║"
echo "╚════════════════════════════════════════════╝"
echo -e "${RESET}"

echo
echo -e "${WHITE}Admin Username : ${GREEN}$USERNAME${RESET}"
echo -e "${WHITE}Admin Email    : ${GREEN}$EMAIL${RESET}"
echo
echo -e "${YELLOW}Next step:${RESET}"
echo "Connect your domain to this server and configure HTTPS."
echo
echo -e "${GREEN}ZayroGod — Installation Complete!${RESET}"
