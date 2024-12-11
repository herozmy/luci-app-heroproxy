include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-heroproxy
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_LICENSE:=GPL-3.0

LUCI_TITLE:=LuCI support for HeroProxy
LUCI_DEPENDS:=+luci-base +sing-box

define Package/$(PKG_NAME)/conffiles
/etc/config/heroproxy
/etc/heroproxy/config.json
/etc/heroproxy/nftables/tproxy.conf
/etc/heroproxy/nftables/route_network
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
chmod 755 /etc/init.d/heroproxy
mkdir -p /etc/heroproxy/nftables
[ -x /etc/init.d/heroproxy ] && /etc/init.d/heroproxy enable >/dev/null 2>&1
[ -x /etc/init.d/heroproxy ] && /etc/init.d/heroproxy restart >/dev/null 2>&1
exit 0
endef

define Package/$(PKG_NAME)/prerm
#!/bin/sh
# 停止服务
[ -x /etc/init.d/heroproxy ] && /etc/init.d/heroproxy stop >/dev/null 2>&1
# 禁用服务
[ -x /etc/init.d/heroproxy ] && /etc/init.d/heroproxy disable >/dev/null 2>&1
# 删除服务
[ -f /etc/init.d/heroproxy ] && rm -f /etc/init.d/heroproxy
# 清理配置文件
rm -rf /etc/heroproxy
# 清理 uci 配置
uci -q delete ucitrack.@heroproxy[-1]
uci commit ucitrack
# 重新加载防火墙
/etc/init.d/firewall reload >/dev/null 2>&1
exit 0
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature 