#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Modify default IP
sed -i 's/192.168.1.1/192.168.100.1/g' package/base-files/files/bin/config_generate

# Modify default theme
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
sed -i 's/OpenWrt/HT2/g' package/base-files/files/bin/config_generate

# Disable RTL8365MB DSA driver — HT2 doesn't use it, and it breaks on kernel 6.12 (field_get removed)
sed -i 's/CONFIG_NET_DSA_REALTEK_RTL8365MB=m/# CONFIG_NET_DSA_REALTEK_RTL8365MB is not set/' target/linux/rockchip/armv8/config-*/kernel-config 2>/dev/null || true
sed -i '/^CONFIG_NET_DSA_REALTEK_RTL8365MB/d' target/linux/rockchip/armv8/config-* 2>/dev/null || true
