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
FORMAT_COMMAND="make_ext4fs"
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

umount() {
	if [[ $( cat /proc/mounts | grep -c $1) -gt 0 ]]; then
		/sbin/umount $1
		checkerror $? "Could not umount $1" $2
	else
		mecho "$1 is already umounted.."
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
    checkerror 1 "Would you like to use f2fs or ext4?"
    checkerror 1 "[volume up: f2fs | volume down: ext4]?"
    mecho ""
    if [[ "$(/tmp/install/bin/volumeinput)" == "up" ]]; then
 	FORMAT_COMMAND="mkfs.f2fs"
    fi
    mecho "Stopping volisnotd"
    killall volisnotd
    checkerror $? "volisnotd was not running???"
    mecho "Unmounting /emmc"
    umount /emmc
    mecho "Unmounting /data"
    umount /data 
    mecho "Formatting /data using $FORMAT_COMMAND ..."
    $FORMAT_COMMAND $DATABLOCK
    checkerror $? "Could not format userdata!.You will need to reboot to recovery. Then format data." -fatal
    mecho "Format of /data complete."
    mecho ""
    sleep 2
fi
