#!/bin/bash

echo -e "\e[93m
                      __          _            _     
 ___   _   _   ___   / _|   ___  | |_    ___  | |__  
/ __| | | | | / __| | |_   / _ \ | __|  / __| | '_ \ 
\__ \ | |_| | \__ \ |  _| |  __/ | |_  | (__  | | | |
|___/  \__, | |___/ |_|    \___|  \__|  \___| |_| |_|
       |___/                                         
\e[0m"

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


