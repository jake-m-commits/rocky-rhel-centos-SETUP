if [[ $1 == "basic" ]]; then
    # update
    rpm -qa | wc -l
    sudo dnf upgrade

    # add epel and rpmfusion repos
    sudo dnf install --nogpgcheck https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E %rhel).noarch.rpm
    sudo dnf install --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm
    sudo dnf config-manager --enable powertools

    # nvidia driver
    sudo dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/cuda-rhel8.repo
    sudo dnf install kernel-devel-$(uname -r) kernel-headers-$(uname -r)
    sudo dnf install nvidia-driver nvidia-settings

    # cuda and flatpak
    sudo dnf install cuda-driver flatpak
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    sudo dnf install neofetch ffmpeg gnome-tweaks neovim curl git tmux python3-pip htop
    sudo pip3 install pynvim

    # get flatpaks and remove esr firefox version with DNF && clean up
    flatpak install flathub org.mozilla.firefox
    flatpak install flathub com.discordapp.Discord
    flatpak install flathub com.valvesoftware.Steam
    flatpak install flathub org.kde.krita
    sudo dnf remove firefox
    sudo dnf autoremove
    sudo dnf clean all

    # reboot for nvidia
    systemctl reboot
fi

# check nvidia driver is being used
if [[ $1 == "post-driver-install" ]]; then
    nvidia-smi
    lspci -k | grep nvidia
    flatpak update
fi

# git setup
if [[ $1 == "git" ]]; then
    ssh-keygen -t ed25519 -C "jm9357481@gmail.com"
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
    cat ~/.ssh/id_ed25519.pub
    ssh -T git@github.com
fi

# get my dotfiles
if [[ $1 == "dots" ]]; then
    git clone git@github.com:jake-m-commits/dotfiles
    cd dotfiles/
    cp -r neofetch/ ~/.config/
    cp -r nvim ~/.config/
    cp -r weather/ ~/Documents/
    cd bash
    cp .bash_alias ~/
    cp .bash_alias_git ~/
    cp .bash_func ~/
    cp .bash_profile ~/
    cp .bashrc ~/
    # customize inputrc
    echo '$include /etc/inputrc' >> $HOME/.inputrc
    echo 'set completion-ignore-case on' >> $HOME/.inputrc
fi

# vimplug for neovim
# ./void_install.sh vimplug

# rust setup
# ./void_install.sh rust

# setup nvm for nodejs management
if [[ $1 == "nodejs" ]]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
    command -v nvm
    nvm ls-remote
    nvm install node
    which node
fi

# install some nice tools
if [[ $1 == "nice" ]]; then
    cargo install starship --locked

    cargo install ripgrep

    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install

    cargo install toipe

    sudo dnf install libgit2 cmake
    git clone https://github.com/ogham/exa.git ~/.exa
    cd .exa/
    cargo build --release
    command -v exa
    mkdir -p ~/bin
    cp target/release/exa ~/bin/

    cargo install git-delta

    cargo install --locked bat
fi
