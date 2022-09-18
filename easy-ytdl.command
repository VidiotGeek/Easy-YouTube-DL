#!/usr/bin/env bash

###################################################################################
#                                Easy-YouTube-DL                                  #
#                                                                                 #
#    The goals of this Easy-YouTube-DL script are:                                #
#                                                                                 #
#    1)  To have a thinly veiled excuse to learn and practice as many             #
#        bash scripting concepts as I can force into what started as              #
#        a six line script that probably should have stayed that way.             #
#                                                                                 #
#    2)  Maybe actually assist users who are CLI-phobic, primarily on             #
#        macOS, to download, install, and use youtube-dl with as                  #
#        little, or as simple, command line interaction as possible.              #
#                                                                                 #
#    3)  Finally publish some original code in open source for public             #
#        benefit, constructive critique, or vehement ridicule.                    #
#                                                                                 #
#    CHANGE HISTORY:                                                              #
#    2022-09-16 Broke down steps into functions. Completed install routines.      #
#               Added sha256 check to curl & wget install methods.                #
#               Linked the option to immediately run the YTDL assistant           #
#               upon successful install of youtube-dl.                            #
#    2022-09-10 Massive mission scope bloat. Added GPLv3 License.                 #
#    2022-09-06 Original release.                                                 #
#                                                                                 #
###################################################################################
###################################################################################
#                                                                                 #
#    Copyright (C) 2022, Matt Bailey                                              #
#    matt@mattbailey.tech                                                         #
#                                                                                 #
#    This program is free software; you can redistribute it and/or modify         #
#    it under the terms of the GNU General Public License as published by         #
#    the Free Software Foundation; either version 3 of the License, or            #
#    (at your option) any later version.                                          #
#                                                                                 #
#    This program is distributed in the hope that it will be useful,              #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of               #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                 #
#    GNU General Public License for more details.                                 #
#                                                                                 #
#    You should have received a copy of the GNU General Public License            #
#    along with this program. If not, see <https://www.gnu.org/licenses/>.        #
#                                                                                 #
###################################################################################
###################################################################################

# Define some ANSI color code variables.
NOCOLOR=$'\e[0m'
WHITE=$'\e1;37m'
GRAY=$'\e[0;37m'
RED=$'\e[0;31m'
YELLOW=$'\e[0;33m'
BLUE=$'\e[1;34m'
GREEN=$'\e[0;32m'
GREENITALIC=$'\e[3;32m'
CYAN=$'\e[0;36m'
PURPLE=$'\e[0;35m'
YINVERT=$'\e[43;30m'

# Define URL variables for tricky printf formatting.
YTCOM='youtube.com'
YTBE='youtu.be'

# Define the assitant function first. If youtube-dl is installed, this will be the only thing that runs.
function run_easy_ytdl () {
	# Make a save folder on the desktop, because your download folder is probably also cluttered.
	SAVE_DIR=$HOME/Desktop/YTDL-Downloads
	if [ ! -d $SAVE_DIR ]; then
		mkdir $SAVE_DIR && cd $SAVE_DIR
	else
		cd $SAVE_DIR
	fi
	clear
	printf '%-6s\n' "${GREENITALIC}============================= Easy YouTube-DL =================================${NOCOLOR}"
	printf '%s\n' "Please paste the YouTube URL you would like to download at the prompt below."
	printf '%s\n' "The link must be to \"$RED$YTCOM$NOCOLOR\", and not \"$RED$YTBE$NOCOLOR\" in order to work."
	printf '%s\n\n' "Your file will be saved to $BLUE$SAVE_DIR$NOCOLOR."
	printf '%s' "${YELLOW}URL:${NOCOLOR} "
	read link_to_download
	printf '\n%-6s\n' "${GREENITALIC}===============================================================================${NOCOLOR}"
	youtube-dl "$link_to_download" && printf '\n\n%s\n\n' "${PURPLE}You may now close this window.${NOCOLOR}" && open $SAVE_DIR && exit 0
}

# After installation, ask user if they want to download a video now.
function ask_download_video () {
	printf '%s\n' "Would you like to download a video now? (yes/no) "
	read now_or_later
	case $now_or_later in
		y|Y|yes|Yes|YES) run_easy_ytdl
			;;
		*) printf '%s\n\n' "The next time you run this script, we will jump straight to the download prompt. Goodbye!"
			exit 0
			;;
	esac
}

