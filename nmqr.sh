#!/bin/sh

if [ "$1" == "h" ] || [ "$1" == "help" ]; then
	echo -e "'$0' - help"
	echo -e "Usage: '$0' [SUBCOMMAND] [ARGS]"
	echo -e ""
	echo -e "Subcommands:"
	echo -e "h | help\t\tshow this help message"
	echo -e "l | list\t\tlist saved wireless network configurations that can be shared"
	echo -e "r | recv\t\tscan a QR code from another device and add the network configuration"
	echo -e "s | share [CONN_NAME]\tdisplay QR code containing configuration for CONN_NAME"
elif [ "$1" == "l" ] || [ "$1" == "list" ]; then
	nmcli -f name,type connection show | grep "wifi" | awk '{print $1}'
elif [ "$1" == "r" ] || [ "$1" == "recv" ]; then
	wifi_string=$(zbarcam -1 | grep -Po "(?<=^QR-Code:WIFI:).*(?=;)")
	if [ -z "$wifi_string" ]; then
		echo "FATAL: invalid code"
		exit 1
	else
		oldifs="$IFS"
		IFS=";"
		for prop_string in $wifi_string; do
			key="$(echo "$prop_string" | cut -d ":" -f 1)"
			val="$(echo "$prop_string" | cut -d ":" -f 2)"
			case "$key" in
				"T") # authentication type
					auth="$val"
					;;
				"S") # ssid
					ssid="$val"
					;;
				"P") # password
					password="$val"
					;;
				"H") # hidden
					hidden="$val"
					;;
				"E") # eap method
					eap="$val"
					;;
				"A") # anonymous identity
					anon_identity="$val"
					;;
				"I") # identity
					identity="$val"
					;;
				"PH2") # phase 2
					phase2="$val"
					;;
				*) # default
					echo "WARNING: unknown key '$key'"
			esac
		done
		IFS="$oldifs"
	fi
	wifi_interface="$(nmcli -c no -g TYPE,DEVICE device status | grep -Po "(?<=^wifi:).*$")"
	nmcli connection add \
		type wifi \
		con-name "$ssid" -- \
		ifname "$wifi_interface" \
		+802-11-wireless.ssid "$ssid" \
		+wifi-sec.auth-alg open \
		+wifi-sec.key-mgmt wpa-psk \
		+wifi-sec.psk "$password"
elif [ "$1" == "s" ] || [ "$1" == "share" ]; then
	if [ -z "$2" ]; then
		# use current connection if no argument is given
		conn_name="$(nmcli -f type,name connection show --active | grep "wifi" | awk '{print $2}')"
		if [ -z "$conn_name" ]; then
			echo "FATAL: no connection name given and currently not connected to a wireless network"
			exit 1
		fi
	elif nmcli -g all connection show "$2" &> /dev/null; then
		conn_name="$2"
	else
		echo "FATAL: invalid connection name"
		exit 1
	fi
	auth="WPA" # TODO: add support for other authentication types
	ssid="$(nmcli -g 802-11-wireless.ssid connection show "$conn_name")"
	password="$(nmcli -s -g 802-11-wireless-security.psk connection show "$conn_name")"
	# TODO: implement these
	#hidden=
	#eap=
	#anon_identity=
	#identity=
	#phase2=
	wifi_string="WIFI:T:${auth};S:${ssid};P:${password};;"
	qrencode -t ansiutf8 "$wifi_string"
	echo "Scan to connect to $ssid"
elif [ -z "$1" ]; then
	echo "FATAL: subcommand required"
	exit 1
else
	echo "FATAL: unknown subcommand '$1'"
	exit 1
fi
