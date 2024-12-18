local m = Map("heroproxy", translate("HeroProxy"), translate("A proxy tool based on sing-box"))

-- 基本设置部分
local s = m:section(TypedSection, "heroproxy", translate("Basic Settings"))
s.anonymous = true

-- 启用开关
local o = s:option(Flag, "enabled", translate("Enable"))
o.rmempty = false
o.write = function(self, section, value)
    if value == "0" then
        -- 如果关闭开关，执行清理操作
        local sys = require "luci.sys"
        sys.call("/etc/init.d/heroproxy stop")
        sys.call("/etc/init.d/heroproxy disable")
    end
    
    -- 保存设置
    Flag.write(self, section, value)
end

o = s:option(Value, "core_path", translate("Sing-box Path"))
o.default = "/usr/bin/sing-box"
o.rmempty = false

o = s:option(Value, "config_path", translate("Config Path"))
o.default = "/etc/heroproxy/config.json"
o.rmempty = false

-- 状态显示部分
local s2 = m:section(TypedSection, "heroproxy", translate("Running Status"))
s2.anonymous = true
s2.template = "heroproxy/status"

return m 