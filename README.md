# sysfetch

A small, portable system information script written in [`bash`](sysfetch.sh:1) that prints key details about your machine in a concise, colored output.

### Features

1. Operating system information (kernel, hostname, internal and external IP)
2. System uptime
3. Processor information (model, architecture, core count)
4. Graphics card information
5. Storage information (disk list and sizes)
6. Memory information (total RAM, free memory)
7. Network latency to Google and Cloudflare DNS (only with `-i` flag)
8. Export information to text file (only with `-e` flag)

### Requirements

- bash

### Usage

1. Make the script executable
   `chmod 755 ./sysfetch.sh`
2. Run the script: `./sysfetch.sh`

### Flags

- `-e`: Export the system information to a timestamped text file.
- `-i`: Measure internet latency to Google and Cloudflare DNS.

#### Examples:

| Action                      | Command               |
| --------------------------- | --------------------- |
| Export only                 | `./sysfetch.sh -e`    |
| Check internet latency only | `./sysfetch.sh -i`    |
| Export and check latency    | `./sysfetch.sh -e -i` |

### Notes

- The script tries several platform-specific commands and will display "Unknown" or "Not available" when data sources are missing.
- Colors and Unicode block characters are used for visual output; if your terminal does not support ANSI colors or Unicode blocks, the display may be less polished.
