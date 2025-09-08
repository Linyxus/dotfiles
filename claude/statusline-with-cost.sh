#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract values from JSON
current_dir=$(echo "$input" | jq -r '.workspace.current_dir')
model_name=$(echo "$input" | jq -r '.model.display_name')
total_cost=$(echo "$input" | jq -r '.cost.total_cost_usd')

# Format directory with icon
dir_name=$(basename "$current_dir")
dir_display=$(printf "\033[38;5;117m📁 \033[1;96m%s\033[0m" "$dir_name")

# Format model with icon and gradient colors
model_display=$(printf "\033[38;5;141m⚡ \033[1;95m%s\033[0m" "$model_name")

# Format cost with dynamic colors and icon
cost_display=""
if [[ -n "$total_cost" && "$total_cost" != "null" ]]; then
    cost_value=$(echo "$total_cost" | bc -l 2>/dev/null)
    if (( $(echo "$cost_value < 1.0" | bc -l 2>/dev/null) )); then
        cost_color="38;5;82"  # Bright green for low cost (< $1)
    elif (( $(echo "$cost_value < 5.0" | bc -l 2>/dev/null) )); then
        cost_color="38;5;226" # Yellow for moderate cost ($1-5)
    else
        cost_color="38;5;196" # Red for high cost (> $5)
    fi
    cost_display=$(printf " \033[38;5;240m•\033[0m \033[${cost_color}m💰 \$%.3f\033[0m" "$total_cost")
fi

# Display elegant status line
printf "%s \033[38;5;240m•\033[0m %s%s" \
    "$dir_display" \
    "$model_display" \
    "$cost_display"