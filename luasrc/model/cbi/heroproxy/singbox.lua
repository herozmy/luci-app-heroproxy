local m = Map("heroproxy", translate("HeroProxy"), translate("基于 sing-box 的代理工具"))

-- Sing-box 设置部分
local s = m:section(NamedSection, "config", "heroproxy", translate("Sing-box 设置"))
s.anonymous = true

local o = s:option(Value, "core_path", translate("Sing-box 路径"))
o.default = "/etc/heroproxy/core/sing-box/sing-box"
o.rmempty = false
o.description = translate("sing-box 可执行文件的路径，可选：") .. 
    "<br/>/etc/heroproxy/core/sing-box/sing-box (官方核心)" ..
    "<br/>/etc/heroproxy/core/sing-box-p/sing-box (P核心)" ..
    "<br/>/etc/heroproxy/core/sing-box-x/sing-box (X核心)"

o = s:option(Value, "config_path", translate("配置文件路径"))
o.default = "/etc/heroproxy/config.json"
o.rmempty = false
o.description = translate("sing-box 配置文件的路径，可选：") ..
    "<br/>/etc/heroproxy/config.json (官方配置)" ..
    "<br/>/etc/heroproxy/config-p.json (P核心配置)" ..
    "<br/>/etc/heroproxy/config-x.json (X核心配置)"

return m 