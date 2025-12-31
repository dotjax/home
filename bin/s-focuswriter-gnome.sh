#!/bin/bash

# s-focuswriter-gnome.sh
# Configures FocusWriter (Flatpak) to use a dark theme (Kvantum) on GNOME.

APP_ID="org.gottcode.FocusWriter"
KVANTUM_CONFIG_DIR="$HOME/.config/Kvantum"
KVANTUM_CONFIG_FILE="$KVANTUM_CONFIG_DIR/kvantum.kvconfig"

echo "Configuring FocusWriter for GNOME Dark Mode..."

# 1. Install Kvantum Style for Flatpak (Qt 6.x and 5.15 just in case)
echo "Installing Kvantum style for Flatpak..."
flatpak install -y org.kde.KStyle.Kvantum//6.9
flatpak install -y org.kde.KStyle.Kvantum//5.15-23.08

# 2. Create Kvantum config if it doesn't exist
if [ ! -f "$KVANTUM_CONFIG_FILE" ]; then
    echo "Creating Kvantum configuration..."
    mkdir -p "$KVANTUM_CONFIG_DIR"
    cat <<EOF > "$KVANTUM_CONFIG_FILE"
[General]
theme=KvGnomeDark
EOF
    echo "Created $KVANTUM_CONFIG_FILE with theme 'KvGnomeDark'."
else
    echo "Kvantum config already exists at $KVANTUM_CONFIG_FILE. Skipping creation."
fi

# 3. Apply Flatpak Overrides
echo "Applying Flatpak overrides..."

# Force Kvantum style
flatpak override --user --env=QT_STYLE_OVERRIDE=kvantum "$APP_ID"

# Allow access to Kvantum config
flatpak override --user --filesystem="xdg-config/Kvantum:ro" "$APP_ID"

# Allow access to KDE globals (sometimes needed for color schemes)
flatpak override --user --filesystem="xdg-config/kdeglobals:ro" "$APP_ID"

echo "Done! FocusWriter should now use the Kvantum dark theme."
