FROM ubuntu as builder

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
	python-minimal
 
RUN useradd --system --user-group tss

# Install simulator
ARG ibmtpm_name=ibmtpm1332
ADD "https://downloads.sourceforge.net/project/ibmswtpm2/$ibmtpm_name.tar.gz" .
RUN sha1sum $ibmtpm_name.tar.gz | grep ^8fe74d8a155fba38e50d029251cd4eaf0c6e199d && \
  mkdir -p $ibmtpm_name && \
  tar xvf $ibmtpm_name.tar.gz -C $ibmtpm_name && \
  cd $ibmtpm_name/src && \
  make -j$(nproc) && \
  cp tpm_server /usr/local/bin

# install TSS itself
RUN git clone https://github.com/tpm2-software/tpm2-tss.git /tmp/tpm2-tss && \
	cd /tmp/tpm2-tss && \
  ./bootstrap && \
	./configure --enable-unit && \
	make check && \
	make install && \
	ldconfig

# Install abrmd itself
ENV LD_LIBRARY_PATH /usr/lib
RUN git clone https://github.com/tpm2-software/tpm2-abrmd.git /tmp/tpm2-abrmd && \
  cd /tmp/tpm2-abrmd && \
  ./bootstrap && \
  ./configure --enable-unit --with-dbuspolicydir=/etc/dbus-1/system.d && \
  dbus-launch make check && \
  make install && \
	ldconfig

# Install tools itself
RUN git clone https://github.com/tpm2-software/tpm2-tools.git /tmp/tpm2-tools && \
	cd /tmp/tpm2-tools && \
	./bootstrap && \
	./configure && \
	make check && \
	make install

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod 755 /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
