FROM azukiapp/alpine
MAINTAINER Azuki <support@azukiapp.com>

COPY test/fixtures/azk /usr/bin/azk

RUN addgroup docker \
 && apk --update add ncurses shadow@testing \
 && rm -rf /var/cache/apk/* \