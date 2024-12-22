local m = Map("heroproxy", translate("HeroProxy"), translate("基于 sing-box 的代理工具"))

-- 基本设置部分
local s = m:section(TypedSection, "heroproxy", translate("基本设置"))
s.anonymous = true

-- 启用开关
local o = s:option(Flag, "enabled", translate("启用"))
o.rmempty = false

-- 显示当前使用的核心信息
local s_cores = m:section(TypedSection, "heroproxy", translate("当前核心"))
s_cores.anonymous = true

-- 显示 sing-box 核心信息
local o_singbox = s_cores:option(DummyValue, "core_path", translate("Sing-box 核心"))
o_singbox.rawhtml = true
o_singbox.cfgvalue = function(self, section)
    local core_path = m:get(section, "core_path") or "/etc/heroproxy/core/sing-box/sing-box"
    local core_type = "官方核心"
    if core_path:match("sing%-box%-p") then
        core_type = "P核心"
    elseif core_path:match("sing%-box%-x") then
        core_type = "X核心"
    end
    
    -- 检查核心是否存在
    if nixio.fs.access(core_path, "x") then
        -- 获取完整版本信息（不使用 head 命令，获取全部输出）
        local version = luci.sys.exec(core_path .. " version 2>/dev/null")
        -- 移除末尾的换行符
        version = version:gsub("[\r\n]+$", "")
        -- 如果获取失败则显示未知版本
        if version == "" then
            version = "未知版本"
        else
            -- 保留完整输出，不做任何过滤
            version = version:gsub("^sing%-box version ", "")
        end
        
        return core_path .. " (" .. core_type .. " - " .. version .. ")"
    else
        return '<span style="color: red">' .. translate("未安装") .. '</span>' .. 
               ' <a href="' .. 
               luci.dispatcher.build_url("admin/services/heroproxy/cores") .. 
               '" class="btn cbi-button cbi-button-apply" style="margin-left: 10px">' .. 
               translate("前往安装") .. 
               '</a>'
    end
end

-- 显示 mosdns 核心信息
local o_mosdns = s_cores:option(DummyValue, "mosdns_path", translate("Mosdns 核心"))
o_mosdns.rawhtml = true
o_mosdns.cfgvalue = function(self, section)
    local mosdns_path = m:get(section, "mosdns_path") or "/etc/heroproxy/core/mosdns/mosdns"
    
    -- 检查核心是否存在
    if nixio.fs.access(mosdns_path, "x") then
        -- 获取完整版本信息
        local version = luci.sys.exec(mosdns_path .. " version 2>/dev/null")
        -- 移除末尾的换行符
        version = version:gsub("[\r\n]+$", "")
        -- 如果获取失败则显示未知版本
        if version == "" then
            version = "未知版本"
        end
        
        return mosdns_path .. " (" .. version .. ")"
    else
        return '<span style="color: red">' .. translate("未安装") .. '</span>' .. 
               ' <a href="' .. 
               luci.dispatcher.build_url("admin/services/heroproxy/cores") .. 
               '" class="btn cbi-button cbi-button-apply" style="margin-left: 10px">' .. 
               translate("前往安装") .. 
               '</a>'
    end
end

-- 添加 UI 按钮
local s_ui = m:section(TypedSection, "heroproxy", translate("Web 界面"))
s_ui.anonymous = true

-- 获取当前 IP
local current_ip = luci.sys.exec("uci -q get network.lan.ipaddr") or "192.168.1.1"
current_ip = current_ip:gsub("\n", "")

o = s_ui:option(Button, "_openui", translate("打开 UI"))
o.inputtitle = translate("打开")
o.inputstyle = "apply"
o.write = function()
    luci.http.redirect("http://" .. current_ip .. ":9090")
end

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

-- 添加核心切换按钮
o = s_cores:option(Button, "_switch_official", translate("切换到官方核心"))
o.inputstyle = "apply"
o.write = function()
    local uci = require "luci.model.uci".cursor()
    uci:set("heroproxy", "config", "core_path", "/etc/heroproxy/core/sing-box/sing-box")
    uci:set("heroproxy", "config", "config_path", "/etc/heroproxy/config.json")
    uci:commit("heroproxy")
    luci.sys.call("/etc/init.d/heroproxy restart >/dev/null 2>&1")
    luci.http.redirect(luci.dispatcher.build_url("admin/services/heroproxy/basic"))
end

o = s_cores:option(Button, "_switch_p", translate("切换到P核心"))
o.inputstyle = "apply"
o.write = function()
    local uci = require "luci.model.uci".cursor()
    uci:set("heroproxy", "config", "core_path", "/etc/heroproxy/core/sing-box-p/sing-box")
    uci:set("heroproxy", "config", "config_path", "/etc/heroproxy/config-p.json")
    uci:commit("heroproxy")
    luci.sys.call("/etc/init.d/heroproxy restart >/dev/null 2>&1")
    luci.http.redirect(luci.dispatcher.build_url("admin/services/heroproxy/basic"))
end

o = s_cores:option(Button, "_switch_x", translate("切换到X核心"))
o.inputstyle = "apply"
o.write = function()
    local uci = require "luci.model.uci".cursor()
    uci:set("heroproxy", "config", "core_path", "/etc/heroproxy/core/sing-box-x/sing-box")
    uci:set("heroproxy", "config", "config_path", "/etc/heroproxy/config-x.json")
    uci:commit("heroproxy")
    luci.sys.call("/etc/init.d/heroproxy restart >/dev/null 2>&1")
    luci.http.redirect(luci.dispatcher.build_url("admin/services/heroproxy/basic"))
end

return m 