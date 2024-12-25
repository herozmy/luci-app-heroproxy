local m = Map("heroproxy", translate("HeroProxy"), translate("基于 sing-box 的代理工具"))

-- 白名单设置
local s = m:section(TypedSection, "heroproxy", translate("白名单"))
s.anonymous = true
s.addremove = false

local white = s:option(TextValue, "white_list", translate("直连规则"))
white.template = "cbi/tvalue"
white.rows = 20
white.wrap = "off"
white.rmempty = true
white.optional = false

function white.cfgvalue(self, section)
    return nixio.fs.readfile("/etc/heroproxy/mosdns/rule/whitelist.txt") or " "
end

function white.write(self, section, value)
    if value then
        value = value:gsub("\r\n?", "\n")
        value = value:gsub("^%s+", ""):gsub("%s+$", "")
        if value == "" then value = " " end
        nixio.fs.writefile("/etc/heroproxy/mosdns/rule/whitelist.txt", value)
        m.uci:set("heroproxy", section, "white_list", value)
        luci.sys.call("/etc/init.d/heroproxy restart_mosdns >/dev/null 2>&1")
    end
end

-- 灰名单设置
local s2 = m:section(TypedSection, "heroproxy", translate("灰名单"))
s2.anonymous = true
s2.addremove = false

local grey = s2:option(TextValue, "grey_list", translate("代理规则"))
grey.template = "cbi/tvalue"
grey.rows = 20
grey.wrap = "off"
grey.rmempty = true
grey.optional = false

function grey.cfgvalue(self, section)
    return nixio.fs.readfile("/etc/heroproxy/mosdns/rule/greylist.txt") or " "
end

function grey.write(self, section, value)
    if value then
        value = value:gsub("\r\n?", "\n")
        value = value:gsub("^%s+", ""):gsub("%s+$", "")
        if value == "" then value = " " end
        nixio.fs.writefile("/etc/heroproxy/mosdns/rule/greylist.txt", value)
        m.uci:set("heroproxy", section, "grey_list", value)
        luci.sys.call("/etc/init.d/heroproxy restart_mosdns >/dev/null 2>&1")
    end
end

return m 