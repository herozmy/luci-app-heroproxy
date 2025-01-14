include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-heroproxy
PKG_VERSION:=3.1.7
PKG_RELEASE:=1

PKG_LICENSE:=GPL-3.0
PKG_MAINTAINER:=Your Name <your@email.com>

LUCI_TITLE:=LuCI support for HeroProxy (Please install tar and unzip manually)
LUCI_DEPENDS:=+unzip
LUCI_PKARCH:=all

# 定义配置文件
define Package/$(PKG_NAME)/conffiles
/etc/config/heroproxy
endef

# 安装前脚本 - 备份已存在的配置
define Package/$(PKG_NAME)/preinst
#!/bin/sh
# 备份配置文件
[ -f /etc/config/heroproxy ] && mv /etc/config/heroproxy /etc/config/heroproxy.bak

# 创建临时备份目录
mkdir -p /tmp/heroproxy_backup

# 备份核心文件
[ -d /etc/heroproxy/core ] && cp -rf /etc/heroproxy/core /tmp/heroproxy_backup/
# 备份所有配置文件
[ -f /etc/heroproxy/config.json ] && cp -f /etc/heroproxy/config.json /tmp/heroproxy_backup/
[ -f /etc/heroproxy/config-p.json ] && cp -f /etc/heroproxy/config-p.json /tmp/heroproxy_backup/
[ -f /etc/heroproxy/config-x.json ] && cp -f /etc/heroproxy/config-x.json /tmp/heroproxy_backup/
[ -d /etc/heroproxy/mosdns ] && cp -rf /etc/heroproxy/mosdns /tmp/heroproxy_backup/
# 备份规则文件
[ -d /etc/heroproxy/rule ] && cp -rf /etc/heroproxy/rule /tmp/heroproxy_backup/

exit 0
endef

# 安装后脚本 - 创建目录、设置权限等
define Package/$(PKG_NAME)/postinst
#!/bin/sh
[ -z "$$IPKG_INSTROOT" ] || exit 0

# 创建必要目录
mkdir -p /etc/heroproxy/nftables
mkdir -p /etc/heroproxy/mosdns
mkdir -p /etc/heroproxy/core
mkdir -p /etc/heroproxy/rule/geoip
mkdir -p /etc/heroproxy/rule/geosite
mkdir -p /etc/uci-defaults

# 从临时目录恢复备份
if [ -d /tmp/heroproxy_backup ]; then
    # 恢复核心文件
    [ -d /tmp/heroproxy_backup/core ] && cp -rf /tmp/heroproxy_backup/core /etc/heroproxy/
    # 恢复配置文件
    [ -f /tmp/heroproxy_backup/config.json ] && cp -f /tmp/heroproxy_backup/config.json /etc/heroproxy/
    [ -f /tmp/heroproxy_backup/config-p.json ] && cp -f /tmp/heroproxy_backup/config-p.json /etc/heroproxy/
    [ -f /tmp/heroproxy_backup/config-x.json ] && cp -f /tmp/heroproxy_backup/config-x.json /etc/heroproxy/
    [ -d /tmp/heroproxy_backup/mosdns ] && cp -rf /tmp/heroproxy_backup/mosdns /etc/heroproxy/
    # 恢复规则文件
    [ -d /tmp/heroproxy_backup/rule ] && cp -rf /tmp/heroproxy_backup/rule /etc/heroproxy/
    # 清理临时备份
    rm -rf /tmp/heroproxy_backup
fi

# 处理 UCI 配置
if [ -f /etc/uci-defaults/40_luci-heroproxy ]; then
    if [ -f /etc/config/heroproxy.bak ]; then
        mv /etc/config/heroproxy.bak /etc/config/heroproxy
    else
        ( . /etc/uci-defaults/40_luci-heroproxy ) && rm -f /etc/uci-defaults/40_luci-heroproxy
    fi
fi

# 设置权限
chmod 755 /etc/init.d/heroproxy
chmod -R 755 /etc/heroproxy/core
chmod -R 755 /etc/heroproxy/rule
/etc/init.d/heroproxy enable >/dev/null 2>&1
rm -rf /tmp/luci-indexcache /tmp/luci-modulecache
exit 0
endef

