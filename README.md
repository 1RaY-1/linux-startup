# About
Program **makeit-startup.sh** makes other bash programs startup.

You can also make it a **bin** command by running **makeit-a-bin-command.sh**, so you will be able to execute it as a command from any directory.

Tested on **Linux Mint, Fedora, Parrot OS**
# How it works
This program does this things:

1. Locate your startup bash script
2. Ask you if you want to move your script to other directory
3. Check if your script and needed directory for your script exists
4. Move your script to other directory (if you want to)
5. Make it executable
6. Create and edit service file
7. Reload daemon
8. Enable and start service file which will execute yout bash script at every startup

# Usage
Run with
```
sudo bash run-at-startup.sh
```

**If you do not run this program with `sudo` command, it will probably not work.**

Then you simply have to do few things.

1. First of all you  have to enter your bash script's filename, it can be or full path or just a filename, if it's located in the same directory where is this program is located.

2. Then you have to decide if you want your script to be located in other directory or not (the program will ask you).

3. And finally decide if you're ok with things which this program will do (the program will ask you).

# Problems
You can encounter problems.

To check if you have some problems with this script or not, you can try making script **test.sh** (which is in **test** folder) startup, this script creates on your desktop directory folder named **ITS-WORKING**

So let's see some solutions for some problems.

If after executing: 
```
systemctl status YOUR-SERVICE-FILE
```
You recive an error which is saying: **Permissions denied**, you probably need to edit **/etc/selinux/config** and change line:
```
SELINUX=enforcing 
```
with
```
SELINUX=permissive
```

Or if you recive an error which is saying that you have a bad **Unit** file, you can edit your service file and try changing:
**[Unit]** with **[UNIT]** or with **[unit]**

Maybe you can encounter more not understandable errors, but I didn't.

# Note
If this program is not working for you and you can't understand what's happening, don't try to fix the problems, just make your script startup manually (it's not so difficult).

But if this program works fine for you, then:
- Don't forget that at any time you can edit, disable or remove your service file.

- And don't forget that you can modify this program so it will work perfectly for you.
