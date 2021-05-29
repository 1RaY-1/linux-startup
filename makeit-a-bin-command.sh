#!/bin/bash

needed_file=makeit-startup.sh
needed_dir=/bin/

check_for_problems(){

# check if script is running as root
    if [ $EUID -ne 0 ]; then
        echo "Please run me as root"
        exit
    fi

    if [ ! -f ${needed_file} ]; then
	echo "File ${needed_file} does not exist!"
        exit
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

        n | N | no | NO) exit;;

        *) echo "Invalid choice!";exit;;
    esac
}

do_it(){
    sudo cp ${needed_file} ${needed_dir}${needed_file%.*}

    chmod +x ${needed_dir}${needed_file%.*}

    echo "Done"
    echo 
  "
Now you can easily execute this script by typing: '${needed_file%.*}' from any directory
To remove it, type: sudo rm ${needed_dir}${needed_file%.*}
  "
}

check_for_problems
ask_if_ok
do_it
