#!/usr/bin/env bash

# Author: Ray (https://github.com/1RaY-1)
# LICENSE: MIT (see LICENSE file)
# Version: 1.0
# Description:
#   A program to make scripts startup on Linux in few clicks (so at every boot a needed script executes automatically).
#   if you encounter problems, see https://github.com/1RaY-1/linux-startup/blob/main/README.md#problems

# exit on any error
set -e

# colors
readonly green="\e[32m"
readonly red="\e[31m"
readonly reset="\e[0m" 

# configure
configure(){
    printf "Enter your script filename that you want to make startup\n${red}>>> ${reset}"
    read target_file

    echo "
Do you want to let this script in it's current dicrectory or move it to other directory?
Options:
1-- Let it in it's current dicrectory
2-- Move it to '/usr/local/sbin/'
3-- Move it to '/lib/systemd/system-sleep/'
4-- Move it to other dicrectory
"
    printf "${red}>>>${reset} "
    read choice
    
    temp_target_file=${target_file%.*}.service
    temp_target_file=${temp_target_file##*/}
    target_service_file=${temp_target_file}
    # i had problems when tried to move service files to '/etc/systemd/user/' so i use '/etc/systemd/system/' directory instead
    dest_dir_for_target_service_file=/etc/systemd/system/
    
    case $choice in
        1)
        if [ -f $(pwd)/${target_file} ]; then
            dest_dir_for_target_file=$(pwd)/
        else
            dest_dir_for_target_file="${target_file%/*}"
        fi
        move_target_file_to_another_dir=0 # false
        ;;
        2)
        dest_dir_for_target_file=/usr/local/sbin/
        move_target_file_to_another_dir=1 # true
        ;;

        3)
        dest_dir_for_target_file=/lib/systemd/system-sleep/
        move_target_file_to_another_dir=1
        ;;

        4)
        echo "Enter directory where you want your startup script to be stored:"
        printf "\n${red}>>>${reset} "
        read dest_dir_for_target_file
        move_target_file_to_another_dir=1
        ;;

        *)
        printf "\n${red}Your option is not valid!\n${reset}"
        exit 1
        ;;
    esac
    unset choice
}

check_if_ok(){
    printf "Checking some things..."
    sleep 0.8

    problems=()
    
    # check if script is running as root
    if [ $EUID -ne 0 ]; then
        problems+=("Please run me as root")
    fi

    # check if needed directory exists
    if [ $move_target_file_to_another_dir -eq 1 ]; then
        if [ ! -d $dest_dir_for_target_file ]; then
            problems+=("Directory: '${dest_dir_for_target_file}' does not exist!")
        fi
    fi
    
    # check if needed file exists
    if [ ! -f ${target_file} ]; then
        problems+=("File: '${target_file}' does not exist!")
    else
        # check if needed files contains shebang
        read -r firstline<${target_file}
        [[ ! $firstline == "#"* ]] && problems+=("Please add a shebang to '${target_file}'! If don't know what is a shebang, see: https://en.wikipedia.org/wiki/Shebang_(Unix)")
        unset firstline
    fi

    if [ ${#problems[@]} -ne 0 ]; then
        printf "\n${red}Some problems occurred:${reset}\n\n"
        for eachProblem in "${problems[@]}"; do echo -e "${red}*${reset} $eachProblem"; done
        exit 1
    else
        printf "${green}OK${reset}\n"
    fi
    unset problems
}

# ask user if proceed or no
ask_if_proceed(){
    echo "
I will do this things:
1-- Move ${target_file} to ${dest_dir_for_target_file} 
2-- Make it executable
3-- Create and edit ${dest_dir_for_target_service_file}${target_service_file}
4-- Reload daemon
5-- Enable service ${target_service_file}
"

    printf "\nIs this ok? [y/n]\n${red}>>>${reset} "
    read is_ok

    case $is_ok in
        y | Y | yes | YES) echo ;;
        *) exit 0;;
    esac
    unset is_ok 
}

# make script startup
register_on_startup(){
    if [ $move_target_file_to_another_dir -eq 1 ]; then
        printf "Moving  ${target_file} to ${dest_dir_for_target_file} ...";sleep 0.8
        mv $target_file $dest_dir_for_target_file
        target_file=${dest_dir_for_target_file}/${target_file##*/}
        printf "${green}OK${reset}\n"
        
    fi
    
    printf "Changing permissions for ${target_file} ...";sleep 0.8
    sudo chmod +x ${target_file}
    target_file=${target_file##*/}
    printf "${green}OK${reset}\n"
    
    # Do not remove underscores
    config_for_target_service_file="[Unit]\nDescription=Startup_script\n\n[Service]\nExecStart=${dest_dir_for_target_file}/${target_file}\n\n[Install]\nWantedBy=multi-user.target\n"
    
    printf "Editing ${dest_dir_for_target_service_file}${target_service_file} ...";sleep 0.8
    printf ${config_for_target_service_file} > ${dest_dir_for_target_service_file}${target_service_file}
    printf "${green}OK${reset}\n"

    printf "Reloading daemon...";sleep 0.8
    systemctl daemon-reload
    printf "${green}OK${reset}\n"

    printf "Enabling service: ${target_service_file} ...";sleep 0.8
    systemctl enable ${target_service_file}
    printf "${green}OK${reset}\n"

    # print some useful info
    echo -e "
${green}Done${reset}
${green}Do ${red}not${reset} forget that:
${red}*${reset} You can edit ${dest_dir_for_target_service_file}${target_service_file} at any time.
${red}*${reset} You can disable ${target_service_file} by typing: sudo systemctl disable ${target_service_file}
${red}*${reset} You can remove ${target_service_file} by typing: sudo rm ${dest_dir_for_target_service_file}${target_service_file}
"
}

main(){
    echo -e "If you face problems with this program, see 'https://github.com/1RaY-1/linux-startup/blob/main/README.md#problems'\n"
    configure
    check_if_ok
    ask_if_proceed
    register_on_startup
}

main
exit 0
