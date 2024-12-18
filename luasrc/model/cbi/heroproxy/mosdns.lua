local m = Map("heroproxy", translate("HeroProxy"), translate("基于 sing-box 的代理工具"))

-- Mosdns 设置部分
local s = m:section(TypedSection, "heroproxy", translate("Mosdns 设置"))
s.anonymous = true

local o = s:option(Value, "mosdns_path", translate("Mosdns 路径"))
o.default = "/usr/bin/mosdns"
o.rmempty = false
o.description = translate("mosdns 可执行文件的路径")

o = s:option(Value, "mosdns_dir", translate("工作目录"))
o.default = "/etc/heroproxy/mosdns"
o.rmempty = false
o.description = translate("mosdns 的工作目录路径")

o = s:option(Value, "mosdns_config", translate("配置文件路径"))
o.default = "/etc/heroproxy/mosdns/config.yaml"
o.rmempty = false
o.description = translate("mosdns 配置文件的路径")

return m 