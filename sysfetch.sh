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
    CPU_MODEL=$(lscpu | grep "Model name" | sed 's/Model name://g' | sed 's/^[ \t]*//')
    CPU_ARCHITECTURE=$(lscpu | grep "Architecture" | sed 's/Architecture://g' | sed 's/^[ \t]*//')
elif [[ -f /proc/cpuinfo ]]; then
    CPU_MODEL=$(grep "model name" /proc/cpuinfo | head -1 | cut -d':' -f2 | sed 's/^[ \t]*//')
    CPU_ARCHITECTURE=$(uname -m)
elif command -v sysctl &> /dev/null; then
    CPU_MODEL=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Unknown")
    CPU_ARCHITECTURE=$(uname -m)
else
    CPU_MODEL="Unknown"
    CPU_ARCHITECTURE=$(uname -m)
fi

printf "   \e[94m%-1s\e[0m %s\n" "Model:" "$CPU_MODEL"
printf "   \e[94m%-1s\e[0m %s\n" "Architecture:" "$CPU_ARCHITECTURE"
echo


