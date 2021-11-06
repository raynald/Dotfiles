#!/bin/bash
intern=eDP1
extern=HDMI3

if xrandr | grep "$extern disconnected"; then
    xrandr --output "$extern" --off --output "$intern" --auto
else
    xrandr --output "$intern" --off --output "$extern" --mode 3840x2160
fi

