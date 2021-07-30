#!/bin/bash
set -e

# This script copies makeit-startup.sh file to /usr/bin directory, so you'll be able to run it with a single command (but with sudo command) from any directory

needed_file=makeit-startup.sh
needed_dir=/usr/bin/

check_for_problems(){

# check if script is running as root
    if [ $EUID -ne 0 ]; then
        echo "Please run me as root"
        exit 1
    fi

    if [ ! -f ${needed_file} ]; then
	echo "File ${needed_file} does not exist!"
        exit 1
    fi
}

ask_if_ok(){
    echo "
This script will:
1: Copy ${needed_file} to ${needed_dir} as ${needed_file%.*}
2: Make it executable

So you will be able to run this program with a single command from any directory
"
    printf "\nIs this ok?[y/n]\n"

    read is_ok

    case $is_ok in

        y | yes | Y | YES) echo "Ok";;

        *) echo "Invalid choice!";exit;;
    esac
}

do_it(){
    cp ${needed_file} ${needed_dir}${needed_file%.*}
    chmod +x ${needed_dir}${needed_file%.*}

    echo "Done"
    echo "
Now you can easily execute this script by typing: sudo ${needed_file%.*} from any directory
To remove it, type: sudo rm ${needed_dir}${needed_file%.*}
"
}

check_for_problems
ask_if_ok
do_it
