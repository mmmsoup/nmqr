#compdef nmqr

function _nmqr() {
	_arguments -C "1: :->subcmds" "*::subcommands:->current_subcmd"
	case "$state" in
		"subcmds")
			compadd "help" "list" "recv" "share"
			;;
		"current_subcmd")
			case $line[1] in
				"share")
					compadd $(nmcli -c no -f name,type connection show | grep "wifi" | awk '{print $1}')
				;;
			esac
		;;
	esac
}

compdef _nmqr nmqr
