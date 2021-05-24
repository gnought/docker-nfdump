# syntax=docker/dockerfile:1

FROM alpine
ARG GIT
ARG HASH

WORKDIR /

RUN apk add --no-cache lddtree libtool bzip2-dev libpcap-dev \
    zlib-dev rrdtool-dev curl-dev && \
    apk add --no-cache --virtual build-deps \
    git autoconf automake m4 pkgconfig make g++ flex byacc

RUN git clone $GIT && \
    cd nfdump && \
    git checkout ${HASH:-HEAD} && \
    ./autogen.sh && \
    ./configure \
      --prefix=/usr \
      --disable-shared \
      --enable-nsel \
      --disable-jnat \
      --disable-nfprofile \
      --enable-influxdb \
      --disable-nftrack \
      --enable-sflow \
      --enable-readpcap \
      --enable-nfpcapd && \
    make -j"$(nproc)" && \
    cd bin && make nfreader && cd .. && \
    DESTDIR=/tmp make install-strip && \
    cp bin/nfreader /tmp/usr/bin/ && \
    cd .. && \
    rm -rf nfdump && \
    apk del build-deps

RUN mkdir -p /nfdump && \
    mkdir -p /nfdump/usr/bin && \
    find /tmp/usr/bin -type f -exec sh -c ' \
      cp $1 /nfdump/usr/bin/$(basename $1); \
      lddtree -l $1 | grep -v $1 | xargs -I % sh -c '"'mkdir -p \$(dirname /nfdump%); cp % /nfdump%;'"' \
    ' sh {} \;

FROM scratch
WORKDIR /
ENV PATH=/usr/bin
COPY --from=0 nfdump /
CMD ["nfcapd", "-V"]
