FROM centos:latest

### Install and configure SSH Server for SSH access to container ###
RUN yum update -y && \
    yum clean all

RUN yum install -y \
		openssh \
		openssh-server \
		openssh-clients \
		sudo \
		passwd \
		httpd \
		bash \
		net-tools && \
   yum clean all

RUN mkdir /var/run/sshd

RUN sshd-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''

RUN sed -i "s/UsePAM.*/UsePAM yes/g" /etc/ssh/sshd_config && \
    sed -i "s/#UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && \
    useradd admin -G wheel -s /bin/bash -m && \
    echo 'root:radiuid' | chpasswd && \
    echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers && \

### Download and install RadiUID from latest release ###
RUN mkdir -p /radiuid-2.4.3
COPY /radiuid-2.4.3/radiuid.conf /radiuid-2.4.3/
COPY /radiuid-2.4.3/radiuid.py /radiuid-2.4.3/

RUN cd radiuid-2.4.3 && \
    python radiuid.py request reinstall replace-config no-confirm && \
    python radiuid.py request freeradius-install no-confirm

### Expose ports and provide run commands ###
EXPOSE 1813/udp
EXPOSE 1813/tcp
EXPOSE 22/tcp

ENTRYPOINT ["/usr/sbin/sshd", "-D"]
#CMD radiusd & radiuid run >> /etc/radiuid/STDOUT & /usr/sbin/sshd >> /etc/radiuid/SSH-STDOUT & /bin/bash
