# Dockerfile for ardupilot on Alpine Linux
#
# Designed for Research & Development on the ardupilot SITL simulation
#
# Copyright (C)2017 PARC, a Xerox company
# Licensed under GPL, Version 3
#
FROM alpine:latest
MAINTAINER Michael Youngblood <Michael.Youngblood@parc.com>
#
# 
#########################################################################################

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
WORKDIR "/ardupilot"
RUN git submodule update --init --recursive; 
WORKDIR "/"

# Install JSBsim
RUN git clone git://github.com/tridge/jsbsim.git
WORKDIR "/jsbsim" 
RUN ./autogen.sh --enable-libraries && make

# Alpine cleanup
RUN ln -s /usr/include/locale.h /usr/include/xlocale.h
# -- Hack because the function prototype doesn't match expected
RUN sed -i 's/, int,/, unsigned int,/' /usr/include/assert.h

# Complete ardupilot install
RUN pip install pymavlink \
	MAVProxy

# Setup environment
RUN echo 'export PATH=$PATH:/jsbsim/src' >> /etc/profile ; \
	echo 'export PATH=$PATH:/ardupilot/Tools/autotest' >> /etc/profile ; \
	echo 'export PATH=/usr/lib/ccache:$PATH' >> /etc/profile
RUN . /etc/profile

# Compile ardupilot
WORKDIR "/ardupilot/ArduPlane"
# -- Hacks because Alpine doesn't use glibc, so we are going to adjust some code
RUN sed -i 's/feenableexcept(exceptions);/\/\/feenableexcept(exceptions);/' /ardupilot/libraries/AP_HAL_SITL/Scheduler.cpp  && \
	sed -i 's/int old = fedisableexcept(FE_OVERFLOW);/int old = 1;/' /ardupilot/libraries/AP_Math/matrix_alg.cpp && \
	sed -i 's/if (old >= 0 && feenableexcept(old) < 0)/if (0)/' /ardupilot/libraries/AP_Math/matrix_alg.cpp 
# -- Ok, let's compile
RUN . /etc/profile && sim_vehicle.py -w

# Cleanup
RUN rm -rf /tmp/*

# Setup shell so that it does load profile info
ENV ENV="/etc/profile"

# Execution Setup for sim_vehicle autorun
ENV SIM_OPTIONS "--out=udpout:127.0.0.1:14559"
ENV SPEEDUP 1
WORKDIR "/ardupilot/ArduPlane"
ENTRYPOINT . /etc/profile && sim_vehicle.py --speedup=$SPEEDUP $SIM_OPTIONS

# fin.
