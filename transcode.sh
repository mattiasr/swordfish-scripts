#!/bin/bash
function abort()
{
	echo $1
	exit 1
}
# Make sure you have created the pre and post file with
# ffmpeg -i templates/pre.mp4 -qscale:v 1 pre.mpg
PRE="templates/pre.mpg"
POST="templates/post.mpg"
WATERMARK="templates/swordfish-watermark.png"

PROGRESS="progress"
OUTPUT="output"
GOPRO=$(echo $1| sed "s/ /\\ /g")
FILENAME=${GOPRO/input\//}
FILENAME=$(echo ${FILENAME}|sed "s/.MP4/.mpg/")
FILENAME=$(echo ${FILENAME}|sed "s/.mp4/.mpg/")

if [ -f "${OUTPUT}/${FILENAME}" ]; then
	abort "${FILENAME} already exists"
fi

$($(which ffmpeg) -loglevel fatal -i "${GOPRO}" -qscale:v 1 -s 1280x720 -b:v 15000 \
	-vf "movie=${WATERMARK} [movie]; [in][movie] overlay=main_w-overlay_w-10:10 [out]" \
	"${PROGRESS}/${FILENAME}")
RET=$?
if [ ${RET} -gt 0 ]; then
	abort "Something went wrong in watermark stage."
fi

# Combine the pre and post files with the fight
$($(which ffmpeg) -loglevel fatal -i concat:"${PRE}|${PROGRESS}/${FILENAME}|${POST}" \
	-c copy "${OUTPUT}/${FILENAME}")
RET=$?
if [ ${RET} -gt 0 ]; then
	abort "Something went wrong in concat stage."
fi

# Cleanup
if [ -f  "${PROGRESS}/${FILENAME}" ]; then
	rm -fr "${PROGRESS}/${FILENAME}"
fi
