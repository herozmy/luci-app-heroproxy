module("luci.controller.heroproxy", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/heroproxy") then
        return
    end
    
    local page = entry({"admin", "services", "heroproxy"}, alias("admin", "services", "heroproxy", "basic"), _("HeroProxy"), 10)
    page.dependent = true
    
    entry({"admin", "services", "heroproxy", "basic"}, cbi("heroproxy/basic"), _("基本设置"), 10)
    entry({"admin", "services", "heroproxy", "cores"}, cbi("heroproxy/cores"), _("核心管理"), 15)
    entry({"admin", "services", "heroproxy", "singbox"}, cbi("heroproxy/singbox"), _("Sing-box设置"), 20)
    entry({"admin", "services", "heroproxy", "mosdns"}, cbi("heroproxy/mosdns"), _("Mosdns设置"), 30)
    entry({"admin", "services", "heroproxy", "status"}, call("action_status"))
    entry({"admin", "services", "heroproxy", "check_core"}, call("action_check_core"))
    entry({"admin", "services", "heroproxy", "download_core"}, call("action_download_core"))
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

function action_check_core()
    local sys = require "luci.sys"
    local nixio = require "nixio"
    local e = {}
    
    -- 检查各种 sing-box 核心
    local cores = {
        singbox = "/etc/heroproxy/core/sing-box/sing-box",
        ["singbox-p"] = "/etc/heroproxy/core/sing-box-p/sing-box",
        ["singbox-x"] = "/etc/heroproxy/core/sing-box-x/sing-box"
    }
    
    for type, path in pairs(cores) do
        if nixio.fs.access(path, "x") then
            e[type .. "_exists"] = true
            e[type .. "_version"] = sys.exec(path .. " version 2>/dev/null"):match("sing%-box version ([%d%.]+)")
        else
            e[type .. "_exists"] = false
        end
    end
    
    -- 检查 mosdns
    local mosdns_path = "/usr/bin/mosdns"
    if nixio.fs.access(mosdns_path, "x") then
        e.mosdns_exists = true
        local version = sys.exec(mosdns_path .. " version 2>/dev/null")
        e.mosdns_version = version:match("v([%d%.]+)") or version:match("version%s+([%d%.]+)") or version:match("([%d%.]+)")
    else
        e.mosdns_exists = false
    end
    
    luci.http.prepare_content("application/json")
    luci.http.write_json(e)
end

function action_download_core()
    local core_type = luci.http.formvalue("type")
    local download_url = luci.http.formvalue("url")
    local target_path = luci.http.formvalue("path")
    local sys = require "luci.sys"
    local nixio = require "nixio"
    local result = {}
    
    -- 检查参数
    if not core_type or not download_url or not target_path then
        result.success = false
        result.error = "Missing parameters"
        luci.http.prepare_content("application/json")
        luci.http.write_json(result)
        return
    end
    
    -- 创建目录
    local core_dir = target_path:match("(.+)/[^/]+$")
    if sys.call("mkdir -p " .. core_dir) ~= 0 then
        result.success = false
        result.error = "Failed to create directory"
        luci.http.prepare_content("application/json")
        luci.http.write_json(result)
        return
    end
    
    if core_type:match("^singbox") then
        -- 清理旧文件
        sys.call(string.format("cd '%s' && rm -f sing-box.tar.gz sing-box", core_dir))
        
        -- 下载文件
        local download_cmd = string.format(
            "cd '%s' && wget --no-check-certificate '%s' -O sing-box.tar.gz",
            core_dir, download_url
        )
        
        local ret = sys.call(download_cmd)
        if ret ~= 0 then
            result.success = false
            result.error = "Download failed"
            luci.http.prepare_content("application/json")
            luci.http.write_json(result)
            return
        end
        
        -- 解压文件
        ret = sys.call(string.format(
            "cd '%s' && tar -xzf sing-box.tar.gz && mv sing-box*/sing-box sing-box && chmod +x sing-box",
            core_dir
        ))
        
        if ret ~= 0 then
            result.success = false
            result.error = "Extract failed"
            luci.http.prepare_content("application/json")
            luci.http.write_json(result)
            return
        end
        
        -- 清理文件
        sys.call(string.format(
            "cd '%s' && rm -rf sing-box.tar.gz sing-box-*",
            core_dir
        ))
        
        -- 最终检查
        if nixio.fs.access(target_path, "x") then
            result.success = true
        else
            result.success = false
            result.error = "Final check failed: Binary not found or not executable"
        end
        
    elseif core_type == "mosdns" then
        -- 下载并安装 mosdns
        result.success = (sys.call("wget -O /tmp/mosdns.ipk '" .. download_url .. "' && opkg install /tmp/mosdns.ipk && rm /tmp/mosdns.ipk") == 0)
    end
    
    luci.http.prepare_content("application/json")
    luci.http.write_json(result)
end 