#!/bin/bash

# 1. Update Conky immediately
pkill -USR1 conky || conky & 

(
    # --- STEP A: GENERATE THE GTK WIDGET THEME ---
    OOMOX_GTK_COLORS="$HOME/.cache/matugen/oomox-gtk-colors"
    THEME_NAME="Matugen-Theme"
    
    if [ -f "$OOMOX_GTK_COLORS" ]; then
        # This builds the folder in ~/.themes
        oomox-cli -o "$THEME_NAME" "$OOMOX_GTK_COLORS"
    fi

    # --- STEP B: GENERATE ICONS ---
    OOMOX_CLI="/opt/oomox/plugins/icons_papirus/change_color.sh"
    PALETTE="$HOME/.cache/matugen/oomox-matugen.colors"
    ICON_THEME="Papirus-Matugen"
    
    if [ -f "$PALETTE" ]; then
        # Use a fresh build area
        BUILD_DIR="/tmp/oomox-icons-build"
        rm -rf "$BUILD_DIR" && mkdir -p "$BUILD_DIR"
        
        # Oomox generates the theme files directly into the --destdir
        "$OOMOX_CLI" "$PALETTE" --output "$ICON_THEME" --destdir "$BUILD_DIR"
        
        # Verify index.theme exists in the build dir before moving
        if [ -f "$BUILD_DIR/index.theme" ]; then
            rm -rf "$HOME/.icons/$ICON_THEME"
            mkdir -p "$HOME/.icons/$ICON_THEME"
            # Move the contents into the named theme folder
            mv "$BUILD_DIR"/* "$HOME/.icons/$ICON_THEME/"
            gtk-update-icon-cache -f "$HOME/.icons/$ICON_THEME"
        fi
    fi

    # --- STEP C: APPLY THEMES ---
    gsettings set org.gnome.desktop.interface gtk-theme "$THEME_NAME"
    gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"

    # --- STEP D: RESTART THUNAR ---
    thunar -q
    pkill thunar
) &
