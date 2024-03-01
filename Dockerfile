FROM ubuntu as builder

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /tpm2

RUN apt-get update
RUN	apt-get install -y git \
	openssl \
	autoconf \
	autoconf-archive \
	automake \
	build-essential \
	strongswan-pki \
	g++ \
	gcc \
	git \
	libssl-dev \
	libtool \
	m4 \
	net-tools \
	pkg-config \
	lcov \
	pandoc \
	autoconf-archive \
	liburiparser-dev \
	libdbus-1-dev \
	libglib2.0-dev \
	dbus-x11 \
	libcmocka0 \
	libcmocka-dev \
	libgcrypt20-dev \
	libtool \
	liburiparser-dev \
	uthash-dev \
	libcurl4-gnutls-dev \
	doxygen \
	python2-minimal \
	libjson-c-dev
 
RUN useradd --system --user-group tss

# Install simulator
ARG ibmtpm=ibmtpm1682
ARG ibmtpm_hash=651800d0b87cfad55b004fbdace4e41dce800a61
ADD "https://downloads.sourceforge.net/project/ibmswtpm2/${ibmtpm}.tar.gz" .
RUN sha1sum ${ibmtpm}.tar.gz | grep ^${ibmtpm_hash} && \
  mkdir -p ${ibmtpm} && \
  tar xvf ${ibmtpm}.tar.gz -C ${ibmtpm} && \
  cd ${ibmtpm}/src && \
  make -j$(nproc) && \
  cp tpm_server /usr/local/bin

# install TSS itself
RUN git clone https://github.com/lparth/tpm2-tss.git /tmp/tpm2-tss && \
	cd /tmp/tpm2-tss && \
  ./bootstrap && \
	./configure --enable-unit && \
	make -j$(nproc) check && \
	make install && \
	ldconfig

# Install abrmd itself
ENV LD_LIBRARY_PATH /usr/lib
RUN git clone https://github.com/lparth/tpm2-abrmd.git /tmp/tpm2-abrmd && \
  cd /tmp/tpm2-abrmd && \
  ./bootstrap && \
  ./configure --enable-unit --with-dbuspolicydir=/etc/dbus-1/system.d && \
  dbus-launch make -j$(nproc) check && \
  make install && \
	ldconfig

# Install tools itself
RUN git clone https://github.com/lparth/tpm2-tools.git /tmp/tpm2-tools && \
	cd /tmp/tpm2-tools && \
	./bootstrap && \
	./configure && \
	make -j$(nproc) check && \
	make install

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod 755 /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
