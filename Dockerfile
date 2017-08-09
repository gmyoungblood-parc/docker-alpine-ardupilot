# Dockerfile for ardupilot on Alpine Linux
#
# Designed for Research development using
#              Gunicorn-Python-Django Server with SciPy and R support
#              Local Postgres Database (9.3)
#              iNotebook Server
#
# Copyright (C)2017 PARC, a Xerox company
# Licensed under GPL, Version 3
#
FROM alpine:latest
MAINTAINER Michael Youngblood <Michael.Youngblood@parc.com>
#
# 
#########################################################################################

#ENV DATABASE_URL postgres://postgres:postgres1234@127.0.0.1:5432/apm_missions
ENV PORT 8000
ENV INSTANCE mavsim

EXPOSE 10000-10001
EXPOSE 14550-14559

# Base Packages
RUN apk update && apk add bash \
	git \
	libtool \ 
	automake \
	autoconf \
	expat-dev \
	gcc \
	make \
	g++ \
	python \
	py-lxml \
	py-pip \
	ccache \
	gawk \
	freetype-dev \
	libpng-dev \
	python-dev \
	lapack-dev \
	gfortran

# PostgreSQL Database
#
#RUN apk add py2-psycopg2
#RUN pip install psycopg2

# Python Dependencies
#
RUN pip install pip matplotlib \
	pyserial \
	scipy \
	opencv \
	pexpect \
	future 

# Install ardupilot
RUN git clone git://github.com/ArduPilot/ardupilot.git
WORKDIR /ardupilot
RUN git submodule update --init --recursive; 

# Install JSBsim
RUN git clone git://github.com/tridge/jsbsim.git
WORKDIR /jsbsim
RUN git pull ; ./autogen.sh --enable-libraries ; make

# Alpine cleanup
RUN ln -s /usr/include/locale.h /usr/include/xlocale.h
RUN sed -i 's/, int,/, unsigned int,/' /usr/include/assert.h

# Complete ardupilot install
RUN pip install pymavlink \
	MAVProxy

# Setup environment
RUN echo 'export PATH=$PATH:/jsbsim/src' >> /etc/profile ; \
	echo 'export PATH=$PATH:/ardupilot/Tools/autotest' >> /etc/profile ; \
	echo 'export PATH=/usr/lib/ccache:$PATH' >> /etc/profile; \
	. /etc/profile

# Compile ardupilot
# -- Hacks because Alpine doesn't use glibc
RUN sed -i 's/feenableexcept(exceptions);/\/\/feenableexcept(exceptions);/' /ardupilot/libraries/AP_HAL_SITL/Scheduler.cpp
RUN sed -i 's/if (old >= 0 && feenableexcept(old) < 0)/if (0)/' /ardupilot/libraries/AP_Math/matrix_alg.cpp
# -- Ok, now we can compile
WORKDIR /ardupilot/ArduPlane
# RUN ln -s /ardupilot/modules/mavlink/message_definitions message_definitions
RUN sim_vehicle.py -w

# Cleanup
RUN apk cache clean ; sudo rm -rf /tmp/* ; apk cache -v sync

# fin.
