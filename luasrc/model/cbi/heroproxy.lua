local m = Map("heroproxy", translate("HeroProxy"), translate("A proxy tool based on sing-box"))

-- 基本设置部分
local s = m:section(TypedSection, "heroproxy", translate("Basic Settings"))
s.anonymous = true

-- 启用开关
local o = s:option(Flag, "enabled", translate("Enable"))
o.rmempty = false

o = s:option(Value, "core_path", translate("Sing-box Path"))
o.default = "/usr/bin/sing-box"
o.rmempty = false

o = s:option(Value, "config_path", translate("Config Path"))
o.default = "/etc/heroproxy/config.json"
o.rmempty = false

-- 状态显示部分
local s2 = m:section(TypedSection, "heroproxy", translate("Running Status"))
s2.anonymous = true
s2.addremove = false
s2.template = "heroproxy/status"

-- 添加刷新按钮
o = s2:option(Button, "_refresh")
o.title = translate("Refresh Status")
o.inputtitle = translate("Refresh")
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