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

# Fix RTL8365MB DSA driver for kernel 6.12 — field_get() lowercased, should be FIELD_GET (macro from <linux/bitfield.h>)
# This driver is inside the upstream kernel source, not a package. Patch via sed at build time.
# Runs after "make defconfig" (which resolves kernel symbols) but before "make download"
# The actual source is in build_dir — we can only patch it after kernel prepare.
# Instead, add a quirk kernel patch to target/linux/generic
mkdir -p target/linux/generic/hack-6.12
cat > target/linux/generic/hack-6.12/999-rtl8365mb-field-get.patch << 'PATCHEND'
From: Auto-generated fix
Subject: [PATCH] rtl8365mb: fix field_get -> FIELD_GET for kernel 6.12+

The function field_get() was an old pre-bitfield.h helper or typo.
Linux 6.12 removed it. Use FIELD_GET() from <linux/bitfield.h> instead.

--- a/drivers/net/dsa/realtek/rtl8365mb_vlan.c
+++ b/drivers/net/dsa/realtek/rtl8365mb_vlan.c
@@ -714,9 +714,9 @@ int rtl8365mb_vlan_port_get_framefilter(struct realtek_priv *priv, int port,
 					enum rtl8365mb_vlan_accept_frame_type *frame_type)
 {
 	u32 val;
 	int ret;

 	ret = rtl8365mb_get_vlan_4k(priv, port, &val);
 	if (ret)
 		return ret;

-	*frame_type = field_get(RTL8365MB_VLAN_ACCEPT_FRAME_TYPE_MASK(port),
+	*frame_type = FIELD_GET(RTL8365MB_VLAN_ACCEPT_FRAME_TYPE_MASK(port),
 			       val);
 	return 0;
 }
PATCHEND
