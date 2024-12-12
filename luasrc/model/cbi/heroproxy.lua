local m, s

m = Map("heroproxy", translate("HeroProxy"), 
    translate("基于 sing-box 的代理服务") .. [[<br /><br /><a href="https://github.com/herozmy/luci-app-heroproxy" target="_blank">]] .. 
    translate("点击查看使用说明") .. [[</a>]])

s = m:section(NamedSection, "config", "heroproxy")
s.anonymous = true
s.addremove = false

-- sing-box 设置
s:tab("singbox", translate("Sing-box 设置"))

local enable = s:taboption("singbox", Flag, "enabled", translate("启用"))
enable.default = 0
enable.rmempty = false

local core_path = s:taboption("singbox", Value, "core_path", translate("核心程序路径"))
core_path.default = "/usr/bin/sing-box"
core_path.rmempty = false
core_path.description = translate("自定义核心程序路径，如使用其他分支版本，请确保核心与配置文件兼容")

local config_path = s:taboption("singbox", Value, "config_path", translate("配置文件路径"))
config_path.default = "/etc/heroproxy/config.json"
config_path.rmempty = false
config_path.description = translate("自定义配置文件路径，更换核心时请注意修改���置文件以确保兼容")

-- mosdns 设置
s:tab("mosdns", translate("Mosdns 设置"))

local mosdns_enable = s:taboption("mosdns", Flag, "mosdns_enabled", translate("启用"))
mosdns_enable.default = 0
mosdns_enable.rmempty = false

local mosdns_path = s:taboption("mosdns", Value, "mosdns_path", translate("核心程序路径"))
mosdns_path.default = "/usr/bin/mosdns"
mosdns_path.rmempty = false
mosdns_path.description = translate("mosdns 程序路径")

local mosdns_config = s:taboption("mosdns", Value, "mosdns_config", translate("配置文件路径"))
mosdns_config.default = "/etc/heroproxy/mosdns/config.yaml"
mosdns_config.rmempty = false
mosdns_config.description = translate("mosdns 配置文件路径")

-- 状态显示
s:tab("status", translate("运行状态"))
local status = s:taboption("status", DummyValue, "_status")
status.template = "heroproxy/status"

-- 日志管理
s:tab("log", translate("日志管理"))

-- 插件日志
local heroproxy_log = s:taboption("log", TextValue, "_heroproxy_log", translate("插件日志"))
heroproxy_log.template = "cbi/tvalue"
heroproxy_log.rows = 20
heroproxy_log.wrap = "off"
heroproxy_log.readonly = "readonly"

function heroproxy_log.cfgvalue()
    local fs = require "nixio.fs"
    return fs.readfile("/etc/heroproxy/heroproxy.log") or ""
end

-- sing-box 日志
local singbox_log = s:taboption("log", TextValue, "_singbox_log", translate("Sing-box 日志"))
singbox_log.template = "cbi/tvalue"
singbox_log.rows = 20
singbox_log.wrap = "off"
singbox_log.readonly = "readonly"

function singbox_log.cfgvalue()
    local fs = require "nixio.fs"
    return fs.readfile("/etc/heroproxy/singbox.log") or ""
end

-- mosdns 日志
local mosdns_log = s:taboption("log", TextValue, "_mosdns_log", translate("Mosdns 日志"))
mosdns_log.template = "cbi/tvalue"
mosdns_log.rows = 20
mosdns_log.wrap = "off"
mosdns_log.readonly = "readonly"

function mosdns_log.cfgvalue()
    local fs = require "nixio.fs"
    return fs.readfile("/etc/heroproxy/mosdns.log") or ""
end

return m 