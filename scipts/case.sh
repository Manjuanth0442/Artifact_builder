#!/bin/bash


function usage {
	echo "use the proper arguments type ? to list valid argument"
}
## list of arguments expected in the input

optstring=":h"

while getopts ${optstring} arg; do
	case ${arg} in
		h)
			echo "you name is $1"
		        ;;
		## when no arguments are password OPTARG is set to : and run this part of the code	
		:)
			echo "$0: must supply an argument to $OPTARG."
			usage
			;;
		## when an invalid option is passed OPTARG is set to ? and this part of the code is run
		?)
			echo "invalid option ${OPTARG}."
			echo "valid options is -h"
			;;
		esac
done



