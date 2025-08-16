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
    CPU_MODEL=$(lscpu | grep "Model name" | head -1 | sed 's/Model name://g' | sed 's/^[ \t]*//g' | sed 's/[ \t]*$//g' | tr -s ' ' | sed 's/BIOS.*//g')
    CPU_CORES=$(lscpu | grep "Core(s) per socket" | head -1 | sed 's/Core(s) per socket://g' | sed 's/^[ \t]*//g' | sed 's/[ \t]*$//g')
    CPU_SOCKETS=$(lscpu | grep "Socket(s)" | head -1 | sed 's/Socket(s)://g' | sed 's/^[ \t]*//g' | sed 's/[ \t]*$//g')
    PHYSICAL_CORES=$((CPU_CORES * CPU_SOCKETS))
    CPU_MODEL="$CPU_MODEL ($PHYSICAL_CORES cores)"
    CPU_ARCHITECTURE=$(lscpu | grep "Architecture" | head -1 | sed 's/Architecture://g' | sed 's/^[ \t]*//g' | sed 's/[ \t]*$//g' | tr -s ' ')

elif [[ -f /proc/cpuinfo ]]; then
    CPU_MODEL=$(grep "model name" /proc/cpuinfo | head -1 | cut -d':' -f2 | sed 's/^[ \t]*//')
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


