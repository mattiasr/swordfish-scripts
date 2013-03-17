#!/bin/bash
CMD="./transcode.sh"
DEBUG=0

if [ $1 ]; then
	OUT="output/${1/input\//}"
	BUFFER=$(${CMD} $1 2>&1 >/dev/null)
	RET=$?
	if [ ${DEBUG} -eq 1 ]; then
		echo "${CMD} $1"
	fi

	echo -n "Converting ${1}"
	echo " Complete..."
else
	echo "Converting batch"
	echo "=========================================="
	SAVEIFS=${IFS}
	IFS=$(echo -en "\n\b")
	for FILE in $(ls -1 input/); do
		OUT="output/${FILE}"
		echo -n "`date +"%H:%M"` Converting ${FILE}"
		BUFFER=$(${CMD} input/${FILE} 2>&1 >/dev/null)
		RET=$?
		echo " Complete...(`date +"%H:%M"`)"
	done
	IFS=${SAVEIFS}
fi
