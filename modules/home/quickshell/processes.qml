Process {
    id: wifiProc
    command: ["sh", "-c", "nmcli -t -f IN-USE,SIGNAL dev wifi | grep '^*' | cut -d: -f2"]

    stdout: SplitParser {
        onRead: data => {
            if (!data) return
            wifiPercent = parseInt(data.trim())
        }
    }
}


Process {
    id: cpuTempProc
    // Using single quotes inside the shell command to minimize shell-escaping drama
    command: ["sh", "-c", "sensors | grep 'Package id 0' | awk '{print ''$4}' | tr -d '+°C'"]
    
    stdout: SplitParser {
        onRead: (data) => {
            if (data) {
                cpuTemp = data.trim();
            }
        }
    }
    Component.onCompleted: running = true
}

Process {
    id: pipewireVolumeProc
    command: ["sh", "-c", "wpctl get-volume @DEFAULT_SINK@"]
    stdout: SplitParser {
        onRead: data => {
            if (!data) return

            // Remove "Volume:" prefix if present
            var cleaned = data.trim().replace(/^Volume:\s*/, "")

            // Convert to float
            var volumeFloat = parseFloat(cleaned)

            if (!isNaN(volumeFloat)) {
                // Convert fraction (0.0–1.0) to percent
                pipewireVolume = Math.round(volumeFloat * 100) + "%"
            }
        }
    }

    Component.onCompleted: running = true
}

Process {
    id: memProc
    command: ["sh", "-c", "free | grep Mem"]
    stdout: SplitParser {
        onRead: data => {
            if (!data) return
            var parts = data.trim().split(/\s+/)
            
            // Column 2 is "Used" (what Fastfetch shows)
            var usedKiB = parseInt(parts[2]) || 0
            var usedGiB = usedKiB / (1024 * 1024)
            
            // Column 1 is "Total"
            var totalKiB = parseInt(parts[1]) || 1
            var totalGiB = totalKiB / (1024 * 1024)
            
            // Column 6 is "Available" (what you saw as 9.9)
            var availableKiB = parseInt(parts[6]) || 0
            
            // Fastfetch Style String: "5.7 GiB / 15.5 GiB"
            memUsageStr = usedGiB.toFixed(2);
            
            // Percentage for your progress bar
            memPercent = (usedKiB / totalKiB)
        }

    }
    Component.onCompleted: running = true
}

// Logic to fetch and parse CPU data
Process {
    id: cpuProc
    command: ["sh", "-c", "head -1 /proc/stat"]
    stdout: SplitParser {
        onRead: data => {
            if (!data) return;
            var p = data.trim().split(/\s+/);
            var idle = parseInt(p[4]) + parseInt(p[5]);
            var total = p.slice(1, 8).reduce((a, b) => a + parseInt(b), 0);
            
            if (lastCpuTotal > 0) {
                cpuUsage = Math.round(100 * (1 - (idle - lastCpuIdle) / (total - lastCpuTotal)));
            }
            
            lastCpuTotal = total;
            lastCpuIdle = idle;
        }
    }
}

Process {
    id: windowTitleProc
    // Command to get current window title in Hyprland
    command: ["sh", "-c", "hyprctl activewindow | grep 'title:' | cut -d ':' -f2- | sed 's/^ //'"]

    stdout: SplitParser {
        onRead: data => {
            if (!data) return
            currentWindowTitle = data.trim()
        }
    }

    // Automatically run on startup
    Component.onCompleted: running = true
}

Process {
    id: mediaTitleProc
    command: ["bash", "-lc", "playerctl metadata title 2>/dev/null || true"]
    stdout: SplitParser {
        onRead: data => {
            mediaTitle = data ? data.trim() : ""
        }
    }
    Component.onCompleted: running = true
}

Process {
    id: mediaStatusProc
    command: ["bash", "-lc", "playerctl status 2>/dev/null || echo \"Stopped\""]
    stdout: SplitParser {
        onRead: data => {
            if (!data) {
                mediaStatus = "Stopped"
                isPlaying = false
                return
            }
            var status = data.trim()
            mediaStatus = status
            isPlaying = status === "Playing"
        }
    }
    Component.onCompleted: running = true
}

Process {
    id: mediaPositionProc
    command: ["bash", "-lc", "playerctl position 2>/dev/null || echo \"0\""]
    stdout: SplitParser {
        onRead: data => {
            if (!data) {
                mediaPosition = 0
                return
            }
            var pos = parseFloat(data.trim())
            if (!isNaN(pos)) mediaPosition = pos
        }
    }
    Component.onCompleted: running = true
}

Process {
    id: mediaLengthProc
    command: ["bash", "-lc", "playerctl metadata mpris:length 2>/dev/null || echo \"0\""]
    stdout: SplitParser {
        onRead: data => {
            if (!data) {
                mediaLength = 0
                return
            }
            var len = parseFloat(data.trim())
            if (!isNaN(len)) mediaLength = len / 1000000 // Convert from microseconds to seconds
        }
    }
    Component.onCompleted: running = true
}

Process {
    id: mediaArtProc
    command: ["bash", "-lc", "playerctl metadata mpris:artUrl 2>/dev/null || echo \"\""]
    stdout: SplitParser {
        onRead: data => {
            mediaArtUrl = data ? data.trim() : ""
        }
    }
    Component.onCompleted: running = true
}
