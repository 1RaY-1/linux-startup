# About
[makeit-startup.sh](https://github.com/1RaY-1/bash-startup/blob/main/makeit-startup.sh) makes scripts startup on Linux.

**Do not forget to add a shebang on your script that you wanna make startup!**

*You can also make it a bin command by running makeit-a-bin-command.sh, so you will be able to execute it as a command from any directory.*

Tested on **Linux Mint, Fedora, Parrot OS**
# How it works
The [main](https://github.com/1RaY-1/bash-startup/blob/main/makeit-startup.sh) script does this things:

1. Locate your needed script (that you wanna be startup)
2. Ask you if you want to move this script to other directory
3. Check if everything is ok
4. Move this script to other directory (if you want to)
5. Make it executable
6. Create and edit service file
7. Reload daemon
8. Enable service file that will execute your script at startup

# Usage
Run [makeit-startup.sh](https://github.com/1RaY-1/bash-startup/blob/main/makeit-startup.sh) with
```
sudo bash makeit-startup.sh
```

**Dont't forget that you have to run it with `sudo` command.**

Then you simply have to do few things.

1. Enter path to your script that you want to be startup.

2. Decide if you want to move this script to other directory or not.

3. Decide if you are ok with things that this [makeit-startup.sh](https://github.com/1RaY-1/bash-startup/blob/main/makeit-startup.sh) will do.

# Problems
You can encounter problems.

To check if you have some problems with this script or not, you can try making script [test.py](https://github.com/1RaY-1/linux-startup/blob/main/test/test.py) or [test.sh](https://github.com/1RaY-1/bash-startup/blob/main/test/test.sh) startup

So if you encounter problems, let's see some solutions for some problems.

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

Maybe you can encounter more problems, but I didn't.

# Note
If [makeit-startup.sh](https://github.com/1RaY-1/bash-startup/blob/main/makeit-startup.sh) is not working for you and you can't understand what's happening, don't try to fix the problems, just make your script startup manually, here are some useful links that might help you:

https://stackoverflow.com/questions/12973777/how-to-run-a-shell-script-at-startup

https://www.youtube.com/watch?v=-aKb-k8B8xo

But if this script works fine for you, then:
- Don't forget that at any time you can edit, disable or remove your service file.
- Don't forget that you can modify [makeit-startup.sh](https://github.com/1RaY-1/bash-startup/blob/main/makeit-startup.sh) so it will work perfectly for you.
