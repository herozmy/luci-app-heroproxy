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
    entry({"admin", "services", "heroproxy", "status"}, call("status"))
    entry({"admin", "services", "heroproxy", "restart_singbox"}, call("restart_singbox"))
    entry({"admin", "services", "heroproxy", "restart_mosdns"}, call("restart_mosdns"))
    entry({"admin", "services", "heroproxy", "check_core"}, call("action_check_core"))
    entry({"admin", "services", "heroproxy", "download_core"}, call("download_core"))
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
            -- 获取版本信息，只取第一行
            local version = sys.exec(path .. " version 2>/dev/null | head -n1")
            -- 移除末尾的换行符
            version = version:gsub("[\r\n]+$", "")
            -- 只保留 "sing-box version" 后面的部分
            version = version:gsub("^sing%-box version ", "")
            e[type .. "_version"] = version ~= "" and version or "未知版本"
        else
            e[type .. "_exists"] = false
        end
    end
    
    -- 检查 mosdns
    local mosdns_path = "/etc/heroproxy/core/mosdns/mosdns"
    if nixio.fs.access(mosdns_path, "x") then
        e.mosdns_exists = true
        local version = sys.exec(mosdns_path .. " version 2>/dev/null")
        version = version:gsub("[\r\n]+$", "")
        e.mosdns_version = version ~= "" and version or "未知版本"
    else
        e.mosdns_exists = false
    end
    
    luci.http.prepare_content("application/json")
    luci.http.write_json(e)
end

function download_core()
    local http = require "luci.http"
    local sys = require "luci.sys"
    local nixio = require "nixio"
    local result = { success = false }
    
    local core_type = http.formvalue("type")
    local download_url = http.formvalue("url")
    local target_path = http.formvalue("path")
    
    if core_type == "mosdns" then
        local install_dir = "/etc/heroproxy/core/mosdns"
        local zip_file = install_dir .. "/mosdns.zip"
        
        -- 创建安装目录
        if sys.call(string.format("mkdir -p '%s'", install_dir)) == 0 then
            -- 下载文件
            if sys.call(string.format("cd '%s' && wget -O '%s' '%s'", 
                install_dir, zip_file, download_url)) == 0 then
                -- 解压并安装
                if sys.call(string.format(
                    "cd '%s' && unzip -o '%s' && mv mosdns-linux-amd64 mosdns && chmod +x mosdns",
                    install_dir, zip_file)) ~= 0 then
                    result.error = "Installation failed. Please install unzip package first: opkg update && opkg install unzip"
                else
                    -- 检查文件
                    if nixio.fs.access(install_dir .. "/mosdns", "x") then
                        result.success = true
                    else
                        result.error = "Binary verification failed"
                    end
                end
                
                -- 清理临时文件
                sys.call(string.format("rm -f '%s'", zip_file))
            else
                result.error = "Download failed"
            end
        else
            result.error = "Failed to create directory"
        end
    else
        local core_dir = target_path:match("(.+)/[^/]+$")
        if sys.call("mkdir -p " .. core_dir) == 0 then
            if core_type:match("^singbox") then
                -- 清理旧文件
                sys.call(string.format("cd '%s' && rm -f sing-box.tar.gz sing-box", core_dir))
                
                -- 下载文件
                if sys.call(string.format(
                    "cd '%s' && wget --no-check-certificate '%s' -O sing-box.tar.gz",
                    core_dir, download_url)) == 0 then
                    
                    -- 解压文件
                    if core_type == "singbox-x" then
                        -- X核心的特殊处理
                        if sys.call(string.format(
                            "cd '%s' && tar -xzf sing-box.tar.gz && mv sing-box_linux_amd64 sing-box && chmod +x sing-box",
                            core_dir)) == 0 then
                            
                            -- 清理文件
                            sys.call(string.format(
                                "cd '%s' && rm -f sing-box.tar.gz",
                                core_dir))
                            
                            -- 最终检查
                            if nixio.fs.access(target_path, "x") then
                                result.success = true
                            else
                                result.error = "Final check failed: Binary not found or not executable"
                            end
                        else
                            result.error = "Extract failed"
                        end
                    else
                        -- 其他心的原有处理
                        if sys.call(string.format(
                            "cd '%s' && tar -xzf sing-box.tar.gz && mv sing-box*/sing-box sing-box && chmod +x sing-box",
                            core_dir)) ~= 0 then
                            result.error = "Extract failed. Please install tar package first: opkg update && opkg install tar"
                        else
                            -- 清理文件
                            sys.call(string.format(
                                "cd '%s' && rm -rf sing-box.tar.gz sing-box-*",
                                core_dir))
                            
                            -- 最终检查
                            if nixio.fs.access(target_path, "x") then
                                result.success = true
                            else
                                result.error = "Final check failed: Binary not found or not executable"
                            end
                        end
                    end
                else
                    result.error = "Download failed"
                end
            end
        else
            result.error = "Failed to create directory"
        end
    end
    
    http.prepare_content("application/json")
    http.write_json(result)
end

function get_core_status()
    local e = {}
    local core_path = uci:get("heroproxy", "config", "core_path") or "/etc/heroproxy/core/sing-box/sing-box"
    
    if nixio.fs.access(core_path, "x") then
        local version = luci.sys.exec(core_path .. " version 2>/dev/null")
        version = version:gsub("[\r\n]+$", "")
        if version ~= "" then
            version = version:gsub("^sing%-box version ", "")
        else
            version = "未知版本"
        end
        
        e.singbox_status = {
            installed = true,
            version = version
        }
    end
    
    luci.http.prepare_content("application/json")
    luci.http.write_json(e)
end

function status()
    local sys  = require "luci.sys"
    local uci  = require "luci.model.uci".cursor()
    local nixio = require "nixio"
    local data = {}

    -- 检查服务是否启用
    data.enabled = (uci:get("heroproxy", "config", "enabled") == "1")
    
    -- 获取核心路径
    local core_path = uci:get("heroproxy", "config", "core_path") or "/etc/heroproxy/core/sing-box/sing-box"
    local mosdns_path = uci:get("heroproxy", "config", "mosdns_path") or "/etc/heroproxy/core/mosdns/mosdns"
    
    -- 检查进程是否运行
    data.singbox_running = sys.call("pgrep -f '" .. core_path:gsub("'", "'\\''") .. ".*run' >/dev/null") == 0
    data.mosdns_running = sys.call("pgrep -f '" .. mosdns_path:gsub("'", "'\\''") .. ".*start' >/dev/null") == 0
    
    -- 检查 pid 文件
    data.singbox_pid = nixio.fs.access("/var/run/heroproxy.singbox.pid")
    data.mosdns_pid = nixio.fs.access("/var/run/heroproxy.mosdns.pid")

    luci.http.prepare_content("application/json")
    luci.http.write_json(data)
end

function restart_singbox()
    luci.sys.call("/etc/init.d/heroproxy restart_singbox >/dev/null 2>&1")
    luci.http.prepare_content("application/json")
    luci.http.write_json({ code = 0 })
end

function restart_mosdns()
    luci.sys.call("/etc/init.d/heroproxy restart_mosdns >/dev/null 2>&1")
    luci.http.prepare_content("application/json")
    luci.http.write_json({ code = 0 })
end 