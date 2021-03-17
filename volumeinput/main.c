/*
 * Copyright (C) 2021 The LineageOS Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <linux/input.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>

#define VOLUMEINPUTPATH "/dev/input/event0"

int main(int argc, char *argv[]) {
    int fd = -1,retval = -2;
    struct input_event ev;
    int size = sizeof(struct input_event);
    fd = open(VOLUMEINPUTPATH, O_RDONLY);
    if (fd) {
restart:
	read(fd, &ev, size);
	if(ev.type ==  1) {
	    switch (ev.code) {
		case 114:
		    printf("down\n");
		    retval = -1;
		    break;
		case 115:
		    printf("up\n");
		    retval = 0;
		    break;
		default:
		    goto restart;
	    }
	}
	close(fd);
    } else {
		printf("Could not open %s\n", VOLUMEINPUTPATH);
    }
    return retval;
}


