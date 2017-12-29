#!/bin/sh

#
# automatically reload haproxy process if the certificates change
# watch the whole tls folder for changes
#

while inotifywait ${1}; do
    kill -HUP $(cat /run/haproxy.pid)
done
