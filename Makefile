ROOT_PATH:=$(shell pwd)
LIB_PATH:=${ROOT_PATH}/lib

all: dependencies test

test:
	@azk shell test -c './lib/bats/install.sh /usr/local && bats test/suite.bats'

dependencies: ${LIB_PATH}/bats

BATS_VERSION=master
${LIB_PATH}/bats:
	@git clone -b ${BATS_VERSION} https://github.com/sstephenson/bats ${LIB_PATH}/bats

.PHONY: test
