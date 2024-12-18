local m = Map("heroproxy", translate("HeroProxy"), translate("基于 sing-box 的代理工具"))

-- Sing-box 核心
local s = m:section(NamedSection, "config", "heroproxy", translate("Sing-box 核心"))
s.anonymous = true
s.addremove = false

local o = s:option(DummyValue, "_singbox_status", translate("官方核心状态"))
o.template = "heroproxy/core_status"
o.core_type = "singbox"
o.core_path = "/etc/heroproxy/core/sing-box/sing-box"
o.config_path = "/etc/heroproxy/config.json"

local o2 = s:option(DummyValue, "_singbox_p_status", translate("P核心状态"))
o2.template = "heroproxy/core_status"
o2.core_type = "singbox-p"
o2.core_path = "/etc/heroproxy/core/sing-box-p/sing-box"
o2.config_path = "/etc/heroproxy/config-p.json"

local o3 = s:option(DummyValue, "_singbox_x_status", translate("X核心状态"))
o3.template = "heroproxy/core_status"
o3.core_type = "singbox-x"
o3.core_path = "/etc/heroproxy/core/sing-box-x/sing-box"
o3.config_path = "/etc/heroproxy/config-x.json"

-- Mosdns 核心
local s2 = m:section(NamedSection, "config", "heroproxy", translate("Mosdns 核心"))
s2.anonymous = true
s2.addremove = false

local o4 = s2:option(DummyValue, "_mosdns_status", translate("核心状态"))
o4.template = "heroproxy/core_status"
o4.core_type = "mosdns"

return m 