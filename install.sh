#!/bin/bash
set -e

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Header ---
clear
echo -e "${CYAN}"
echo "=============================================="
echo " Windows Docker Installer"
echo " Made by Deepak"
echo "=============================================="
echo -e "${NC}"
echo "Select an option:"
echo "1️⃣ Install Windows 10 (fresh & background start)"
echo "2️⃣ Start existing Windows 10 container with backup"
echo "3️⃣ Install Windows 11 (fresh & background start)"
echo "4️⃣ Exit setup"
echo ""
read -p " Enter your choice (1-4): " choice

case $choice in
# -------------------- OPTION 1 --------------------
1)
    echo -e "${CYAN}⚙️ Starting Windows 10 installation...${NC}"
    sleep 1
    sudo apt update -y
    sudo apt install -y ca-certificates curl gnupg lsb-release
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update -y
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

    sudo systemctl enable docker
    sudo systemctl start docker || echo "⚠️ Docker could not start automatically."

    DOCKER_DATA_DIR="/tmp/docker-data"
    sudo mkdir -p "$DOCKER_DATA_DIR"
    sudo chmod 777 "$DOCKER_DATA_DIR"

    echo -e "${CYAN}⚙️ Creating .env file...${NC}"
    cat <<EOF > .env
WINDOWS_USERNAME=Deepak
WINDOWS_PASSWORD=sankhla
EOF

    echo -e "${CYAN} Creating windows10.yml...${NC}"
    cat <<'EOF' > windows10.yml
services:
  windows:
    image: dockurr/windows
    container_name: windows10
    environment:
      VERSION: "10"
      USERNAME: ${WINDOWS_USERNAME}
      PASSWORD: ${WINDOWS_PASSWORD}
      RAM_SIZE: "4G"
      CPU_CORES: "4"
    cap_add:
      - NET_ADMIN
    ports:
      - "8006:8006"
      - "3389:3389/tcp"
    volumes:
      - /tmp/docker-data:/mnt/disco1
      - windows10-data:/mnt/windows-data
    devices:
      - "/dev/kvm:/dev/kvm"
      - "/dev/net/tun:/dev/net/tun"
    restart: always
volumes:
  windows10-data:
EOF

    echo -e "${GREEN} Launching Windows 10 container in background...${NC}"
    docker compose -f windows10.yml up -d
    echo -e "${GREEN}✅ Windows 10 Installation complete!${NC}"
    ;;

# -------------------- OPTION 2 --------------------
2)
  echo -e "${YELLOW}♻️ Starting existing Windows 10 container...${NC}"
  docker compose -f windows10.yml up -d
  ;;

# -------------------- OPTION 3 --------------------
3)
  echo -e "${CYAN}⚙️ Starting Windows 11 installation...${NC}"
  sleep 1
  DOCKER_DATA_DIR="/tmp/docker-data11"
  sudo mkdir -p "$DOCKER_DATA_DIR"
  sudo chmod 777 "$DOCKER_DATA_DIR"

  echo -e "${CYAN}⚙️ Creating .env file...${NC}"
  cat <<EOF > .env
WINDOWS_USERNAME=Deepak
WINDOWS_PASSWORD=sankhla
EOF

  echo -e "${CYAN} Creating windows11.yml...${NC}"
  cat <<'EOF' > windows11.yml
services:
  windows:
    image: dockurr/windows
    container_name: windows11
    environment:
      VERSION: "11"
      USERNAME: ${WINDOWS_USERNAME}
      PASSWORD: ${WINDOWS_PASSWORD}
      RAM_SIZE: "4G"
      CPU_CORES: "4"
    cap_add:
      - NET_ADMIN
    ports:
      - "8011:8006"
      - "3390:3389/tcp"
    volumes:
      - /tmp/docker-data11:/mnt/disco1
      - windows11-data:/mnt/windows-data
    devices:
      - "/dev/kvm:/dev/kvm"
      - "/dev/net/tun:/dev/net/tun"
    restart: always
volumes:
  windows11-data:
EOF

  echo -e "${GREEN} Launching Windows 11 container in background...${NC}"
  docker compose -f windows11.yml up -d
  echo -e "${GREEN}✅ Windows 11 Installation complete!${NC}"
  ;;

# -------------------- OPTION 4 (EXIT) --------------------
4)
  echo -e "${YELLOW}👋 Exiting setup... Bye Deepak!${NC}"
  exit 0
  ;;

# -------------------- INVALID --------------------
*)
  echo -e "${RED}Invalid option! Please run the script again.${NC}"
  ;;
esac
