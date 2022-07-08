local maid = 

local characterManager = {}

characterManager.__index = characterManager

function characterManager.new()
    local self = setmetatable({}, characterManager)

    self._cache = {}

    return self
end

return characterManager