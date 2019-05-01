############################################
# bashrc 
#
# for NHM
# version: 0.2.3
# date:    24 January 2011
############################################

# if not running interactively return
[ -z "$PS1" ] && return

echo "Executing bashrc"
BASHLOCATION=`which bash`

if [ "$SHELL" != "$BASHLOCATION" ] 
then
	# mostly for work, where I can't change my default shell from ksh
	export SHELL="$BASHLOCATION"
fi

# if the helper script exists execute it
if [ -e ~/.nhmrc/.bash_os_helper ];
then
	helperscriptloaded=yes
	. ~/.nhmrc/.bash_os_helper
fi

# Check terminal size after every command, and update if necessary
shopt -s checkwinsize

# set the default umask
umask 022

# tweak how bash history is used
export HISTSIZE=1500
export HISTIGNORE=\&
export HISTCONTROL=ignoreboth

# check what type of terminal we are in, and whether it supports color
case "$TERM" in
	# Ubuntu 10 simply declares the term as xterm
	xterm-color | xterm) 
		color_prompt=yes
		[ -n "$TERM_PROGRAM" ] && [ "$TERM_PROGRAM" != Apple_Terminal ] && export TERM=xterm-256color
		# Redhat 6.5 recognizes xterm-color and xterm as 8 bit only terminals
		# this is confirmed with infocmp | grep color
		[ -z "$TERM_PROGRAM" ] && [ "$MAJOR" == RHEL ] && export TERM=xterm-256color
		;;
	screen) 
		color_prompt=yes
		screen_term=yes
		;;
	xterm-256color) 
		color_prompt=yes
		;;
esac

if [ -n $TERM_PROGRAM ]; then
	case "$TERM_PROGRAM" in
		# Apple Terminal does not support 256 colors
		Apple_Terminal)
			color256=false
			;;
		*)
			color256=true
			;;
	esac
else
	# Assume all terminals support 256 color
	color256=true
fi

# if the terminal supports color setup a fancy terminal
# and alias several commands to use color by default
if [ "$color_prompt" = yes ]; then
	PS1="\[\e[0;33m\]{\[\e[0;31m\]\u\[\e[0;32m\]@\[\e[0;35m\]\h \[\e[0;36m\]\w\[\e[0;33m\]}\n\$ \[\e[0;39m\]"
	PAGER="/usr/bin/less -R"
	alias ri='ri -f ansi'
	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
	case "$MAJOR" in 
		"$DEBIAN" | "$UBUNTU" | "$REDHAT")
			alias ls='ls --color=auto'
			alias dir='dir --color=auto'
			alias vdir='vdir --color=auto'
		;;
		"$OSX")
			alias ls='ls -G'
			alias dir='ls -G'
		;;
		"$NETBSD")
			alias ls='colorls -G'
			# NetBSD does't have a termcap entry for xterm-color
			[ "$TERM" == "xterm-256color" ] && export TERM=xterm-color
		;;
	esac
	# if dircolors command exists, execute it
	# this is likely only on linux
	# if it doesn't exist, and we are on OS X or NetBSD, 
	# manualy set the colors, they support a different color descriptor than linux
	if [ -x /usr/bin/dircolors ]; 
	then
		eval "`dircolors -b ~/.nhmrc/.DIR_COLORS`"
	else
		case "$MAJOR" in 
			"$OSX")
				LSCOLORS='FxGxExFxBxegedabagacad'
				export LSCOLORS
			;;
			"$NETBSD")
				LSCOLORS='5x6x2x3x1x464301060203'
				export LSCOLORS
			;;
			*)
			;;
		esac
	fi
else # not a color capable terminal
	PS1='\u@\h:\w\$ '
	PAGER=/usr/bin/less
fi # color terminal
PS2="> "

# check if we are in a VIM shell, if we are, update the prompt
if [ -n "$VIM" ];
then
	PS1="(VIM SHELL) $PS1"
fi

if [ -n "$SUDO_USER" ];
then
	PS1="(SUDO) $PS1"
fi

