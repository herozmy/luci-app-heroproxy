local fs = require "nixio.fs"

f = SimpleForm("logview")
f.reset = false
f.submit = false

t = f:field(TextValue, "conf")
t.rmempty = true
t.rows = 20
function t.cfgvalue()
    local logs = luci.util.execi("logread | grep sing-box")
    local value = ""
    for line in logs do
        value = line .. "\n" .. value
    end
    return value
end

return f 