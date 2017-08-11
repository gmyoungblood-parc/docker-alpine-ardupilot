# ardupilot-sitl

From [gmyoungblood-parc's github repository](https://github.com/gmyoungblood-parc/docker-alpine-ardupilot). Feel free to fork and  

### Docker container << Alpine Linux  + ArduPilot SITL + Libs

Docker container setup for ArduPilot Software-In-The-Loop on Alpine Linux

This container establishes an environment for running ArduPilot, which includes a number of large packages such SciPy and OpenCV in a development supporting environment with gcc and python 2.7.

ArduPilot is set to run in ArduPlane using JSBsim for flight dynamics.

This container is currently 1.19 GB in size (stripped down from 1.95 GB) when built locally and squashed (e.g., `docker-alpine-ardupilot$ build --squash -t ardupilot-contained .`). It is listed on [Docker Hub](https://hub.docker.com/r/gmyoungbloodparc/ardupilot-sitl/) as `gmyoungblood/ardupilot-sitl` and weighs in, sadly due to caching, still at 1.95 GB. So, if you need a smaller version then build it locally. 

The details:  ArduPilot and JSBsim comprise ~360 MB, supporting (mostly python) /usr/lib libraries consume ~400 MB of which scipy, MAVproxy, and pymavlink take over half, and in /usr/libexec gcc and git (required) take up ~100 MB. 

### ArduPilot sim_vehicle.py

Use the environmental variable in setup, `SIM_OPTIONS` and the information below to configure the simulator.

    Usage: sim_vehicle.py

    Options:
      -h, --help            show this help message and exit
      -v VEHICLE, --vehicle=VEHICLE
                        vehicle type (ArduCopter|AntennaTracker|APMrover2|Ardu
                        Sub|ArduPlane)
      -f FRAME, --frame=FRAME
                        set vehicle frame type
                        ArduCopter: octa-quad|tri|singlecopter|firefly|gazebo-
                            iris|calibration|hexa|heli|+|heli-compound|dodeca-
                            hexa|heli-dual|coaxcopter|X|quad|y6|IrisRos|octa
                        AntennaTracker: tracker
                        APMrover2: rover|gazebo-rover|rover-skid|calibration
                        ArduSub: vectored
                        ArduPlane: gazebo-zephyr|CRRCSim|last_letter|plane-
                            vtail|plane|quadplane-tilttri|quadplane|quadplane-
                            tilttrivec|calibration|plane-elevon|plane-
                            tailsitter|plane-dspoilers|quadplane-tri
                            |quadplane-cl84|jsbsim
      -C, --sim_vehicle_sh_compatible
                        be compatible with the way sim_vehicle.sh works; make
                        this the first option
      -H, --hil             start HIL

      Build options:
    -N, --no-rebuild    don't rebuild before starting ardupilot
    -D, --debug         build with debugging
    -c, --clean         do a make clean before building
    -j JOBS, --jobs=JOBS
                        number of processors to use during build (default for
                        waf : number of processor, for make : 1)
    -b BUILD_TARGET, --build-target=BUILD_TARGET
                        override SITL build target
    -s BUILD_SYSTEM, --build-system=BUILD_SYSTEM
                        build system to use
    --rebuild-on-failure
                        if build fails, do not clean and rebuild
    --waf-configure-arg=WAF_CONFIGURE_ARGS
                        extra arguments to pass to waf in its configure step
    --waf-build-arg=WAF_BUILD_ARGS
                        extra arguments to pass to waf in its build step

     Simulation options:
    -I INSTANCE, --instance=INSTANCE
                        instance of simulator
    -V, --valgrind      enable valgrind for memory access checking (very
                        slow!)
    -T, --tracker       start an antenna tracker instance
    -A SITL_INSTANCE_ARGS, --sitl-instance-args=SITL_INSTANCE_ARGS
                        pass arguments to SITL instance
    -G, --gdb           use gdb for debugging ardupilot
    -g, --gdb-stopped   use gdb for debugging ardupilot (no auto-start)
    -d DELAY_START, --delay-start=DELAY_START
                        delays the start of mavproxy by the number of seconds
    -B BREAKPOINT, --breakpoint=BREAKPOINT
                        add a breakpoint at given location in debugger
    -M, --mavlink-gimbal
                        enable MAVLink gimbal
    -L LOCATION, --location=LOCATION
                        select start location from
                        Tools/autotest/locations.txt
    -l CUSTOM_LOCATION, --custom-location=CUSTOM_LOCATION
                        set custom start location
    -S SPEEDUP, --speedup=SPEEDUP
                        set simulation speedup (1 for wall clock time)
    -t TRACKER_LOCATION, --tracker-location=TRACKER_LOCATION
                        set antenna tracker start location
    -w, --wipe-eeprom   wipe EEPROM and reload parameters
    -m MAVPROXY_ARGS, --mavproxy-args=MAVPROXY_ARGS
                        additional arguments to pass to mavproxy.py
    --strace            strace the ArduPilot binary
    --model=MODEL       Override simulation model to use
    --use-dir=USE_DIR   Store SITL state and output in named directory
    --no-mavproxy       Don't launch MAVProxy

      Compatibility MAVProxy options (consider using --mavproxy-args instead):
    --out=OUT           create an additional mavlink output
    --map               load map module on startup
    --console           load console module on startup
    --aircraft=AIRCRAFT
                        store state and logs in named directory

    eeprom.bin in the starting directory contains the parameters for your simulated vehicle. Always start from the same directory. It is recommended that you start in the main vehicle directory for the vehicle you are simulating, for example, start in the ArduPlane directory to simulate ArduPlane



### Connecting a *localhost* Ground Control Station (GCS)

Set the container `SIM_OPTIONS` to stream towards your GCS using `--out=udpout:<GCS hostname or IP>:<port>` 

#### On MacOS 
The Mac has a changing IP address (or none if you have no network access). From Docker 17.06 onwards the recommendation is to connect to the special Mac-only DNS name *docker.for.mac.localhost*, which will resolve to the internal IP address used by the host.

For example: `--out=udpout:docker.for.mac.localhost:14553` on the container and set the GCS to connect to localhost on port 14553 for UDP. 

See [Networking features in Docker for Mac](https://docs.docker.com/docker-for-mac/networking/)

#### On Linux

See [Docker container networking](https://docs.docker.com/engine/userguide/networking/#embedded-dns-server)

#### On Windows
*** We do not test on Windows, so please provide feedback on suggestions for fixes for any issues ***

In Docker for Windows, the container communicates through a vEthernet adapter called DockerNAT. The host ports are available on the default gateway of the container network interface. Access the Docker Engine API on the host.

    C:\> ipconfig

    Windows IP Configuration

    Ethernet adapter vEthernet (Temp Nic Name):

       Connection-specific DNS Suffix  . :
       Link-local IPv6 Address . . . . . : fe80::99d:bf5e:8700:56df%26
       IPv4 Address. . . . . . . . . . . : 172.27.219.121
       Subnet Mask . . . . . . . . . . . : 255.255.240.0
       Default Gateway . . . . . . . . . : 172.27.208.1
    C:\> curl http://172.27.208.1:2375/info -UseBasicParsing
    StatusCode        : 200
    StatusDescription : OK
    ...

---
The ArduPilot-SITL Docker Container is maintained by G. Michael Youngblood at the Palo Alto Research Center (PARC, a Xerox company) in California. It is licensed under [GPLv3](https://www.gnu.org/licenses/gpl-3.0.en.html).


