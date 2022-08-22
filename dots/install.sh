#!/bin/bash
set -ue

echo ""
echo "-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-"
echo "|              dotfiles installer                         |"
echo "-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-"

function sudoer_check() {
    echo "Check sudo privilege"
    if test -t 0; then
        stty -echo
        printf "Type your password: "
        read password
        echo "$password" | sudo -p '' -S echo "a" > /dev/null
        stty echo
        echo ""
    else
        echo "    SKIP : Not runnnig in terminal"
    fi
    echo ""

}

function initial_check() {
    echo "Check essential package"

    if [[ "$(uname -a)" != *Darwin* ]]; then
        if [[ "$(command -v curl)" == "" ]]; then
            sudo apt-get update
            sudo apt-get install -y curl git
        fi
    fi
    echo ""
}

function system_check() {
    echo "Check System"

    if [[ "$(uname -a)" == *Darwin* ]]; then
        echo "    System -> macOS(Darwin)"
    elif [[ "$(uname -a)" == *microsoft* ]]; then
        echo "    System -> WSL2"
    else
        echo "    System -> others"
    fi

    if [[ "$(uname -p)" == arm ]]; then
        echo "    arch   -> arm64"
    else
        echo "    arch   -> x86_64"
    fi
    echo ""
}

function make_symlink() {
    echo "Make Symlink"
    
    DIR_ROOT="$(pwd)"
    DOTPATH=$DIR_ROOT/dotfiles
    
    cd $DOTPATH
    for f in .??*
    do
        ln -sfn "$DOTPATH/$f" "$HOME"/"$f"
        echo "    $f -> $HOME/$f"
    done
    cd $DIR_ROOT
    echo ""
}

function install_brew() {
    echo "Install Homebrew"
    source ${HOME}/.zprofile

    if [[ -z "$(command -v brew)" ]]; then
        curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | bash --login
        source ${HOME}/.zprofile
    else
        echo "    SKIP : Homebrew is already exsist"
    fi
    echo ""

}
function install_brew_packages() {
    echo "Install Apps"

    if [[ "$(uname -a)" == Linux* ]]; then
        sudo apt-get update
        sudo apt-get install -y build-essential
    fi

    brew update

    cli_app=("zsh" "nvm" "neovim" "go" "neofetch" "cask" "exa")

    for cli in ${cli_app[@]}; do
        if [[ "$(brew list | grep -x $cli)" == $cli || "$(command -v $cli)" != "" ]]; then
            echo "    SKIP : $cli is installed"
        else
            brew install $cli
            if [[ $cli == "zsh" ]]; then
                command -v zsh | sudo tee -a /etc/shells
                sudo chsh -s "$(command -v zsh)" "${USER}"
            fi
        fi
    done
    echo ""
}

function install_cask_packages() {
    echo "Install Cask"

    cask_app=("google-chrome" "slack" "spotify" "visual-studio-code" "iterm2" "vlc" "docker")
    
    for cask in ${cask_app[@]}; do
        if [[ "$(brew list | grep -x $cask)" == $cask ]]; then
            echo "    SKIP : $cask is installed"
        else
            brew install --cask $cask
        fi
    done
    echo ""
}

function node_setup() {
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
    [ -s "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh" ] && \. "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh"  # This loads nvm
    [ -s "/home/linuxbrew/.linuxbrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/home/linuxbrew/.linuxbrew/opt/nvm/etc/bash_completion.d/nvm"
    echo "Setup Node.js"
    nvm install node
    nvm list
    nvm use stable
}

function vim_setup() {
    echo "Setup Vim Plugins"
    if [[ -d $HOME/src/iceberg.vim ]]; then
        echo "    SKIP : Plugins are already exsist"
    else
        git clone https://github.com/cocopon/iceberg.vim/ ${HOME}/src/iceberg.vim
        git clone https://github.com/itchyny/lightline.vim ~/.vim/pack/plugins/start/lightline
        cd ${HOME}/.vim
        ln -s ${HOME}/src/iceberg.vim/colors colors
        ln -s ${HOME}/src/iceberg.vim/autoload autoload
        ln -s $HOME/src/dotfiles/coc/coc-settings.json coc-settings.json
        mkdir -p ${HOME}/.config
        cd ${HOME}/.config
        ln -s ${HOME}/.vim ${HOME}/.config/nvim
        ln -s ${HOME}/.vimrc ${HOME}/.config/nvim/init.vim
        mkdir -p ~/.vim/pack/coc/start
        git clone --branch release https://github.com/neoclide/coc.nvim.git --depth=1 ~/.vim/pack/coc/start/coc.nvim
    fi
    echo ""

}

function zsh_setup() {
    echo "Setup Zsh Plugins"
    if [[ -d $HOME/src/powerlevel10k ]]; then
        echo "    SKIP : Plugins are already exsist"
    else
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${HOME}/src/powerlevel10k
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${HOME}/src/zsh-syntax-highlighting
        git clone https://github.com/zsh-users/zsh-autosuggestions ${HOME}/src/zsh-autosuggestions
    fi
    echo ""
}

function macos_setup() {
    echo "Fix macOS settings"
    echo "    set Computer Name"
    sudo scutil --set ComputerName MacBook
    echo "    set Local Host Name"
    sudo scutil --set LocalHostName MacBook
    echo "    Do not make .DS_Store on network drive"
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    echo "    Enable Firewall"
    sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1
    echo ""
}

# runner

sudoer_check
initial_check
system_check
make_symlink
install_brew
install_brew_packages
node_setup
vim_setup
zsh_setup
if [[ "$(uname -a)" == *Darwin* ]]; then
    install_cask_packages
    macos_setup
fi
echo "🎉 Complete! 🎉"
echo ""
echo "'ssh-keygen -t rsa' and push public key to GitHub.com"
echo ""

exec zsh