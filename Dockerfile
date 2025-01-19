FROM ubuntu:noble
MAINTAINER Dale Glass <daleglass@gmail.com>

RUN apt-get update
RUN apt-get -y -u dist-upgrade
RUN apt-get -y install build-essential git zlib1g-dev python3 curl wget clang libcurl4-openssl-dev libssl-dev

ENTRYPOINT /bin/bash
