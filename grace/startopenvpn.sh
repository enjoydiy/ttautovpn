#!/bin/sh
#
# Author:zijiao E-mail:admin@enjoydiy.com aefskw@gmail.com
# Web: http://blog.enjoydiy.com http://bbs.enjoydiy.com
#
# USAGE: visit web.
#

#The VPN Server IP
vpnserv='10.8.0.1'

#The config path of openvpn
config='/jffs/openvpn/vpn1.ovpn'

#openvpn device
od='tun0'

#deal opensrv
opsrv=`nvram get openvpnsrv | grep "^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$"`
if [[ `echo $opsrv | wc -m` -gt 7 ]]
then
	echo "hello"
	echo $opsrv
	vpnserv=$opsrv
	echo $opsrv
fi
echo "end2"
#0 or more than 1 daemon deal
ISRUN=`ps | grep "openvpn --config" | grep -v "grep" | wc -l`
if [[ $ISRUN -ne 1 ]]
then
	killall openvpn
	while [ `ps | grep "openvpn --config" | grep -v "grep" | wc -l` -ne 0 ]
	do                                                              
        	echo "open is running,waiting for exiting..."
        	sleep 5                                      
		PING=`ping -q -c8 $vpnserv | grep received |awk '{print $4}'`
		if [ $PING -gt 0 ]; then
			exit;
		fi
	done   
	echo $(date)normal >> /jffs/openvpn/log
	echo "Not running, start!"
	openvpn --config $config --daemon
exit
fi

#openvpn daemon running error
echo "will ping test"
PING=`ping -q -c8 ${vpnserv} | grep received |awk '{print $4}'`
if [[ $PING -lt 1 ]]
then
	echo "PING TIMEOUT"
	killall openvpn
	while [ `ps | grep "openvpn --config" | grep -v "grep" | wc -l` -ne 0 ]
	do
		echo "open is running,waiting for exiting..."
		sleep 5
		PING=`ping -q -c8 $vpnserv | grep received |awk '{print $4}'`
		if [[ $PING -gt 0 ]]
		then
			exit;
		fi
	done
	echo "start openvpn..."
	echo $(date)timeout >> /jffs/openvpn/log
	openvpn --config $config --daemon
	echo "PING TIMEOUT, RESTARTED..."
else
	natnum=`iptables -t nat -vnL | grep tun | wc -l`
	if [[ $natnum -eq 0 ]]
	then
		`iptables -A POSTROUTING -t nat -o ${od} -j MASQUERADE`
		PING=`ping -q -c8 $vpnserv | grep received |awk '{print $4}'`
		if [[ $PING -gt 0 ]]
		then
			exit;
		fi
	fi
	echo "Openvp is already running ..."
fi
exit