# Upon successful curl or wget installation, run a checksum to confirm good file download.
# Checksums for homebrew and pip installed executables are not published, that I could find.
function run_checksum () {
	printf '\n%s\n\n' "To verify install, compare this ${GREEN}SHA256 hash${NOCOLOR} to the published one at ${BLUE}https://ytdl-org.github.io/youtube-dl/download.html${NOCOLOR}" &&
	shasum -a 256 /usr/local/bin/youtube-dl &&
	printf '\n%s\n' "If the checksums do not match, the download may be incomplete, corrupt, or modified. Choosing ${RED}\"NO\"${NOCOLOR} will remove the copy of youtube-dl that we just installed."
	function confirm_checksum () {
		printf '%s' "Do they match? (yes/no/skip): " && read matched
		case $matched in
			y|Y|yes|Yes|YES) printf '\n%s\n' "${GREEN}Congratulations! youtube-dl is now installed.${NOCOLOR}"
				ask_download_video
				;;
			n|N|no|No|NO) printf '\n%s\n' "$(RED)Removing youtube-dl executable\!${NOCOLOR}" && rm -vi /usr/local/bin/youtube-dl && exit 0
				;;
			s|S|skip|Skip|SKIP) printf '\n%s\n' "${YELLOW}Skipping verification.${NOCOLOR} youtube-dl is now installed."
				ask_download_video
				;;
			*) printf '%s\n' "Look again, if the first and last few characters match, then we are good to go."
				printf '%s\n' "Otherwise if you'd like to skip this step, type \"${YELLOW}skip.${NOCOLOR}\""
				confirm_checksum
				;;
		esac
	}
	confirm_checksum
}

# Possible download methods per https://yt-dl.org.
function install_ytdl_brew () {
	# Easiest alternative install method is Homebrew, which we've confirmed is present.
	# Although, if the user has Homebrew, they're savvy enough not to need this script...
	brew install youtube-dl &&
	printf '\n%s\n' "${GREEN}Congratulations! youtube-dl is now installed.${NOCOLOR}"
	ask_download_video
}

function install_ytdl_curl () {
	# First recommended install method is curl, which we've confirmed is present.
	sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl &&
	run_checksum
}

function install_ytdl_wget () {
	# We didn't have curl, proceding with wget as second recommended install method.
	sudo wget https://yt-dl.org/downloads/latest/youtube-dl -O /usr/local/bin/youtube-dl &&
	run_checksum
}

function install_ytdl_pip () {
	# We did not have curl or wget, proceeding with pip as third recommended install method.
	sudo pip install --upgrade youtube-dl &&
	printf '\n%s\n' "${GREEN}Congratulations! youtube-dl is now installed.${NOCOLOR}"
	ask_download_video
}

# How should we install youtube-dl?
function test_install_methods () {
if ! command -v brew &> /dev/null; then
	# We don't have Homebrew as the easiest install option.
	if ! command -v curl &> /dev/null ; then
		# We can't use curl to install.
		if ! command -v wget &> /dev/null ; then
			# We also can't use wget to install.
			if ! command -v pip &> /dev/null ; then
				printf '%s\n' "Sorry, we seem to have none of four possible install methods."
				printf '%s\n' "Please see additional info at ${GREEN}https://yt-dl.org/${NOCOLOR}"
				exit 1
			else
				install_ytdl_pip
			fi
		else
			install_ytdl_wget
		fi
	else
		install_ytdl_curl
	fi
else
	install_ytdl_brew
fi
}

# Do we need to install Python?
function test_python () {
	if ! command -v python &> /dev/null ;  then
		# We also don't have python. Prompt for Python install.
		printf '%s\n' "Sorry, Python 2.6 or later is a requirement for youtube-dl and this system doesn't have it"
		printf '%s' "Do you want to manually install it from www.python.org and try this script again? (yes/no): "
		read get_python
		case $get_python in
			y|Y|yes|Yes|YES) open "https://www.python.org/downloads/" && exit 0
				;;
			*) exit 1
				;;
		esac
	else
		# We've confirmed Python is present. Can we write to the default install location?
		if -w /usr/local/bin ; then
			printf '%s' "Sorry, youtube-dl could not be found. Would you like to download and install it? (yes/no): "
			read get_youtube_dl
			case "$get_youtube_dl" in
				y|Y|yes|Yes|YES) printf '%s\n\n' "Proceeding..."
					test_install_methods
					;;
				*) exit 0
					;;
			esac
		else
			printf '%s\n' "Sorry, the user $USER is not able to write to the install location at /usr/local/bin."
			printf '%s\n' "Login as an administrator and try again." && exit 1
		fi
	fi
}

# Do we need to install youtube-dl?
function test_youtube_dl () {
	if ! command -v youtube-dl &> /dev/null ; then
		# We don't have it. Do we have Python as a requirement?
		test_python
	else
		run_easy_ytdl
	fi
}

test_youtube_dl
