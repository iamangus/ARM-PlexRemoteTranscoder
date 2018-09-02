FROM lsiobase/ubuntu.armhf:xenial

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="sparklballs"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV HOME="/config"

RUN \
 echo "**** install packages ****" && \
 buildDeps=" \
		curl \
		unzip" && \
 apt-get update && \
 apt-get install -y \
 	${buildDeps} \
	ca-certificates \
	inotify-tools \
	jq \
	nfs-kernel-server \
	openssh-client \
	openssh-server \
	python-psutil \
	python-setuptools \
	apt-transport-https \
	avahi-daemon \
	dbus \
	udev \
	unrar \
	wget && \
 echo "**** add dev2day repo ****" && \
 wget -O - https://dev2day.de/pms/dev2day-pms.gpg.key | apt-key add - && \
 echo "deb https://dev2day.de/pms/ jessie main" >> /etc/apt/sources.list.d/plex.list && \
 echo "**** install plexmediaserver ****" && \
 apt-get update && \
 apt-get install -y \
	plexmediaserver-installer && \
 echo "**** cleanup ****" && \
 apt-get clean && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/* && \
 curl -o /tmp/prt-wnielson.zip -L "https://github.com/wnielson/Plex-Remote-Transcoder/archive/master.zip" && \
	curl -o /tmp/prt-JJK801.zip -L "https://github.com/JJK801/Plex-Remote-Transcoder/archive/master.zip" && \
	mkdir -p /app && \
	unzip /tmp/prt-wnielson.zip -d /app/prt-wnielson && \
	unzip /tmp/prt-JJK801.zip -d /app/prt-JJK801 && \
	
# Plex-Remote-Transcoder configuration
	ln -s /config/Library /var/lib/plexmediaserver/Library && \
	
# NFS Server configuration
	echo "nfs             2049/tcp" >> /etc/services && \
	
# SSHD configuration
	mkdir /var/run/sshd && \
	sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
	sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
	printf "StrictHostKeyChecking no\n" >> /etc/ssh/ssh_config && \

# User configuration
	sed -i -e 's;/config:/bin/false;/config:/bin/bash;g' /etc/passwd && \
	
# Cleaning
	apt-get -y --purge autoremove ${buildDeps} && \
	rm -rf \
		/tmp/* \
		/var/lib/apt/lists/* \
		/var/tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 32400 32400/udp 32469 32469/udp 5353/udp 1900/udp 22 2049/tcp
VOLUME /config /transcode
