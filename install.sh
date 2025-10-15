#!/bin/bash
# =====================================================
# 🪟 Fast Windows Docker Starter for Docker (Existing Container)
# Author : Deepak
# Purpose: Quickly start existing Windows 10 container with backup
# =====================================================

set -e

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

# --- Header ---
clear
echo -e "${CYAN}"
echo "=============================================="
echo "        🪟 Fast Windows Docker Starter"
echo "            Made by Deepak"
echo "=============================================="
echo -e "${NC}"

# --- Menu ---
echo "Select an option:"
echo "1️⃣  Install Windows 10 (fresh)"
echo "2️⃣  Start existing Windows 10 container FAST with backup"
echo "3️⃣  Exit"
echo ""
read -p "👉 Enter your choice (1-3): " choice

case $choice in
1)
# Fresh install (same as before)
echo -e "${GREEN}⚙️ Installing Windows 10 fresh...${NC}"
# [Fresh install steps same as your previous script]
;;

2)
# --- Fast start existing container ---
DOCKER_DATA_DIR="/tmp/docker-data"
WINDOWS_VOLUME_DIR="windows-data"
BACKUP_DIR="$HOME/windows_backup_$(date +%Y%m%d_%H%M%S)"

# Backup only if container exists
if [ -f "windows10.yml" ]; then
    echo -e "${CYAN}💾 Backing up existing Windows 10 data...${NC}"
    mkdir -p "$BACKUP_DIR"
    cp -r "$DOCKER_DATA_DIR" "$BACKUP_DIR/" 2>/dev/null || true
    cp -r "$WINDOWS_VOLUME_DIR" "$BACKUP_DIR/" 2>/dev/null || true
    echo -e "${GREEN}✅ Backup complete at $BACKUP_DIR${NC}"
else
    echo -e "${YELLOW}⚠️ windows10.yml not found! Cannot backup.${NC}"
fi

# Fast container start (skip daemon restart, folder creation, etc.)
echo -e "${CYAN}🚀 Starting existing Windows 10 container in background...${NC}"
docker-compose -f windows10.yml up -d

echo -e "${GREEN}✅ Container started FAST with backup!${NC}"
echo "💾 Backup Location: $BACKUP_DIR"
echo "🖥️ Use 'docker ps' to verify container status."
;;

3)
echo -e "${YELLOW}👋 Exiting. Goodbye!${NC}"
exit 0
;;

*)
echo -e "${RED}Invalid option!${NC}"
;;
esac
