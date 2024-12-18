module("luci.model.cbi.heroproxy.log", package.seeall)

function index()
    return m
end

m = SimpleForm("heroproxy", translate("HeroProxy Log"))
m.reset = false
m.submit = false

-- HeroProxy 日志
s = m:section(SimpleSection, translate("HeroProxy Log"))
s.template = "heroproxy/log"
s.logfile = "/etc/heroproxy/heroproxy.log"
s.title = translate("HeroProxy Log")

-- 下载按钮
o = s:option(Button, "_download_heroproxy")
o.inputtitle = translate("Download")
o.inputstyle = "apply"
o.write = function()
    luci.http.redirect(luci.dispatcher.build_url("admin/services/heroproxy/download_heroproxy_log"))
end

-- Sing-box 日志
s2 = m:section(SimpleSection, translate("Sing-box Log"))
s2.template = "heroproxy/log"
s2.logfile = "/etc/heroproxy/singbox.log"
s2.title = translate("Sing-box Log")

-- 下载按钮
o = s2:option(Button, "_download_singbox")
o.inputtitle = translate("Download")
o.inputstyle = "apply"
o.write = function()
    luci.http.redirect(luci.dispatcher.build_url("admin/services/heroproxy/download_singbox_log"))
end

-- Mosdns 日志
s3 = m:section(SimpleSection, translate("Mosdns Log"))
s3.template = "heroproxy/log"
s3.logfile = "/etc/heroproxy/mosdns/mosdns.log"
s3.title = translate("Mosdns Log")

-- 下载按钮
o = s3:option(Button, "_download_mosdns")
o.inputtitle = translate("Download")
o.inputstyle = "apply"
o.write = function()
    luci.http.redirect(luci.dispatcher.build_url("admin/services/heroproxy/download_mosdns_log"))
end

return m 