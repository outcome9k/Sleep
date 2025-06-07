#!/bin/bash
clear

# ══════════════════════════════════════════════
# COLORS & SYMBOLS
# ══════════════════════════════════════════════
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
BG_BLUE='\e[44m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m'
FG_WHITE='\033[1;37m'

CHECK="${GREEN}✓${NC}"
CROSS="${RED}✗${NC}"
ARROW="${CYAN}➜${NC}"
STAR="${YELLOW}★${NC}"
LINE="${BLUE}$(printf '%*s' $(tput cols) | tr ' ' '═')${NC}"

# ══════════════════════════════════════════════
# HEADER
# ══════════════════════════════════════════════
display_header() {
    termwidth=$(tput cols)
    full_line=$(printf '%*s' "$termwidth" | tr ' ' '═')
    title="Server Management Toolkit"
    padding=$(( (termwidth - ${#title}) / 2 ))
    echo -e "${BLUE}${full_line}${NC}"
    printf "%${padding}s" ""
    echo -e "${BG_BLUE}${FG_WHITE}${title}${NC}"
}

# ══════════════════════════════════════════════
# SYSTEM INFORMATION
# ══════════════════════════════════════════════
show_system_info() {
    ERRORS=()

    PUBLIC_IP=$(curl -s https://api.ipify.org)
    [[ -z "$PUBLIC_IP" ]] && ERRORS+=("Failed to get Public IP") && PUBLIC_IP="N/A"

    DOMAIN=$(hostname -f 2>/dev/null)
    [[ -z "$DOMAIN" ]] && DOMAIN="N/A"

    NS=$(grep "nameserver" /etc/resolv.conf | awk 'NR==1{print $2}')
    [[ -z "$NS" ]] && NS="N/A" && ERRORS+=("Nameserver info not found")

    RAM_TOTAL=$(free -h | awk '/Mem:/ {print $2}')
    RAM_USED=$(free -h | awk '/Mem:/ {print $3}')
    RAM_FREE=$(free -h | awk '/Mem:/ {print $4}')

    CPU_MODEL=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2- | sed 's/^ //')
    CPU_CORES=$(grep -c ^processor /proc/cpuinfo)
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8"%"}')

    GPU_INFO=$(lspci | grep -i 'vga\|3d\|2d' | head -n1)
    [[ -z "$GPU_INFO" ]] && GPU_INFO="N/A" && ERRORS+=("GPU info not found")

    TEMP_INFO=$(sensors 2>/dev/null | grep -m1 'Package id 0:' | awk '{print $4}')
    [[ -z "$TEMP_INFO" ]] && TEMP_INFO="❌ Not available (try: sudo apt install lm-sensors)" && ERRORS+=("Temperature info not available")

    DNS_CHECK=$(dig +short google.com @"$NS")
    [[ -z "$DNS_CHECK" ]] && DNS_CHECK="N/A" && ERRORS+=("DNS check failed")

    echo -e "\n${LINE}"
    echo -e "========= 🖥️ SYSTEM INFORMATION =========\n"
    echo -e "🌐 ${YELLOW}Public IP:${NC}        $PUBLIC_IP"
    echo -e "📡 ${YELLOW}Domain:${NC}           $DOMAIN"
    echo -e "🧭 ${YELLOW}Nameserver:${NC}       $NS"
    echo -e "🧠 ${YELLOW}RAM Usage:${NC}        $RAM_USED / $RAM_TOTAL (Free: $RAM_FREE)"
    echo -e "⚙️ ${YELLOW}CPU Model:${NC}        $CPU_MODEL"
    echo -e "🔢 ${YELLOW}CPU Cores:${NC}        $CPU_CORES"
    echo -e "🔥 ${YELLOW}CPU Usage:${NC}        $CPU_USAGE"
    echo -e "🎮 ${YELLOW}GPU:${NC}              $GPU_INFO"
    echo -e "🌡️ ${YELLOW}Temperature:${NC}      $TEMP_INFO"
    echo -e "🔎 ${YELLOW}DNS Check:${NC}        $DNS_CHECK"
    echo -e "\n========================================="

    [[ ${#ERRORS[@]} -ne 0 ]] && {
        echo -e "\n${RED}⚠️  Errors Detected:${NC}"
        for error in "${ERRORS[@]}"; do
            echo -e "❌  $error"
        done
    }

    echo -e "${LINE}\n"
}

# ══════════════════════════════════════════════
# SERVICE STATUS
# ══════════════════════════════════════════════
show_server_status() {
    echo -e "\n${LINE}"
    echo -e "${STAR} ${GREEN}VPS Server Service Status:${NC}"

    services=("nginx" "ssh" "xray" "openvpn" "fail2ban")
    for svc in "${services[@]}"; do
        status=$(systemctl is-active "$svc" 2>/dev/null)
        if [[ "$status" == "active" ]]; then
            echo -e "${CHECK} $svc is ${GREEN}running${NC}"
        else
            echo -e "${CROSS} $svc is ${RED}NOT running${NC}"
            journalctl -u "$svc" --no-pager -n 3 2>/dev/null | sed 's/^/    /'
        fi
    done

    echo -e "\n${STAR} ${GREEN}Open Ports:${NC}"
    for port in 22 80 443 8080 8443 5555; do
        if ss -tuln | grep -q ":$port "; then
            echo -e "${CHECK} Port $port is ${GREEN}open${NC}"
        else
            echo -e "${CROSS} Port $port is ${RED}closed${NC}"
        fi
    done

    echo -e "${LINE}"
}

# ══════════════════════════════════════════════
# MAIN MENU
# ══════════════════════════════════════════════
show_menu() {
    echo -e "\n${MAGENTA}MAIN MENU - Select an Option:${NC}\n"

    left_col=(
        "0 ∆ System Update & Upgrade"
        "1 ∆ Install MHSanaei 3X-UI"
        "2 ∆ Install Alireza0 3X-UI"
        "3 ∆ Install 4-0-4 UDP Boost"
        "4 ∆ Install UDP Custom Manager"
        "5 ∆ Install DARKSSH Manager"
        "6 ∆ Install 404-SSH Manager"
        "7 ∆ Install ZI-VPN"
    )

    right_col=(
        "8 ∆ Uninstall ZI-VPN"
        "9 ∆ Install AutoScript"
        "10 ∆ Install zi-Vpn menu"
        "11 ∆ Install zi-v1"
        "12 ∆ Install zi-v2 AMD"
        "13 ∆ Install zi-v2 ARM"
        "14 ∆ SSH + SlowDNS (443)"
        "404 ∆ Selector Tool"
    )

    for i in "${!left_col[@]}"; do
        printf "${ARROW} ${GREEN}%-3s${NC} %-35s" "$(echo "${left_col[$i]}" | cut -d' ' -f1)" "$(echo "${left_col[$i]}" | cut -d' ' -f2-)"
        printf "${ARROW} ${GREEN}%-5s${NC} %-s\n" "$(echo "${right_col[$i]}" | cut -d' ' -f1)" "$(echo "${right_col[$i]}" | cut -d' ' -f2-)"
    done

    echo -e "\n${ARROW} ${YELLOW}help${NC} ∆ Show Help"
    echo -e "${ARROW} ${RED}exit${NC} ∆ Quit Program"
    echo -e "${LINE}"
}

# ══════════════════════════════════════════════
# INSTALL OPTIONS
# ══════════════════════════════════════════════
install_option() {
    case $1 in
        0) apt update && apt upgrade -y ;;
        1) bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh) ;;
        2) bash <(curl -Ls https://raw.githubusercontent.com/alireza0/x-ui/master/install.sh) ;;
        3) git clone https://github.com/nyeinkokoaung404/udp-custom && cd udp-custom && chmod +x install.sh && ./install.sh ;;
        4) wget -qO install.sh https://raw.githubusercontent.com/noobconner21/UDP-Custom-Script/main/install.sh && chmod +x install.sh && bash install.sh ;;
        5) wget -q https://raw.githubusercontent.com/sbatrow/DARKSSH-MANAGER/master/Dark && chmod +x Dark && ./Dark ;;
        6) wget -q https://raw.githubusercontent.com/nyeinkokoaung404/ssh-manger/main/hehe && chmod +x hehe && ./hehe ;;
        7) wget -O zi.sh https://raw.githubusercontent.com/zahidbd2/udp-zivpn/main/zi.sh && chmod +x zi.sh && ./zi.sh ;;
        8) wget -O ziun.sh https://raw.githubusercontent.com/zahidbd2/udp-zivpn/main/uninstall.sh && chmod +x ziun.sh && ./ziun.sh ;;
        9|10|11|12|13|14|404)
            echo -e "${YELLOW}[Info] Placeholder - Not implemented yet${NC}"
            ;;
        *)
            echo -e "${RED}Invalid option. Try again.${NC}"
            ;;
    esac
}

# ══════════════════════════════════════════════
# MAIN LOOP
# ══════════════════════════════════════════════
while true; do
    display_header
    show_system_info
    show_server_status
    show_menu

    read -rp "${ARROW} Enter Option: " choice

    case $choice in
        help) show_help ;;
        exit) echo -e "${GREEN}Goodbye!${NC}"; exit 0 ;;
        [0-9]*|404) install_option "$choice"; read -rp "Press Enter to return..." ;;
        *) echo -e "${RED}Invalid choice!${NC}" ;;
    esac
done
