#!/bin/bash
# =====================================================
# 🪟 Windows Setup Script for Docker (Codespace)
# Made by Deepak (Fixed version by GPT)
# =====================================================

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
echo "     Windows Docker Installer"
echo "        Made by Deepak"
echo "=============================================="
echo -e "${NC}"

echo "Select an option:"
echo "1️⃣ Install Windows 10 (fresh & background start)"
echo "2️⃣ Start existing Windows 10 container with backup"
echo "3️⃣ Exit"
echo ""
read -p "👉 Enter your choice (1-3): " choice

case $choice in
1)
  echo -e "${CYAN}⚙️ Starting Windows 10 installation...${NC}"
  sleep 1

  # --- Update and install Docker ---
  echo -e "${YELLOW}🔄 Updating system packages...${NC}"
  sudo apt update -y

  echo -e "${YELLOW}🐳 Installing Docker and Docker Compose...${NC}"
  sudo apt install -y ca-certificates curl gnupg lsb-release

  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt update -y
  sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

  # --- Enable Docker service ---
  echo -e "${CYAN}🚀 Enabling Docker service...${NC}"
  sudo systemctl enable docker
  sudo systemctl start docker || echo "⚠️ Docker could not start automatically. Please check systemctl status docker."

  # --- Check storage ---
  echo -e "${BLUE}💾 Checking available storage...${NC}"
  df -h | grep -E "Filesystem|/tmp|/home|/"
  sleep 1

  # --- Create Docker data folder ---
  DOCKER_DATA_DIR="/tmp/docker-data"
  echo -e "${BLUE}📂 Creating Docker data folder in $DOCKER_DATA_DIR ...${NC}"
  sudo mkdir -p "$DOCKER_DATA_DIR"
  sudo chmod 777 "$DOCKER_DATA_DIR"

  # --- Configure Docker daemon ---
  echo -e "${CYAN}🛠 Setting Docker data-root...${NC}"
  sudo mkdir -p /etc/docker
  cat <<EOF | sudo tee /etc/docker/daemon.json >/dev/null
{
  "data-root": "$DOCKER_DATA_DIR"
}
EOF

  # --- Restart Docker ---
  echo -e "${YELLOW}🔁 Restarting Docker service...${NC}"
  sudo systemctl restart docker || echo "⚠️ Could not restart Docker. Make sure it is installed."

  # --- Create .env ---
  echo -e "${CYAN}⚙️ Creating .env file...${NC}"
  cat <<EOF > .env
WINDOWS_USERNAME=Deepak
WINDOWS_PASSWORD=sankhla
EOF
  echo ".env" >> .gitignore

  # --- Create docker-compose file ---
  echo -e "${CYAN}📄 Creating windows10.yml...${NC}"
  cat <<'EOF' > windows10.yml
services:
  windows:
    image: dockurr/windows
    container_name: windows
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
      - windows-data:/mnt/windows-data
    devices:
      - "/dev/kvm:/dev/kvm"
      - "/dev/net/tun:/dev/net/tun"
    stop_grace_period: 2m
    restart: always
volumes:
  windows-data:
EOF

  # --- Verify Docker ---
  echo -e "${BLUE}🔍 Checking Docker configuration...${NC}"
  if ! command -v docker >/dev/null; then
    echo -e "${RED}❌ Docker not found!${NC}"
    exit 1
  fi
  docker info | grep "Docker Root Dir" || echo "⚠️ Could not verify Docker root dir."

  # --- Run container ---
  echo -e "${GREEN}🚀 Launching Windows 10 container in background...${NC}"
  docker compose -f windows10.yml up -d

  # --- Done ---
  echo ""
  echo -e "${GREEN}✅ Installation complete!${NC}"
  echo "-------------------------------------------"
  echo " Docker Root Dir: $DOCKER_DATA_DIR"
  echo " Container: windows"
  echo " Image: dockurr/windows (Windows 10)"
  echo " Access via RDP -> Host: localhost | Port: 3389"
  echo " User: Deepak | Password: sankhla"
  echo "-------------------------------------------"
  echo "️ Use 'docker ps' to verify container status."
  ;;
2)
  echo -e "${YELLOW}♻️ Starting existing Windows 10 container...${NC}"
  docker compose -f windows10.yml up -d
  ;;
3)
  echo -e "${RED}👋 Exiting installer. Goodbye!${NC}"
  exit 0
  ;;
*)
  echo -e "${RED}Invalid option! Please run the script again.${NC}"
  ;;
esac
