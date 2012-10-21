#!/bin/sh
#
# Author:zijiao E-mail:admin@enjoydiy.com aefskw@gmail.com
#
# Web: http://blog.enjoydiy.com http://bbs.enjoydiy.com
#
# USAGE: visit web.
#
echo "##################################################"
echo "#        Thanks for using VPN from EnjoyDiy      #"
echo "#              welecom to visit our websit       #"
echo "#                       http://bbs.enjoydiy.com  #"
echo "#         Email: admin@enjoydiy.com              #"
echo "##################################################"
OPENVPNDEV='tun0'
VPNGW=$(ifconfig $OPENVPNDEV | grep -Eo "P-t-P:([0-9.]+)" | cut -d: -f2)
OLDGW=$(nvram get wan_gateway)
function set_pass()
{
	if [[ -n "$2" ]] && [[ -n "$3" ]]; then
		a=$2;
		b=$3;
		echo "account:${a}   password:${b}"
		echo $a > /jffs/openvpn/passwd.txt
		echo $b >> /jffs/openvpn/passwd.txt
		echo "OK!"
		exit
	else
		read -p "Please your Openvpn account: " a
		read -p "Please your Openvpn password: " b
		echo "account:${a}   password:${b}"
		echo $a > /jffs/openvpn/passwd.txt
		echo $b >> /jffs/openvpn/passwd.txt
		echo "OK!"
		main
	fi
}
function t_vpn()
{
	if [ -n "$2" ]; then
		ip=$2
		echo "route add -host $ip gw \$VPNGW" >> /jffs/openvpn/vpnup_custom
		route add -host $ip gw $VPNGW		
		exit
	fi
	read -p "Please type in the ip address:" ip
	echo "The ip:$ip"
	read -p "The ip is right? y or n:" y
	if [ "$y" -eq "y" ];then
		echo "route add -host $ip gw \$VPNGW" >> /jffs/openvpn/vpnup_custom
		route add -host $ip gw $VPNGW		
		echo "OK!"
		sleep 1
		main
	else
		t_vpn
	fi
}
function t_net()
{	
	if [ -n "$2" ]; then
		ip=$2
		echo "route add -host $ip gw \$OLDGW" >> /jffs/openvpn/vpnup_custom
		route add -host $ip gw $OLDGW		
		exit
	fi
	read -p "Please type in the ip address:" ip
	echo "The ip:$ip"
	read -p "The ip is right? y or n:" y
	if [ "$y" -eq "y" ];then
		echo "route add -host $ip gw \$OLDGW" >> /jffs/openvpn/vpnup_custom
		route add -host $ip gw $OLDGW		
		echo "OK!"
		sleep 1
		main
	else
		t_net
	fi
}
function clean_route()
{
	cat /jffs/openvpn/vpnup_custom.bak > /jffs/openvpn/vpnup_custom
	echo "OK!"
	sleep 1
	if [ $1 ]; then
		echo $1
		exit 1
	else
		main
	fi
}
function update_route()
{
	PING=PING=`ping -q -c4 github.com | grep received |awk '{print $4}'`
	if [[ $PING -lt 1 ]]
	then
		echo "bad network! update fail!"
		main
	else
		#wget http://raw.github.com/enjoydiy/ttautovpn/master/up.sh -O /jffs/up.sh
		#wget http://raw.github.com/enjoydiy/ttautovpn/master/down.sh -O /jffs/down.sh
		wget https://raw.github.com/enjoydiy/ttautovpn/master/grace/routeg/route -O /jffs/openvpn/routeg/route.bak
		if [ `cat /jffs/openvpn/routeg/route.bak | wc -l` -gt 100 ]; then
			mv /jffs/openvpn/routeg/route.bak /jffs/openvpn/routeg/route
			echo "success!"
		else
			echo "fail!"
		fi
		if [ -n "$1" ]; then
			exit
		else
			main
		fi
	fi
}
function set_server()
{
	if [ -n "$2" ]; then
		sed -e "s/enjoydiy.com/${2}" /jffs/openvpn/vpn1.ovpn.bak > /jffs/openvpn/vpn1.ovpn
		echo "OK"
		exit
	else
		read -p "Enter openvpn server ip:" IP
		sed -e "s/enjoydiy.com/${IP}" /jffs/openvpn/vpn1.ovpn.bak > /jffs/openvpn/vpn1.ovpn
		echo "OK"
		main
	fi
}
function update_tools()
{
	wget https://raw.github.com/enjoydiy/ttautovpn/master/grace/tools.sh -O /jffs/openvpn/tools.sh.bak
	if [ `cat /jffs/openvpn/tools.sh.bak | wc -l` -gt 100 ]; then
		mv /jffs/openvpn/tools.sh.bak /jffs/openvpn/tools.sh
		echo "UPDATE OK!"
	fi
	if [ -n "$1" ]; then
		exit
	else
		main
	fi
}
function main()
{
	echo "The functions lists:"
	echo "---------------------------------------------- "
	echo "1.Set openvpn account and password"
	echo "2.Set a IP through VPN"
	echo "3.Set a IP through your network"
	echo "4.Clean up the your own network routes lists"
	echo "5.Start the openvpn daemon"
	echo "6.Update routes from network"
	echo "7.Set openvpn server address"
	echo "8.Update the tools"
	echo "9.exit and enjoy your life"
	echo "----------------------------------------------"
	if [ -z $1 ]; then
		read -p "Please type a number: " fun
	else
		fun=$1
	fi
	case "$fun" in
		1)
			set_pass $*
		;;
		2)
			t_vpn $*
		;;
		3)
			t_net $*
		;;
		4)
			clean_route $*
		;;
		5)
			sh /jffs/openvpn/startopenvpn.sh $*
		;;
		6)
			update_route $*
		;;
		7)
			set_server $*
		;;
		8)
			update_tools $*
		;;
		9)
			echo "Good Bye!"
			exit
		;;
		*)
			echo "The wrong num!"
			main
	esac
}
main $*
