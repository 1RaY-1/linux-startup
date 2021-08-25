#!/usr/bin/env python3

# you can try making this script startup to check if the program is actually working  for you
# this script creates a directory named 'ITS-WORKING' on your desktop
# if this script isn't working, try making 'test.sh' startup

import os
home = os.environ['HOME']
os.mkdir(home + "/Desktop/ITS-WORKING")
