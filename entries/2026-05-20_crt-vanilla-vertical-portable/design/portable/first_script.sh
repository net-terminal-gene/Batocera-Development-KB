#!/bin/bash
# Event hook script used by Batocera on game START or STOP

##### ES RESOLUTION
REQUESTED="$(batocera-settings-get -f /boot/batocera-boot.conf es.resolution)"
H=$(echo "$REQUESTED" | sed "s/\([0-9]*\)x.*/\1/")
V=$(echo "$REQUESTED" | sed "s/.*x\([0-9]*\).*/\1/")
es_res="${H}x${V}"
ratio=0
if [ -n "$H" ] && [ -n "$V" ] && [ "$V" -gt 0 ] 2>/dev/null; then
	ratio=$((H / V))
fi

if [ -n "$V" ] && [ "$V" -lt 480 ] 2>/dev/null; then
	scaler="320x240"
else
	scaler="640x480"
fi

GPU=$(lspci | grep VGA | cut -d ":" -f3)
shopt -s nocasematch
for word in $GPU; do
	if /usr/bin/grep -s -i -F $word /etc/ati0dot.txt > /dev/null; then
		GPU="AMD15"
		break
	fi
done

export DISPLAY=:0
TATE_ROT=$(batocera-settings-get display.rotate 2>/dev/null)

/usr/retroasd/bin/pyJammASD/main.py -c /usr/retroasd/bin/pyJammASD/batocera.ini >/dev/null 2>&1

if [ "$3" == "libretro" ] || [ "$3" == "model2" ]; then
	/usr/retroasd/bin/pyJammASD/main.py -c /usr/retroasd/bin/pyJammASD/x360pad.ini >/dev/null 2>&1
fi

if [ "$3" == "supermodel" ]; then
	/usr/retroasd/bin/pyJammASD/main.py -c /usr/retroasd/bin/pyJammASD/supermodel.ini >/dev/null 2>&1
fi

if [ ! -L /.local/share ]; then mkdir /.local/share 2>/dev/null; fi
ln -s /userdata/system/configs/yuzu /.local/share/yuzu 2>/dev/null

case $GPU in
*"GM10"* | *"GM20"* | *"GK10"* | *"GK20"* | *"AMD15"* | *"CoffeeLake"* | *"HD Graphics 530"*)

	case $1 in
	gameStart)
		if [ -z "$TATE_ROT" ] || [ "$TATE_ROT" = "0" ]; then
			/usr/bin/xrandr -display :0.0 --output $(get_video_output) --transform none
			if [ "$3" == "mame" ]; then
				/usr/bin/xrandr -display :0.0 --output $(get_video_output) --mode "640x480"
			fi
		fi
		;;
	gameStop)
		/usr/retroasd/bin/pyJammASD/main.py -c /usr/retroasd/bin/pyJammASD/batocera.ini >/dev/null 2>&1
		if [ -z "$TATE_ROT" ] || [ "$TATE_ROT" = "0" ]; then
			/usr/bin/xrandr -display :0.0 --output $(get_video_output) --transform none
			if [ "$ratio" -ge 2 ] 2>/dev/null; then
				xrandr --output $(get_video_output) --mode "$es_res" --scale-from $scaler
			else
				xrandr --output $(get_video_output) --mode "$es_res"
			fi
		fi
		;;
	esac
	;;
*)
	case $1 in
	gameStart)
		if [ -z "$TATE_ROT" ] || [ "$TATE_ROT" = "0" ]; then
			/usr/bin/xrandr -display :0.0 --output $(get_video_output) --transform none
			if [ "$3" == "mame" ]; then
				/usr/bin/xrandr -display :0.0 --output $(get_video_output) --mode "640x480"
			fi
			if [ "$3" != "mame" ] && [ "$3" != "libretro" ] && [ "$3" != "supermodel" ] && [ "$3" != "yuzu-early-access" ]; then
				/usr/bin/xrandr -display :0.0 --output $(get_video_output) --mode "1280x480" --scale-from 640x480
			fi
		fi
		;;
	gameStop)
		/usr/retroasd/bin/pyJammASD/main.py -c /usr/retroasd/bin/pyJammASD/batocera.ini >/dev/null 2>&1
		if [ -z "$TATE_ROT" ] || [ "$TATE_ROT" = "0" ]; then
			/usr/bin/xrandr -display :0.0 --output $(get_video_output) --transform none
			if [ "$ratio" -ge 2 ] 2>/dev/null; then
				xrandr --output $(get_video_output) --mode "$es_res" --scale-from $scaler
			else
				xrandr --output $(get_video_output) --mode "$es_res"
			fi
		fi
		;;
	esac
	;;
esac
