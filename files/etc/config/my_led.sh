#!/bin/sh

timer_set_ms=250

status_R=255
status_G=255
status_B=255
status_flag=0
status_case="R"
status_one=0
status_interval=25

network_R=255
network_G=255
network_B=255
network_flag=0
network_case="G"
network_one=0
network_interval=25

change_value() {
    value=$1
    flag=$2
    one=$3
    interval=$4

    if [ "$flag" -eq 1 ]; then
        value=$((value + interval))
        if [ "$value" -ge 255 ]; then
            value=255
            flag=0
            one=1
        fi
    else
        value=$((value - interval))
        if [ "$value" -le 0 ]; then
            value=0
            flag=1
        fi
    fi

    echo "$value $flag $one"
}

change_color() {
    # Control rgb:status
    if [ "$status_case" = "R" ]; then
        result=$(change_value $status_R $status_flag $status_one $status_interval)
        status_R=$(echo "$result" | awk '{print $1}')
        status_flag=$(echo "$result" | awk '{print $2}')
        status_one=$(echo "$result" | awk '{print $3}')
        if [ "$status_one" -eq 1 ]; then
            status_one=0
            status_case="G"
        fi
    elif [ "$status_case" = "G" ]; then
        result=$(change_value $status_G $status_flag $status_one $status_interval)
        status_G=$(echo "$result" | awk '{print $1}')
        status_flag=$(echo "$result" | awk '{print $2}')
        status_one=$(echo "$result" | awk '{print $3}')
        if [ "$status_one" -eq 1 ]; then
            status_one=0
            status_case="B"
        fi
    else
        result=$(change_value $status_B $status_flag $status_one $status_interval)
        status_B=$(echo "$result" | awk '{print $1}')
        status_flag=$(echo "$result" | awk '{print $2}')
        status_one=$(echo "$result" | awk '{print $3}')
        if [ "$status_one" -eq 1 ]; then
            status_one=0
            status_case="R"
        fi
    fi

    # Control rgb:network
    if [ "$network_case" = "R" ]; then
        result=$(change_value $network_R $network_flag $network_one $network_interval)
        network_R=$(echo "$result" | awk '{print $1}')
        network_flag=$(echo "$result" | awk '{print $2}')
        network_one=$(echo "$result" | awk '{print $3}')
        if [ "$network_one" -eq 1 ]; then
            network_one=0
            network_case="G"
        fi
    elif [ "$network_case" = "G" ]; then
        result=$(change_value $network_G $network_flag $network_one $network_interval)
        network_G=$(echo "$result" | awk '{print $1}')
        network_flag=$(echo "$result" | awk '{print $2}')
        network_one=$(echo "$result" | awk '{print $3}')
        if [ "$network_one" -eq 1 ]; then
            network_one=0
            network_case="B"
        fi
    else
        result=$(change_value $network_B $network_flag $network_one $network_interval)
        network_B=$(echo "$result" | awk '{print $1}')
        network_flag=$(echo "$result" | awk '{print $2}')
        network_one=$(echo "$result" | awk '{print $3}')
        if [ "$network_one" -eq 1 ]; then
            network_one=0
            network_case="R"
        fi
    fi

    echo "$status_R $status_G $status_B" > /sys/class/leds/rgb:status/multi_intensity
    echo "$network_R $network_G $network_B" > /sys/class/leds/rgb:network/multi_intensity
}

while true; do
    change_color
    sleep 0.25
done