# check if we are in a screen shell
if [ -n "$screen_term" ];
then
	screenPS="screen"
	# check if the window number is defined
	if [ -n "$WINDOW" ];
	then
		screenPS="$screenPS $WINDOW"
	fi
	PS1="($screenPS) $PS1"
fi


# create some useful functions
# psx = search for a pattern in ps
psx () { ps axww | grep -i $* | grep -v grep;}
# vimd = compare the same filename in two different directories
# vimd /foo/var /bar/var file.txt
function vimd { 
	vim -d $1/$3 $2/$3
}
# localconfigure = way to set site specific configure options
# exclusively used for OS X
# checks to see if ~/config.site exists, if it exists
# turns the values in that file into arguments, and then calls
# the ./configure script with those arguments and any additional
# arguments that it receives
function localconfigure { 
	if [ -e ~/config.site ];
	then
		if [ -e .pkg_name ];
		then
			pkg=`cat .pkg_name`
		else
			echo -n "Enter Package Name: "
			read pkg
			echo -n $pkg > .pkg_name
		fi
		./configure --help > .tmp_help
		args=`cat ~/config.site | grep -o -e '^[-a-zA-Z]\+'`
		LOCAL_CONFIG_ARGS=$(for arg in $args; 
		do 
			grep -q -E "[-]{2}$arg[= ]" .tmp_help && grep -E "^$arg(=|$)" ~/config.site
	  	done | sed 's/$PKG_NAME/'$pkg'/g' | awk '/^[^#]/{printf("--%s ", $0)}')
		LOCAL_ENV_ARGS=$(cat ~/config.site | awk '/^~.*$/{print(substr($0, 2, length($0)-1))}' | tr '\n' ' ')
	fi
	config_cmd="$LOCAL_ENV_ARGS ./configure $LOCAL_CONFIG_ARGS $@"
	echo "Invoking $config_cmd"
	echo "$config_cmd" > config.nhm.site
	eval $config_cmd
}	

# aliases
alias untar="/usr/bin/tar -zxvvf "
alias grepmes="cat mes* | grep -C 10 Error"

CPPFLAGS=""
LDFLAGS=""
MANPATH=`append_path "$MANPATH" "/usr/share/man"`
PATH=`append_path "$PATH" "/bin:/usr/bin:/sbin:/usr/sbin"`
XPATH=""
PYTHONPATH=""
PKG_CONFIG_PATH=/usr/lib/pkgconfig
SVNPATH="/usr/bin/svn"

# if the helper script didn't load, this is as far as we can go
if [ -z $helperscriptloaded ];
then
	export MANPATH
	export PATH
	export PS1
	export PS2
	export PAGER
	return
fi

# standard local additions
# Netbsd doesn't use /usr/local
case "$MAJOR" in
	"$NETBSD")
		PATH=`append_path "$PATH" "/usr/pkg/bin:/usr/pkg/sbin"`
		MANPATH=`append_path "$MANPATH" "/usr/pkg/share/man:/usr/pkg/man"`
	;;
	*)
		PATH=`append_path "$PATH" "/usr/local/bin:/usr/local/sbin"`
		MANPATH=`append_path "$MANPATH" "/usr/local/share/man:/usr/local/man"`
	;;
esac


# X11 Additions
if [ -d "/usr/X11" ];
then
	XPATH=/usr/X11
elif [ -d "/usr/X11R6" ];
then
	XPATH=/usr/X11R6
fi

# Add the following if XPATH is valid/not null
if [ -n "$XPATH" ];
then
	PATH=`append_path "$PATH" "$XPATH/bin"`
	case "$MAJOR" in
		"$OSX" | "$NETBSD")
			# OS X and NetBSD puts X stuff in here as well
			MANPATH=`append_path "$MANPATH" "$XPATH/share/man"`
			CPPFLAGS="$CPPFLAGS-I$XPATH/include "
			LDFLAGS="$LDFLAGS-L$XPATH/lib "
			#PKG_CONFIG_PATH=`append_path $PKG_CONFIG_PATH $XPATH/lib/pkgconfig`
		;;
	esac
fi

