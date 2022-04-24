# ottr

## Overview
Organisational Task Tracker (ottr) is a repository-specifc terminal app for keeping track of tasks associated with a specific project. 
Once initialized inside of a repo, users can add, remove, re-organize, and nest tasks, either striaght from the command line or by launching
the ottr user interface. ottr was designed with flexible workflows in mind, so everything that can be done from ottr's UI can also be achieved
through command line arguments.

## Set-up & Installation

These installation instructions assume you are using a UNIX-like system with Ruby installed.

### Running the script

The following instructions will allow you to run the script without proper installation;
this is okay for testing ottr out, but won't allow you to run it from other directories.

1. clone the ottr repo
1. open terminal
1. `cd` into the `ottr/src` directory containing `ottr`
1. run `./installer.sh`
1. initialize ottr by running `./ottr init`

Now that ottr is initalized you can run the script using the command `./ottr` from the current working directory 

### Installing ottr

The following instructions are a bit more involved but will allow you to use ottr from any directory, 
the way it was intended to be run.

1. clone the ottr repo
1. open terminal
1. run `echo $PATH` to see a list of directories. You will need to choose one for installing ottr, traditionally it's best to use `/usr/local/bin/`
1. if you would like to use `/usr/local/bin/` but it doesn't exist, create it using `mkdir -p /usr/local/bin`
1. `cd` into the `ottr/src` directory containing `ottr`
1. run `./installer.sh` to install required ruby gems
1. create a softlink by running `sudo ln -s $PWD/ottr /usr/local/bin/` (or use the path you chose in step 3)

If the link was successful you should be able to initiate ottr in any directory by `cd`ing into it and running `ottr init`. Ottr can then be used in that directory by running `ottr`.

## How to use ottr

The easiest way to learn how to use ottr is to jump into the UI and play around with it.

To initiate ottr in any directory, simply `cd` into that directory and run `ottr init`. The ottr UI can now be accessed from that directory using the `ottr` command. We'll cover how to use the UI later, but for now lets look at what else you can do from the command line.

### ottr from the command line

* `ottr init` initiates ottr in the current working directory
* `ottr add "just an example"` will add a new task called *just an example*
* `ottr add 1 "a nested example"` will add a new child-task called *a nested example* to the task in position 1
* `ottr log` prints a list of all tasks and child-tasks

e.g. running the previous **add** commands and then running the **log** command would return:
```
1. just an example
    1.1. a nested example
```

* `ottr move 3` will open a menu for moving the **3rd** task
* `ottr move 3 2` will open a menu for moving the **2nd** child-task of the **3rd** task
* `ottr del 2` will delete the **2nd** task (you will be asked to confirm the deletion)
* `ottr del 5 3` will delete the **3rd** child-task of the ***5th*** task (you will be asked to confirm the deletion)
* `ottr name 3` will open a menu to rename the **3rd** task
* `ottr name 2 6` will open a menu to rename the **6th** child-task of the **2nd** task

