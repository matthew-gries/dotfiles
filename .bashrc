#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

alias firefox-nightly='~/firefox-nightly/src/firefox/firefox'
alias discord='~/discord/pkg/discord/opt/discord/Discord'
alias setupfinn='cd financialnn && conda activate finn'

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/matt/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/matt/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/home/matt/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/matt/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

export CPPUTEST_HOME="/home/matt/cpputest-3.7.2"
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Execute neofetch
neofetch

