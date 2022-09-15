#!/usr/bin/env bash
###################################################################################
#                                Easy-YouTube-DL                                  #
#                                                                                 #
#    The goals of this Easy-YouTube-DL script are:                                #
#                                                                                 #
#     1)  To have a thinly veiled excuse to learn and practice as many            #
#          bash scripting concepts as I can force into what started as            #
#          a six line script that probably should have stayed that way.           #
#                                                                                 #
#      2)  Maybe actually assist users who are CLI-phobic, primarily on           #
#         macOS, to download, install, and use youtube-dl with as                 #
#          little, or as simple, command line interaction as possible.            #
#                                                                                 #
#      3)  Finally publish some original code in open source for public           #
#          benefit, constructive critique, or vehement ridicule.                  #
#                                                                                 #
#    Change History                                                               #
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

# Clear the screen and print system info just for funsies. Will probably delete later.
clear
printf '\n\e[3;35m%-6s\a\e[m\n' "=============================== SYSTEM INFO ==================================" ;
printf "System Version:\t\t $(uname -srm) \n"
printf "Current Date/Time:\t $(date) \n"
printf "Current Directory:\t $(pwd) \n"
printf '\n\e[3;35m%-6s\a\e[m\n' "==============================================================================" ;
echo

#The farther I went down the path of writing everything in line, it seems like
#it might be easier and fewer lines of code to run all my tests ahead of time, save the
#results into variables, then also break each step out into a function... TBD


# Test if youtube-dl is in $PATH
if ! command -v youtube-dl &> /dev/null ; then
  # We don't have it. Do we have Python as a requirement?
  if ! command -v python &> /dev/null ;  then
    # We also don't have python. Prompt for install.
    echo "Sorry, Python 2.6 or later is a requirement for youtube-dl and this system doesn't have it"
    read -p "Do you want to install it from www.python.org and try again? (yes/no): " "get_python"
    case $get_python in
      y|Y|yes|Yes|YES) open "https://www.python.org/downloads/"
        ;;
      *) exit
        ;;
    esac
  else
    echo "youtube-dl could not be found. Installation requires admin privileges."
    read -p "Would you like to download and install it? (yes/no): " "get_youtube_dl"
    if ! command -v curl &> /dev/null ; then
        # We can't use curl to install.
        if ! command -v wget &> /dev/null ; then
          # We also can't use wget to install.
            if ! command -v pip &> /dev/null ; then
            # We don't even have pip which should have come with Python when installed?
            # Abandon all hope.
                exit 0
            else
              case "$get_youtube_dl" in
                y|Y|yes|Yes|YES) echo "Proceeding..."
                  sudo pip install --upgrade youtube_dl
                  ;;
                *) exit 0
                  ;;
              esac
            fi
        else
          case "$get_youtube_dl" in
            y|Y|yes|Yes|YES) echo "Proceeding..."
              if -w /usr/local/bin ; then
                sudo wget https://yt-dl.org/downloads/latest/youtube-dl -O /usr/local/bin/youtube-dl
              else
                echo "We cannot write to /usr/local/bin"
                exit 0
              fi
              ;;
            *) exit 0
              ;;
          esac
        fi
      else
    case "$get_youtube_dl" in
      y|Y|yes|Yes|YES) echo "Proceeding..."
        if -w /usr/local/bin ; then
          sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
        else
          echo "We cannot write to /usr/local/bin"
          exit 0
        fi
        ;;
      *) exit 0
        ;;
    esac
  fi
fi

cd ~/Desktop
# Save file to the desktop, because your download folder is probably also cluttered.
printf '\n\e[3;35m%-6s\a\e[m\n' "============================= Easy YouTube-DL =================================" ;
echo "Please paste the YouTube URL you would like to download below."
echo "Must be "youtube.com", not "youtu.be". The file will be saved to ~/Desktop"
echo
read -p "URL: " "link_to_download"
echo
printf '\n\e[3;35m%-6s\a\e[m\n' "===============================================================================" ;
echo
youtube-dl "$link_to_download"
