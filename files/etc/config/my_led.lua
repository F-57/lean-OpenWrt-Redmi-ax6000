#!/usr/bin/env lua

-- 放弃臃肿的 uloop，使用纯粹的硬件级死循环，确保 100% 稳定运行
local timer_set_ms = 0.25 -- 250毫秒刷新一次颜色

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

local function change_value( value,flag,one,interval )
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

-- 开启永不退出的顶级死循环
while true do
    -- 控制 rgb:status 灯
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

    -- 控制 rgb:network 灯
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

    -- 将混合后的 RGB 强行注入硬件节点（注意：加上了单引号修复多色融合Bug）
    os.execute("echo '"..status_R.." "..status_G.." "..status_B.."' > /sys/class/leds/rgb:status/multi_intensity")
    os.execute("echo '"..network_R.." "..network_G.." "..network_B.."' > /sys/class/leds/rgb:network/multi_intensity")

    -- 阻塞等待 250 毫秒后进入下一次循环
    os.execute("sleep " .. timer_set_ms)
end
