FROM azukiapp/alpine
MAINTAINER Azuki <support@azukiapp.com>

COPY test/fixtures/azk /usr/bin/azk

RUN apk --update add ncurses \
 && rm -rf /var/cache/apk/* \