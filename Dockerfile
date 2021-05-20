# syntax=docker/dockerfile:1

FROM alpine
#ARG VCS_REF

RUN apk add --no-cache libtool bzip2-dev libpcap-dev \
    zlib-dev rrdtool-dev curl-dev && \
    apk add --no-cache --virtual build-deps \
    git autoconf automake m4 pkgconfig make g++ flex byacc

#RUN git clone https://github.com/phaag/nfdump.git && \
#    cd nfdump && \
RUN    ./autogen.sh && \
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

# docker build --build-arg
#LABEL org.label-schema.schema-version="1.0" \
#      org.label-schema.vcs-ref=$VCS_REF \
#      org.label-schema.vcs-url="https://github.com/phaag/nfdump.git""