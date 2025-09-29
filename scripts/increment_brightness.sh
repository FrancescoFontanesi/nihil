#!/usr/bin/env bash
set -euo pipefail

BACKLIGHT="backlight"                # se necessario cambia il nome del device
OUTFILE="/home/nihil/.config/quickshell/nihil/tmp/brightness_percent"    # file letto da QML

# cambia luminosità (usa il comando che usi già)
brightnessctl -c "$BACKLIGHT" set +10% >/dev/null 2>&1 || true

# ottieni valori per calcolare percentuale (se il tuo brightnessctl supporta get/max)
cur=$(brightnessctl -c "$BACKLIGHT" get 2>/dev/null || echo "")
max=$(brightnessctl -c "$BACKLIGHT" max 2>/dev/null || echo "")

if [[ -n "$cur" && -n "$max" && "$max" -ne 0 ]]; then
  pct=$(awk -v c="$cur" -v m="$max" 'BEGIN{printf "%d", (c/m)*100}')
  printf "%s\n" "$pct" > "${OUTFILE}.tmp" && mv "${OUTFILE}.tmp" "$OUTFILE"
fi