# 卸载后脚本 - 清理文件
define Package/$(PKG_NAME)/postrm
#!/bin/sh

# 停止服务（如果存在）
if [ -f /etc/init.d/heroproxy ]; then
    /etc/init.d/heroproxy stop >/dev/null 2>&1
    /etc/init.d/heroproxy disable >/dev/null 2>&1
fi

# 删除配置文件（如果存在且未修改）
if [ -f /etc/config/heroproxy ]; then
    if [ -f /etc/config/heroproxy.bak ]; then
        mv /etc/config/heroproxy.bak /etc/config/heroproxy
    else
        rm -f /etc/config/heroproxy
    fi
fi

# 删除目录和文件
rm -rf /etc/heroproxy >/dev/null 2>&1
rm -f /etc/init.d/heroproxy >/dev/null 2>&1

# 清理 UCI 配置（如果存在）
if uci -q show ucitrack.@heroproxy[0] >/dev/null 2>&1; then
    uci -q batch <<-EOF >/dev/null 2>&1
        delete ucitrack.@heroproxy[0]
        commit ucitrack
EOF
fi

# 清理缓存
rm -rf /tmp/luci-indexcache /tmp/luci-modulecache >/dev/null 2>&1

exit 0
endef

# 安装文件
define Package/$(PKG_NAME)/install
    # 创建目录
    $(INSTALL_DIR) $(1)/etc/heroproxy
    $(INSTALL_DIR) $(1)/etc/heroproxy/nftables
    $(INSTALL_DIR) $(1)/etc/heroproxy/iptables
    $(INSTALL_DIR) $(1)/etc/heroproxy/mosdns
    $(INSTALL_DIR) $(1)/etc/heroproxy/core
    $(INSTALL_DIR) $(1)/etc/heroproxy/core/sing-box
    $(INSTALL_DIR) $(1)/etc/heroproxy/core/sing-box-p
    $(INSTALL_DIR) $(1)/etc/heroproxy/core/sing-box-x
    $(INSTALL_DIR) $(1)/etc/heroproxy/core/mosdns
    $(INSTALL_DIR) $(1)/etc/heroproxy/rule
    $(INSTALL_DIR) $(1)/etc/heroproxy/rule/geoip
    $(INSTALL_DIR) $(1)/etc/heroproxy/rule/geosite
    $(INSTALL_DIR) $(1)/etc/init.d
    $(INSTALL_DIR) $(1)/etc/config
    
    # 安装配置文件
    $(CP) ./root/etc/heroproxy/config.json $(1)/etc/heroproxy/
    $(CP) ./root/etc/heroproxy/config-p.json $(1)/etc/heroproxy/
    $(CP) ./root/etc/heroproxy/nftables/* $(1)/etc/heroproxy/nftables/
    $(CP) ./root/etc/heroproxy/mosdns/config_ph.yaml $(1)/etc/heroproxy/mosdns/
    $(CP) ./root/etc/heroproxy/rule/geoip/* $(1)/etc/heroproxy/rule/geoip/ || true
    $(CP) ./root/etc/heroproxy/rule/geosite/* $(1)/etc/heroproxy/rule/geosite/ || true
    
    # 安装并设置 iptables 脚本权限
    $(INSTALL_BIN) ./root/etc/heroproxy/iptables/* $(1)/etc/heroproxy/iptables/
    
    # 安装其他文件
    $(INSTALL_BIN) ./root/etc/init.d/heroproxy $(1)/etc/init.d/
    $(INSTALL_CONF) ./root/etc/config/heroproxy $(1)/etc/config/
    
    # 创建 view 目录并安装模板
    $(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/heroproxy
    $(INSTALL_DATA) ./luasrc/view/heroproxy/notice.htm $(1)/usr/lib/lua/luci/view/heroproxy/
    $(INSTALL_DATA) ./luasrc/view/heroproxy/status.htm $(1)/usr/lib/lua/luci/view/heroproxy/
    $(INSTALL_DATA) ./luasrc/view/heroproxy/core_status.htm $(1)/usr/lib/lua/luci/view/heroproxy/
    $(INSTALL_DATA) ./luasrc/view/heroproxy/button.htm $(1)/usr/lib/lua/luci/view/heroproxy/
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature 