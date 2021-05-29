#!/bin/bash

needed_file=makeit-startup.sh
needed_dir=/bin/

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

check_for_problems(){

    if [ ! -f ${needed_file} ]; then
	echo "File ${needed_file} does not exist!"
        exit
    fi
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

ask_if_ok
check_for_problems
do_it
