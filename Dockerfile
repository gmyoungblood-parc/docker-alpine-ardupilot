# Dockerfile for ardupilot on Alpine Linux
#
# Designed for Research & Development on the ardupilot SITL simulation
#
# Copyright (C)2017 PARC, a Xerox company
# Licensed under GPL, Version 3
#
FROM alpine:3.6
MAINTAINER Michael Youngblood <Michael.Youngblood@parc.com>
#
# 
#########################################################################################

ENV INSTANCE mavsim

EXPOSE 10000-10001
EXPOSE 14550-14559

# Base Packages
RUN apk update && apk add --no-cache\
	git \
	libtool \ 
	automake \
	autoconf \
	expat-dev \
	gcc \
	make \
	cmake \
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
	gfortran \
	ca-certificates \
	openssl \
	linux-headers

# Python Dependencies
#
RUN pip install pip matplotlib \
	pyserial \
	scipy \
	pexpect \
	future 

# adsb needs deeper OpenCV build
#
WORKDIR "/tmp"
RUN update-ca-certificates && \
	cd /tmp && \
	wget -O opencv-2.4.13.4.tar.gz https://github.com/opencv/opencv/archive/2.4.13.4.tar.gz && \
	tar -xzf opencv-2.4.13.4.tar.gz &&\
	cd /tmp/opencv-2.4.13.4 && \
	mkdir build && \
	cd build && \
	cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D WITH_FFMPEG=NO -D WITH_IPP=NO -D WITH_OPENEXR=NO .. && \
	make VERBOSE=1 && \
	make && \
	make install 
WORKDIR "/"

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
RUN echo 'export PATH=$PATH:/jsbsim/src' >> /etc/profile && \
	echo 'export PATH=$PATH:/ardupilot/Tools/autotest' >> /etc/profile && \
	echo 'export PATH=/usr/lib/ccache:$PATH' >> /etc/profile && \
	echo 'export PYTHONPATH=/usr/local/lib/python2.7/site-packages:$PYTHONPATH' >> /etc/profile

# Compile ardupilot
WORKDIR "/ardupilot/ArduPlane"
# -- Hacks because Alpine doesn't use glibc, so we are going to adjust some code
RUN sed -i 's/feenableexcept(exceptions);/\/\/feenableexcept(exceptions);/' /ardupilot/libraries/AP_HAL_SITL/Scheduler.cpp  && \
	sed -i 's/int old = fedisableexcept(FE_OVERFLOW);/int old = 1;/' /ardupilot/libraries/AP_Math/matrix_alg.cpp && \
	sed -i 's/if (old >= 0 && feenableexcept(old) < 0)/if (0)/' /ardupilot/libraries/AP_Math/matrix_alg.cpp && \
	sed -i "s/#include <sys\/types.h>/#include <sys\/types.h>\n\n#define TCGETS2 _IOR('T', 0x2A, struct termios2)\n#define TCSETS2 _IOW('T', 0x2B, struct termios2)/" /ardupilot/libraries/AP_HAL_SITL/UART_utils.cpp
RUN . /etc/profile && sim_vehicle.py -w

# Cleanup unnecessary packages after build
RUN apk del \
	build-base \
	cmake \
	automake \
	autoconf \
	ccache \
	openssl \
	ca-certificates \
	gawk && \
	rm -rf /var/cache/apk/* && \
	rm -rf /tmp/opencv* && \
	rm -rf /root/.ccache && \
	rm -rf /root/.config && \
	rm -rf /root/.ash_history && \
	rm -rf /root/.tilecache && \
	rm -rf /jsbsim/.git && \
	rm -rf /ardupilot/.git/objects/pack 
	
# Execution Setup for sim_vehicle autorun
ENV ENV="/etc/profile"
ENV SIM_OPTIONS "--out=udpout:docker.for.mac.localhost:14559"
ENV SPEEDUP 1
WORKDIR "/ardupilot/ArduPlane"
ENTRYPOINT . /etc/profile && sim_vehicle.py --speedup=$SPEEDUP $SIM_OPTIONS

# fin.
