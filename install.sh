#!/usr/bin/env bash

SOURCE_DIR="$(dirname "${BASH_SOURCE[0]}")"
TARGET_DIR="$HOME/.tilekitty"

if ! curl -Is https://github.com/ &>/dev/null; then
    echo "Cannot reach GitHub. Check network or firewall."
    exit 1
fi

if [ -d "$TARGET_DIR" ]; then
    read -p "Directory $TARGET_DIR exists. Remove it? [y/N] " answer
    case "$answer" in
    [yY][eE][sS] | [yY])
        rm -rf "$TARGET_DIR"
        echo "Removed '$TARGET_DIR'."
        ;;
    *)
        echo "Aborted."
        exit 1
        ;;
    esac
fi

read -p "This installer will erase your hyprland/waybar/gtk4 dotfiles. Proceed? [y/N] " answer
case "$answer" in
[yY][eE][sS] | [yY]) ;;
*)
    echo "Aborted."
    exit 1
    ;;
esac

# create directory and copy files

mkdir -pv "$TARGET_DIR"

cp -rv "$SOURCE_DIR/stubs" "$TARGET_DIR/stubs"
cp -rv "$SOURCE_DIR/scripts" "$TARGET_DIR/scripts"
cp -rv "$SOURCE_DIR/dotfiles" "$TARGET_DIR/dotfiles"
cp -rv "$SOURCE_DIR/resources" "$TARGET_DIR/resources"

if lsmod | grep -q '^nvidia'; then
    echo "NVIDIA Detected - Copying NVIDIA .conf files"
    cp -rv "$SOURCE_DIR/extra/nvidia/"* "$TARGET_DIR"
fi

# download resources

curl -L 'https://github.com/twinkgenocide/tilekitty/releases/download/resources/tilekitty-resources.tar.gz' | tar -xz -C "$TARGET_DIR/resources"

# symlinks

for dir in "$TARGET_DIR/stubs"/*; do
    [ -d "$dir" ] || continue

    base=$(basename "$dir")
    target="$HOME/.config/$base"

    if [ -e "$target" ] || [ -L "$target" ]; then
        echo "Removing existing '$target'"
        rm -rf "$target"
    fi

    ln -sv "$dir" "$target"
done

# gtk4

GTK_DIR="$HOME/.config/gtk-4.0"
if [ -d "$GTK_DIR" ]; then
    rm -rfv "$GTK_DIR"/*
else
    mkdir -pv "$GTK_DIR"
fi

ln -sfv "$TARGET_DIR/resources/gtk4/gtk.css" "$GTK_DIR/gtk.css"
ln -sfv "$TARGET_DIR/resources/gtk4/assets" "$GTK_DIR/assets"
ln -sfv "$TARGET_DIR/resources/css/colors-gtk.css" "$GTK_DIR/colors-gtk.css"

# done!

echo '₍^. .^₎⟆ tilekitty has been installed. enjoy!'
