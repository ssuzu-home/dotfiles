# .bashrc

# Initial. {{{1

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Language
export LANG=C
export LC_ALL=en_US.UTF-8

# Read /etc/bashrc, if present.
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Check existing.
loading() {
    echo -e "$fg[blue]Starting $SHELL....$reset_color\n"
    if [[ -d  ~/.loading ]]; then
        for f in ~/.loading/*.sh
        do
            if [[ ! -x "$f" ]]; then
                source "$f" 2>/dev/null &&
                    echo "  loading $f"
            fi
            unset f
        done
        echo ""
    fi
}

# tmux_automatically_attach {{{1
tmux_automatically_attach() {
    if is_screen_or_tmux_running; then
        if is_tmux_runnning; then
            export DISPLAY="$TMUX"
        elif is_screen_running; then
            # For GNU screen
            :
        fi
    else
        if shell_has_started_interactively && ! is_ssh_running; then
            if ! has 'tmux'; then
                echo 'Error: tmux command not found' >/dev/stderr
                return 1
            fi

            if tmux has-session >/dev/null 2>&1 && tmux list-sessions | grep -qE '.*]$'; then
                # detached session exists
                tmux list-sessions
                echo -n "Tmux: attach? (y/N/num) "
                read
                if [[ "$REPLY" =~ ^[Yy]$ ]] || [[ "$REPLY" == '' ]]; then
                    tmux attach-session
                    if [ $? -eq 0 ]; then
                        echo "$(tmux -V) attached session"
                        return 0
                    fi
                elif [[ "$REPLY" =~ ^[0-9]+$ ]]; then
                    tmux attach -t "$REPLY"
                    if [ $? -eq 0 ]; then
                        echo "$(tmux -V) attached session"
                        return 0
                    fi
                fi
            fi

            if is_osx && has 'reattach-to-user-namespace'; then
                # on OS X force tmux's default command
                # to spawn a shell in the user's namespace
                tmux_login_shell="/usr/local/bin/bash"
                tmux_config=$(cat ~/.tmux.conf <(echo 'set-option -g default-command "reattach-to-user-namespace -l' $tmux_login_shell'"'))
                tmux -f <(echo "$tmux_config") new-session && echo "$(tmux -V) created new session supported OS X"
            else
                tmux new-session && echo "tmux created new session"
            fi
        fi
    fi
}

function has()
{
	type $1 >/dev/null 2>&1; return $?;
}

# OS judgement. boolean.
loading

# environment variables
export OS=$(uname | awk '{print tolower($1)}')
export BIN="$HOME/bin"
export PATH="$BIN:$PATH"

# Search executable file in $PATH.
function search()
{
	local    IFS=$'\n'
	local -i i=0
	local -a TARGET=( `echo $PATH | tr ':' "\n" | sort | uniq` )

	for ((i=0; i<${#TARGET[@]}; i++)); do
		if [ -x ${TARGET[i]}/"$1" ]; then
			echo "${TARGET[i]}/$1"
		fi
	done
}

#--------------------------------------------------------------
# Define EDITOR environment value with search().
# Use vim with compiled '+clipboard', if present.
#--------------------------------------------------------------
all_vim_path=( `search vim` )
for ((i=0; i<${#all_vim_path[@]}; i++)); do
	if ${all_vim_path[i]} --version 2>/dev/null | grep -qi '+clipboard'; then
		clipboard_vim_path="${all_vim_path[i]}"
		break
	fi
done
export EDITOR="${clipboard_vim_path:-vim}"
unset i all_vim_path clipboard_vim_path

#-------------------------------------------------------------
# Tailoring 'less'
#-------------------------------------------------------------
export PAGER=less
export LESS='-i -N -w  -z-4 -g -e -M -X -F -R -P%t?f%f :stdin .?pb%pb\%:?lbLine %lb:?bbByte %bb:-...'
export LESS='-f -N -X -i -P ?f%f:(stdin). ?lb%lb?L/%L.. [?eEOF:?pb%pb\%..]'
export LESS='-f -X -i -P ?f%f:(stdin). ?lb%lb?L/%L.. [?eEOF:?pb%pb\%..]'
export LESSCHARSET='utf-8'

# LESS man page colors (makes Man pages more readable).
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

#-------------------------------------------------------------
# Tailoring 'ls'
#-------------------------------------------------------------
all_ls_path=( `search ls` )
for ((i=0; i<${#all_ls_path[@]}; i++)); do
	if ${all_ls_path[i]} --version 2>/dev/null | grep -qi "GNU"; then
		export LSPATH="${all_ls_path[i]}"
		break
	fi
done
unset i all_ls_path
if $(has 'gls'); then
	alias ls="gls --color=auto -F -b"
else
	alias ls="$LSPATH --color=auto -F -b"
	if [ "$LSPATH" == "" ]; then
		unalias ls
	fi
fi

#--------------------------------------------------------------
#  Automatic setting of $DISPLAY (if not set already).
#  This works for me - your mileage may vary. . . .
#  The problem is that different types of terminals give
#+ different answers to 'who am i' (rxvt in particular can be
#+ troublesome) - however this code seems to work in a majority
#+ of cases.
#--------------------------------------------------------------

function get_xserver()
{
    case $TERM in
			xterm* )
            XSERVER=$(who am i | awk '{print $NF}' | tr -d ')''(' )
            # Ane-Pieter Wieringa suggests the following alternative:
            #  I_AM=$(who am i)
            #  SERVER=${I_AM#*(}
            #  SERVER=${SERVER%*)}
            XSERVER=${XSERVER%%:*}
            ;;
            aterm | rxvt)
            # Find some code that works here. ...
            ;;
    esac
}

if [ -z ${DISPLAY:=""} ]; then
    get_xserver
    if [[ -z ${XSERVER}  || ${XSERVER} == $(hostname) ||
       ${XSERVER} == "unix" ]]; then
          DISPLAY=":0.0"          # Display on local host.
    else
       DISPLAY=${XSERVER}:0.0     # Display on remote host.
    fi
fi

export DISPLAY

# Coloring variables {{{2
#-------------------------------------------------------------
# Greeting, motd etc. ...
#-------------------------------------------------------------
# Color definitions (taken from Color Bash Prompt HowTo).
# Some colors might look different of some terminals.
# For example, I see 'Bold Red' as 'orange' on my screen,
# hence the 'Green' 'BRed' 'Red' sequence I often use in my prompt.

# Normal Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White

# Background
On_Black='\033[40m'       # Black
On_Red='\033[41m'         # Red
On_Green='\033[42m'       # Green
On_Yellow='\033[43m'      # Yellow
On_Blue='\033[44m'        # Blue
On_Purple='\033[45m'      # Purple
On_Cyan='\033[46m'        # Cyan
On_White='\033[47m'       # White

NC="\033[m"               # Color Reset
CR="$(echo -ne '\r')"
LF="$(echo -ne '\n')"
TAB="$(echo -ne '\t')"
ESC="$(echo -ne '\033')"

ALERT=${BWhite}${On_Red} # Bold White on red background
#}}}

# If completion files exist, load it.
[ -f /etc/bash_completion ]     && . /etc/bash_completion
[ -f /etc/git-completion.bash ] && . /etc/git-completion.bash
[ -f /etc/git-prompt.bash ]     && . /etc/git-prompt.bash

# Linux.
if [ "$OS" = "linux" ]; then
	:
	#[ -f ~/.bashrc.unix ] && source ~/.bashrc.unix

# Max OSX.
elif [ "$OS" = "darwin" ]; then
	:
	#[ -f ~/.bashrc.mac ] && source ~/.bashrc.mac
fi

# Local configure file.
if [ -f ~/.bashrc.local ]; then
	source ~/.bashrc.local
fi

# Start bash.
echo -e "${BCyan}This is BASH ${BRed}${BASH_VERSION%.*}${BCyan} - DISPLAY on ${BRed}$DISPLAY${NC}\n"

# Loads the file except executable one.

date

# Show fortune instead of nowon
# Makes our day a bit more fun.... :-)
# if nowon does not exist, ...
# execute handler:
# > nowon_on=1
if [ "$nowon_on"x == 'x' ]; then
	if $(has 'fortune'); then
		`which fortune` -s
	fi
fi

# Utilities. {{{1
#-------------------------------------------------------------
# File & strings related functions:
#-------------------------------------------------------------

# Priority. {{{1

# history {{{2
#-------------------------------------------------------------
# Enrich your history file. The ~/.bash_history is default.
#-------------------------------------------------------------
HISTSIZE=50000
HISTFILESIZE=50000

export MYHISTFILE=$HOME/.bash_myhistory
function show_exit()
{
	if [ "$1" -eq 0 ]; then return; fi
	echo -e "\007exit $1"
}

function log_history()
{
	echo "$(date '+%Y-%m-%d %H:%M:%S') $HOSTNAME:$$ $PWD ($1) $(history 1)" >> $MYHISTFILE
}

function prompt_cmd()
{
	local s=$?
	show_exit $s;
	log_history $s;
}

function end_history()
{
	log_history $?;
	echo "$(date '+%Y-%m-%d %H:%M:%S') $HOSTNAME:$$ $PWD (end)" >> $MYHISTFILE
}

echo "$(date '+%Y-%m-%d %H:%M:%S') $HOSTNAME:$$ $PWD (start)" >> $MYHISTFILE
#trap end_history EXIT
PROMPT_COMMAND="prompt_cmd;$PROMPT_COMMAND"
#}}}

function _exit()
# Function to run upon exit of shell.
{
	end_history
  echo -e  "${BRed}Hasta la vista, baby!"
  echo -en "\033[m"
}
trap _exit EXIT

if ! is_osx && $(has 'dircolors'); then
	eval `dircolors -b ~/.dir_colors`
fi

if [ "$nowon_on"x != 'x' ]; then
	# If function 'nowon' exist, call and unset it.
	if type nowon >/dev/null 2>&1; then
		nowon && unset nowon
	fi
fi

if [ ! -f $BIN/cdhist.sh ]; then
	function cd()
	{
		builtin cd "$@" && ls;
	}
fi

# Appearance. {{{1
#-------------------------------------------------------------
# Shell Prompt - for many examples, see:
#       http://www.debian-administration.org/articles/205
#       http://www.askapache.com/linux/bash-power-prompt.html
#       http://tldp.org/HOWTO/Bash-Prompt-HOWTO
#       https://github.com/nojhan/liquidprompt
#-------------------------------------------------------------
# Current Format: [TIME USER@HOST PWD] >
# TIME:
#    Green     == machine load is low
#    Orange    == machine load is medium
#    Red       == machine load is high
#    ALERT     == machine load is very high
# USER:
#    Cyan      == normal user
#    Orange    == SU to user
#    Red       == root
# HOST:
#    Cyan      == local session
#    Green     == secured remote connection (via ssh)
#    Red       == unsecured remote connection
# PWD:
#    Green     == more than 10% free disk space
#    Orange    == less than 10% free disk space
#    ALERT     == less than 5% free disk space
#    Red       == current user does not have write privileges
#    Cyan      == current filesystem is size zero (like /proc)
# >:
#    White     == no background or suspended jobs in this shell
#    Cyan      == at least one background job in this shell
#    Orange    == at least one suspended job in this shell
#
#    Command is added to the history file each time you hit enter,
#    so it's available to all shells (using 'history -a').


# Test connection type:
if [ -n "${SSH_CONNECTION}" ]; then
    CNX=${Green}        # Connected on remote machine, via ssh (good).
elif [[ "${DISPLAY%%:0*}" != "" ]]; then
    CNX=${ALERT}        # Connected on remote machine, not via ssh (bad).
else
    CNX=${BCyan}        # Connected on local machine.
fi

# Test user type:
if [[ ${USER} == "root" ]]; then
    SU=${Red}           # User is root.
elif [[ ${USER} != $(logname) ]]; then
    SU=${BRed}          # User is not login user.
else
    SU=${BCyan}         # User is normal (well ... most of us are).
fi

#  Note that a variable may require special treatment
#+ if it will be exported.

DARKGRAY='\e[1;30m'
LIGHTRED='\e[1;31m'
GREEN='\e[32m'
YELLOW='\e[1;33m'
LIGHTBLUE='\e[1;34m'

#  For "literal" command substitution to be assigned to a variable,
#+ use escapes and double quotes:
#+       PCT="\` ... \`" . . .
#  Otherwise, the value of PCT variable is assigned only once,
#+ when the variable is exported/read from .bash_profile,
#+ and it will not change afterwards even if the user ID changes.

PS_HOST="\[${Green}\]\h\[${NC}\]"
PS_USER="\[${Green}\]\u\[${NC}\]"
PS_WORK="\[${Yellow}\]\w\[${NC}\]"
PS_HIST="\[${Red}\](\!)\[${NC}\]"

if [ -n "${WINDOW}" ] ; then
	PS_SCREEN="\[${Cyan}\]#${WINDOW}\[${NC}\]"
else
	PS_SCREEN=""
fi

if [ -n "${TMUX}" ] ; then
	TMUX_WINDOW=$(tmux display -p '#I-#P')
	PS_SCREEN="\[${Cyan}\]#${TMUX_WINDOW}\[${NC}\]"
else
	PS_SCREEN=""
fi

if [ -n "${SSH_CLIENT}" ] ; then
	PS_SSH="\[${Cyan}\]/$(echo ${SSH_CLIENT} | sed 's/ [0-9]\+ [0-9]\+$//g')\[${NC}\]"
else
	PS_SSH=""
fi

PS1=
##if $(has '__git_ps1'); then
##	GIT_PS1_SHOWDIRTYSTATE=true
##	GIT_PS1_SHOWSTASHSTATE=true
##	GIT_PS1_SHOWUNTRACKEDFILES=true
##	GIT_PS1_SHOWUPSTREAM=auto
##	PS_GIT="${Red}"'$(__git_ps1)'"${NC}"
##
##	PS1+="${PS_USER}@${PS_HOST}:${PS_WORK}${PS_GIT}"
##	PS1+='$ '
##	#PS1+=">>> "$(show_exit $?)"\n${PS_GIT} "
##else
##	PS1+="[${PS_USER}${PS_ATODE}@${PS_HOST}${PS_SCREEN}${PS_SSH}:${PS_WORK}]\[\033[01;32m\]"
##	PS1+='$(if git status &>/dev/null;then echo git[branch:$(git branch | cut -d" "  -f2-) change:$(git status -s |wc -l)];fi)\[\033[00m\]'
##	PS1+='$ '
##fi
PS1=\\h:\\w\\$

#PCT="\`if [[ \$EUID -eq 0 ]]; then T='$LIGHTRED' ; else T='$LIGHTBLUE'; fi; 
#echo \$T \`"
#PS1+="\`if [[ \$EUID -eq 0 ]]; then PCT='$LIGHTRED';
#else PCT='${LIGHTBLUE}'; fi; 
#	echo '$GREEN[\w] \n$DARKGRAY('\$PCT'\t$DARKGRAY)-('\$PCT'\u$DARKGRAY)-('\$PCT'\h$DARKGRAY)$YELLOW-> $NC'\`"

export PS1;

# Options. {{{1
#-------------------------------------------------------------
# Some settings
#-------------------------------------------------------------

#set -o nounset     # These  two options are useful for debugging.
#set -o xtrace
alias debug="set -o nounset; set -o xtrace"

ulimit -S -c 0      # Don't want coredumps.
set -o notify
set -o noclobber
set -o ignoreeof


# Enable options:
shopt -s cdspell
shopt -s cdable_vars
shopt -s checkhash
shopt -s checkwinsize
shopt -s sourcepath
shopt -s no_empty_cmd_completion
shopt -s cmdhist
shopt -s histappend histreedit histverify
shopt -s extglob       # Necessary for programmable completion.

# Disable options:
shopt -u mailwarn
unset MAILCHECK        # Don't want my shell to warn me of incoming mail.

# Aliases. {{{1
#============================================================

alias vim="$EDITOR"
alias vi="$EDITOR"
alias v="$EDITOR"

if is_osx; then
  alias vim='env LANG=ja_JP.UTF-8 /Applications/MacVim.app/Contents/MacOS/Vim "$@"'
  alias vi=vim
  alias v=vim
fi

# Git.
if $(has 'git'); then
	alias gst='git status'
fi

if is_osx; then
	if $(has 'qlmanage'); then
		alias ql='qlmanage -p "$@" >& /dev/null'
	fi
fi

# function
alias cl="richpager"

# Common aliases
alias c=cat
alias l='ls -al'
#alias ll='ls -al | lv'
alias d='ls --color=auto -lFo'
alias ..='cd ..'
alias ...='cd ../..'
#alias --='cd -'
alias p='ps -aef'
alias nsna='netstat -na'
alias nsnr='netstat -nr'
alias sudo='sudo '

alias ..="cd .."
alias ld="ls -ld"          # Show info about the directory
alias lla="ls -lAF"        # Show hidden all files
alias ll="ls -lF"          # Show long file information
alias la="ls -AF"          # Show hidden files
alias lx="ls -lXB"         # Sort by extension
alias lk="ls -lSr"         # Sort by size, biggest last
alias lc="ls -ltcr"        # Sort by and show change time, most recent last
alias lu="ls -ltur"        # Sort by and show access time, most recent last
alias lt="ls -ltr"         # Sort by date, most recent last
alias lr="ls -lR"          # Recursive ls

# The ubiquitous 'll': directories first, with alphanumeric sorting:
alias ll="ls -lv --group-directories-first"

alias cp="cp -i"
alias mv="mv -i"
alias du="du -h"
alias jobs="jobs -l"
alias temp="test -e ~/temporary && command cd ~/temporary || mkdir ~/temporary && cd ~/temporary"
alias untemp="command cd $HOME && rm ~/temporary && ls"
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Use if colordiff exists
if $(has 'colordiff'); then
	alias diff='colordiff -u'
fi

# Use plain vim.
alias nvim='vim -N -u NONE -i NONE'

# The first word of each simple command, if unquoted, is checked to see 
# if it has an alias. [...] If the last character of the alias value is 
# a space or tab character, then the next command word following the 
# alias is also checked for alias expansion
alias sudo='sudo '

#  ALIASES AND FUNCTIONS
#
#  Arguably, some functions defined here are quite big.
#  If you want to make this file smaller, these functions can
#+ be converted into scripts and removed from here.
#
#============================================================
# Pretty-print of some PATH variables:

alias path='echo -e ${PATH//:/\\n}'

# Misc. {{{1
#=========================================================================
#  PROGRAMMABLE COMPLETION SECTION
#  Most are taken from the bash 2.05 documentation and from Ian McDonald's
# 'Bash completion' package (http://www.caliban.org/bash/#completion)
#  You will in fact need bash more recent then 3.0 for some features.
#
#  Note that most linux distributions now provide many completions
# 'out of the box' - however, you might need to make your own one day,
#  so I kept those here as examples.
#=========================================================================

if [ "${BASH_VERSION%.*}" \< "3.0" ]; then
    echo "You will need to upgrade to version 3.0 for full \
          programmable completion features"
    return
fi

shopt -s extglob        # Necessary.

complete -A hostname   rsh rcp telnet rlogin ftp ping disk
complete -A export     printenv
complete -A variable   export local readonly unset
complete -A enabled    builtin
complete -A alias      alias unalias
complete -A function   function
complete -A user       su mail finger

complete -A helptopic  help     # Currently same as builtins.
complete -A shopt      shopt
complete -A stopped -P '%' bg
complete -A job -P '%'     fg jobs disown

complete -A directory  mkdir rmdir
complete -A directory   -o default cd

# Compression
complete -f -o default -X '*.+(zip|ZIP)'  zip
complete -f -o default -X '!*.+(zip|ZIP)' unzip
complete -f -o default -X '*.+(z|Z)'      compress
complete -f -o default -X '!*.+(z|Z)'     uncompress
complete -f -o default -X '*.+(gz|GZ)'    gzip
complete -f -o default -X '!*.+(gz|GZ)'   gunzip
complete -f -o default -X '*.+(bz2|BZ2)'  bzip2
complete -f -o default -X '!*.+(bz2|BZ2)' bunzip2
complete -f -o default -X '!*.+(zip|ZIP|z|Z|gz|GZ|bz2|BZ2)' extract


# Documents - Postscript,pdf,dvi.....
complete -f -o default -X '!*.+(ps|PS)'  gs ghostview ps2pdf ps2ascii
complete -f -o default -X \
'!*.+(dvi|DVI)' dvips dvipdf xdvi dviselect dvitype
complete -f -o default -X '!*.+(pdf|PDF)' acroread pdf2ps
complete -f -o default -X '!*.@(@(?(e)ps|?(E)PS|pdf|PDF)?\
(.gz|.GZ|.bz2|.BZ2|.Z))' gv ggv
complete -f -o default -X '!*.texi*' makeinfo texi2dvi texi2html texi2pdf
complete -f -o default -X '!*.tex' tex latex slitex
complete -f -o default -X '!*.lyx' lyx
complete -f -o default -X '!*.+(htm*|HTM*)' lynx html2ps
complete -f -o default -X \
'!*.+(doc|DOC|xls|XLS|ppt|PPT|sx?|SX?|csv|CSV|od?|OD?|ott|OTT)' soffice

# Multimedia
complete -f -o default -X \
'!*.+(gif|GIF|jp*g|JP*G|bmp|BMP|xpm|XPM|png|PNG)' xv gimp ee gqview
complete -f -o default -X '!*.+(mp3|MP3)' mpg123 mpg321
complete -f -o default -X '!*.+(ogg|OGG)' ogg123
complete -f -o default -X \
'!*.@(mp[23]|MP[23]|ogg|OGG|wav|WAV|pls|\
m3u|xm|mod|s[3t]m|it|mtm|ult|flac)' xmms
complete -f -o default -X '!*.@(mp?(e)g|MP?(E)G|wma|avi|AVI|\
asf|vob|VOB|bin|dat|vcd|ps|pes|fli|viv|rm|ram|yuv|mov|MOV|qt|\
QT|wmv|mp3|MP3|ogg|OGG|ogm|OGM|mp4|MP4|wav|WAV|asx|ASX)' xine



complete -f -o default -X '!*.pl'  perl perl5


#  This is a 'universal' completion function - it works when commands have
#+ a so-called 'long options' mode , ie: 'ls --all' instead of 'ls -a'
#  Needs the '-o' option of grep
#+ (try the commented-out version if not available).

#  First, remove '=' from completion word separators
#+ (this will allow completions like 'ls --color=auto' to work correctly).

COMP_WORDBREAKS=${COMP_WORDBREAKS/=/}


_get_longopts()
{
  #$1 --help | sed  -e '/--/!d' -e 's/.*--\([^[:space:].,]*\).*/--\1/'| \
  #grep ^"$2" |sort -u ;
    $1 --help | grep -o -e "--[^[:space:].,]*" | grep -e "$2" |sort -u
}

