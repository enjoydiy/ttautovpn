#!/bin/sh
#The OPenVpn config file
CONF_PATH='/jffs/openvpn/vpn1.ovpn'
ISRUN=`ps | grep "openvpn --config" | grep -v "grep" | wc -l`
echo $ISRUN
if [[ $ISRUN -ne 1 ]]
then
killall openvpn
while [ `ps | grep "openvpn --config" | grep -v "grep" | wc -l` -ne 0 ]
do                                                              
        echo "open is running,waiting for exiting..."
        sleep 5                                      
done   
echo $(date)normal >> /jffs/openvpn/log
echo "Not running, start!"
openvpn --config $CONF_PATH --daemon
exit
fi
echo "will ping test"
PING=`ping -q -c8 8.8.8.8 | grep received |awk '{print $4}'`
if [[ $PING -lt 1 ]]
then
echo "PING TIMEOUT, RESTART..."
killall openvpn
while [ `ps | grep "openvpn --config" | grep -v "grep" | wc -l` -ne 0 ]
do
	echo "open is running,waiting for exiting..."
	sleep 5
done
echo "start openvpn..."
echo $(date)timeout >> /jffs/openvpn/log
openvpn --config $CONF_PATH --daemon
echo "PING TIMEOUT, RESTART..."
else
echo "Openvp is already running ..."
exit
fi
