
#!/bin/sh

sensors | awk '/^Core /{++r; gsub(/[^[:digit:]]+/, "", $3); s+=$3} END{printf "%.1f°C\n", s/(10*r)}'
