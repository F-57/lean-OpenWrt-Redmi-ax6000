#!/usr/bin/env lua

require "uloop"

uloop.init()

local timer
local timer_set_ms=250

local status_R=255
local status_G=255
local status_B=255
local status_flag=0
local status_case="R"
local status_one=0
local status_interval=25

local network_R=255
local network_G=255
local network_B=255
local network_flag=0
local network_case="G"
local network_one=0
local network_interval=25

function change_value( value,flag,one,interval )
        if(flag == 1) then
                value=value+interval
                if(value >= 255) then
                        value=255
                        flag=0
                        one=1
                end
        else
                value=value-interval
                if(value <= 0) then
                        value=0
                        flag=1
                end
        end
        return value,flag,one
end

function change_color()
        if(status_case == "R") then
                status_R,status_flag,status_one=change_value(status_R,status_flag,status_one,status_interval)
                if(status_one == 1) then
                        status_one=0
                        status_case="G"
                end
        elseif(status_case == "G") then
                status_G,status_flag,status_one=change_value(status_G,status_flag,status_one,status_interval)
                if(status_one == 1) then
                        status_one=0
                        status_case="B"
                end
        else
                status_B,status_flag,status_one=change_value(status_B,status_flag,status_one,status_interval)
                if(status_one == 1) then
                        status_one=0
                        status_case="R"
                end
        end

        if(network_case == "R") then
                network_R,network_flag,network_one=change_value(network_R,network_flag,network_one,network_interval)
                if(network_one == 1) then
                        network_one=0
                        network_case="G"
                end
        elseif(network_case == "G") then
                network_G,network_flag,network_one=change_value(network_G,network_flag,network_one,network_interval)
                if(network_one == 1) then
                        network_one=0
                        network_case="B"
                end
        else
                network_B,network_flag,network_one=change_value(network_B,network_flag,network_one,network_interval)
                if(network_one == 1) then
                        network_one=0
                        network_case="R"
                end
        end

        os.execute("echo "..status_R.." "..status_G.." "..status_B.." > /sys/class/leds/rgb:status/multi_intensity")
        os.execute("echo "..network_R.." "..network_G.." "..network_B.." > /sys/class/leds/rgb:network/multi_intensity")
        timer:set(timer_set_ms)
end

timer = uloop.timer(change_color)
timer:set(timer_set_ms)

uloop.run()
