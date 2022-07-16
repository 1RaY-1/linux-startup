# About
A program to easily make any script startup on Linux, so at every boot a needed script executes automatically.

Tested on **Linux Mint, Fedora, Parrot OS, Kali Linux, Arch Linux**

-----------------------------------------------------------------------

# How it works ?
[It](https://github.com/1RaY-1/bash-startup/blob/main/makeit-startup.sh) does this things:

1. Locate your needed script (that you wanna be startup)
2. Ask you if you want to move this script to other directory
3. Check if everything is ok
4. Move this script to other directory (if you want to)
5. Make it executable
6. Create and edit service file
7. Reload daemon
8. Enable service file that will execute your script at startup

-----------------------------------------------------------------------

# How to install ?
Type the following commands in your terminal
* `git clone https://github.com/1RaY-1/linux-startup`
* `cd linux-startup`

And run it
* `sudo bash makeit-startup.sh`

Or install it and then run

* `sudo bash install.sh`
* `sudo makeit-startup`

-----------------------------------------------------------------------

# Usage
If you just downloaded this program.
```
sudo bash makeit-startup.sh
```
If you installed it.
```
sudo makeit-startup
```
Then you simply have to do few things.

1. Enter full path to the script that you wanna make startup.

2. Decide if you want to move it to other directory or not.

3. Agree to continue.

You can watch [example video](https://github.com/1RaY-1/linux-startup/blob/main/example.mp4), to see that it's very easy to use it.

-----------------------------------------------------------------------

# Problems
You can encounter problems.

To check if you have some problems with this script or not, you can try making script [test.py](https://github.com/1RaY-1/linux-startup/blob/main/test/test.py) or [test.sh](https://github.com/1RaY-1/bash-startup/blob/main/test/test.sh) startup

So

- If after typing: 
```
systemctl status YOUR-SERVICE-FILE
```
You recive an error which is saying something like: **Permissions denied**, then you probably need to edit **/etc/selinux/config** and change line:
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

# Note few things
* Before making any script startup, make sure it has a [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix))
* If you wanna understand how to manually make any script startup, here's some link that should help you.
https://stackoverflow.com/questions/12973777/how-to-run-a-shell-script-at-startup
https://www.youtube.com/watch?v=-aKb-k8B8xo
