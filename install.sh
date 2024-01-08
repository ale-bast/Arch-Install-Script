#!/bin/sh
echo "#########################################################"
echo "## Adding the DTOS core repository to /etc/pacman.conf ##"
echo "#########################################################"
grep -qxF "[dtos-core-repo]" /etc/pacman.conf || ( echo " "; echo "[dtos-core-repo]"; echo "SigLevel = Optional DatabaseOptional"; \ echo "Server = https://gitlab.com/dtos/\$repo/-/raw/main/\$arch") | sudo tee -a /etc/pacman.conf } addrepo || error "Error adding DTOS repo to /etc/pacman.conf."

sudo sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf || error "Failed to uncomment multilib repository"
sudo sed -i '/Color/ s/#//' /etc/pacman.conf
sudo sed -i '/ILoveCandy/ s/#//' /etc/pacman.conf

sudo pacman --noconfirm --needed -Sy dtos-core-repo/paru-bin || error "Error installing dtos-core-repo/paru-bin."

sudo paru --needed -Sy - cat pkglist.txt || error "Failed to install a required package from pkglist.txt."

cp -Rf /etc/dtos/.local/* /home/axel/.local || error "Failed to copy /etc/dtos/.local/bin folder to home/.local/bin"

find "$HOME/.local/bin" -type f -print0 | xargs -0 chmod 775 || error "Failed to change permissions of $HOME/.local/bin folder to 775"

sudo cp /etc/dtos/.config/xmonad/pacman-hooks/recompile-xmonad.hook /etc/pacman.d/hooks/
sudo cp /etc/dtos/.config/xmonad/pacman-hooks/recompile-xmonadh.hook /etc/pacman.d/hooks/

sudo npm install -g ricemood

sudo chsh "$USER" -s "/bin/zsh"
