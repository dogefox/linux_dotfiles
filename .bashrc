# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# https://misc.flogisoft.com/bash/tip_colors_and_formatting
RED='\033[31m'
GREEN='\e[32m'
BLUE='\e[34m'
NC='\e[0m'

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi

# Git branch in prompt.
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export PS1="\u@\h \W\[\033[32m\]\$(parse_git_branch)\[\033[00m\] $ "

unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

## nico's custom aliases ##

# enable touchpad
alias mouseon='exec xinput --enable "FocalTechPS/2 FocalTech Touchpad"'
alias mouseoff='exec xinput disable "FocalTechPS/2 FocalTech Touchpad"'

# screen brightness aliases
alias dark='xrandr --output eDP-1-1 --brightness 0.4'
alias darker='xrandr --output eDP-1-1 --brightness 0.3'
alias darkest='xrandr --output eDP-1-1 --brightness 0.2'
alias light='xrandr --output eDP-1-1 --brightness 0.7'
alias lighter='xrandr --output eDP-1-1 --brightness 0.9'
alias lightest='xrandr --output eDP-1-1 --brightness 1.0'
alias sleep='systemctl suspend'

# limabean vpn connection alias
alias limavpn='sudo openvpn --config ~/limavpn.ovpn'

# get my ip
alias myip='curl icanhazip.com'

alias pepkorjump='ssh cms@197.96.177.1 -p22'

# the ultimate database dump script alias
#alias mysqldumpking= 'mysqldump -f --single-transaction --skip-lock-tables --log-error=dump-errors.log database_name | pv | gzip > database_name.sql.gz'
#alias mysqlrestore= 'gunzip < database_name.sql.gz | mysql -uUSER -p -h HOST database_name'
#alias mysqldumpking= 'mysqldump -f --single-transaction --skip-lock-tables --log-error=dump-errors.log theproshopdb | pv | gzip > theproshopdb.sql.gz'


# docker aliases
alias dcd='docker kill $(docker ps -q)'

# gitbry = git branchcheckout remote.yml yarn build
# parameter $1 = $branchname
gitbry() {
    
    echo -e "${RED}[CODE REVIEW]${NC} stashing uncommitted work & killing all containers"
    git stash && dcd
    echo -e "${BLUE}[CODE REVIEW]${NC} pulling master & fetching branches"
    git checkout master && git pull && git fetch
    echo -e "${BLUE}[CODE REVIEW]${NC} checking out $1"
    git checkout $1 && git pull
    echo -e "${BLUE}[CODE REVIEW]${NC} upping docker-compose remote"
    docker-compose -f remote.yml up -d
    echo -e "${GREEN}[CODE REVIEW]${NC} running build"
    docker-compose -f remote.yml exec node yarn build
    echo -e "${BLUE}[CODE REVIEW]${NC} ${GREEN}ready for review${NC}"
}

# gitbr = git branchcheckout remote.yml - no build process
# parameter $1 = $branchname
gitbr() {
    
    echo -e "${RED}[CODE REVIEW]${NC} stashing uncommitted work & killing all containers"
    git stash && dcd
    echo -e "${BLUE}[CODE REVIEW]${NC} pulling master & fetching branches"
    git checkout master && git pull && git fetch
    echo -e "${BLUE}[CODE REVIEW]${NC} checking out $1"
    git checkout $1 && git pull
    echo -e "${BLUE}[CODE REVIEW]${NC} upping docker-compose remote"
    docker-compose -f remote.yml up -d
    echo -e "${BLUE}[CODE REVIEW]${NC} ${GREEN}ready for review${NC}"
}

# gitbly = git branchcheckout local (so no remote.yml) yarn build
# parameter $1 = $branchname
gitbly() {
    # https://misc.flogisoft.com/bash/tip_colors_and_formatting
    RED='\033[31m'
    GREEN='\e[32m'
    BLUE='\e[34m'
    NC='\e[0m'
    
    echo -e "${RED}[CODE REVIEW]${NC} stashing uncommitted work & killing all containers"
    git stash && dcd
    echo -e "${BLUE}CODE [REVIEW]${NC} pulling master & fetching branches"
    git checkout master && git pull && git fetch
    echo -e "${BLUE}[CODE REVIEW]${NC} checking out $1"
    git checkout $1 && git pull
    echo -e "${BLUE}[CODE REVIEW]${NC} upping docker-compose remote"
    docker-compose up -d
    echo -e "${GREEN}[CODE REVIEW]${NC} running build"
    #if [ $# -eq 2 ]
    #then
    #    #docker-compose -f remote.yml exec node $2 build
    #    docker-compose exec node yarn build
    #fi
    docker-compose exec node yarn build
    echo -e "${BLUE}[REVIEW]${NC} ${GREEN}ready for review${NC}"
}

# gitbl = git branchcheckout local (so no remote.yml) without build process
# parameter $1 = $branchname
gitbl() {
    # https://misc.flogisoft.com/bash/tip_colors_and_formatting
    RED='\033[31m'
    GREEN='\e[32m'
    BLUE='\e[34m'
    NC='\e[0m'
    
    echo -e "${RED}[CODE REVIEW]${NC} stashing uncommitted work & killing all containers"
    git stash && dcd
    echo -e "${BLUE}CODE [REVIEW]${NC} pulling master & fetching branches"
    git checkout master && git pull && git fetch
    echo -e "${BLUE}[CODE REVIEW]${NC} checking out $1"
    git checkout $1 && git pull
    echo -e "${BLUE}[CODE REVIEW]${NC} upping docker-compose remote"
    docker-compose up -d
    echo -e "${BLUE}[REVIEW]${NC} ${GREEN}ready for review${NC}"
}

# kubectl alias to roll out update on deployment
alias kuberollout='kubectl patch deployment $@ -p "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"date\":\"`date +'%s'`\"}}}}}"'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
