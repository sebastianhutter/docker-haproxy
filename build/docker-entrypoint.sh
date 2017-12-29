#!/bin/sh
set -e

# check if the specified ssl certificate exists.
# if not create a self signed cert
if [ ! -f "${SSL_CERTIFICATE}" ]; then
  # before creating the certificate make sure the subdirectory exists
  [ -d "$(dirname ${SSL_CERTIFICATE})" ] || mkdir -p $(dirname ${SSL_CERTIFICATE})

  openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /tmp/key -out /tmp/certificate -subj "/CN=self-sgined"
  cat /tmp/certificate /tmp/key > ${SSL_CERTIFICATE}
  rm /tmp/certificate /tmp/key
fi

# check if the download url is set. if so try to download the file via curl
CONFIG_LOCAL="/usr/local/etc/haproxy/haproxy.cfg"
if [ -z "$CONFIG_URL" ]; then
  echo "No config url set. Will use local configuration file"
else
  echo "Config url is set. Download the configuration file"
  # now try to download the configuration file
  if [ -z "$CONFIG_USERNAME" ] || [ -z "$CONFIG_PASSWORD" ]; then
    # if no usename and password is specified
    curl "$CONFIG_URL" -o "$CONFIG_LOCAL"
    [ $? -ne 0 ] && exit 1
  else
    curl --user $CONFIG_USERNAME:$CONFIG_PASSWORD "$CONFIG_URL" -o "$CONFIG_LOCAL"
    [ $? -ne 0 ] && exit 1
  fi
fi

# reload haproxy if certificate changes
/reload-haproxy.sh $(dirname ${SSL_CERTIFICATE}) >/dev/null 2>&1 &

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
        set -- haproxy "$@"
fi

if [ "$1" = 'haproxy' ]; then
        shift # "haproxy"
        # if the user wants "haproxy", let's add a couple useful flags
        #   -W  -- "master-worker mode" (similar to the old "haproxy-systemd-wrapper"; allows for reload via "SIGUSR2")
        #   -db -- disables background mode
        set -- haproxy -p /run/haproxy.pid -W -db "$@"
fi

exec "$@"