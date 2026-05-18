#!/usr/bin/env lua

require "uloop"
uloop.init()

-- 1. 性能参数：30ms 刷新率，步长为 3，极度丝滑
local TIMER_INTERVAL_MS = 30
local STEP_INTERVAL = 3

-- 2. 状态机与流光相位差初始化
local function create_led(name, initial_channel, phase_offset)
    local path = string.format("/sys/class/leds/rgb:%s/multi_intensity", name)
    
    -- 色彩环状态转移链：绿(G) -> 红(R) -> 蓝(B) -> 绿(G)
    local next_channel = { G = "R", R = "B", B = "G" }
    
    -- 初始化基础颜色：当前主色满（255），其余全灭
    local colors = { G = 0, R = 0, B = 0 }
    colors[initial_channel] = 255
    local current_channel = initial_channel

    -- 【核心重构】如果有相位差，计算出落后的色彩状态
    if phase_offset and phase_offset > 0 then
        local steps = phase_offset
        -- 模拟步长演进，让当前灯的颜色“往回退” steps 个单位
        while steps > 0 do
            local nxt = next_channel[current_channel]
            -- 如果下一个颜色不是0，说明正在从主色向下一个颜色过渡
            -- 那么“后退”就意味着降低下一个颜色，升高当前主色
            if colors[nxt] > 0 then
                local diff = math.min(steps, colors[nxt])
                colors[nxt] = colors[nxt] - diff
                colors[current_channel] = colors[current_channel] + diff
                steps = steps - diff
            else
                -- 如果下一个颜色是0，说明已经退到边界，需要向“上一个通道”倒退
                -- 找出谁的 next 是当前 channel（即倒退回上一个通道）
                local prev_channel
                for k, v in pairs(next_channel) do
                    if v == current_channel then prev_channel = k; break end
                end
                current_channel = prev_channel
                colors[current_channel] = 0
                colors[next_channel[current_channel]] = 255
            end
        end
    end

    return {
        name = name,
        path = path,
        fh = nil,
        colors = colors,
        current_channel = current_channel,
        next_channel = next_channel
    }
end

-- 【导师配置】
-- status 灯从纯绿(G)开始跑
-- network 灯同样从绿(G)开始，但通过注入 120 个单位的相位差，强制让它“落后”
-- 120 大约是总行程（255）的一半，两个灯会呈现出完美的色彩前后追逐拉丝效果
local leds = {
    status  = create_led("status", "G", nil),
    network = create_led("network", "G", 120) 
}

-- 3. 防御性文件写入：具备错误捕获与自动重连
local function safe_write_led(led)
    if not led.fh then
        led.fh = io.open(led.path, "w")
        if not led.fh then return false end
    end

    local _, err = led.fh:seek("set", 0)
    if err then
        led.fh:close()
        led.fh = nil
        return false
    end

    -- 严格对应红米硬件物理线序: G R B
    local payload = string.format("%d %d %d\n", led.colors.G, led.colors.R, led.colors.B)
    local success, write_err = led.fh:write(payload)
    
    if not success then
        led.fh:close()
        led.fh = nil
        return false
    end

    led.fh:flush()
    return true
end

-- 4. 无缝炫彩渐变算法
local function update_led_rainbow(led)
    local cur = led.current_channel
    local nxt = led.next_channel[cur]
    
    led.colors[cur] = led.colors[cur] - STEP_INTERVAL
    led.colors[nxt] = led.colors[nxt] + STEP_INTERVAL
    
    -- 边界校准：完成单个通道的交接
    if led.colors[nxt] >= 255 then
        led.colors[cur] = 0
        led.colors[nxt] = 255
        led.current_channel = nxt
    end
end

-- 5. 异步定时器
local timer
local function timer_cb()
    for _, led in pairs(leds) do
        update_led_rainbow(led)
        safe_write_led(led)
    end
    timer:set(TIMER_INTERVAL_MS)
end

timer = uloop.timer(timer_cb)
timer:set(TIMER_INTERVAL_MS)

uloop.run()
