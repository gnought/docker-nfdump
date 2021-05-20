# syntax=docker/dockerfile:1

FROM alpine
ARG GIT
ARG HASH

RUN apk add --no-cache libtool bzip2-dev libpcap-dev \
    zlib-dev rrdtool-dev curl-dev && \
    apk add --no-cache --virtual build-deps \
    git autoconf automake m4 pkgconfig make g++ flex byacc

RUN git clone $GIT && \
    cd nfdump && \
    git checkout $HASH && \
    ./autogen.sh && \
    ./configure \
      --enable-shared \
      --enable-nsel \
      --disable-jnat \
      --disable-nfprofile \
      --enable-influxdb \
      --disable-nftrack \
      --enable-sflow \
      --enable-readpcap \
      --enable-nfpcapd && \
    make -j"$(nproc)" && \
    make install-strip && \
    rm -rf nfdump && \
    apk del build-deps

CMD ["nfcapd"
]