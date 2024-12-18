local m = Map("heroproxy", translate("HeroProxy"), translate("基于 sing-box 的代理工具"))

-- Sing-box 设置部分
local s = m:section(TypedSection, "heroproxy", translate("Sing-box 设置"))
s.anonymous = true

local o = s:option(Value, "core_path", translate("Sing-box 路径"))
o.default = "/usr/bin/sing-box"
o.rmempty = false
o.description = translate("sing-box 可执行文件的路径")

o = s:option(Value, "config_path", translate("配置文件路径"))
o.default = "/etc/heroproxy/config.json"
o.rmempty = false
o.description = translate("sing-box 配置文件的路径")

return m 