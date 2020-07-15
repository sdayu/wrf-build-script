FROM debian:buster
RUN echo 'deb http://mirror.psu.ac.th/debian/ buster main contrib non-free' > /etc/apt/sources.list && \
	echo 'deb http://mirror.kku.ac.th/debian/ buster main contrib non-free' > /etc/apt/sources.list && \
	echo 'deb http://ftp.debianclub.org/debian/ buster main contrib non-free' > /etc/apt/sources.list && \
	echo 'deb http://ftp.debianclub.org/debian-security/ buster/updates main contrib' >> /etc/apt/sources.list


RUN apt update && apt upgrade -y && apt install -y \
	build-essential cmake byacc git csh wget sudo \
	netcdf-bin libnetcdf-mpi-dev libnetcdf-pnetcdf-dev libnetcdff-dev libpnetcdf-dev \
	libhdf5-openmpi-dev libfl-dev libpng-dev ncl-ncarg 


RUN wget http://www.ece.uvic.ca/~frodo/jasper/software/jasper-2.0.14.tar.gz --directory-prefix=/tmp/ && \
	tar zxvf /tmp/jasper-2.0.14.tar.gz --directory=/tmp/ && \
	mkdir -p /tmp/jasper-2.0.14/build-dir && \
	cd /tmp/jasper-2.0.14/build-dir && \
	cmake .. && \
	make && \
	make install 


ARG USER="user"
ARG UID=1000
ARG GID=1000
ENV HOME_DIR="/home/${USER}"
ENV WORK_DIR="${HOME_DIR}/projects" \
	PATH="${HOME_DIR}/.local/bin:${PATH}"

RUN /usr/sbin/useradd --create-home --shell /bin/bash -m ${USER} --uid=${UID}
RUN /usr/sbin/usermod -append --groups sudo ${USER}
RUN echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib:/usr/local/lib" >> "${HOME_DIR}/.bashrc"


USER ${UID}:${GID}
WORKDIR ${WORK_DIR}

