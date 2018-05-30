FROM centos:latest
MAINTAINER John W Kerns "jkerns@packetsar.com"

### Download and install RadiUID from latest release ###
RUN curl -sL https://codeload.github.com/PackeTsar/radiuid/tar.gz/2.4.3 | tar xz
RUN cd radiuid-2.4.3;python radiuid.py request reinstall replace-config no-confirm
RUN cd radiuid-2.4.3;python radiuid.py request freeradius-install no-confirm

### Expose ports and provide run commands ###
EXPOSE 1813/udp
EXPOSE 1813/tcp
CMD radiusd & radiuid run >> /etc/radiuid/STDOUT & /bin/bash
