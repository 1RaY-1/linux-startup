# About
A script to easily make any script startup on Linux using SYSTEMD

<details>
  <summary><h3>Tested on</h3></summary>

- **Pop_!OS 22.04 (LTS)**
- **Linux Mint (older version)**
- **Fedora (older version, with SELinux set to permissive)**
- **Arch Linux (older)**
</details>

-----------------------------------------------------------------------

# How to use it
After executing [this script](https://github.com/1RaY-1/bash-startup/blob/main/makeit-startup.sh) you'll have to do the following:

0. Enter full path for the needed script
1. Decide if you want to move it to other directory or not
2. Decide if to execute startup script as root or as user
3. Check if everything's fine (check if needed file exists, contains shebang, etc...)

## Then

0. It will move your script to other directory (if you want to)
1. Make it executable
2. Create and edit service file
3. Reload daemon
4. Enable service file
5. Print useful commands to manage the service file

-----------------------------------------------------------------------

## Installing
You can run install.sh (it'll simply move the script to a *bin* directory), but it's not obligatory

-----------------------------------------------------------------------

## Running
Simply execute the script without any arguments (**with BASH**):
```
sudo bash makeit-startup.sh
```

-----------------------------------------------------------------------

# Problems
You can encounter problems.

To check if you have some problems with this script or not, you can try making script [test.py](https://github.com/1RaY-1/linux-startup/blob/main/test/test.py) or [test.sh](https://github.com/1RaY-1/bash-startup/blob/main/test/test.sh) startup.

So

- If after typing: 
```
systemctl status YOUR-SERVICE-FILE
```
You recive an error which is saying something like: **Permissions denied** (will happen on SELinux distros) , then you probably need to edit **/etc/selinux/config** and change line:
```
SELINUX=enforcing 
```
with
```
SELINUX=permissive
```

*And reboot your system*

- If you recive an error which is saying that you have a bad **Unit** file, you can edit your service file and try changing:
**[Unit]** with **[UNIT]** or with **[unit]**

If you encounter more problems, please tell me by creating an [issue](https://github.com/1RaY-1/linux-startup/issues).

-----------------------------------------------------------------------

# More:

* If you don't know what you are doing then don't run it, or try it out in a VM
* You can try this out on a virtual machine before making any changes on your host, for better stability
* Before making any script startup, make sure it has a [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix))
* If you want to understand how to manually make any script startup, here some links that will help you:

https://stackoverflow.com/questions/12973777/how-to-run-a-shell-script-at-startup

https://www.youtube.com/watch?v=-aKb-k8B8xo
