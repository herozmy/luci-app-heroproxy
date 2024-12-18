local m = Map("heroproxy", translate("HeroProxy"), translate("基于 sing-box 的代理工具"))

-- 基本设置部分
local s = m:section(TypedSection, "heroproxy", translate("基本设置"))
s.anonymous = true

-- 启用开关
local o = s:option(Flag, "enabled", translate("启用"))
o.rmempty = false

-- Sing-box 设置部分
local s_singbox = m:section(TypedSection, "heroproxy", translate("Sing-box 设置"))
s_singbox.anonymous = true

o = s_singbox:option(Value, "core_path", translate("Sing-box 路径"))
o.default = "/usr/bin/sing-box"
o.rmempty = false
o.description = translate("sing-box 可执行文件的路径")

o = s_singbox:option(Value, "config_path", translate("配置文件路径"))
o.default = "/etc/heroproxy/config.json"
o.rmempty = false
o.description = translate("sing-box 配置文件的路径")

-- Mosdns 设置部分
local s_mosdns = m:section(TypedSection, "heroproxy", translate("Mosdns 设置"))
s_mosdns.anonymous = true

o = s_mosdns:option(Value, "mosdns_path", translate("Mosdns 路径"))
o.default = "/usr/bin/mosdns"
o.rmempty = false
o.description = translate("mosdns 可执行文件的路径")

o = s_mosdns:option(Value, "mosdns_dir", translate("工作目录"))
o.default = "/etc/heroproxy/mosdns"
o.rmempty = false
o.description = translate("mosdns 的工作目录路径")

o = s_mosdns:option(Value, "mosdns_config", translate("配置文件路径"))
o.default = "/etc/heroproxy/mosdns/config.yaml"
o.rmempty = false
o.description = translate("mosdns 配置文件的路径")

-- 状态显示部分
local s_status = m:section(TypedSection, "heroproxy", translate("运行状态"))
s_status.anonymous = true
s_status.addremove = false
s_status.template = "heroproxy/status"

-- 添加刷新按钮
o = s_status:option(Button, "_refresh")
o.title = translate("刷新状态")
o.inputtitle = translate("刷新")
o.inputstyle = "reload"
o.write = function()
    luci.http.redirect(luci.dispatcher.build_url("admin/services/heroproxy"))
end

-- 重写 Map 的 on_commit 函数
function m.on_commit(self)
    -- 获取新的启用状态
    local new_enabled = self:get("config", "enabled")
    local sys = require "luci.sys"
    
    if new_enabled == "0" then
        -- 如果关闭开关
        sys.call("/etc/init.d/heroproxy stop >/dev/null 2>&1")
        sys.call("/etc/init.d/heroproxy disable >/dev/null 2>&1")
    else
        -- 如果开启开关
        sys.call("/etc/init.d/heroproxy enable >/dev/null 2>&1")
        sys.call("/etc/init.d/heroproxy restart >/dev/null 2>&1")
    end
end

return m 