function wifiIconForPercent(p) {
    if (p >= 80) return "󰤨" // full
    if (p >= 60) return "󰤥" // strong
    if (p >= 40) return "󰤢" // medium
    if (p >= 20) return "󰤟" // weak
    return "󰤯"              // none
}

function refreshMediaState() {
    Qt.callLater(function() {
        mediaTitleProc.running = true
        mediaStatusProc.running = true
        mediaPositionProc.running = true
        mediaLengthProc.running = true
        mediaArtProc.running = true
    })
}

function fetchTheme() {
    var xhr = new XMLHttpRequest()
    xhr.open("GET", "file:///home/rhys/.config/quickshell/colors.json")
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (!xhr.responseText) return

            try {
                var clean = xhr.responseText.replace(/^\uFEFF/, "").replace(/\0/g, "").trim()

                var data = JSON.parse(clean)

                if (data.special && data.special.background)
                    backgroundColor = data.special.background
                if (data.colors && data.special.foreground)
                    accentColor = data.special.foreground
                if (data.colors && data.special.lightBackground)
                    lighterBackgroundColor = data.special.lightBackground

            } catch(e) {
                console.warn("Failed to parse wal colors.json:", e)
            }
        }
    }
    xhr.send()
}
