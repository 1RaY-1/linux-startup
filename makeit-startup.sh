#!/usr/bin/env bash

# Author: 1RaY-1 (https://github.com/1RaY-1)
# LICENSE: MIT (see LICENSE file)
currentv=1.3 # <-- Version
# Description:
#   A program to set scripts to run at startup on Linux in few clicks (so at every boot a needed script executes automatically, thanks to a .service file)
#   It supports bash, python, or other INTERPRETED scripts
#   if you encounter problems, see https://github.com/1RaY-1/linux-startup/blob/main/README.md#problems
#
# Tested on: Linux Mint, Fedora, Parrot OS, Kali Linux, Arch Linux, Debian
# This script requires to be ran with BASH to function properly

# TODO
# Edit/improve the .service file
# Ask user if the startup script should be restarted every time it stops (due to any reasons) or no
# Add an option to rename the future (target) .service file

# exit on any error
set -e


# colors
readonly green="\e[32m"
readonly red="\e[31m"
readonly reset="\e[0m" 

# Some variables
override_service_file=0 # <-- ZERO means NO

version_check(){
    latestv=$(curl -s https://api.github.com/repos/1RaY-1/linux-startup/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

    if (( $(echo "$latestv > $currentv" |bc -l) )); then
        echo -e "A new version of Linux Startup is available: $latestv\n"; sleep 0.5s
    fi
}

# a function to exit and print a text at the same time
die(){
    echo -ne "$1"
    exit
}

# configure
configure(){
#   Before it worked when I was typing the RELATIVE path to a script, but now it apparently just doesn't work
    printf "Enter the full path of the script that you wanna set as a startup\n(Note: Variables (\$PWD, \$HOME, etc...) will not work here)\n${red}>>> ${reset}"
    read target_file

    echo -ne "
Do you wanna move this script to other directory?
Options:
1-- No (skip this)
2-- Move it to $( [ -d "/usr/local/sbin" ] && echo "'/usr/local/sbin/'" || echo "'/usr/local/sbin/' ${red}DOESN'T EXIST${reset}" )
3-- Move it to $( [ -d "/lib/systemd/system-sleep" ] && echo "'/lib/systemd/system-sleep/'" || echo "'/lib/systemd/system-sleep' ${red}DOESN'T EXIST${reset}")
4-- Move it to other dicrectory (you'll type it)
"
    printf "${red}>>>${reset} "
    read choice
    
    temp_target_file=${target_file%.*}.service
    temp_target_file=${temp_target_file##*/}
    target_service_file=${temp_target_file}
    # I had problems when tried to move service files to '/etc/systemd/user/' so i use '/etc/systemd/system/' instead
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
        echo "Enter a directory: "
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

#    detect the non-root user (because the script is supposed to be executed as ROOT)
    if [ -n "$SUDO_USER" ]; then
        ruser="$SUDO_USER"
    #elif [ -n "$LOGNAME" ]; then # apparently this isn't needed, but I'm just gonna let itcommented for now
    #    REAL_USER="$LOGNAME"
    elif [ -n "$USER" ] && [ "$USER" != "root" ]; then
        ruser="$USER"
    #else # this is probably not needed either
    #    ruser=$(id -un 1000 2>/dev/null || echo "unknown")
    fi

#    Ask if want to execute the script (at every boot) as root or as a user
    echo -e "\nDo you want the script to be executed as root or as $ruser ?
    Options: 
    1 --- Execute as a user ($ruser)
    2 --- Execute as root"

    printf "\n${red}>>>${reset} "
    read choice

    case $choice in
        1) id_choice="user" ;;
        2) id_choice="root" ;;
        *) echo "Invalid answer!" ; exit 1 ;;

    esac
    unset choice
}

# Check for problems before proceeding
check_if_ok(){
    printf "Checking some things..."
    sleep 0.8

    problems=()
    
    # check if the init system is systemd
    if ! [[ `command -v systemctl` ]]; then
        problems+=("Your distribution is not using 'systemd'!")
    fi

    # check if running with elevated privileges
    if [ $EUID -ne 0 ]; then
        problems+=("Please run me with sudo!")
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
        [[ ! $firstline == "#!"* ]] && problems+=("Please add a shebang to '${target_file}'! Read about shebang here: https://en.wikipedia.org/wiki/Shebang_(Unix)")
        unset firstline
    fi

    if [ ${#problems[@]} -ne 0 ]; then
        printf "\n${red}Some problems occurred:${reset}\n\n"; sleep 0.8s
        for eachProblem in "${problems[@]}"; do echo -e "${red}*${reset} $eachProblem"; done
        exit 1
    else
#        Check if the service file (that were gonna create) already exists
        if [ -f "${dest_dir_for_target_service_file}${target_service_file}" ]; then
            echo -ne "${red}[Warning]${reset}"; sleep 0.8s
            echo -e "\nThe service file ${dest_dir_for_target_service_file}${target_service_file} already exists"
            echo "I'm supposed to name the new service file the same as the startup script (at least as for now)"
            echo -e "\nAre you willing to override it?"
            echo "Y -- Just override it and proceed"
            echo "N -- Skip and abort"
            printf "\n${red}>>>${reset} "
            read choice

            case $choice in
                Y | y | yes | YES)
                    echo -ne "${green}Proceeding${reset}\n"
                    override_service_file=1
                    sleep 0.8s
                    ;;
                *)
                    echo -ne "${red}Aborting...${reset}"
                    sleep 0.8s
                    exit ;;
            esac
        else
            printf "${green}OK${reset}\n"
            fi
    fi
    unset problems
}

