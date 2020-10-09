# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH="/usr/local/bin:$PATH"

# Path to your oh-my-zsh installation.
export ZSH="/Users/anton.merezko/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
#ZSH_THEME="robbyrussell"
#ZSH_THEME="agnoster"
ZSH_THEME="powerlevel10k/powerlevel10k"
# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
 export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Hide legacy commands for docker
export DOCKER_HIDE_LEGACY_COMMANDS=true

# Aliases
alias gips=get_ec2s
alias grep=rg
alias gs='git status'
alias gd='git diff'
alias gc='git commit'
alias mv='mv -i'
alias rm='rm -i'
# functions
get_ec2s() {
 if [ $1 ]
 then
   aws --profile $1 ec2 describe-instances --query 'Reservations[].Instances[].{InstanceId:InstanceId,  Name:Tags[?Key==`Name`].Value | [0], Ip:PrivateIpAddress, Status:State.Name| [0]}' --output table
 else
   aws ec2 describe-instances --query 'Reservations[].Instances[].{InstanceId:InstanceId, Name:Tags[?Key==`Name`].Value | [0], Ip:PrivateIpAddress, Status:State.Name | [0]}' --output table
 fi
}

get_dbs() (
  if [ "$#" -eq 0 ]
  then
    aws rds describe-db-instances --query 'DBInstances[].Endpoint.Address' --profile staging
  else
    aws rds describe-db-instances --query 'DBInstances[].Endpoint.Address' --profile $1
  fi
)

get_stacks() {
    aws cloudformation describe-stacks --profile $1 --query 'Stacks[].{StackName:StackName,ECSService:Outputs[?OutputKey==`ECSService`].OutputValue[] | [0],ECSCluster:Outputs[?OutputKey==`ECSCluster`].OutputValue[] | [0]}' --output table
}

generate_key_pair() {
    openssl genpkey -algorithm RSA -out "ib_api_private_key_$1.pem" -pkeyopt rsa_keygen_bits:2048
    openssl rsa -pubout -in "ib_api_private_key_$1.pem" -out "ib_api_public_key_$1.pem"
}

export AWS_USER_ACCOUNT_NAME=anton_merezko
_ssh(){
 if [ "$#" -eq 1 ]
 then
   ssh $AWS_USER_ACCOUNT_NAME@$1 -o ProxyCommand="ssh $AWS_USER_ACCOUNT_NAME@xxx nc $1 22"
 elif [ "$#" -eq 2 ]
 then
   if [ "$2" = stg ]
   then
     ssh $AWS_USER_ACCOUNT_NAME@$1 -o ProxyCommand="ssh $AWS_USER_ACCOUNT_NAME@xxx nc $1 22"
   elif [ "$2" = prod ]
   then
     ssh $AWS_USER_ACCOUNT_NAME@$1 -o ProxyCommand="ssh $AWS_USER_ACCOUNT_NAME@xxx nc $1 22"
   elif [ "$2" = mgmt ]
   then
     ssh $AWS_USER_ACCOUNT_NAME@$1 -o ProxyCommand="ssh $AWS_USER_ACCOUNT_NAME@xxx nc $1 22"
   fi
 fi
}

HISTTIMEFORMAT="%d/%m/%y %T "

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
alias python=/usr/local/bin/python3
alias pip=/usr/local/bin/pip3
