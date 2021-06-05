#!/bin/bash

# bash program to make any bash scripts run at startup

# it's made of functions, so you can easily modify it

# configure
configure(){

    # default directory for the startup script
    dest_dir_for_target_file="/usr/local/sbin/"
    
    printf "Enter script filename which you want to run at startup \n"
    printf "( write full directory or just it's filename if it's located in the same directory where is this program located )\n\n"
    read target_file

    echo "
Do you want to let this script in its current dicrectory or move it to other directory?
Options:
1-- Let it in its current dicrectory
2-- Move it to '${dest_dir_for_target_file}'
3-- Move it to other dicrectory (you choose it)
"
    read choice
    
    temp_target_file=${target_file%.*}.service
    temp_target_file=${temp_target_file##*/}
    target_service_file=${temp_target_file}
    unset temp_target_file
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
        dest_dir_for_target_file="/usr/local/sbin/"
        move_target_file_to_another_dir=1 # true
        ;;

        3)
        echo "Enter directory where you want your startup script to be located:"
        read dest_dir_for_target_file
        move_target_file_to_another_dir=1 # true
        ;;

        *)
        echo "Your option is not valid!"
        exit
        ;;
    esac
}

# check if everything is ok
check_if_ok(){
    printf "Checking some things...\n"

    problems=()
    
    # check if script is running as root
    if [ $EUID -ne 0 ]; then
        problems+=("Please run me as root")
    fi

    # check if needed file exists (In our dir)
    if [ $choice -eq 1 ]; then
        if [ ! -f "$target_file" ]; then
            problems+=("File: ' ${target_file} ' does not exist!")
        fi
    fi
    
    # check if needed directory exists
    if [ $move_target_file_to_another_dir -eq 1 ]; then
        if [ ! -d $dest_dir_for_target_file ]; then
            problems+=("Directory: ' ${dest_dir_for_target_file} ' does not exist!")
        fi
    fi
    
    # check if needed file exists
    if [ $choice -eq 2 ] || [ $choice -eq 3 ]; then
        if [ ! -f ${target_file} ]; then
            problems+=("File: ' ${target_file} ' does not exist!")
        fi
    fi

    if [ ${#problems[@]} -ne 0 ]; then
        printf "Some problems occured:\n\n"
        for eachProblem in "${problems[@]}"; do echo $eachProblem; done
        exit 
    else
        printf "\nOK\n"
    fi
    
    unset problems

}

# ask user if proceed or no
ask_if_proceed(){
    echo "
This program will do this things:
1-- Move ${target_file} to ${dest_dir_for_target_file} 
2-- Make it executable
3-- Create and edit ${dest_dir_for_target_service_file}${target_service_file}
4-- Reload daemon
5-- Enable service ${target_service_file}
6-- Start service ${target_service_file}
"

    printf "\nIs this ok? [y/n]\n"
    read is_ok

    case $is_ok in
        y | Y ) 
            echo "Ok..."
            ;;

        n | N) 
            echo "Operation aborted."
            exit
            ;;
        *)
            echo "Operation  aborted."
            exit
            ;;
    esac
}

# main function to make script run at startup
register_on_startup(){

    if [ $move_target_file_to_another_dir -eq 1 ]; then
        echo "Moving  ${target_file} to ${dest_dir_for_target_file}"
        sudo mv $target_file $dest_dir_for_target_file
        target_file=${dest_dir_for_target_file}/${target_file##*/}
        
    fi
    
    echo "Changing permissions for ${target_file}"
    sudo chmod +x ${target_file}
    target_file=${target_file##*/}
    
    # Don't remove underscores, because this program won't write all this config to the service file, anyways you can edit this service file later
    config_for_target_service_file="[Unit]\nDescription=Startup_bash_script\n\n[Service]\nExecStart=${dest_dir_for_target_file}/${target_file}\n\n[Install]\nWantedBy=multi-user.target\n"
    
    echo "Editing ${dest_dir_for_target_service_file}${target_service_file}"
    sudo printf ${config_for_target_service_file} > ${dest_dir_for_target_service_file}${target_service_file}

    echo "Reloading daemon..."
    sudo systemctl daemon-reload

    echo "Enabling service: ${target_service_file}"
    sudo systemctl enable ${target_service_file}

    echo "Starting service: ${target_service_file}"
    sudo systemctl start ${target_service_file}
    
    printf "\nDone\n"
    # print some useful info
    echo "You can edit ${dest_dir_for_target_service_file}${target_service_file} at any time, or remove it"
    echo "You can disable ${target_service_file} by executing: sudo systemctl disable ${target_service_file}"

}

configure
check_if_ok
ask_if_proceed
register_on_startup
