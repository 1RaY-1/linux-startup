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
        echo "Missing needed file: '${needed_file}'"
        exit 1
    fi
}


do_it(){
    # just in case
    if [ -f "${needed_dir}${needed_file%.*}" ]; then
        echo -e "[!] File '${needed_dir}${needed_file%.*}' already exists."
        echo "Wanna replace it or cancel this installation? [1:replace/2:cancel]"
        read choice
        if [[ $choice = "replace" || $choice -eq 1 ]]; then rm ${needed_dir}${needed_file%.*}
        else echo "Exiting...";exit 0
        fi
    fi
    echo "Installing..."
    sleep 0.5

    cp ${needed_file} ${needed_dir}${needed_file%.*}
    chmod +x ${needed_dir}${needed_file%.*}

    echo "
Done!
Now you can run this program by typing: 'sudo ${needed_file%.*}'

To test if it works, you can try making '/test/test.py' startup.

To remove it, type: sudo rm ${needed_dir}${needed_file%.*}

For more info read README.md 
"
}

check
do_it
exit
