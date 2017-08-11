# ardupilot-sitl
### Docker container << Alpine Linux  + ArduPilot SITL

Docker container setup for ArduPilot Software-In-The-Loop on Alpine Linux

This container establishes an environment for running ArduPilot, which includes a number of large packages such SciPy and OpenCV in a development supporting environment

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
The ArduPilot-SITL Docker Container is maintained by G. Michael Youngblood at tge Palo Alto Research Center (PARC, a Xerox company) in California. It is licensed under [GPLv3](https://www.gnu.org/licenses/gpl-3.0.en.html).


