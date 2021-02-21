FROM ubuntu:latest as build

WORKDIR /build
RUN apt update && apt install -y build-essential libssl-dev git libevent-dev

RUN git clone https://github.com/akamensky/redsocks2.git
RUN cd redsocks2/ && git apply patches/disable-ss.patch && make

FROM ubuntu:latest

ENV NET_INTERFACE=docker0
ENV TYPE=socks5
ENV DEST_IP=127.0.0.1
ENV DEST_PORT=9050

RUN apt update && apt install -y libevent-dev iptables
COPY --from=build /build/redsocks2/redsocks2 /usr/local/bin/redsocks2

#Copy configuration files
COPY config/* /etc/redsocks-conf/
COPY whitelist.txt /etc/redsocks-whitelist.txt
COPY scripts/redsocks.sh /usr/local/bin/redsocks.sh
COPY scripts/redsocks-fw.sh /usr/local/bin/redsocks-fw.sh

RUN chmod +x /usr/local/bin/*

ENTRYPOINT ["/usr/local/bin/redsocks.sh"]