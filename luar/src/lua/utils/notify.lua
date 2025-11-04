local exec_async = astal.exec_async

---@class NotifyArgs
---@field summary string
---@field body? string
---@field icon? string Specifies an icon filename or stock icon to display.
---@field appname? string Specifies the app name for the notification.
---@field actions? table<string, function> Specifies the actions to display to the user.
---@field urgency? "LOW"|"NORMAL"|"CRITICAL" Specifies the urgency level (low, normal, critical).
---@field timeout? number The duration, in milliseconds, for the notification to appear on screen.
---@field category? string Specifies the notification category.
---@field hints? string[] Specifies basic extra data to pass. Valid types are BOOLEAN, INT, DOUBLE, STRING, BYTE and VARIANT.

---@param summary string | NotifyArgs
---@param body? string
---@param icon? string
---@async
return function(summary, body, icon)
    ---@type NotifyArgs
    local args

    if type(summary) == 'table' then
        args = summary
    else
        args = { summary = tostring(summary), body = body, icon = icon }
    end

    local cmd = { 'notify-send' }

    -- table.insert(cmd, '--app-name=' .. (args.appname or 'no'))

    if args.appname then table.insert(cmd, '--app-name=' .. args.appname) end
    if args.icon then table.insert(cmd, '--icon=' .. args.icon) end
    if args.urgency then table.insert(cmd, '--urgency=' .. args.urgency:lower()) end
    if args.timeout then table.insert(cmd, '--expire-time=' .. tostring(args.timeout)) end
    if args.category then table.insert(cmd, '--category=' .. args.category) end
    if args.hints then
        for _, hint in ipairs(args.hints) do
            table.insert(cmd, '--hint=' .. hint)
        end
    end

    if args.actions and type(args.actions) == 'table' then
        for label in pairs(args.actions) do
            table.insert(cmd, '--action=' .. label .. '=' .. label)
        end
    end

    if args.body then
        table.push(cmd, args.summary, args.body)
    else
        table.insert(cmd, args.summary)
    end

    exec_async(cmd, function(stdout, stderr)
        if stderr ~= nil then return end
        if args.actions and args.actions[stdout] then args.actions[stdout]() end
    end)
end
