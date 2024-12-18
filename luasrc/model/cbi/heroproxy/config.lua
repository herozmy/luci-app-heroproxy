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

-- 日志部分
local s3 = m:section(TypedSection, "heroproxy", translate("Logs"))
s3.anonymous = true

-- HeroProxy 日志
o = s3:option(DummyValue, "_heroproxy_log", translate("HeroProxy Log"))
o.template = "heroproxy/log"
o.logfile = "/etc/heroproxy/heroproxy.log"

-- Sing-box 日志
o = s3:option(DummyValue, "_singbox_log", translate("Sing-box Log"))
o.template = "heroproxy/log"
o.logfile = "/etc/heroproxy/singbox.log"

-- Mosdns 日志
o = s3:option(DummyValue, "_mosdns_log", translate("Mosdns Log"))
o.template = "heroproxy/log"
o.logfile = "/etc/heroproxy/mosdns/mosdns.log"

-- 下载按钮
o = s3:option(Button, "_download_heroproxy")
o.title = translate("Download HeroProxy Log")
o.inputtitle = translate("Download")
o.inputstyle = "apply"
o.write = function()
    luci.http.redirect(luci.dispatcher.build_url("admin/services/heroproxy/download_heroproxy_log"))
end

o = s3:option(Button, "_download_singbox")
o.title = translate("Download Sing-box Log")
o.inputtitle = translate("Download")
o.inputstyle = "apply"
o.write = function()
    luci.http.redirect(luci.dispatcher.build_url("admin/services/heroproxy/download_singbox_log"))
end

return m 