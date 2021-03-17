#!/sbin/sh
#
# Copyright (C) 2021 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

DATABLOCK="/dev/block/platform/hi_mci.0/by-name/userdata"
UPDATERFD_PATH=""

get_updater_info() {

    UPDATERPID=""
    UPDATERFD=""
    UPDATERPROC=""

    for line in "$(ps | grep updater)"
    do
	    if [[ "$(echo $line | cut -d ' ' -f5)" == "/tmp/updater" ]]; then
	    	UPDATERPID="$(echo $line | cut -d ' ' -f1)"
		UPDATERFD="$(echo $line | cut -d ' ' -f7)"
	    	break
	    fi
    done

    UPDATERFD_PATH="/proc/$UPDATERPID/fd/$UPDATERFD"
}

mecho(){
    echo -n -e "ui_print      $1\n" > "$UPDATERFD_PATH"
    echo -n -e "ui_print\n" > "$UPDATERFD_PATH"
}

checkerror() {
    if [[ $1 -gt 0 ]]; then
	if [[ "$3" == "-fatal" ]]; then
		mecho "ERROR: $2"
		exit $1
	else
		mecho "WARNING: $2"	
	fi
    fi
}


clearscreen() {
    I=0
    while true
    do
	mecho ""
 	if [[ $I -eq 19 ]]; then break; fi
	I=$(expr $I + 1)
    done
}

if [[ "$(getprop sys.stock)" == "1" ]]; then
    get_updater_info
    clearscreen
    printheader 
    checkerror 1 "The current ROM is a stock EMUI ROM."
    checkerror 1 "Internal storage MUST be formatted!"
    checkerror 1 "You have an opportunity to stop -"
    checkerror 1  "and back up your data now."
    mecho ""
    checkerror 1 "Do you wish to continue?"
    checkerror 1 "[volume up: yes | volume down: no]?"
    mecho ""
    if [[ "$(/tmp/install/bin/volumeinput)" == "down" ]]; then
    	checkerror 1 "Installation cancelled."
        checkerror 1 "Nothing has been modified."
	checkerror 1 " " -fatal
    fi
fi