_longopts()
{
    local cur
    cur=${COMP_WORDS[COMP_CWORD]}

    case "${cur:-*}" in
       -*)      ;;
        *)      return ;;
    esac

    case "$1" in
       \~*)     eval cmd="$1" ;;
         *)     cmd="$1" ;;
    esac
    COMPREPLY=( $(_get_longopts ${1} ${cur} ) )
}
complete  -o default -F _longopts configure bash
complete  -o default -F _longopts wget id info a2ps ls recode

_make()
{
    local mdef makef makef_dir="." makef_inc gcmd cur prev i;
    COMPREPLY=();
    cur=${COMP_WORDS[COMP_CWORD]};
    prev=${COMP_WORDS[COMP_CWORD-1]};
    case "$prev" in
        -*f)
            COMPREPLY=($(compgen -f $cur ));
            return 0
            ;;
    esac;
    case "$cur" in
        -*)
            COMPREPLY=($(_get_longopts $1 $cur ));
            return 0
            ;;
    esac;

    # ... make reads
    #          GNUmakefile,
    #     then makefile
    #     then Makefile ...
    if [ -f ${makef_dir}/GNUmakefile ]; then
        makef=${makef_dir}/GNUmakefile
    elif [ -f ${makef_dir}/makefile ]; then
        makef=${makef_dir}/makefile
    elif [ -f ${makef_dir}/Makefile ]; then
        makef=${makef_dir}/Makefile
    else
       makef=${makef_dir}/*.mk         # Local convention.
    fi


    #  Before we scan for targets, see if a Makefile name was
    #+ specified with -f.
    for (( i=0; i < ${#COMP_WORDS[@]}; i++ )); do
        if [[ ${COMP_WORDS[i]} == -f ]]; then
            # eval for tilde expansion
            eval makef=${COMP_WORDS[i+1]}
            break
        fi
    done
    [ ! -f $makef ] && return 0

    # Deal with included Makefiles.
    makef_inc=$( grep -E '^-?include' $makef |
                 sed -e "s,^.* ,"$makef_dir"/," )
    for file in $makef_inc; do
        [ -f $file ] && makef="$makef $file"
    done


    #  If we have a partial word to complete, restrict completions
    #+ to matches of that word.
    if [ -n "$cur" ]; then gcmd='grep "^$cur"' ; else gcmd=cat ; fi

    COMPREPLY=( $( awk -F':' '/^[a-zA-Z0-9][^$#\/\t=]*:([^=]|$)/ \
                               {split($1,A,/ /);for(i in A)print A[i]}' \
                                $makef 2>/dev/null | eval $gcmd  ))

}

complete -F _make -X '+($*|*.[cho])' make gmake pmake

_killall()
{
    local cur prev
    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}

    #  Get a list of processes
    #+ (the first sed evaluation
    #+ takes care of swapped out processes, the second
    #+ takes care of getting the basename of the process).
    COMPREPLY=( $( ps -u $USER -o comm  | \
        sed -e '1,1d' -e 's#[]\[]##g' -e 's#^.*/##'| \
        awk '{if ($0 ~ /^'$cur'/) print $0}' ))

    return 0
}

complete -F _killall killall killps

# settings for peco
_replace_by_history() {
  local l=$(HISTTIMEFORMAT= history | tac | sed -e 's/^\s*[0-9]*    \+\s\+//' | peco --query "$READLINE_LINE")
  READLINE_LINE="$l"
  READLINE_POINT=${#l}
}
peco-select-history() {
  declare l=$(HISTTIMEFORMAT= history | sort -k1,1nr | perl -ne 'BEGIN { my @lines = (); } s/^\s*\d+\s*//; $in=$_; if (!(grep {$in eq $_} @lines)) { push(@lines, $in); print $in; }' | peco --query "$READLINE_LINE")
  READLINE_LINE="$l"
  READLINE_POINT=${#l}
}

bind -x '"\C-r": _replace_by_history'
bind    '"\C-xr": reverse-search-history'
bind -x '"\C-r": peco-select-history'

tmux_automatically_attach

# vim:fdm=marker fdc=3 ft=sh ts=2 sw=2 sts=2:
#}}}
