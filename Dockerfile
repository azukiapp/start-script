FROM azukiapp/alpine
MAINTAINER Azuki <support@azukiapp.com>

COPY test/fixtures/azk /usr/bin/azk

RUN echo "@testing http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
  && apk -U add ncurses shadow@testing \
  && addgroup docker \
  && usermod -aG docker root \
  && rm -rf /var/cache/apk/* \
