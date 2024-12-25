local fs = require "nixio.fs"

local f = SimpleForm("logview")
f.reset = false
f.submit = false
f.handle = nil
f.title = translate("Mosdns 日志")
f.description = translate("日志实时刷新") .. [[<span id="countdown" style="margin-left: 10px;"></span>]]

-- 添加按钮区域
local s = f:section(SimpleSection)
s.anonymous = true

-- 创建按钮容器
local buttons = s:option(DummyValue, "_buttons")
buttons.rawhtml = true
buttons.default = [[
    <div style="display: flex; gap: 1em; margin: 0.5em 0;">
        <input type="button" class="btn cbi-button cbi-button-reload" value="]] .. translate("刷新") .. [[" onclick="location.href=']] .. 
            luci.dispatcher.build_url("admin/services/heroproxy/mosdns/log") .. [['" />
        <input type="button" class="btn cbi-button cbi-button-reset" value="]] .. translate("清空") .. [[" onclick="if(confirm(']] .. 
            translate("确认要清空日志吗？") .. [[')){ (new XHR()).get(']] .. 
            luci.dispatcher.build_url("admin/services/heroproxy/mosdns/clear_log") .. 
            [[',null,function(x){location.reload()}); }" />
    </div>
]]

-- 日志显示区域
local o = f:field(TextValue, "logdata")
o.readonly = true
o.rows = 30
o.wrap = "off"

function o.cfgvalue()
    local logfile = "/etc/heroproxy/mosdns.log"
    if fs.access(logfile) then
        local logs = fs.readfile(logfile) or ""
        return logs
    end
    return ""
end

-- 添加自动刷新脚本
o.footer = [[
<script type="text/javascript" src="<%=resource%>/xhr.js"></script>
<script type="text/javascript">
var countdownEl = document.getElementById('countdown');
var countdown = 5;  // 5秒自动刷新

function updateCountdown() {
    if (countdownEl) {
        countdownEl.innerHTML = '(' + countdown + ' 秒后刷新)';
    }
    if (countdown <= 0) {
        window.location.reload();
    } else {
        countdown--;
        setTimeout(updateCountdown, 1000);
    }
}

if (countdownEl) {
    updateCountdown();
}

// 自动滚动到底部
var textarea = document.querySelector('textarea');
if (textarea) {
    textarea.scrollTop = textarea.scrollHeight;
}
</script>
]]

return f 