local player = {}

player.__index = player

function player.new(newPlayer)
    local self = setmetatable({}, player)

    self._player = newPlayer

    return self
end

function player:Destroy()
    setmetatable(self, nil)
end

return player