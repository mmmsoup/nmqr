#/usr/bin/env bash

function _nmqr() {
	local words_num=${#COMP_WORDS[@]}

	if [ "$words_num" == "2" ]; then
		COMPREPLY=($(compgen -W "help list recv share" ${COMP_WORDS[1]}))
	elif [ "$words_num" == "3" ]; then
		if [ "${COMP_WORDS[1]}" == "share" ]; then
			COMPREPLY=($(compgen -W "$(nmcli -c no -f name,type connection show | grep wifi | awk '{print $1}')" ${COMP_WORDS[2]}))
		fi
	fi
}

complete -F _nmqr nmqr
