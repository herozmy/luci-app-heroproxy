module("luci.controller.heroproxy", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/heroproxy") then
        return
    end
    
    entry({"admin", "services", "heroproxy"}, cbi("heroproxy"), _("HeroProxy"), 10)
    entry({"admin", "services", "heroproxy", "status"}, call("action_status"))
    entry({"admin", "services", "heroproxy", "get_heroproxy_log"}, call("get_heroproxy_log"))
    entry({"admin", "services", "heroproxy", "get_singbox_log"}, call("get_singbox_log"))
    entry({"admin", "services", "heroproxy", "download_heroproxy_log"}, call("download_heroproxy_log"))
    entry({"admin", "services", "heroproxy", "download_singbox_log"}, call("download_singbox_log"))
end

function action_status()
    local e = {}
    e.singbox_running = luci.sys.call("pgrep -f sing-box >/dev/null") == 0
    e.mosdns_running = luci.sys.call("pgrep -f mosdns >/dev/null") == 0
    luci.http.prepare_content("application/json")
    luci.http.write_json(e)
end

function get_heroproxy_log()
    local fs = require "nixio.fs"
    local logfile = "/etc/heroproxy/heroproxy.log"
    local content = fs.readfile(logfile) or ""
    luci.http.prepare_content("text/plain")
    luci.http.write(content)
end

function get_singbox_log()
    local fs = require "nixio.fs"
    local logfile = "/etc/heroproxy/singbox.log"
    local content = fs.readfile(logfile) or ""
    luci.http.prepare_content("text/plain")
    luci.http.write(content)
end

function download_heroproxy_log()
    local fs = require "nixio.fs"
    local logfile = "/etc/heroproxy/heroproxy.log"
    
    if fs.access(logfile) then
        luci.http.header('Content-Disposition', 'attachment; filename="heroproxy.log"')
        luci.http.prepare_content("text/plain")
        luci.http.write(fs.readfile(logfile) or "")
    else
        luci.http.status(404, "Log file not found")
    end
end

function download_singbox_log()
    local fs = require "nixio.fs"
    local logfile = "/etc/heroproxy/singbox.log"
    
    if fs.access(logfile) then
        luci.http.header('Content-Disposition', 'attachment; filename="singbox.log"')
        luci.http.prepare_content("text/plain")
        luci.http.write(fs.readfile(logfile) or "")
    else
        luci.http.status(404, "Log file not found")
    end
end 