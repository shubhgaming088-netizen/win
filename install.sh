#!/bin/bash
# =====================================================
# 🪟 Windows Setup Script for Docker (Codespace)
# Made by Deepak
# =====================================================

set -e

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- Header ---
clear
echo -e "${CYAN}"
echo "=============================================="
echo "        Windows Docker Installer"
echo "            Made by Deepak"
echo "=============================================="
echo -e "${NC}"

# --- Menu ---
echo "Select an option:"
echo "1️⃣  Install Windows 10 (fresh & background start)"
echo "2️⃣  Start existing Windows 10 container with backup"
echo "3️⃣  Exit"
echo ""
read -p "👉 Enter your choice (1-3): " choice

case $choice in
1)
echo -e "${GREEN}⚙️ Starting Windows 10 installation...${NC}"
sleep 1

# --- 1️⃣ Check storage ---
echo "📦 Checking available storage..."
df -h | grep -E "Filesystem|/tmp|/home|/"
sleep 1

# --- 2️⃣ Create Docker data folder ---
DOCKER_DATA_DIR="/tmp/docker-data"
echo "📁 Creating Docker data folder in $DOCKER_DATA_DIR ..."
sudo mkdir -p "$DOCKER_DATA_DIR"
sudo chmod 777 "$DOCKER_DATA_DIR"

# --- 3️⃣ Configure Docker ---
echo "⚙️ Setting Docker data-root..."
sudo mkdir -p /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json >/dev/null
{
"data-root": "$DOCKER_DATA_DIR"
}
EOF

# --- 4️⃣ Restart Docker ---
echo "🔁 Restarting Docker service..."
sudo systemctl restart docker || echo "⚠️ Could not restart Docker. Make sure it is installed."

# --- 5️⃣ Create .env ---
echo "🔐 Creating .env file..."
cat <<EOF > .env
WINDOWS_USERNAME=Deepak
WINDOWS_PASSWORD=sankhla
EOF
echo ".env" >> .gitignore

# --- 6️⃣ Create docker-compose file ---
echo "🪟 Creating windows10.yml..."
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
    stop_grace_period: 6h
    restart: always

volumes:
  windows-data:
EOF

# --- 7️⃣ Verify Docker ---
echo "🧩 Checking Docker configuration..."
docker info | grep "Docker Root Dir" || echo "⚠️ Could not verify Docker root dir."

# --- 8️⃣ Run container in background ---
echo "🚀 Launching Windows 10 container in background..."
docker-compose -f windows10.yml up -d

# --- 9️⃣ Done ---
echo ""
echo -e "${GREEN}✅ Installation complete and container started!${NC}"
echo "-------------------------------------------"
echo "🔹 Docker Root Dir: $DOCKER_DATA_DIR"
echo "🔹 Container: windows"
echo "🔹 Image: dockurr/windows (Windows 10)"
echo "🔹 Access via RDP -> Host: localhost | Port: 3389"
echo "🔹 User: Deepak | Password: sankhla"
echo "-------------------------------------------"
echo "🖥️ Use 'docker ps' to verify container status."
;;

2)
echo -e "${CYAN}💾 Starting existing Windows 10 container with backup...${NC}"

# --- Backup existing data ---
DOCKER_DATA_DIR="/tmp/docker-data"
WINDOWS_VOLUME_DIR="windows-data"
BACKUP_DIR="$HOME/windows_backup_$(date +%Y%m%d_%H%M%S)"

if [ -d "$DOCKER_DATA_DIR" ] || [ -d "$WINDOWS_VOLUME_DIR" ]; then
    echo "💾 Existing data found. Creating backup at $BACKUP_DIR ..."
    mkdir -p "$BACKUP_DIR"
    cp -r "$DOCKER_DATA_DIR" "$BACKUP_DIR/" 2>/dev/null || true
    cp -r "$WINDOWS_VOLUME_DIR" "$BACKUP_DIR/" 2>/dev/null || true
    echo "✅ Backup complete."
else
    echo "ℹ️ No existing data found. Skipping backup."
fi

# --- Start container in background ---
echo "🚀 Launching Windows 10 container in background..."
docker-compose -f windows10.yml up -d

echo ""
echo -e "${GREEN}✅ Container started with backup!${NC}"
echo "💾 Backup Location: $BACKUP_DIR"
echo "🖥️ Use 'docker ps' to verify container status."
;;

3)
echo -e "${YELLOW}👋 Exiting installer. Goodbye!${NC}"
exit 0
;;

*)
echo -e "${RED}Invalid option! Please run the script again.${NC}"
;;
esac
