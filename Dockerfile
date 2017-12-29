FROM haproxy:1.8-alpine

ENV SSL_CERTIFICATE /tls/self-signed.pem

RUN apk add --no-cache openssl curl inotify-tools

ADD build/docker-entrypoint.sh /
ADD build/watch-certificate.sh /

RUN chmod +x /docker-entrypoint.sh /watch-certificate.sh
