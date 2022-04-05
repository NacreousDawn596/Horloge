#!/bin/bash

sudo apt-get install npm nodejs
clear
sudo pacman -Sy npm nodejs
clear
sudo dnf install npm nodejs
clear
sudo npm istall electron -g
clear

set -Eeuo pipefail
cd "$(dirname "$(readlink -f "$0")")"

javascript_file="./app.js"
html_file="./horloge.html"
appicon_file="./icon.png"
app_dir="${HOME}/.local/bin"

if [ ! -f "$javascript_file" ]; then
  echo "Error: javascript is missing ${javascript_file}" >&2
  exit 1
fi

if [ ! -f "$html_file" ]; then
  echo "Error: javascript is missing ${html_file}" >&2
  exit 1
fi

[ ! -d "$app_dir" ] && echo "Creating app directory... (${app_dir})" && mkdir -p "$app_dir"
bin_file="${app_dir}/$(basename "$javascript_file")"
hbin_file="${app_dir}/$(basename "$html_file")"
echo "Copying app image... (${javascript_file} -> ${bin_file})"
cp "$javascript_file" "$bin_file"
echo "Copying app image... (${html_file} -> ${hbin_file})"
cp "$html_file" "$hbin_file"
chmod 755 "$bin_file"

if [ -f "$appicon_file" ]; then
  icons_dir="${HOME}/.local/share/icons/hicolor/256x256/apps"
  [ ! -d "$icons_dir" ] && echo "Creating icons directory... (${icons_dir})" && mkdir -p "$icons_dir"
  echo "Copying 256x256 icon... (${icons_dir}/Horloge.png)"
  cp "$appicon_file" "${icons_dir}/Horloge.png"
else
  echo "Warn: Icon is missing ${appicon_file}"
fi

desktop_apps_dir="${HOME}/.local/share/applications"
[ ! -d "$app_dir" ] && echo "Creating desktop applications directory... (${desktop_apps_dir})" && \
  mkdir -p "$desktop_apps_dir"
desktop_file="${desktop_apps_dir}/Horloge.desktop"
desktop_exec="\"$(printf %q "$bin_file")\""
if [ -n "${Horloge_UPDATE_SOURCE:-}" ]; then
  echo "Add the current Horloge_UPDATE_SOURCE to the desktop file!"
  desktop_exec="env Horloge_UPDATE_SOURCE=\"$(printf %q "$Horloge_UPDATE_SOURCE")\" ${desktop_exec}"
fi
echo "Creating desktop file... ($desktop_file)"
cat > "$desktop_file" <<EOF
[Desktop Entry]
Type=Application
Name=Horloge
Icon=Horloge.png
Exec=electron ${bin_file}
Comment=a simple Horloge made to be set in your second monitor at fullscreen lol
Categories=Utility;
Terminal=false
EOF

xdg-desktop-menu forceupdate --mode user >/dev/null 2>&1 || true

echo
echo
echo "Horloge installed successfully!"
echo "- A desktop file has been created too, so you can start Horloge from your"
echo "  menu."
echo
echo "Have fun!"
exit 0
