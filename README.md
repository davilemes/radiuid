# RadiUID ![RadiUID][logo]

An application to extract User-to-IP mappings from RADIUS accounting data and send them to Palo Alto firewalls for use by the User-ID function.



####   VERSION   ####
-----------------------------------------
The version of RadiUID documented here is: **v2.1.0**


####   TABLE OF CONTENTS   ####
-----------------------------------------
1. [What is RadiUID?](#what-is-radiuid)
2. [How it Works](#how-it-works)
3. [Screenshots](#screenshots)
4. [Requirements](#requirements)
5. [Tested Environments](#tested-environments)
6. [Install Instructions](#install-instructions)
7. [Command Interface](#command-interface)
8. [Timeout Tuning](#timeout-tuning)
9. [1.1.0 TO 2.0.0 Updates](#updates-in-v110----v200)
10. [2.0.0 TO 2.0.1 Updates](#updates-in-v200----v201)
11. [Upgrade Processes](#upgrade-processes)
11. [Contributing](#contributing)


####   WHAT IS RADIUID   ####
-----------------------------------------

User-based firewall filtering is a novel and attractive concept which can often be difficult to implement due to the requirement by firewalls to map IP addresses to users. One common method of getting user-to-IP mapping information for your firewall is to install a log-reading agent onto an Active Directory domain controller which can look over transaction logs and send the proper information to the firewall, but this assumes user endpoints interact and authenticate directly with the domain controllers, or that you have Active Directory at all!

RadiUID is a Linux-based application built to take everyday RADIUS accounting information generated by RADIUS authenticators like wireless systems, firewalls, etc (which contains username and IP info) and send that ephemeral IP and username mapping info to a Palo Alto firewall to be used by the User-ID system for user or group-based access-list filtering, or intelligent reporting. 



####   HOW IT WORKS   ####
--------------------------------------

RadiUID uses FreeRADIUS as a backend service to listen on RADIUS accounting ports (typically TCP\UDP 1813) and write recieved accounting information to accounting logs.

RadiUID then parses these logs, pulls down the User and IP mapping information and pushes those mappings to the Palo Alto firewall using the published RESTful XML API.

RadiUID runs as a system service on Linux and is very easy to configure and use. All configuration and interaction with RadiUID is via command line on the Linux BASH shell. Once the installer completes, RadiUID can be invoked from the command shell by typing `radiuid` followed by the desired command. Hit the [TAB] key for command options or hit [ENTER] for the list of options!



####   SCREENSHOTS   ####
--------------------------------------

**The main list of CLI command options**
![RadiUID][all-args]

**Output from the `show log` command**
![RadiUID][show-log]

**Output from the `show config` command**
![RadiUID][show-config]

**Output from the `show config set` command**
![RadiUID][show-config-set]

**Pushing a mapping using the `push` command and checking the current mappings using the `show mappings` command**
![RadiUID][push-and-show]



####   REQUIREMENTS   ####
--------------------------------------

OS:			**Any modern Debian or RHEL distro** (CentOS 6 or 7, Ubuntu 14 or 16...)

Interpreter:		**Python 2.7.X** *(Also works on Python 2.6.6 and up)*

PAN-OS Version:		**6.X and 7.X**



####   TESTED ENVIRONMENTS   ####
--------------------------------------

RadiUID has been written and tested in a few environments to date as it was purpose-built for a specific environment, but it should be very adaptable as it uses standardized RADIUS accounting to source user information and the published API to push that info to Palo Alto firewalls.

RadiUID has currently been tested with the following Operating Systems, RADIUS servers, and authenticators

Operating Systems: **CentOS 7, CentOS 6, Ubuntu 16 Server, Ubuntu 14 Server**

Identity Systems: **JumpCloud RADIUS service, Windows 2012 NPS Server (with Active Directory)**

Authenticators: **Meraki Wireless Access Points, Cisco Wireless (Controller-based), Ruckus Zonedirector**



####   INSTALL INSTRUCTIONS   ####
----------------------------------------------

The install of RadiUID is very quick and straightforward using the built-in installer.
NOTE: You need to be logged in as root or have sudo privileges on the system to install RadiUID



1. Install OS with appropriate IP and OS settings and update to latest patches (recommended)
	- Check out the [CentOS Minimal Server - Post-Install Setup][centos-post-install] and the [Ubuntu Server - Post Install Setup][ubuntu-post-install] for help with some of the post-install configuration steps.
2. Install the Git client (unless you already have the RadiUID files): `sudo yum install git -y` or `sudo apt install git -y`
3. Clone the RadiUID repo to any location on the box: `git clone https://github.com/PackeTsar/radiuid.git`
4. Change to the directory where the RadiUID main code file (radiuid.py) and config file (radiuid.conf) are stored: `cd radiuid`
	- (OPTIONAL) Change to the development branch (perform this step only if you are prepared for a version which is under active development and may have broken features): `git checkout devel`
5. Run the RadiUID program in install mode to perform the installation: `sudo python radiuid.py install`
	- NOTE: Make sure that you have the .conf file in the same directory as the .py directory for the initial install
6. Follow the on-screen prompts to install FreeRADIUS and the RadiUID application
	- The installer should let you know if everything installed correctly and services are running, but in the next section are the CLI commands you can run to check up on it.



####   COMMAND INTERFACE   ####
----------------------------------------------

The RadiUID system is meant to run in the background as a system service: constantly checking for new RADIUS accounting data and pushing User-ID mapping information to the firewall, but it also has an easy to use command interface. This command interface is meant to be used for regular maintenance, troubleshooting, and operation of the system.

Below is the CLI guide for the RadiUID service.

*You can see this guide by typing 'python radiuid.py' (before installation) or 'radiuid' (after installation) and hitting ENTER.*

     -------------------------------------------------------------------------------------------------------------------------------
                          ARGUMENTS                    |                                  DESCRIPTIONS
     -------------------------------------------------------------------------------------------------------------------------------
     
      - run                                            |  Run the RadiUID main program in shell mode begin pushing User-ID information
     -------------------------------------------------------------------------------------------------------------------------------
     
      - install                                        |  Run RadiUID Install/Maintenance Utility
     -------------------------------------------------------------------------------------------------------------------------------
     
      - show log                                       |  Show the RadiUID log file
      - show acct-logs                                 |  Show the log files currently in the FreeRADIUS accounting directory
      - show run (xml | set)                           |  Show the RadiUID configuration in XML format (default) or as set commands
      - show config (xml | set)                        |  Show the RadiUID configuration in XML format (default) or as set commands
      - show clients (file | table)                    |  Show the FreeRADIUS clients and config file
      - show status                                    |  Show the RadiUID and FreeRADIUS service statuses
      - show mappings (<target> | all | consistency)   |  Show the current IP-to-User mappings of one or all targets or check consistency
     -------------------------------------------------------------------------------------------------------------------------------
     
      - set logfile                                    |  Set the RadiUID logfile path
      - set radiuslogpath                              |  Set the path used to find FreeRADIUS accounting log files
      - set maxloglines <number-of-lines>              |  Set the max number of lines allowed in the log ('0' turns circular logging off)
      - set userdomain                                 |  Set the domain name prepended to User-ID mappings
      - set timeout                                    |  Set the timeout (in minutes) for User-ID mappings sent to the firewall targets
      - set client <ip-block> <shared-secret>          |  Set configuration elements for RADIUS clients to send accounting data FreeRADIUS
      - set target <hostname>:<vsys-id> [parameters]   |  Set configuration elements for existing or new firewall targets
     -------------------------------------------------------------------------------------------------------------------------------
     
      - push (<hostname>:<vsys-id> | all) [parameters] |  Manually push a User-ID mapping to one or all firewall targets
     -------------------------------------------------------------------------------------------------------------------------------
     
      - tail log (<# of lines>)                        |  Watch the RadiUID log file in real time
     -------------------------------------------------------------------------------------------------------------------------------
     
      - clear log                                      |  Delete the content in the log file
      - clear acct-logs                                |  Delete the log files currently in the FreeRADIUS accounting directory
      - clear client (<ip-block> | all)                |  Delete one or all RADIUS client IP blocks in FreeRADIUS config file
      - clear target (<hostname>:<vsys-id> | all)      |  Delete one or all firewall targets in the config file
      - clear mappings [parameters]                    |  Remove one or all IP-to-User mappings from one or all firewalls
     -------------------------------------------------------------------------------------------------------------------------------
     
      - edit config                                    |  Edit the RadiUID config file
      - edit clients                                   |  Edit RADIUS client config file for FreeRADIUS
     -------------------------------------------------------------------------------------------------------------------------------
     
      - service [parameters]                           |  Control the RadiUID and FreeRADIUS system services
     -------------------------------------------------------------------------------------------------------------------------------
     
      - request [parameters]                           |  Make system-level changes for RadiUID service
     -------------------------------------------------------------------------------------------------------------------------------
     
      - version                                        |  Show the current version of RadiUID and FreeRADIUS
     -------------------------------------------------------------------------------------------------------------------------------



####   TIMEOUT TUNING   ####
----------------------------------------------

RadiUID pushes ephemeral User-ID information to the firewall whenever new RADIUS accounting information is recieved and by default sets a timeout of 60 minutes. If this accounting information comes from a wireless system (where most devices re-authenticate regularly) then you may be able to tune down that timeout to make the mapping information expire more quickly. If the RADIUS authenticator is something like a VPN concentrator (where re-authentication doesn't typically happen), then you may want to turn up the timeout period. Either way, you should expect to have to play with the timeout settings to make sure your firewalls are not prematurely expiring User-ID data from their mapping tables.



####   UPDATES IN V1.1.0 --> V2.0.0   ####
--------------------------------------

**ADDED FEATURES:**

- The RadiUID config file has been changed to a simpler XML format. Config file management no longer depends on the ConfigParser module.

- All configuration settings (including the RADIUS client configuration for FreeRADIUS) are configurable using `set` commands. Just type `radiuid set` and hit [ENTER] to see the options or type `show config set` and hit [ENTER] to see the current configuration as a series of `set` commands.

- Multiple target firewalls are now supported; mappings can be pushed to multiple firewalls using different credentials.

- Multi-vsys functionality has been added so a configured firewall target includes parameters for the target vsys. If you want to control multiple vsys on the same firewall, you will need to add multiple targets.

- Improved HTTP error handling to keep application from crashing.

- Added CLI auto-complete functionality to allow you to use the [TAB] key to automatically complete commands or see the available options.

- Circular logging was added to maintain the size of the log file. The number of lines allowed in the log file is controlled by the *maxloglines* parameter which is configurable using the `set maxloglines` command.

- The `show mappings` was command added to pull and view mappings directly from one or all firewalls. The `consistency` parameter can also be used to check the consistency of mappings across all configured firewalls.

- The `push` command was added to allow you to manually push a User-to-IP mapping to one or all the firewalls. *NOTE: The user and IP address can be anything you want, they do not have to be legitimate users or working IP addresses*

- The `show config set` command was added to display the current configuration as a series of `set` commands which can be copied and pasted to configure the application.

- The `show clients`, `set client`, and `clear client` commands were added to allow you to more easily control the RADIUS clients configured in the FreeRADIUS clients.conf file. Now it can all be administered using RadiUID commands. The `show config set` output even includes the current RADIUS clients as `set client` commands.



####   UPDATES IN V2.0.0 --> V2.0.1   ####
--------------------------------------

**BUG FIXES:**

- *ISSUE #13*: The RadiUID 'merge_dicts' method was throwing a `KeyError` exception and quitting the loop (service) when a FreeRADIUS log was scraped which didn't contain the three required fields (`usernameterm`, `ipaddressterm`, and the `delineatorterm`). An error handler has been added to detect the `KeyError`, dump the dictionary data to the log, and continue in the loop.
    - This issue was reproduced on v2.0.0 code by removing the line in the FreeRADIUS log containing the `usernameterm` text and running the loop (`radiuid run`).
    - It is highly recommended to update to v2.0.1 or later to fix this bug as it affects the stability of the RadiUID RADIUS log capturing functionality.

- *ISSUE #14*: The default configured `delineatorterm` was documented as non-functional for RADIUS accounting messages from a Ruckus wireless system by Dan Hume on his blog at http://www.dhume.co.uk. He had to change the default `delineatorterm` to "Accounting-Session-ID" to make the log parsing work properly.
    - This bug has been fixed by adding functionality for RadiUID to recognize the paragraph separations between FreeRADIUS log entries within the same file and use those paragraph separations as the delineator. To enable this functionality, you must upgrade to v2.0.1 and use the [PARAGRAPH] keyword as the `delineatorterm` value (which is now the default value in the config file).



####   UPDATES IN V2.0.1 --> V2.1.0   ####
--------------------------------------

**ADDED FEATURES:**

- Multi-OS support: Previously only CentOS 7 was supported for installation due to dependencies on specific file paths and OS commands for interaction with the OS. Now RadiUID should fully work on any modern Debian or RHEL distro. It has been QA tested on CentOS 7.2, CentOS 6.8, Ubuntu 16.04, and Ubuntu 14.04.

- `radiuid show acct-logs` and `radiuid clear acct-logs` commands now added to help with controlling the FreeRADIUS logs in the accounting directory.

- The new `request` top-level command now gives access to some of the more advanced system-level functions in RadiUID. These commands can now be used to fully install RadiUID as an alternative to the Install/Maintenance Utility
    - `request auto-complete` runs the script to install and activate the BASH Auto-Completion feature
    - `request freeradius-install` installs the FreeRADIUS app using the proper package manager
    - `request xml-update` downloads and installs an update to the xml.etree.ElementTree Python module. This upgrades ElementTree to 1.3.0 which is the minimum version required for RadiUID to run properly. This is only required when running Python 2.6.X.
    - `request reinstall keep-config` performs a reinstall of the RadiUID binary, BASH Auto-Completion feature, RadiUID service, and restarts the service, but leaves the current config file alone to preserve the config during an upgrade. This command is now the preferred way to perform an update of an existing installation of RadiUID.
    - `request reinstall replace-config`performs all of the tasks listed above with the exception that it also replaces the existing configuration (if one exists) with the default config. This command can be used to do a quick net-new install of RadiUID without using the classic installer. 

**BUG FIXES:**

- *ISSUE #16*: Newer builds of urllib2 in Python 2.7 started generating an error when the SSL certificate was invalid. Some logic has been added to detect when to use the proper SSL handling

- *ISSUE #17*: The RadiUID XML assembler was hard set to allow up to 100 UIDs in a single API call before splitting into multiple calls which was overwhelming to the Palo Alto. That setting has been moved down to 50 UIDs per call and the setting `maxuidspercall` has been moved to the internal settings area near the top of the radiuid.py file.
    - This fix was reproduced and verified fixed by having RadiUID eat a FreeRADIUS Accounting log file with 2000 UIDs and push them into a test firewall. 50 UIDs per API call seems to work even with long usernames (50 characters).



####   UPGRADE PROCESSES   ####
--------------------------------------

**Upgrading from v2.X to v2.1.0:**

1. Perform a `radiuid show config set` command and save the `set` commands displayed in a safe place (just in case)
2. Download the v2.1.0 code from the GitHub repo by using `git clone https://github.com/PackeTsar/radiuid.git`
    - If the "radiuid" folder already exists, you may want to use git to update the clone `cd radiuid/; git pull`
3. Move to the radiuid folder created by git using the `cd radiuid/` command
4. Perform a quick reinstall/update of RadiUID using the command `python radiuid.py request reinstall keep-config`
5. Type in CONFIRM and hit ENTER to confirm you want to perform the reinstall
6. Once the installer exits, you should run `radiuid show config set` and see your configuration from before.
7. Perform a `radiuid service all restart` command to restart RadiUID to use the new app version


**Upgrading from v1.X to v2.1.0:**

1. Change the name of your config file (/etc/radiuid/radiuid.conf) by issuing the command `mv /etc/radiuid/radiuid.conf /etc/radiuid/radiuid.conf.backup`
2. Grab the contents to have them handy during the install of the new version `more /etc/radiuid/radiuid.conf.backup`
3. Download the v2.1.0 code from the GitHub repo by using `git clone https://github.com/PackeTsar/radiuid.git`
    - If the "radiuid" folder already exists, you may want to use git to update the clone `cd radiuid/; git pull`
4. Move to the radiuid folder created by git using the `cd radiuid/` command
5. Perform a full install of RadiUID using the command `python radiuid.py install`
6. Follow the prompts and fill out the appropriate information using the information from the old configuration file
7. Once the installer exits, you should run `radiuid show config set` and see your configuration.
8. Perform a `radiuid service all restart` command to restart RadiUID to use the new app version



####   CONTRIBUTING   ####
--------------------------------------

If you would like to help out by contributing code or reporting issues, please do!

Visit the GitHub page (https://github.com/PackeTsar/radiuid) and either report an issue or fork the project, commit some changes, and submit a pull request.

[logo]: http://www.packetsar.com/wp-content/uploads/radiuid-logo-tiny-100.png
[all-args]: http://www.packetsar.com/wp-content/uploads/radiuid-all-args.png
[show-log]: http://www.packetsar.com/wp-content/uploads/radiuid-show-log.png
[show-config]: http://www.packetsar.com/wp-content/uploads/radiuid-show-config.png
[show-config-set]: http://www.packetsar.com/wp-content/uploads/radiuid-show-config-set.png
[push-and-show]: http://www.packetsar.com/wp-content/uploads/radiuid-push-and-show.png

[centos-post-install]: https://github.com/PackeTsar/scriptfury/blob/master/CentOS_Post_Install.md
[ubuntu-post-install]: https://github.com/PackeTsar/scriptfury/blob/master/Ubuntu_Post_Install.md