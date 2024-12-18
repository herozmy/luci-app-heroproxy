local m = Map("heroproxy", translate("HeroProxy"), translate("基于 sing-box 的代理工具"))

-- 基本设置部分
local s = m:section(TypedSection, "heroproxy", translate("基本设置"))
s.anonymous = true

-- 启用开关
local o = s:option(Flag, "enabled", translate("启用"))
o.rmempty = false

-- 状态显示部分
local s2 = m:section(TypedSection, "heroproxy", translate("运行状态"))
s2.anonymous = true
s2.template = "heroproxy/status"

-- 添加刷新按钮
o = s2:option(Button, "_refresh")
o.title = translate("刷新状态")
o.inputtitle = translate("刷新")
o.inputstyle = "reload"
o.write = function()
    luci.http.redirect(luci.dispatcher.build_url("admin/services/heroproxy/basic"))
end

-- 添加重启按钮
o = s2:option(Button, "_restart")
o.title = translate("重启服务")
o.inputtitle = translate("重启")
o.inputstyle = "apply"
o.write = function()
    luci.sys.call("/etc/init.d/heroproxy restart >/dev/null 2>&1")
    luci.http.redirect(luci.dispatcher.build_url("admin/services/heroproxy/basic"))
end

return m 