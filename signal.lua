local signal = {}

signal.__index = signal

function signal.new()
    local self = setmetatable({}, signal)

    return self
end

function signal:Connect(func)
    self._callback = func
end

function signal:Fire(...)
    if self._callback then
        task.spawn(self._callback, ...)
    end
end

function signal:Disconnect()
    self._callback = nil
end

function signal:Destroy()
    setmetatable(self, nil)
end

return signal