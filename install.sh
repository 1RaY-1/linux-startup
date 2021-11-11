#!/usr/bin/env bash

set -e

needed_file=makeit-startup.sh
needed_dir=0

if [ -d $HOME/bin/ ]; then
    needed_dir=$HOME/bin/

elif [ -d /usr/bin/ ]; then
    needed_dir=/usr/bin/

elif [ -d /usr/local/bin/ ]; then
    needed_dir=/usr/local/bin/

elif [ -d /bin/ ]; then
    needed_dir=/bin/

else 
    echo "Sorry, I don't know what to do."
    exit 1
fi


check(){

    if [ $EUID -ne 0 ]; then
        echo -e "Please run me as root\nType: sudo bash $0"
        exit 1
    fi

    if [ ! -f ${needed_file} ]; then
        echo "Hey! Did you remove '${needed_file}' ??"
        exit 1
    fi
}

ask_if_ok(){
    echo "
I will:
1: Copy '${needed_file}' to '${needed_dir}' as '${needed_file%.*}'
2: Make it executable

So you will be able to run '${needed_file}' from any directory."
    printf "\nIs this ok?[y/n]\n"
    read is_ok

    case $is_ok in
        y | yes | Y | YES) : ;;
        *) exit 0 ;;
    esac
}

do_it(){
    if [ -f "${needed_dir}${needed_file%.*}" ]; then
        echo -e "Wow, file '${needed_dir}${needed_file%.*}' already exists.\nExiting... "
    fi

    cp ${needed_file} ${needed_dir}${needed_file%.*}
    chmod +x ${needed_dir}${needed_file%.*}

    echo "
Done!
Now you can easily execute this script by typing: 'sudo ${needed_file%.*}' from any directory
To remove it, type: sudo rm ${needed_dir}${needed_file%.*}
"
}

check_for_problems
ask_if_ok
do_it
exit