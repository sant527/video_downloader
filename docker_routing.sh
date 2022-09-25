# Routing packets from a specific Docker container through a specific outgoing interface
# https://stewartadam.io/blog/2019/04/04/routing-packets-specific-docker-container-through-specific-outgoing-interface


# Here 192.168.55.1 is a variable
# Here wlx00e020306060 is a variable

# create a new Docker-managed, bridged connection
# 'avpn' because docker chooses the default route alphabetically

DOCKER_SUBNET="172.57.0.0/16"
docker network create --subnet=$DOCKER_SUBNET -d bridge -o com.docker.network.bridge.name=docker_vpn avpn


# mark packets from the docker_vpn interface during prerouting, to destine them for non-default routing decisions
# 0x25 is arbitrary, any hex (int mask) should work

sudo iptables -t mangle -I PREROUTING -i docker_vpn ! -d $DOCKER_SUBNET -j MARK --set-mark 0x25

# create new routing table - 100 is arbitrary, any integer 1-252
# create new routing table - 100 is arbitrary, any integer 1-252
echo "100 vpn"|sudo tee -a /etc/iproute2/rt_tables

#$ cat /etc/iproute2/rt_tables
##
## reserved values
##
#255	local
#254	main
#253	default
#0	unspec
##
## local
##
##1	inr.ruhep
#100 vpn
#~# ip route show table {table name}

# The /etc/iproute2/rt_tables file basically allows you to give meaningful names to the route tables. 
# You can reference all the possible tables using just a number, 
# but it is easier to remember and use them if you have a good name. There are a few predefined main=254.

# By default the table you will normally look at and manipulate is the 'main' table. 
# So if you run ip route, or ip route show you will get the 'main' table by default. 
# You can do ip route show table main or ip route show table 254 to show the main table. 
# If you don't specify a table when adding or changing routes, this is the one that will be used.


sudo ip route add default via 192.168.55.1 dev wlx00e020306060 table vpn


# configure rules for when to route packets using the new table

sudo ip rule add from all fwmark 0x25 lookup vpn


# setup a different default route on the new routing table
# this route can differ from the normal routing table's default route

sudo ip route add default via 192.168.55.1 dev wlx00e020306060 table vpn

docker run --rm --network avpn byrnedo/alpine-curl http://www.myip.ch
