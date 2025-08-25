# sysfetch

A small, portable system information script written in [`bash`](sysfetch.sh:1) that prints key details about your machine in a concise, colored output.

Features
- Shows kernel and hostname.
- Detects internal and external IP addresses (uses `ip`, `ifconfig`, `curl` or `wget` where available).
- Displays CPU model, core count and architecture (supports `lscpu`, `/proc/cpuinfo` and macOS `sysctl` fallbacks).
- Attempts to detect GPU model across Linux, macOS and Windows (`lspci`, `system_profiler`, `wmic` where available) — with reasonable fallbacks.
- Lists disk devices and sizes (uses `lsblk`, `fdisk`, `diskutil` or `/sys/block`).
- Shows live memory usage with a simple progress bar (reads `/proc/meminfo` or uses macOS `vm_stat`).
- Minimal dependencies and graceful fallbacks when commands are not available.

Requirements
- bash

Usage
1. Make the script executable
   `chmod 755 ./sysfetch.sh`
2. Run the script: `./sysfetch.sh`

Notes
- The script tries several platform-specific commands and will display "Unknown" or "Not available" when data sources are missing.
- Colors and Unicode block characters are used for visual output; if your terminal does not support ANSI colors or Unicode blocks, the display may be less polished.

