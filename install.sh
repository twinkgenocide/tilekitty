#!/usr/bin/env bash

SOURCE_DIR="$(dirname "${BASH_SOURCE[0]}")"
TARGET_DIR="$HOME/.tilekitty"
DEFAULT_WALLPAPER_URL="https://w.wallhaven.cc/full/3k/wallhaven-3kvjxv.jpg"

if ! curl -Is https://github.com/ &>/dev/null; then
    echo "Cannot reach GitHub. Check network or firewall."
    exit 1
fi

if [ -d "$TARGET_DIR" ]; then
    read -p "Tilekitty install detected. All files will be erased unless inside user directories. Proceed? [y/N] " answer
    case "$answer" in
    [yY][eE][sS] | [yY])
        find "$TARGET_DIR" -mindepth 1 -type f ! -path '*user*' -delete
        find "$TARGET_DIR" -depth -type d -empty ! -path '*user' -delete
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

cp -rvn "$SOURCE_DIR/stubs" "$TARGET_DIR"
cp -rvn "$SOURCE_DIR/scripts" "$TARGET_DIR"
cp -rvn "$SOURCE_DIR/dotfiles" "$TARGET_DIR"
cp -rvn "$SOURCE_DIR/resources" "$TARGET_DIR"
cp -rvn "$SOURCE_DIR/env.sh" "$TARGET_DIR"

if lsmod | grep -q '^nvidia'; then
    echo "NVIDIA Detected - Copying NVIDIA .conf files"
    cp -rvn "$SOURCE_DIR/extra/nvidia"/* "$TARGET_DIR"
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

# download wallpaper if it does not exist
if [ ! -f "$TARGET_DIR/resources/user/wallpaper" ]; then
    # curl -l "$DEFAULT_WALLPAPER_URL" >"$TARGET_DIR/resources/user/wallpaper"
    curl -l "$DEFAULT_WALLPAPER_URL" | magick convert - -colorspace Gray "$TARGET_DIR/resources/user/wallpaper"
fi

# done!

echo '₍^. .^₎⟆ tilekitty has been installed. enjoy!'
