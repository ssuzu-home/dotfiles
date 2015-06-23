#!/bin/bash

usage() {
	echo "Usage: $(basename $0) file"
	echo "Change an action by the linage of the file of the argument."
	echo "How to open the file is cat and less."
	echo
	exit 1
}

function spl(){
	local File Path Str Pager="${PAGER:-less}"
	local Pager='less +Gg'
	declare -i {D,L}Num=0
	declare -a List

	while (( $# > 0 )) ; do
		case "$1" in
			-h|--help)
				usage
				;;
			-l|--line)
				[ "$2" -gt 0 ] 2>&- && DNum=$2
				;;
			-p|--pager)
				type -p "$2" 1>&- && Pager=$2
				;;
			*)
				if [[ -d "$1" ]] ; then
					ls "$1"
					return 0
				elif [[ -r "$1" ]] ; then
					List[${#List[@]}]=$( < "$1" )
				else
					List[${#List[@]}]=$1
				fi && shift && continue
				;;
		esac && shift 2 || {
			echo "error: $FUNCNAME: $1: Invalid option." 1>&2
			return 1
		}
	done

	if (( ${#List[@]} > 0 )) ; then
		File=$( for i in "${List[@]}" ; do echo "$i"; done )
	elif [[ -t 0 ]] ; then
		echo "error: $FUNCNAME: No argument." 1>&2
		return 1
	else
		File=$( cat - )
	fi

	LNum=$( echo -n "$File" |grep -c '' )
	(( LNum > 0 )) || {
		echo "error: $FUNCNAME: No entry." 1>&2
		return 1
	}

	(( DNum > 0 )) || DNum=$[ $( stty 'size' < '/dev/tty' |cut -d ' ' -f 1 ) - 2 ]

	if (( LNum > DNum )) ; then
		echo "$File" |${Pager}
	else
		echo "$File"
	fi
}

spl "$@"
