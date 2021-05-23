# bash-startup
This bash program makes other bash programs run at startup

Tested on Linux Mint, Fedora, Parrot OS
# How it works
This program does this things:

Locate your startup bash script and make sure that it exists
Make sure that needed directory for you script exists
Move your script to other directory (if you want to)
Change it's permissions
Create and edit .service file
Reload daemon
Enable and start .service file which will execute yout bash script at every startup

# Usage
Run this program with 'sudo' command
Then you simply have to do few things because the rest will do this program for you

First of all you  have to enter your bash script's filename, it can be or full path or just a filename, if it's located in the same directory where is this program is located

Then you have to decide if you want your script to be located in other directory or not

And finally decide if you're ok with things which this program will do

# Problems
You can encounter some problems, so let's see some solutions for some problems

If after executing: systemctl status YOUR-SERVICE-FILE 
you recive an error which is saying: 'Permissions denied', you probably need to edit '/etc/selinux/config' and change line:
SELINUX=enforcing with SELINUX=permissive

If you recive an error which is saying that you have a bad Unit file, you can edit your .service file and try changing:
[Unit] with [UNIT] or with [unit]

Maybe you can enctounter more not understandable errors, but i didn't

# Note
Don't forget that at any time you can edit, disable or remove your .service file

And don't forget that you can modify this program so it will work perfectly for you
