module("luci.controller.heroproxy", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/heroproxy") then
        return
    end
    
    local page = entry({"admin", "services", "heroproxy"}, alias("admin", "services", "heroproxy", "basic"), _("HeroProxy"), 10)
    page.dependent = true
    
    entry({"admin", "services", "heroproxy", "basic"}, cbi("heroproxy/basic"), _("基本设置"), 10)
    entry({"admin", "services", "heroproxy", "singbox"}, cbi("heroproxy/singbox"), _("Sing-box设置"), 20)
    entry({"admin", "services", "heroproxy", "mosdns"}, cbi("heroproxy/mosdns"), _("Mosdns设置"), 30)
    entry({"admin", "services", "heroproxy", "status"}, call("action_status"))
end

function action_status()
    local sys = require "luci.sys"
    local uci = require "luci.model.uci".cursor()
    local e = {}
    
    -- 获取配置的路径
    local core_path = uci:get("heroproxy", "config", "core_path") or "/usr/bin/sing-box"
    local mosdns_path = uci:get("heroproxy", "config", "mosdns_path") or "/usr/bin/mosdns"
    
    -- 检查 sing-box 状态
    e.singbox_running = sys.call("pgrep -f '" .. core_path:gsub("'", "'\\''") .. ".*run' >/dev/null") == 0
    
    -- 检查 mosdns 状态
    e.mosdns_running = sys.call("pgrep -f '" .. mosdns_path:gsub("'", "'\\''") .. "' >/dev/null") == 0
    
    -- 返回 JSON 结果
    luci.http.prepare_content("application/json")
    luci.http.write_json(e)
end 