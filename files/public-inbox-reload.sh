#!/bin/sh
# Tell public-inbox services to re-read the config file by sending HUPs to their main PIDs
PI_SVCS="public-inbox-httpd public-inbox-nntpd public-inbox-imapd public-inbox-watch"
for PI_SVC in $PI_SVCS; do
    /bin/pkill -HUP -P1 -f $PI_SVC
done
exit 0
