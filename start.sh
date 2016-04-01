#!/bin/sh

atput() {
  [ -z "$TERM" ] && return 0
  eval "tput $@"
}

format() {
  echo "$@" | sed "
    s/%{bold}/$(atput bold)/g;
    s/%{underline}/$(atput smul)/g;
    s/%{green}/$(atput setaf 2)/g;
    s/%{yellow}/$(atput setaf 3)/g;
    s/%{red}/$(atput setaf 1)/g;
    s/%{blue}/$(atput setaf 4)/g;
    s/%{reset}/$(atput sgr0)/g;
    s/%{[a-z]*}//g;
  "
}

command_exists() {
  which ${@} > /dev/null 2>&1
}

match() {
  if [ $# != 2 ]; then return 1; fi
  echo "${1}" | grep -qE "${2}"
}

curl_or_wget() {
  CURL_BIN="curl"; WGET_BIN="wget"
  if command_exists ${CURL_BIN}; then
    echo "${CURL_BIN} -sL"
  elif command_exists ${WGET_BIN}; then
    echo "${WGET_BIN} -qO-"
  fi
}

install_or_update_azk() {
  echo
  ${FETCH_CMD} http://www.azk.io/install.sh | bash
}

stop_azk_installation() {
  cat <<-EOS

    $(format '%{bold}azk%{reset}') installation aborted.
    To install azk, just run:
      $(format "%{bold}\$ ${FETCH_CMD} http://www.azk.io/install.sh | bash%{reset}")

EOS
  exit 4
}

check_azk_installed() {
  if ! command_exists $AZK_BIN; then
    cat <<-EOS

$(format '%{bold}%{green}Hi!%{reset}') The $( format '%{bold}Run Project button%{reset}') is a feature of $(format '%{bold}azk%{reset}').
    $(format '%{bold}azk%{reset}') is an open-source engine to orchestrate development environments.

    It seems you don't have $(format "%{bold}$AZK_BIN%{reset}") installed on your machine yet.

EOS
    FETCH_CMD=$(curl_or_wget)
    if [ -z "${FETCH_CMD}" ]; then
      cat <<-EOS
    To install $(format "%{bold}$AZK_BIN%{reset}"), please check out our docs at:
      $(format '%{bold}%{underline}http://docs.azk.io/en/installation%{reset}')

EOS
      exit 1
    else
      trap stop_azk_installation INT
      cat <<-EOS
    Installing $(format '%{bold}azk%{reset}') in $(format '%{bold}10 seconds%{reset}').
    To prevent its installation, just press CTRL+C now.
EOS
      sleep 10
      trap - INT
      install_or_update_azk
    fi
  fi
}

azk_is_up_to_date() {
  AZK_CURRENT_VERSION=$(azk version | sed -e 's/^azk //; s/^version //; s/,.*//')
  AZK_TAGS_URL="https://api.github.com/repos/azukiapp/azk/tags"
  AZK_LATEST_VERSION=$( curl -sSL ${AZK_TAGS_URL} | \
                        grep name | \
                        head -1 | \
                        sed 's/[^0-9.]*"v\([0-9.]*\).*",/\1/' )
  [ "${AZK_CURRENT_VERSION}" = "${AZK_LATEST_VERSION}" ]
}

skip_azk_update() {
  cat <<-EOS

    To upgrade $(format '%{bold}azk%{reset}'), just run:
      $(format "%{bold}\$ ${FETCH_CMD} http://www.azk.io/install.sh | bash%{reset}")

EOS
  SKIP_UPDATE='true'
  kill -13 ${SLEEP_PID} > /dev/null 2>&1
}

check_azk_updated() {
  if ! azk_is_up_to_date; then
    FETCH_CMD=$(curl_or_wget)
    if [ ! -z "${FETCH_CMD}" ]; then
      trap skip_azk_update INT
      cat <<-EOS

    $(format "%{bold}azk v${AZK_LATEST_VERSION}%{reset}") is available!
    Updating $(format "%{bold}azk%{reset}") in $(format '%{bold}10 seconds%{reset}').

    To prevent it, just press CTRL+C now.
EOS
      sleep 10 &
      SLEEP_PID=$!
      wait > /dev/null 2>&1
      trap - INT
      if [ -z ${SKIP_UPDATE} ]; then
        install_or_update_azk
      fi
    fi
  fi
}

check_repo_project() {
  HTTPS_REGEX="^https://github.com/[^/]+/[^/]+$"
  SSH_REGEX="^git@github.com:[^/]+/[^/]+.git$"
  SHORT_REGEX="^[^/]+/[^/]+$"

  if ! match ${REPO_PROJECT} "${SHORT_REGEX}|${HTTPS_REGEX}|${SSH_REGEX}"; then
    cat <<-EOS
$(format "%{bold}%{yellow}Ops!%{reset}") It seems you haven't copied the whole command.
     Please ensure it's complete and try again.
EOS
    exit 2
  fi
}

AZK_BIN="azk"
REPO_PROJECT="${1}"; shift

check_repo_project

if check_azk_installed && check_azk_updated; then
  if match "$(uname -a)" "^Linux\ " && \
     ! match "$(id -Gn)" "(^|\ )docker(\ |$)" && \
     getent group docker > /dev/null 2>&1; then
    sg docker -c "azk agent start && echo && azk start -o ${REPO_PROJECT} ${@}"
  else
    azk agent start && echo && azk start -o ${REPO_PROJECT} ${@}
  fi
else
  exit 3
fi
