local httpService = game:GetService("HttpService")

local signal = {}

signal.__index = signal

function signal.new()
    local self = setmetatable({}, signal)

    self._connections = {}
    self._tempConnections = {}

    return self
end

function signal:Connect(func)
    local holder = {}
    local id = httpService:GenerateGUID()

    function holder:Disconnect()
        self._connections[id] = nil
    end

    self._connections[id] = func

    return holder
end

function signal:Once(func)
    self._tempConnections[#self._tempConnections + 1] = func
end

function signal:Wait()
    local currentThread = coroutine.running()

    self:Once(function(...)
        coroutine.resume(currentThread, ...)
    end)

    return coroutine.yield()
end

function signal:Fire(...)
    for i, v in pairs(self._tempConnections) do
        task.spawn(v, ...)

        self._tempConnections[i] = nil
    end

    for _, v in pairs(self._connections) do
        task.spawn(v, ...)
    end
end

function signal:Destroy()
    setmetatable(self, nil)
end

return signal