# if there is an opt directory we want to load it too
if [ -d "/opt" ];
then
	[ -d "/opt/bin" ] && PATH=`append_path "$PATH" /opt/bin:/opt/sbin`
	[ -d "/opt/share" ] && MANPATH=`append_path "$MANPATH" /opt/share/man:/opt/man`
	[ -d "/opt/include" ] && CPPFLAGS="$CPPFLAGS-I/opt/include "
	[ -d "/opt/lib" ] && LDFLAGS="$LDFLAGS-L/opt/lib " && PKG_CONFIG_PATH=`append_path $PKG_CONFIG_PATH /opt/lib/pkgconfig`
	[ -d "/opt/lib/python*" ] && PYTHONPATH=`append_path $PYTHONPATH /opt/lib/python2.6/site-packages`
fi

# the following is something that is unique to my XEN virtual
# NetBSD installs
if [ -d "/local/pkg" ];
then
	PATH=`append_path "$PATH" /local/pkg/bin:/local/pkg/sbin`
	MANPATH=`append_path "$MANPATH" /local/pkg/share/man:/local/pkg/man`
	CPPFLAGS="$CPPFLAGS-I/local/pkg/include "
	LDFLAGS="$LDFLAGS-L/local/pkg/lib "
	PYTHONPATH=`append_path $PYTHONPATH /local/pkg/lib/python2.6/site-packages`
	#PKG_CONFIG_PATH=`append_path $PKG_CONFIG_PATH /local/pkg/lib/pkgconfig`
fi

# OS Specific additions
case "$MAJOR" in
	"$OSX")
		# OS X puts python binaries here
		PATH=`append_path "$PATH" /System/Library/Frameworks/Python.framework/Versions/Current/bin`
	;;
	"$NETBSD")
		# needs PKG_PATH to get new packages
		PKG_PATH=http://ftp2.us.netbsd.org/pub/NetBSD/packages/current-packages/NetBSD/x86_64
		case "$MINOR" in
			"$V50")
				PKG_PATH=$PKG_PATH/5.0.1_2010Q1
			;;
		esac
		PKG_PATH=$PKG_PATH/All/
		export PKG_PATH
		SVNPATH="/usr/pkg/bin/svn"
	;;
	"$UNKNOWN")
		SVNPATH=""
	;;
esac

PATH=`append_path "$PATH" ~/bin:.`
PYTHONPATH=`append_path "$PYTHONPATH" ~/python`

export PATH
export MANPATH
[ -n "$XPATH" ] && export XPATH
[ -n "$CPPFLAGS" ] && export CPPFLAGS
[ -n "$LDFLAGS" ] && export LDFLAGS
[ -n "$PYTHONPATH" ] && export PYTHONPATH
[ -n "$PKG_CONFIG_PATH" ] && export PKG_CONFIG_PATH
export PS1
export PS2
export PAGER

# don't execute svn update if we are in a vim shell
if [ -z "$VIM" ] && [ -z "$SUDO_USER" ];
then
	# try to update this file
	if [ -n "$SVNPATH" ];
	then
		if svnres=`$SVNPATH update ~/.nhmrc 2>/dev/null`
		then
			if ! `eval echo $svnres | grep -e '[Aa][Tt] [Rr][Ee][Vv][Ii][Ss][Ii][Oo][Nn].*' > /dev/null`
			then
				# an upgrade was performed if U filename
				if `eval echo $svnres | grep -e '[Uu].*' > /dev/null`
				then
					echo "Need to reload .bash_profile"
					source ~/.bash_profile
					exit
				fi
			fi
		else
			echo "Couldn't update .nhmrc, problem with svn"
		fi
	else
		echo "Couldn't update .nhmrc, svn not found"
	fi
fi

alias witc='wit copy -p --wbfs --dest "%x" --source'
alias transd='sudo transmission-daemon -c /Volumes/raid/media/Wii/Torrents/ -w /Volumes/raid/media/Wii/ -T -B'
alias rmappled='sudo find . -iname .AppleDouble -exec rm -r {} \;'
alias findappled='find . -iname .AppleDouble'
