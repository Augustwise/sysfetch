#!/bin/bash

echo -e "\e[93m
                      __          _            _     
 ___   _   _   ___   / _|   ___  | |_    ___  | |__  
/ __| | | | | / __| | |_   / _ \ | __|  / __| | '_ \ 
\__ \ | |_| | \__ \ |  _| |  __/ | |_  | (__  | | | |
|___/  \__, | |___/ |_|    \___|  \__|  \___| |_| |_|
       |___/                                         
\e[0m"

echo -e "\e[96mOperating System:\e[0m"
KERNEL=$(uname -sr)
HOSTNAME=$(hostname)

if command -v ip &> /dev/null; then
    INTERNAL_IP=$(ip addr | grep "inet " | grep -v "127.0.0.1" | awk '{print $2}' | cut -d'/' -f1 | head -n1)
elif command -v ifconfig &> /dev/null; then
    INTERNAL_IP=$(ifconfig | grep "inet " | grep -v "127.0.0.1" | awk '{print $2}' | head -n1)
else
    INTERNAL_IP="Unknown"
fi
if [[ -z "$INTERNAL_IP" ]]; then
    INTERNAL_IP="Not available"
fi

if command -v curl &> /dev/null; then
    EXTERNAL_IP=$(curl -s icanhazip.com)
elif command -v wget &> /dev/null; then
    EXTERNAL_IP=$(wget -qO- icanhazip.com)
else
    EXTERNAL_IP="Unknown"
fi
if [[ -z "$EXTERNAL_IP" ]]; then
    EXTERNAL_IP="Not available"
fi

printf "   \e[94m%-1s\e[0m %s\n" "Kernel:" "$KERNEL"
printf "   \e[94m%-1s\e[0m %s\n" "Hostname:" "$HOSTNAME"
printf "   \e[94m%-1s\e[0m %s\n" "Internal IP:" "$INTERNAL_IP"
printf "   \e[94m%-1s\e[0m %s\n" "External IP:" "$EXTERNAL_IP"
echo

echo -e "\e[96mProcessor:\e[0m"

if command -v lscpu &> /dev/null; then
    CPU_MODEL=$(lscpu | grep "Model name" | head -1 | sed 's/Model name://g' | sed 's/^[ \t]*//g' | sed 's/[ \t]*$//g' | tr -s ' ' | sed 's/BIOS.*//g' | sed 's/[[:space:]]*$//')
    CPU_CORES=$(lscpu | grep "Core(s) per socket" | head -1 | sed 's/Core(s) per socket://g' | sed 's/^[ \t]*//g' | sed 's/[ \t]*$//g')
    CPU_SOCKETS=$(lscpu | grep "Socket(s)" | head -1 | sed 's/Socket(s)://g' | sed 's/^[ \t]*//g' | sed 's/[ \t]*$//g')
    PHYSICAL_CORES=$((CPU_CORES * CPU_SOCKETS))
    CPU_MODEL=$(echo "$CPU_MODEL" | sed 's/[[:space:]]*$//' | tr -s ' ')
    CPU_MODEL="$CPU_MODEL ($PHYSICAL_CORES cores)"
    CPU_ARCHITECTURE=$(lscpu | grep "Architecture" | head -1 | sed 's/Architecture://g' | sed 's/^[ \t]*//g' | sed 's/[ \t]*$//g' | tr -s ' ')

elif [[ -f /proc/cpuinfo ]]; then
    CPU_MODEL=$(grep "model name" /proc/cpuinfo | head -1 | cut -d':' -f2 | sed 's/^[ \t]*//' | sed 's/[[:space:]]*$//' | tr -s ' ')
    PHYSICAL_CORES=$(grep "^core id" /proc/cpuinfo | sort -u | wc -l)
    
    if [[ $PHYSICAL_CORES -eq 0 ]]; then
        PHYSICAL_CORES=$(grep "^physical id" /proc/cpuinfo | sort -u | wc -l)
        if [[ $PHYSICAL_CORES -eq 0 ]]; then
            PHYSICAL_CORES=$(grep -c "^processor" /proc/cpuinfo)
        fi
    fi
    
    CPU_MODEL="$CPU_MODEL ($PHYSICAL_CORES cores)"
    CPU_ARCHITECTURE=$(uname -m)

elif command -v sysctl &> /dev/null; then
    CPU_MODEL=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Unknown")
    PHYSICAL_CORES=$(sysctl -n hw.physicalcpu 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo "Unknown")
    
    if [[ "$PHYSICAL_CORES" != "Unknown" ]]; then
        CPU_MODEL="$CPU_MODEL ($PHYSICAL_CORES cores)"
    fi
    
    CPU_ARCHITECTURE=$(uname -m)

else
    CPU_MODEL="Unknown"
    CPU_ARCHITECTURE=$(uname -m)
fi

printf "   \e[94m%-1s\e[0m %s\n" "Model:" "$CPU_MODEL"
printf "   \e[94m%-1s\e[0m %s\n" "Architecture:" "$CPU_ARCHITECTURE"
echo

echo -e "\e[96mGraphics:\e[0m"

if command -v lspci &> /dev/null; then
    GPU_MODEL=$(lspci | grep -i "vga\|3d\|display" | head -1 | sed 's/.*: //' | sed 's/\[.*\]//' | sed 's/^[ \t]*//' | sed 's/[ \t]*$//' | tr -s ' ')
    if [[ -z "$GPU_MODEL" ]]; then
        GPU_MODEL=$(lspci | grep -i "graphics" | head -1 | sed 's/.*: //' | sed 's/\[.*\]//' | sed 's/^[ \t]*//' | sed 's/[ \t]*$//' | tr -s ' ')
    fi

elif command -v system_profiler &> /dev/null; then
    GPU_MODEL=$(system_profiler SPDisplaysDataType 2>/dev/null | grep "Chipset Model" | head -1 | sed 's/.*: //' | sed 's/^[ \t]*//' | sed 's/[ \t]*$//' | tr -s ' ')

elif command -v wmic &> /dev/null; then
    GPU_MODEL=$(wmic path win32_VideoController get name /format:list 2>/dev/null | grep "Name=" | head -1 | sed 's/Name=//' | sed 's/\r//' | sed 's/^[ \t]*//' | sed 's/[ \t]*$//' | tr -s ' ')

elif [[ -d /sys/class/drm ]]; then
    for card in /sys/class/drm/card*/device; do
        if [[ -f "$card/vendor" && -f "$card/device" ]]; then
            VENDOR_ID=$(cat "$card/vendor" 2>/dev/null)
            DEVICE_ID=$(cat "$card/device" 2>/dev/null)
            if [[ "$VENDOR_ID" == "0x10de" ]]; then
                GPU_MODEL="NVIDIA Graphics Card"
                break
            elif [[ "$VENDOR_ID" == "0x1002" ]]; then
                GPU_MODEL="AMD Graphics Card"
                break
            elif [[ "$VENDOR_ID" == "0x8086" ]]; then
                GPU_MODEL="Intel Graphics Card"
                break
            fi
        fi
    done
fi

if [[ -z "$GPU_MODEL" ]]; then
    GPU_MODEL="Unknown"
fi

printf "   \e[94m%-1s\e[0m %s\n" "Model:" "$GPU_MODEL"
echo

echo -e "\e[96mStorage:\e[0m"

bytes_to_gb() {
    local bytes=$1
    if [[ $bytes -gt 0 ]]; then
        echo "scale=1; $bytes / 1073741824" | bc 2>/dev/null || echo $(($bytes / 1073741824))
    else
        echo "0"
    fi
}

DISK_TABLE_DATA=""

if command -v lsblk &> /dev/null; then
    while IFS= read -r line; do
        DISK_NAME=$(echo "$line" | awk '{print $1}')
        DISK_SIZE_BYTES=$(echo "$line" | awk '{print $2}')
        if [[ -n "$DISK_NAME" && -n "$DISK_SIZE_BYTES" && "$DISK_SIZE_BYTES" != "0" ]]; then
            DISK_SIZE_GB=$(bytes_to_gb "$DISK_SIZE_BYTES")
            DISK_TABLE_DATA+="/dev/$DISK_NAME:${DISK_SIZE_GB}GB\n"
        fi
    done < <(lsblk -bdno NAME,SIZE,TYPE | grep "disk" | grep -v "loop\|ram")

elif command -v fdisk &> /dev/null; then
    while IFS= read -r line; do
        DISK_PATH=$(echo "$line" | awk '{print $2}' | sed 's/:$//')
        DISK_SIZE_STR=$(echo "$line" | grep -o '[0-9.]*[[:space:]]*[KMGT]B' | head -1)
        if [[ -n "$DISK_PATH" && -n "$DISK_SIZE_STR" ]]; then
            if [[ "$DISK_SIZE_STR" =~ ([0-9.]+)[[:space:]]*([KMGT])B ]]; then
                SIZE_NUM="${BASH_REMATCH[1]}"
                SIZE_UNIT="${BASH_REMATCH[2]}"
                case "$SIZE_UNIT" in
                    "K") DISK_SIZE_GB=$(echo "scale=1; $SIZE_NUM / 1048576" | bc 2>/dev/null || echo "0.0") ;;
                    "M") DISK_SIZE_GB=$(echo "scale=1; $SIZE_NUM / 1024" | bc 2>/dev/null || echo "$(echo $SIZE_NUM | cut -d. -f1)") ;;
                    "G") DISK_SIZE_GB="$SIZE_NUM" ;;
                    "T") DISK_SIZE_GB=$(echo "scale=1; $SIZE_NUM * 1024" | bc 2>/dev/null || echo "$((${SIZE_NUM%.*} * 1024))") ;;
                esac
                DISK_TABLE_DATA+="$DISK_PATH:${DISK_SIZE_GB}GB\n"
            fi
        fi
    done < <(fdisk -l 2>/dev/null | grep "Disk /dev/" | grep -v "loop\|ram")

