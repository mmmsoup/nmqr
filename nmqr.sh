#!/bin/sh

# takes a single argument: connection name
function create_wifi_string() {
	auth="WPA" # TODO: add support for other authentication types
	ssid="$(nmcli -g 802-11-wireless.ssid connection show "$1")"
	password="$(nmcli -s -g 802-11-wireless-security.psk connection show "$1")"
	# TODO: implement these
	#hidden=
	#eap=
	#anon_identity=
	#identity=
	#phase2=

	wifi_str="WIFI:T:${auth};S:${ssid};P:${password};;"
	
	echo "$wifi_str"
}

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
	echo "TODO: implement this"
elif [ "$1" == "s" ] || [ "$1" == "share" ]; then
	if [ -z "$2" ]; then
		ssid="$(nmcli -g 802-11-wireless.ssid connection show "$(nmcli -g name connection show --active)")"
		wifi_string=$(create_wifi_string "$(nmcli -g name connection show --active)")
	elif nmcli -g all connection show "$2" &> /dev/null; then
		ssid="$2"
		wifi_string=$(create_wifi_string "$2")
	else
		echo "invalid connection name"
		exit 1
	fi
	qrencode -t ansiutf8 "$wifi_string"
	echo "Scan to connect to $ssid"
elif [ -z "$1" ]; then
	echo "subcommand required: see '$0 help'"
	exit 1
else
	echo "unknown subcommand '$1'"
	exit 1
fi
