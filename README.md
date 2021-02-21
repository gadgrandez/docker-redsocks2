First release

Based on [ncarlier/redsocks](https://hub.docker.com/r/ncarlier/redsocks)

## Environment variables

| Variable | Description | Default value |
|----------|-------------|---------|
|NET_INTERFACE| The interface for redirect to redsocks |docker0|
|TYPE| Type of redsocks listen can be: **socks4**, **socks5**, **http-proxy** (this configure redsocks for use http-relay and http-connect), **direct**, **https-connect** |socks5|
|LISTEN_IP| The ip for bind redsocks |0.0.0.0|
|LISTEN_PORT| The listen port for redsocks |9150|
|DEST_IP| Target ip for redirect traffic |127.0.0.1|
|DEST_PORT| Target port for redirect traffic |9050|
-----------

## Usage example
<code>
docker run \ 
 
 --privileged=true \
 --net=host \
 -e NET_INTERFACE=eth1 \
 -e TYPE=socks5 \
 -e LISTEN_IP=10.0.9.1 \
 -e LISTEN_PORT=9150 \
 -e DEST_IP=172.16.0.1 \
 -e DEST_PORT=1080 \
 -d gadgrandez/redsocks
</code>