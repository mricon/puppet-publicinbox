#!/bin/sh
# Reload public-inbox services if they are running
PI_UNITS="public-inbox-httpd@1 public-inbox-nntpd@1 public-inbox-watch"
for PI_UNIT in $PI_UNITS; do
    /bin/systemctl -q is-active $PI_UNIT && /bin/systemctl reload $PI_UNIT
done
exit 0
