FROM alpine:3.10 as builder

WORKDIR /build

RUN apk update \
	&& apk add git \
		build-base \
		libtool \
		binutils \
		grep \
		findutils \
		coreutils \
		bash \
		cmocka-dev \
		procps-dev \
		procps \
		iproute2 \
		pkgconf \
		automake \
		openssl-dev \
		uthash-dev \
		autoconf \
		doxygen \
		libltdl \
		linux-headers \
		curl-dev \
		autoconf-archive \
    openssl \
    glib-dev \
    dbus-x11 \
	&& rm -rf /var/cache/apk/*
 
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
ADD "https://github.com/tpm2-software/tpm2-tss/archive/2.3.1.tar.gz" /tmp
RUN cd /tmp && tar xvf 2.3.1.tar.gz && \
  cd /tmp/tpm2-tss-2.3.1 && \
  ./bootstrap && \
  ./configure --prefix=/usr && \
  make -j$(nproc) && \
  make install

# Install abrmd itself
RUN ldconfig /usr/lib /usr/glibc/usr/lib
ENV LD_LIBRARY_PATH /usr/lib
ADD "https://github.com/tpm2-software/tpm2-abrmd/archive/2.2.0.tar.gz" /tmp
RUN cd /tmp && tar xvf 2.2.0.tar.gz && \
  cd /tmp/tpm2-abrmd-2.2.0 && \
  ./bootstrap && \
  ./configure && \
  dbus-launch make check && \
  make -j$(nproc) && \
  make install

RUN ldconfig /usr/lib /usr/glibc/usr/lib

# Install tools itself
ADD "https://github.com/tpm2-software/tpm2-tools/archive/4.0.tar.gz" /tmp
RUN cd /tmp && tar xvf 4.0.tar.gz && \
  cd /tmp/tpm2-tools-4.0 && \
  ./bootstrap && \
  ./configure --prefix=/usr && \
  make -j$(nproc) && \
  make install

# RUN tpm_server &
# RUN tpm2-abrmd --allow-root --tcti=mssim
