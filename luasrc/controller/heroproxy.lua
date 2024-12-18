module("luci.controller.heroproxy", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/heroproxy") then
        return
    end
    
    entry({"admin", "services", "heroproxy"}, cbi("heroproxy"), _("HeroProxy"), 10)
    entry({"admin", "services", "heroproxy", "status"}, call("action_status"))
end

function action_status()
    local sys = require "luci.sys"
    local uci = require "luci.model.uci".cursor()
    local e = {}
    
    -- 获取配置的路径
    local core_path = uci:get("heroproxy", "config", "core_path") or "/usr/bin/sing-box"
    
    -- 检查 sing-box 状态
    e.singbox_running = sys.call("pgrep -f '" .. core_path:gsub("'", "'\\''") .. ".*run' >/dev/null") == 0
    
    -- 检查 mosdns 状态
    e.mosdns_running = sys.call("pgrep mosdns >/dev/null") == 0
    
    -- 返回 JSON 结果
    luci.http.prepare_content("application/json")
    luci.http.write_json(e)
end 