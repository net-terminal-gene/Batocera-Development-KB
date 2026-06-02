#!/bin/bash
#This is an example file how Events on START or STOP can be uses
#

logfile=/tmp/scriptlog.txt
TATE_ROT=$(batocera-settings-get display.rotate 2>/dev/null)

case $1 in
	gameStart)
        echo $2 > /dev/shm/sysname.txt
		echo $3 > /dev/shm/emulator.txt
        echo $4 > /dev/shm/core.txt
		echo $5 > /dev/shm/args.txt

		if [[ "$3" == "libretro" ]]; then
		if [[ "$2" == "fbneo" ]]; then
	    :
		else
		xrandr -display :0.0 -o normal
		fi
	    elif [[ "$5" == "/userdata/roms/windows/Annalynn.pc.wsquashfs" ]]; then
        xrandr -display :0.0 -o right
		elif [[ "$5" == "/userdata/roms/windows/Assault Shell.pc.wsquashfs" ]]; then
        xrandr -display :0.0 -o right
		elif [[ "$5" == "/userdata/roms/windows/Bullet Garden.pc.wsquashfs" ]]; then
        xrandr -display :0.0 -o right
	    elif [[ "$5" == "/userdata/roms/windows/Nyxx.pc.wsquashfs" ]]; then
        xrandr -display :0.0 -o right
		elif [[ "$5" == "/userdata/roms/windows/Z-Warp.pc.wsquashfs" ]]; then
        xrandr -display :0.0 -o right
		elif [[ "$5" == "/userdata/roms/windows/Binarystar Infinity.pc.wsquashfs" ]]; then
        xrandr -display :0.0 -o right
		elif [[ "$5" == "/userdata/roms/windows/Donkey Me.pc.wsquashfs" ]]; then
        xrandr -display :0.0 -o right
		elif [[ "$5" == "/userdata/roms/windows/MissileDancer.pc.wsquashfs" ]]; then
        xrandr -display :0.0 -o right
		elif [[ "$5" == "/userdata/roms/windows/Space Moth DX.pc.wsquashfs" ]]; then
        xrandr -display :0.0 -o right
		elif [[ "$5" == "/userdata/roms/windows/Verminest.wsquashfs" ]]; then
        xrandr -display :0.0 -o right
		elif [[ "$5" == "/userdata/roms/windows/Rysen.wsquashfs" ]]; then
        xrandr -display :0.0 -o right
		elif [[ "$5" == "/userdata/roms/windows/The Adventures of Ten and Till.wsquashfs" ]]; then
        xrandr -display :0.0 -o right
		elif [[ "$5" == "/userdata/roms/windows/Eden's Eclipse.wsquashfs" ]]; then
        xrandr -display :0.0 -o right
		elif [[ "$5" == "/userdata/roms/windows/Bullet Soul Infinite Burst.wsquashfs" ]]; then
        DISPLAY=:0 xrandr --output $(get_video_output) --transform 1,0,10,0,1,0,0,0,1
		else
			if ([[ "$2" == "windows" ]]); then
                    xrandr -display :0.0 -o normal
	       			xrandr --output $(get_video_output) --set TearFree ON
			fi
		fi
    	;;
    	gameStop)
		xrandr --output $(get_video_output) --set TearFree OFF 2>/dev/null
		if [ -n "$TATE_ROT" ] && [ "$TATE_ROT" != "0" ]; then
			DISPLAY=:0 batocera-resolution setRotation "$TATE_ROT"
		else
			xrandr -display :0.0 -o normal
			REQUESTED="$(batocera-settings-get -f /boot/batocera-boot.conf es.resolution)"
			H=$(echo "$REQUESTED" | sed "s/\([0-9]*\)x.*/\1/")
			V=$(echo "$REQUESTED" | sed "s/.*x\([0-9]*\).*/\1/")
			xrandr --output $(get_video_output) --mode "${H}x${V}" 2>/dev/null
		fi
		;;
esac
