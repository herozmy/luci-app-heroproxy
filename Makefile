include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-heroproxy
PKG_VERSION:=3.1.1
PKG_RELEASE:=1

PKG_LICENSE:=GPL-3.0
PKG_MAINTAINER:=Your Name <your@email.com>

LUCI_TITLE:=LuCI support for HeroProxy
LUCI_DEPENDS:=+sing-box +mosdns
LUCI_PKGARCH:=all

# 定义配置文件
define Package/$(PKG_NAME)/conffiles
/etc/config/heroproxy
endef

# 安装前脚本 - 备份已存在的配置
define Package/$(PKG_NAME)/preinst
#!/bin/sh
[ -f /etc/config/heroproxy ] && mv /etc/config/heroproxy /etc/config/heroproxy.bak
exit 0
endef

# 安装后脚本 - 创建目录、设置权限等
define Package/$(PKG_NAME)/postinst
#!/bin/sh
[ -z "$$IPKG_INSTROOT" ] || exit 0
mkdir -p /etc/heroproxy/nftables
mkdir -p /etc/heroproxy/mosdns
mkdir -p /etc/heroproxy/rule/geoip
mkdir -p /etc/heroproxy/rule/geosite
mkdir -p /etc/uci-defaults
if [ -f /etc/uci-defaults/40_luci-heroproxy ]; then
    ( . /etc/uci-defaults/40_luci-heroproxy ) && rm -f /etc/uci-defaults/40_luci-heroproxy
fi
chmod 755 /etc/init.d/heroproxy
chmod -R 755 /etc/heroproxy/rule
/etc/init.d/heroproxy enable >/dev/null 2>&1
rm -rf /tmp/luci-indexcache /tmp/luci-modulecache
exit 0
endef

# 卸载后脚本 - 清理文件
define Package/$(PKG_NAME)/postrm
#!/bin/sh
rm -rf /etc/config/heroproxy
rm -rf /etc/heroproxy
rm -f /etc/init.d/heroproxy
rm -rf /tmp/luci-indexcache /tmp/luci-modulecache
exit 0
endef

# 安装文件
define Package/$(PKG_NAME)/install
    # 创建目录
    $(INSTALL_DIR) $(1)/etc
    $(INSTALL_DIR) $(1)/etc/heroproxy
    $(INSTALL_DIR) $(1)/etc/heroproxy/nftables
    $(INSTALL_DIR) $(1)/etc/heroproxy/mosdns
    $(INSTALL_DIR) $(1)/etc/heroproxy/rule
    $(INSTALL_DIR) $(1)/etc/heroproxy/rule/geoip
    $(INSTALL_DIR) $(1)/etc/heroproxy/rule/geosite
    $(INSTALL_DIR) $(1)/etc/init.d
    $(INSTALL_DIR) $(1)/etc/config
    
    # 安装配置文件
    $(CP) ./root/etc/heroproxy/config.json $(1)/etc/heroproxy/
    $(CP) ./root/etc/heroproxy/config-p.json $(1)/etc/heroproxy/
    $(CP) ./root/etc/heroproxy/nftables/* $(1)/etc/heroproxy/nftables/
    $(CP) ./root/etc/heroproxy/mosdns/config.yaml $(1)/etc/heroproxy/mosdns/
    $(CP) ./root/etc/heroproxy/rule/geoip/* $(1)/etc/heroproxy/rule/geoip/ || true
    $(CP) ./root/etc/heroproxy/rule/geosite/* $(1)/etc/heroproxy/rule/geosite/ || true
    
    # 安装其他文件
    $(INSTALL_BIN) ./root/etc/init.d/heroproxy $(1)/etc/init.d/
    $(INSTALL_CONF) ./root/etc/config/heroproxy $(1)/etc/config/
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature 