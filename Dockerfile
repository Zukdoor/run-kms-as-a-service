FROM ubuntu:16.04
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
  build-essential gdb pkg-config cmake \
  clang debhelper valgrind \
  git wget maven 'openjdk-[8|7]-jdk'


RUN apt-get install -y pkg-config debhelper
RUN REPO="xenial-dev"
RUN echo "deb http://ubuntu.kurento.org xenial-dev kms6\n" > /etc/apt/sources.list.d/kurento.list
#RUN tee /etc/apt/sources.list.d/kurento.list > /dev/null <<EOF
# deb http://ubuntu.kurento.org $REPO kms6 
# EOF
RUN wget http://ubuntu.kurento.org/kurento.gpg.key -O - | apt-key add -
RUN apt-get update 

RUN apt-get install -y --no-install-recommends \
  libboost-dev \
  libboost-filesystem-dev \
  libboost-log-dev \
  libboost-program-options-dev \
  libboost-regex-dev \
  libboost-system-dev \
  libboost-test-dev \
  libboost-thread-dev \
  libevent-dev \
  libglib2.0-dev \
  libglibmm-2.4-dev \
  libopencv-dev \
  libsigc++-2.0-dev \
  libsoup2.4-dev \
  libssl-dev \
  libvpx-dev \
  libxml2-utils \
  uuid-dev

RUN apt-get install -y --no-install-recommends \
  gstreamer1.5-libav \
  gstreamer1.5-nice \
  gstreamer1.5-plugins-bad \
  gstreamer1.5-plugins-base \
  gstreamer1.5-plugins-good \
  gstreamer1.5-plugins-ugly \
  gstreamer1.5-x \
  libgstreamer1.5-dev \
  libgstreamer-plugins-base1.5-dev \
  libnice-dev \
  openh264-gst-plugins-bad-1.5 \
  openwebrtc-gst-plugins-dev \
  kmsjsoncpp-dev \
  ffmpeg

RUN git clone https://github.com/Kurento/kms-omni-build.git \
  && cd kms-omni-build \
  && git submodule init \
  && git submodule update --recursive --remote

RUN mkdir /kms-omni-build/build-Debug
RUN cd /kms-omni-build/build-Debug \
&& cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_VERBOSE_MAKEFILE=ON .. \
&& make && make install

RUN cd /
RUN wget http://nginx.org/download/nginx-1.13.6.tar.gz
RUN tar -zxvf nginx-1.13.6.tar.gz
RUN cd /nginx-1.13.6 && ./configure --prefix=/usr/local/nginx 
RUN cd /nginx-1.13.6 \
&& make && make install
#
RUN cd /
RUN wget http://www.ffmpeg.org/releases/ffmpeg-3.1.tar.gz
RUN tar -zxvf ffmpeg-3.1.tar.gz
RUN cd /ffmpeg-3.1 && ./configure --prefix=/usr/local/ffmpeg --disable-yasm
RUN cd /ffmpeg-3.1 \
&& make && make install

RUN apt-get install -y build-essential \
  libtool \
  libpcre3 \
  libpcre3-dev \
  zlib1g-dev \
  openssl 

RUN rm ffmpeg-3.1.tar.gz \
  && rm nginx-1.13.6.tar.gz

EXPOSE 8888

ENV GST_DEBUG=3,Kurento*:4,kms*:4,rtpendpoint:4,webrtcendpoint:4

# 容器启动时执行指令
CMD ["/kms-omni-build/build-Debug/kurento-media-server/server/kurento-media-server"," --modules-path=/kms-omni-build/build-Debug --modules-config-path=/etc/kurento/modules/kurento --conf-file=/etc/kurento/kurento.conf.json --gst-plugin-path=/kms-omni-build/build-Debug","daemon off"]
