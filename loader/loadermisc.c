/*
 * loadermisc.c - miscellaneous loader functions that don't seem to fit
 * anywhere else (yet)  (was misc.c)
 * JKFIXME: need to break out into reasonable files based on function
 *
 * Copyright (C) 1999-2011  Red Hat, Inc.  All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Author(s): Erik Troan <ewt@redhat.com>
 *            Matt Wilson <msw@redhat.com>
 *            Michael Fulbright <msf@redhat.com>
 *            Jeremy Katz <katzj@redhat.com>
 *            David Cantrell <dcantrell@redhat.com>
 */

#include <ctype.h>
#include <errno.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>
#include <stdarg.h>
#include <stdlib.h>
#include <glib.h>
#include <stdio.h>
#include <time.h>
#include "log.h"
#include "windows.h"
#include "loadermisc.h"

int copyFileFd(int infd, char * dest, progressCB pbcb,
               struct progressCBdata *data, long long total) {
    int outfd;
    char buf[4096];
    int i;
    int rc = 0;
    long long count = 0;

    outfd = open(dest, O_CREAT | O_RDWR, 0666);

    if (outfd < 0) {
        logMessage(ERROR, "failed to open %s: %m", dest);
        return 1;
    }

    while ((i = read(infd, buf, sizeof(buf))) > 0) {
        if (write(outfd, buf, i) != i) {
            rc = 1;
            break;
        }

        count += i;

        if (pbcb && data && total) {
            pbcb(data, count, total);
        }
    }

    close(outfd);

    return rc;
}

int copyFile(char * source, char * dest) {
    int infd = -1;
    int rc;

    infd = open(source, O_RDONLY);

    if (infd < 0) {
        logMessage(ERROR, "failed to open %s: %m", source);
        return 1;
    }

    rc = copyFileFd(infd, dest, NULL, NULL, 0);

    close(infd);

    return rc;
}

int simpleStringCmp(const void * a, const void * b) {
    const char * first = *((const char **) a);
    const char * second = *((const char **) b);

    return strverscmp(first, second);
}

int replaceChars(char *str, char old, char new) {
    char *pos = str;
    int count = 0;
    while (*pos != '\0') {
        if (*pos == old) {
            *pos = new;
            count++;
        }
        pos++;
    }
    return count;
}

char *replace_str(int *dst_len, char *src, char *dst, char *old_str, char *new_str)
{
    char old_len = strlen(old_str);
    char *src_ptr = src, *dst_ptr = dst;
    //char new_str_buf[1024] = {0};
    char *new_ptr = new_str;
    char *ptr = NULL;
    int new_len = 0;
    //memset(new_str_buf,0,1024);
    // strcpy(new_str_buf, new_str);
    if (strlen(old_str) == 0){
        return src;
    }
    if (strcmp(old_str, new_str) == 0){
        return src;
    }
    while((ptr = strstr(src_ptr, old_str)) != NULL){
      new_ptr = new_str;    
      while (*src_ptr && src_ptr != ptr){
        *dst_ptr  = *src_ptr;
	dst_ptr++;
	src_ptr++;
	new_len++;
      }
    
      while (*new_ptr){
        *dst_ptr = *new_ptr;
	dst_ptr++;
	new_ptr++;
	new_len++;
      }
      src_ptr += old_len;
    }
    while (*src_ptr){
        *dst_ptr = *src_ptr;
	dst_ptr++;
	src_ptr++;
        new_len++;
    }
    *dst_ptr = '\0';
    logMessage(INFO, "replace %s with  %s,length=%d: %m", old_str, new_str, new_len);
    *dst_len = new_len;
    return dst;
}
//Author : heiden deng (dengjq@sugon.com)
int convert_file(char *old_name, char *new_name,  char *old_str, char *new_str)
{
    int infd = -1;
    int outfd;
    char buf[4096];
    char buf_new[4096];
    int line_len = 0;
    int i;
    int rc = 0;
    long long count = 0;
    char *buf_new_ptr = NULL;

    infd = open(old_name, O_RDONLY);

    if (infd < 0) {
        printf("failed to open %s", old_name);
        return 1;
    }
    outfd = open(new_name, O_CREAT | O_RDWR, 0666);

    if (outfd < 0) {
        printf("failed to open %s", new_name);
        return 1;
    }
    memset(buf, 0, sizeof(buf));
    while ((i = read(infd, buf, sizeof(buf))) > 0) {
	memset(buf_new, 0, 4096);
        buf_new_ptr = replace_str(&line_len, buf, buf_new, old_str, new_str);
	if (write(outfd, buf_new_ptr, line_len) != line_len) {
            logMessage(ERROR, "write data to %s,length=%d,ori length=%d: %m", new_name,  line_len, i);
	    rc = 1;
            break;
        }
        count += line_len;
    }
    close(outfd);
    close(infd);
    //flush(outfd);
    return rc;   
}

int replace_in_file(char *filename, char *old_str, char *new_str)
{
    char tmp_filename[1024] = {0};
    srand((int)time(0));
    snprintf(tmp_filename,sizeof(tmp_filename),"%s_%d", filename,  rand()%100);
    copyFile(filename, tmp_filename);
    //unlink(filename);
    return convert_file(tmp_filename, filename, old_str, new_str);
}
