#!/bin/sh
addrepo() { \
    echo "#########################################################"
    echo "## Adding the DTOS core repository to /etc/pacman.conf ##"
    echo "#########################################################"
    grep -qxF "[dtos-core-repo]" /etc/pacman.conf ||
        ( echo " "; echo "[dtos-core-repo]"; echo "SigLevel = Optional DatabaseOptional"; \
        echo "Server = https://gitlab.com/dtos/\$repo/-/raw/main/\$arch") | sudo tee -a /etc/pacman.conf
}

addrepo || error "Error adding DTOS repo to /etc/pacman.conf."

sudo sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf || error "Failed to uncomment multilib repository"
sudo sed -i '/Color/s/^#//;35 i ILoveCandy' /etc/pacman.conf || error "Failed to uncomment Color or to ass ILoveCandy"

echo "paru"

sudo pacman --noconfirm --needed -Sy dtos-core-repo/paru-bin || error "Error installing dtos-core-repo/paru-bin."

echo "pkglist"

paru --needed -Sy - < pkglist.txt || error "Failed to install a required package from pkglist.txt."

echo "copy .local/bin"

cp -Rf /etc/dtos/.local/bin "$HOME/.local" || error "Failed to copy /etc/dtos/.local/bin folder to home/.local/bin"

echo "chmod"

find "$HOME/.local/bin" -type f -print0 | xargs -0 chmod 775 || error "Failed to change permissions of $HOME/.local/bin folder to 775"

echo "dm-setbg"

sudo cp -f "$HOME/Arch-Install-Script/dm-setbg" /usr/bin/ || error "Failed to replace /usr/bin/dm-setbg"

echo "hooks"

sudo mkdir -p /etc/pacman.d/hooks/
sudo cp /etc/dtos/.config/xmonad/pacman-hooks/* /etc/pacman.d/hooks/ || error "Failed to copy xmonad's pacman-hooks for recompilation"
sudo cp -f "$HOME/Arch-Install-Script/pacman_hooks/clean_package_cache.hook /etc/pacman.d/hooks/clean_package_cache.hook" || error "Failed to copy clean_package_cache.hook"

echo "ricemood"

sudo npm install -g ricemood || error "Failed to install ricemood"

echo "zsh"

sudo chsh "$USER" -s "/bin/zsh" || error "Failed to change shell"

echo "makepkg"

sudo sed -i 's/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$(nproc)\"/g' /etc/makepkg.conf || error "Failed to change the number of cores used during compilation"

echo ".bashrc"

rm -f ~/.bashrc || error "Failed to rm .bashrc"

echo ".dotfiles"

git clone https://github.com/ale-bast/.dotfiles ~/.dotfiles || error "Failed to create .dotfiles"

echo "Wallpapers"

mkdir -p ~/Pictures || error "Failed to create ~/Pictures"
git clone https://github.com/ale-bast/Wallpapers ~/Pictures/Wallpapers || error "Failed to create ~/Pictures/Wallpapers"

echo "stow"

cd ~/.dotfiles || error "Failed to cd into ~/.dotfiles"
stow . || error "Failed to stow ."
