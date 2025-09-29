#!/usr/bin/env bash
bat="BAT1"   # cambia in BAT1 se serve

cap="$(cat "/sys/class/power_supply/$bat/capacity" 2>/dev/null || echo 0)"
st="$(cat "/sys/class/power_supply/$bat/status"   2>/dev/null || echo Unknown)"
charging=false; [[ "$st" =~ (Charging|Full) ]] && charging=true

# COMPACT one-line JSON:
jq -cn --argjson cap "$cap" --argjson ch "$charging" '{percent:$cap, charging:$ch}'