# ask user if proceed or no
ask_if_proceed(){
    echo "
These things will be performed:
$( [ $move_target_file_to_another_dir -eq 1 ] && echo "* Move '$target_file' to '$dest_dir_for_target_file'" || :) 
* Make '${target_file##*/}' executable
$( [ $override_service_file -eq 1 ] && echo "* Override (the existant) '${dest_dir_for_target_service_file}${target_service_file}'" || echo "* Create and edit '${dest_dir_for_target_service_file}${target_service_file}'" )
* Reload daemon
* Enable service '${target_service_file}' "

    printf "\nProceed? [y/n]\n${red}>>>${reset} "
    read is_ok

    case $is_ok in
        y | Y | yes | YES) : ;;
        *) exit 0;;
    esac
    unset is_ok 
}

# make script startup
register_on_startup(){
    if [ $move_target_file_to_another_dir -eq 1 ]; then
        printf "Moving  ${target_file} to ${dest_dir_for_target_file} ...";sleep 0.8
        sudo mv $target_file $dest_dir_for_target_file
#       If everything's fine, it'll print the OK msg, otherwise exit
        #printf "${green}OK${reset}\n"
        [[ $? -eq 0 ]] && printf "${green}OK${reset}\n" || die "${red}Something went wrong${reset}\n"
        target_file=${dest_dir_for_target_file}/${target_file##*/}
        
    fi

#   Change perms of the exec file
    printf "Changing permissions for ${target_file} ...";sleep 0.8
    sudo chmod +x ${target_file}
#   If everything's fine, it'll print the OK msg, otherwise exit
    [[ $? -eq 0 ]] && printf "${green}OK${reset}\n" || die "${red}Something went wrong${reset}\n"
    target_file=${target_file##*/} # <-- I think this  code shouldn't give any errors
        
#   Detect the user again (if needed)
    if [ $id_choice == "root" ] ; then
#       # Do not remove underscores from this variable
        config_for_target_service_file="[Unit]\nDescription=Startup_script\n\n[Service]\nExecStart=${dest_dir_for_target_file}/${target_file}\n\n[Install]\nWantedBy=multi-user.target\n"
    elif [ $id_choice == "user" ] ; then
        
        # detect the non-root user (because the script is supposed to be executed as ROOT)
        if [ -n "$SUDO_USER" ]; then
            ruser="$SUDO_USER"
        #elif [ -n "$LOGNAME" ]; then
        #    REAL_USER="$LOGNAME"
        elif [ -n "$USER" ] && [ "$USER" != "root" ]; then
            ruser="$USER"
        #else
        #    ruser=$(id -un 1000 2>/dev/null || echo "unknown")
        fi

        config_for_target_service_file="[Unit]\nDescription=Startup_script\n\n[Service]\nUser=$ruser\nGroup=$ruser\nExecStart=${dest_dir_for_target_file}/${target_file}\nRestart=always\n\n[Install]\nWantedBy=multi-user.target\n"
        #config_for_target_service_file="[Unit]\nDescription=Startup_script\n\n[Service]\nExecStart=${dest_dir_for_target_file}/${target_file}\n\n[Install]\nWantedBy=multi-user.target\n"
    fi
    
    printf "Editing ${dest_dir_for_target_service_file}${target_service_file} ...";sleep 0.8
    printf "${config_for_target_service_file}" > "${dest_dir_for_target_service_file}${target_service_file}"
    [[ $? -eq 0 ]] && printf "${green}OK${reset}\n" || die "${red}Something went wrong${reset}\n"

    printf "Reloading daemon...";sleep 0.8
    sudo systemctl daemon-reload
    [[ $? -eq 0 ]] && printf "${green}OK${reset}\n" || die "${red}Something went wrong${reset}\n"

    printf "Enabling service: ${target_service_file} ...";sleep 0.8
    sudo systemctl enable ${target_service_file}
    [[ $? -eq 0 ]] && printf "${green}OK${reset}\n" || die "${red}Something went wrong${reset}\n"

    echo -en "${green}Done!${reset}"; sleep 1s

    # print some useful info
    echo -e "
Your script will now execute at every boot.

${green}Do ${red}not${reset} forget that:
${red}*${reset} You can ${green}edit${reset} '${dest_dir_for_target_service_file}${target_service_file}' at any time (with sudo)
${red}*${reset} You can ${green}start${reset} (right now) '${target_service_file}' with: sudo systemctl start ${target_service_file}
${red}*${reset} You can ${green}check${reset} the status of '${target_service_file}' with: systemctl status ${target_service_file}
${red}*${reset} You can ${green}disable${reset} '${target_service_file}' with: sudo systemctl disable ${target_service_file}
${red}*${reset} You can ${green}remove${reset} '${target_service_file}' with: sudo rm ${dest_dir_for_target_service_file}${target_service_file}
"
}

main(){
#   if 'wget' & 'curl' are installed on this system and there is connection with github, then we can check if there is a new version of Linux Startup available
    if [[ `command -v curl` ]] && [[ `command -v wget` ]] &> /dev/null; then
        wget -q --spider https://github.com/1RaY-1/linux-startup/releases
        if [ $? -eq 0 ]; then
            version_check
        fi
    fi
    configure
    check_if_ok
    ask_if_proceed
    register_on_startup
}

main