elif command -v diskutil &> /dev/null; then
    while IFS= read -r disk; do
        if [[ -n "$disk" ]]; then
            DISK_INFO=$(diskutil info "$disk" 2>/dev/null)
            DISK_SIZE_BYTES=$(echo "$DISK_INFO" | grep "Disk Size" | awk '{print $3}' | tr -d '()')
            if [[ -n "$DISK_SIZE_BYTES" && "$DISK_SIZE_BYTES" != "0" ]]; then
                DISK_SIZE_GB=$(bytes_to_gb "$DISK_SIZE_BYTES")
                DISK_TABLE_DATA+="$disk:${DISK_SIZE_GB}GB\n"
            fi
        fi
    done < <(diskutil list | grep "/dev/disk" | grep "physical" | awk '{print $1}')

elif [[ -d /sys/block ]]; then
    for disk in /sys/block/*/; do
        DISK_NAME=$(basename "$disk")
        if [[ ! "$DISK_NAME" =~ ^(loop|ram|sr|md) ]]; then
            if [[ -f "$disk/size" ]]; then
                SECTORS=$(cat "$disk/size" 2>/dev/null)
                if [[ "$SECTORS" -gt 0 ]]; then
                    DISK_SIZE_BYTES=$((SECTORS * 512))
                    DISK_SIZE_GB=$(bytes_to_gb "$DISK_SIZE_BYTES")
                    DISK_TABLE_DATA+="/dev/$DISK_NAME:${DISK_SIZE_GB}GB\n"
                fi
            fi
        fi
    done
fi

if [[ -n "$DISK_TABLE_DATA" ]]; then
    printf "   \e[94m%-12s %-10s\e[0m\n" "Disk" "Size"
    printf "   \e[90m%-12s %-10s\e[0m\n" "────────────" "──────────"
    echo -e "$DISK_TABLE_DATA" | while IFS=':' read -r disk_name disk_size; do
        if [[ -n "$disk_name" && -n "$disk_size" ]]; then
            printf "   %-12s %-10s\n" "$disk_name" "$disk_size"
        fi
    done
else
    printf "   \e[94m%-1s\e[0m %s\n" "Disks:" "Unknown"
fi
echo -e "\e[96mMemory:\e[0m"

get_memory_data() {
    if [[ -f /proc/meminfo ]]; then
        local total_kb=$(grep "MemTotal:" /proc/meminfo | awk '{print $2}')
        local available_kb=$(grep "MemAvailable:" /proc/meminfo | awk '{print $2}')
        [[ -z "$available_kb" ]] && available_kb=$(grep "MemFree:" /proc/meminfo | awk '{print $2}')
        local used_kb=$((total_kb - available_kb))
        echo "$used_kb $available_kb $total_kb"
    elif command -v vm_stat &> /dev/null; then
        local page_size=$(vm_stat | grep "page size" | awk '{print $8}')
        local free_pages=$(vm_stat | grep "Pages free" | awk '{print $3}' | tr -d '.')
        local total_mem=$(sysctl -n hw.memsize 2>/dev/null)
        local total_kb=$((total_mem / 1024))
        local free_kb=$((free_pages * page_size / 1024))
        local used_kb=$((total_kb - free_kb))
        echo "$used_kb $free_kb $total_kb"
    else
        echo "0 0 0"
    fi
}

draw_bar() {
    local used=$1 total=$2 width=20
    local filled=$((used * width / total))
    local bar=""
    for ((i=0; i<width; i++)); do
        if [[ $i -lt $filled ]]; then
            bar+="█"
        else
            bar+="░"
        fi
    done
    echo "$bar"
}

printf "   \e[94m%-8s\e[0m " "Total:"
while true; do
    read used_kb free_kb total_kb <<< $(get_memory_data)
    used_gb=$(echo "scale=2; $used_kb / 1048576" | bc 2>/dev/null || echo "0.00")
    free_gb=$(echo "scale=2; $free_kb / 1048576" | bc 2>/dev/null || echo "0.00")
    total_gb=$(echo "scale=2; $total_kb / 1048576" | bc 2>/dev/null || echo "0.00")
    percent=$((used_kb * 100 / total_kb))
    bar=$(draw_bar $used_kb $total_kb)
    
    printf "\r   \e[94m%-8s\e[0m %s GB  \e[94m%-8s\e[0m %s GB  \e[90m[\e[92m%s\e[90m] %s%%\e[0m" \
           "Total:" "$total_gb" "Free:" "$free_gb" "$bar" "$percent"
    sleep 0.7
done

