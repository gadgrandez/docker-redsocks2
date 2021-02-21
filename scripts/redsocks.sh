#!/bin/bash

if [ -z "$LISTEN_IP" ]
then
    LOCAL_IP=0.0.0.0
else
    LOCAL_IP="$LISTEN_IP"
fi

if [ -z "$LISTEN_PORT" ]
then
    LOCAL_PORT=9150
else
    LOCAL_PORT="$LISTEN_PORT"
fi

CONFIG_TEMPLATE=default.tmpl
if [ ! -z "$TYPE" ]
then
    case "$TYPE" in
        socks4)
            ;;
        socks5)
            CONFIG_TEMPLATE=socks5.tmpl
            ;;
        http-proxy)
            ;;
        direct)
            ;;
        https-connect)
            ;;
        *)
            CONFIG_TEMPLATE=default.tmpl
            ;;
    esac
fi

echo "Creating redsocks configuration file using proxy ${DEST_IP}:${DEST_PORT}..."
sed -e "s|\${proxy_ip}|${DEST_IP}|" \
    -e "s|\${proxy_port}|${DEST_PORT}|" \
    -e "s|\${local_ip}|${LOCAL_IP}|" \
    -e "s|\${local_port}|${LOCAL_PORT}|" \
    -e "s|\${local_port2}|$(($LOCAL_PORT + 1))|" \
    /etc/$CONFIG_TEMPLATE > /tmp/redsocks.conf

echo "Generated configuration:"
cat /tmp/redsocks.conf

echo "Activating iptables rules..."
/usr/local/bin/redsocks-fw.sh start

pid=0

# SIGUSR1 handler
usr_handler() {
  echo "usr_handler"
}

# SIGTERM-handler
term_handler() {
    if [ $pid -ne 0 ]; then
        echo "Term signal catched. Shutdown redsocks and disable iptables rules..."
        kill -SIGTERM "$pid"
        wait "$pid"
        /usr/local/bin/redsocks-fw.sh stop
    fi
    exit 143; # 128 + 15 -- SIGTERM
}

# setup handlers
trap 'kill ${!}; usr_handler' SIGUSR1
trap 'kill ${!}; term_handler' SIGTERM

echo "Starting redsocks..."
/usr/sbin/redsocks -c /tmp/redsocks.conf &
pid="$!"

# wait indefinetely
while true
do
    tail -f /dev/null & wait ${!}
done