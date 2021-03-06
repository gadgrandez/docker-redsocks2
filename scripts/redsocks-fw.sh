#!/bin/sh

##########################
# Setup the Firewall rules
##########################
fw_setup() {
  # First we added a new chain called 'REDSOCKS' to the 'nat' table.
  iptables -t nat -N REDSOCKS

  # Next we used "-j RETURN" rules for the networks we don’t want to use a proxy.
  while read item; do
      iptables -t nat -A REDSOCKS -d $item -j RETURN
  done < /etc/redsocks-whitelist.txt

  if [ ! -z "$TYPE" ]
  then
      case "$TYPE" in
          socks4)
              ;;
          socks5)
              iptables -t nat -A REDSOCKS -p tcp -j REDIRECT --to-ports ${LOCAL_PORT}
              ;;
          http-proxy)
              ;;
          direct)
              ;;
          https-connect)
              ;;
          *)
              # We then told iptables to redirect all port 80 connections to the http-relay redsocks port and all other connections to the http-connect redsocks port.
              iptables -t nat -A REDSOCKS -p tcp --dport 80 -j REDIRECT --to-ports ${LOCAL_PORT}
              iptables -t nat -A REDSOCKS -p tcp -j REDIRECT --to-ports $(($LOCAL_PORT + 1))
              ;;
      esac
  else
    # We then told iptables to redirect all port 80 connections to the http-relay redsocks port and all other connections to the http-connect redsocks port.
    iptables -t nat -A REDSOCKS -p tcp --dport 80 -j REDIRECT --to-ports ${LOCAL_PORT}
    iptables -t nat -A REDSOCKS -p tcp -j REDIRECT --to-ports $(($LOCAL_PORT + 1))
  fi

  # Finally we tell iptables to use the ‘REDSOCKS’ chain for all outgoing connection in the network interface ‘$NET_INTERFACE′.
  if [ -z "$NET_INTERFACE" ]
  then
    iptables -t nat -A PREROUTING -p tcp -j REDSOCKS
  else
    iptables -t nat -A PREROUTING -i $NET_INTERFACE -p tcp -j REDSOCKS
  fi
}

##########################
# Clear the Firewall rules
##########################
fw_clear() {
  iptables-save | grep -v REDSOCKS | iptables-restore
  #iptables -L -t nat --line-numbers
  #iptables -t nat -D PREROUTING 2
}

case "$1" in
    start)
        echo -n "Setting REDSOCKS firewall rules..."
        fw_clear
        fw_setup
        echo "done."
        ;;
    stop)
        echo -n "Cleaning REDSOCKS firewall rules..."
        fw_clear
        echo "done."
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac
exit 0