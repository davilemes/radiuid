FROM centos:latest

### Install and configure SSH Server for SSH access to container ###
RUN set -x && \
	yum update && \
	yum -y --nodocs install \
		openssh \
		openssh-server \
		openssh-clients \
		sudo \
		passwd \
		httpd \
		net-tools && \
	yum clean all

RUN sshd-keygen && \
    sed -i "s/UsePAM.*/UsePAM yes/g" /etc/ssh/sshd_config && \
    sed -i "s/#UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && \
    useradd admin -G wheel -s /bin/bash -m && \
    echo 'root:radiuid' | chpasswd && \
    echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers && \

### Download and install RadiUID from latest release ###
ADD ./radiuid-2.4.3 /radiuid-2.4.3

RUN cd radiuid-2.4.3 && \
    python radiuid.py request reinstall replace-config no-confirm && \
    python radiuid.py request freeradius-install no-confirm

### Expose ports and provide run commands ###
EXPOSE 1813/udp
EXPOSE 1813/tcp
EXPOSE 22/tcp

CMD /usr/sbin/sshd
#CMD radiusd & radiuid run >> /etc/radiuid/STDOUT & /usr/sbin/sshd >> /etc/radiuid/SSH-STDOUT & /bin/bash
