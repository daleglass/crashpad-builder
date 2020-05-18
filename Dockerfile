FROM ubuntu:bionic
MAINTAINER Dale Glass <daleglass@gmail.com>

RUN apt-get update
RUN apt-get -y -u dist-upgrade
RUN apt-get -y install build-essential git zlib1g-dev python curl wget clang

ENTRYPOINT /bin/bash
