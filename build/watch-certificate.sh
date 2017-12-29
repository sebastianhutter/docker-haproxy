#!/bin/sh

#
# automatically reload haproxy process if the certificates change
# watch the whole tls folder for changes
#

CERTIFICATE="${1}"
CERTIFICATE_DIRECTORY=$(dirname "${CERTIFICATE}")

# if the directory containing the certifciate registers changes
while inotifywait "${CERTIFICATE_DIRECTORY}"; do
    # check if we have letsencrypt files around
    # if so re-recreate the certificate
    # and if not only reload the haproxy config
    if [ -f "${CERTIFICATE_DIRECTORY}/fullchain.pem" ] && [ -f "${CERTIFICATE_DIRECTORY}/privkey.pem" ]; then
      cat "${CERTIFICATE_DIRECTORY}/fullchain.pem"  "${CERTIFICATE_DIRECTORY}/privkey.pem"  > "${CERTIFICATE}" 
    fi

    kill -HUP $(cat /run/haproxy.pid)
done
