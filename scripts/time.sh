#!/usr/bin/bash

time=`/usr/bin/date | /usr/bin/awk '{print $4}'`
/usr/bin/notify-send $time
