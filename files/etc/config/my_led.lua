#!/usr/bin/env lua

-- 既然当前系统只认识整数，我们直接休眠 1 秒
local timer_set_ms = 1

-- 为了在休眠 1 秒时不卡顿，我们将步长调小，让每次变化的色彩跨度看起来自然（你可以根据需要调整）
local status_R, status_G, status_B = 255, 255, 255
local status_flag, status_case, status_one, status_interval = 0, "R", 0, 25

local network_R, network_G, network_B = 255, 255, 255
local network_flag, network_case, network_one, network_interval = 0, "G", 0, 25

local function change_value(value, flag, one, interval)
    if flag == 1 then
        value = value + interval
        if value >= 255 then value = 255; flag = 0; one = 1 end
    else
        value = value - interval
        if value <= 0 then value = 0; flag = 1 end
    end
    return value, flag, one
end

local f_status = io.open("/sys/class/leds/rgb:status/multi_intensity", "w")
local f_network = io.open("/sys/class/leds/rgb:network/multi_intensity", "w")

while true do
    if status_case == "R" then
        status_R, status_flag, status_one = change_value(status_R, status_flag, status_one, status_interval)
        if status_one == 1 then status_one = 0; status_case = "G" end
    elseif status_case == "G" then
        status_G, status_flag, status_one = change_value(status_G, status_flag, status_one, status_interval)
        if status_one == 1 then status_one = 0; status_case = "B" end
    else
        status_B, status_flag, status_one = change_value(status_B, status_flag, status_one, status_interval)
        if status_one == 1 then status_one = 0; status_case = "R" end
    end

    if network_case == "R" then
        network_R, network_flag, network_one = change_value(network_R, network_flag, network_one, network_interval)
        if network_one == 1 then network_one = 0; network_case = "G" end
    elseif network_case == "G" then
        network_G, network_flag, network_one = change_value(network_G, network_flag, network_one, network_interval)
        if network_one == 1 then network_one = 0; network_case = "B" end
    else
        network_B, network_flag, network_one = change_value(network_B, network_flag, network_one, network_interval)
        if network_one == 1 then network_one = 0; network_case = "R" end
    end

    -- 物理修正红绿反转
    if f_status then 
        f_status:write(string.format("%d %d %d\n", status_G, status_R, status_B))
        f_status:flush() 
    end

    if f_network then 
        f_network:write(string.format("%d %d %d\n", network_G, network_R, network_B))
        f_network:flush() 
    end

    -- 用当前系统绝对支持的整数 1 秒进行阻塞，彻底拯救 CPU
    os.execute("sleep " .. timer_set_ms)
end

if f_status then f_status:close() end
if f_network then f_network:close() end
