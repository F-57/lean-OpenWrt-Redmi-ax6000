#!/bin/bash
#
# Copyright (c) 2019-2023 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#


# 1. 替换 LAN 口默认 IP (192.168.1.1 -> 10.0.0.1)
sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/files/bin/config_generate

# 2. 替换其他接口的递增网段 (192.168.$((...)) -> 10.0.$((...)))
sed -i 's/192.168.\$((addr_offset++))/10.0.\$((addr_offset++))/g' package/base-files/files/bin/config_generate

# 512布局
sed -i 's/reg = <0x600000 0x6e00000>/reg = <0x600000 0x1ea00000>/' target/linux/mediatek/dts/mt7986a-xiaomi-redmi-router-ax6000.dts

# --- 取消集成指定的 LuCI 插件 ---
items=(
    "luci-app-vsftpd"
    "luci-app-uhttpd"
    "luci-app-wol"
    "luci-app-accesscontrol"
    "luci-app-vlmcsd"
    "luci-app-arpbind"
)

for item in "${items[@]}"; do
    # 将 CONFIG_PACKAGE_luci-app-xxx=y 替换为未设置状态
    sed -i "s/CONFIG_PACKAGE_$item=y/# CONFIG_PACKAGE_$item is not set/g" .config
done


