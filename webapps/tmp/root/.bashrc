# .bashrc

# User specific aliases and functions

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

export PATH=$PATH:/root/bin:/webapps/bin:/webapps/libs/vendor/bin
export TERM=xterm

## php composer
export COMPOSER_HOME=/webapps/libs
export COMPOSER_BIN_DIR=/webapps/bin

## nvm, node, npm
export NVM_DIR="/root/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

alias ls='ls --color=auto'
alias la='ls -aF --color=auto'
alias ll='ls -alF --color=auto'
alias ..='cd ..'
alias grep='grep -E'
alias pstree='pstree -achpuU'
