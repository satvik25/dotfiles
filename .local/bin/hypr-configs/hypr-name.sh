#!/usr/bin/env zsh

## Hyprland workspace icons
### Define icon keywords
typeset -A HYPR_WS_ICONS=(
  # keyword   	icon
    code      	"󰅩"
    web       	"󰖟"
    mail		""
    msg			"󱜾"
    music     	"󰎇"
    work 		""
)

### Rename workspaces
hypr-name () {
    # if [[ $# -lt 2 ]]; then
    #     print -u2 "Usage: hypr-name <workspace-number> <keyword|name> [name]"
    #     return 1
    # fi

    local ws="$(hyprctl -j activewindow | jq -r '.workspace.id')"
    # shift

    local label_parts=()
    local icon_replaced=0
    local icon_value=""

    for arg in "$@"; do
        if [[ $icon_replaced -eq 0 && -n ${HYPR_WS_ICONS[$arg]} ]]; then
            icon_value="${HYPR_WS_ICONS[$arg]}"
            label_parts+=("$icon_value")
            icon_replaced=1
        else
            label_parts+=("$arg")
        fi
    done

    # Build the label string
    local label=""
    for ((i = 1; i <= ${#label_parts[@]}; ++i)); do
        if [[ $i -eq 1 ]]; then
            label="${label_parts[i]}"
        elif [[ "${label_parts[i]}" == "$icon_value" ]]; then
            label+="  ${label_parts[i]}"
        elif [[ "${label_parts[i]}" =~ ^[0-9]+$ ]]; then
            label+="  ${label_parts[i]}"
        else
            label+=" ${label_parts[i]}"
        fi
    done

    # Add one leading and one trailing space, per your original
    if (( $# > 0 )); then
        label=" $label "
    fi
    
    hyprctl dispatch renameworkspace "$ws" "$label" "$ws" ""
}

# If someone invokes this file directly, call the function with all args:
hypr-name "$@"
