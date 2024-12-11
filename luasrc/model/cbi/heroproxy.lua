local m, s

m = Map("heroproxy", translate("HeroProxy"), 
    translate("基于 sing-box 的代理服务") .. [[<br /><br /><a href="https://github.com/herozmy/luci-app-heroproxy" target="_blank">]] .. 
    translate("点击查看使用说明") .. [[</a>]])

s = m:section(TypedSection, "heroproxy", translate("基本设置"))
s.anonymous = true

-- 启用开关
local enable = s:option(Flag, "enabled", translate("启用"))
enable.default = 0
enable.rmempty = false
function enable.write(self, section, value)
    if value == "1" then
        luci.sys.call("/etc/init.d/heroproxy start >/dev/null")
    else
        luci.sys.call("/etc/init.d/heroproxy stop >/dev/null")
    end
    return Flag.write(self, section, value)
end

-- 核心程序路径
local core_path = s:option(Value, "core_path", translate("核心程序路径"))
core_path.default = "/usr/bin/sing-box"
core_path.rmempty = false
core_path.description = translate("自定义核心程序路径，如使用其他分支版本，请确保核心与配置文件兼容")

-- 配置文件路径
local config_path = s:option(Value, "config_path", translate("配置文件路径"))
config_path.default = "/etc/heroproxy/config.json"
config_path.rmempty = false
config_path.description = translate("自定义配置文件路径，更换核心时请注意修改配置文件以确保兼容")

-- 状态显示
local status = s:option(DummyValue, "_status", translate("运行状态"))
status.template = "heroproxy/status"

-- 日志管理
s = m:section(TypedSection, "heroproxy", translate("日志管理"))
s.anonymous = true

-- 插件日志
local heroproxy_log = s:option(TextValue, "_heroproxy_log", translate("插件日志"))
heroproxy_log.template = "cbi/tvalue"
heroproxy_log.rows = 20
heroproxy_log.wrap = "off"
heroproxy_log.readonly = "readonly"

function heroproxy_log.cfgvalue()
    local fs = require "nixio.fs"
    local log = fs.readfile("/etc/heroproxy/heroproxy.log") or ""
    return log
end

-- 下载插件日志按钮
local download_heroproxy = s:option(Button, "_download_heroproxy", translate(""))
download_heroproxy.inputtitle = translate("下载插件日志")
download_heroproxy.inputstyle = "reload"
function download_heroproxy.write()
    luci.http.redirect(luci.dispatcher.build_url("admin", "services", "heroproxy", "download_heroproxy_log"))
end

-- 核心日志
local singbox_log = s:option(TextValue, "_singbox_log", translate("核心日志"))
singbox_log.template = "cbi/tvalue"
singbox_log.rows = 20
singbox_log.wrap = "off"
singbox_log.readonly = "readonly"

function singbox_log.cfgvalue()
    local fs = require "nixio.fs"
    local log = fs.readfile("/etc/heroproxy/singbox.log") or ""
    return log
end

-- 下载核心日志按钮
local download_singbox = s:option(Button, "_download_singbox", translate(""))
download_singbox.inputtitle = translate("下载核心日志")
download_singbox.inputstyle = "reload"
function download_singbox.write()
    luci.http.redirect(luci.dispatcher.build_url("admin", "services", "heroproxy", "download_singbox_log"))
end

return m 