local uRequire = loadstring(game:HttpGet("https://raw.githubusercontent.com/dotowasbaking/-/main/utilRequire.lua", true))()
local maid = uRequire("maid")
local signal = uRequire("signal")

local players = game:GetService("Players")

local characterManager = {}

characterManager.__index = characterManager

function characterManager.new()
    local self = setmetatable({}, characterManager)

    self._maid = maid.new()
    self._players = {}
    self._characters = {}
    self._aliveCharacters = {}

    self._playerMaids = {}
    self._characterMaids = {}

    self._signals = {
        "PlayerAdded";
        "CharacterAdded";
        "PlayerRemoving";
        "CharacterRemoving";
        "CharacterDied";
    }

    for _, v in ipairs(self._signals) do
        self[v] = self._maid:AddTask(signal.new())
    end

    self._maid:AddTask(players.PlayerAdded:Connect(function(newPlayer)
        self:_addPlayer(newPlayer)
    end))

    self._maid:AddTask(players.PlayerRemoving:Connect(function(player)
        self:_removePlayer(player)
    end))

    for _, player in ipairs(players:GetPlayers()) do
        self:_addPlayer(player)
    end

    return self
end

function characterManager:_addPlayer(player)
    self._players[#self._players + 1] = player
    local playerMaid = self._maid:AddTask(maid.new())
    self._playerMaids[player] = playerMaid

    playerMaid:AddTask(player.CharacterAdded:Connect(function(character)
        self:_addCharacter(character)
    end))

    playerMaid:AddTask(player.CharacterRemoving:Connect(function(character)
        self:_removeCharacter(character)
    end))

    if player.Character then
        self:_addCharacter(player.Character)
    end

    self.PlayerAdded:Fire(player)
end

function characterManager:_removePlayer(player)
    self.PlayerRemoving:Fire(player)
    self:_tableRemove(self._players, player)
    self:_tableRemove(self._playerMaids[player]):Destroy()
end

function characterManager:_addCharacter(character)
    self._characters[#self._characters + 1] = character
    local characterMaid = self._maid:AddTask(maid.new())

    self._characterMaids[character] = characterMaid
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    local function addHumanoid(newHumanoid)
        if newHumanoid.Health <= 0 then
            characterMaid:Destroy()
            return
        end

        self._aliveCharacters[#self._aliveCharacters + 1] = character

        characterMaid:AddTask(newHumanoid.Died:Connect(function()
            self:_tableRemove(self._aliveCharacters, character)
            self.CharacterDied:Fire(character)
            characterMaid:Destroy()
        end))
    end

    if humanoid then
        addHumanoid(humanoid)
    else
        characterMaid:AddTask(character.ChildAdded:Connect(function(child)
            if child:IsA("Humanoid") then
                addHumanoid(child)
            end
        end))
    end

    self.CharacterAdded:Fire(character)
end

function characterManager:_removeCharacter(character)
    self.CharacterRemoving:Fire(character)
    local characterIndex = table.find(self._aliveCharacters, character)

    if characterIndex then
        table.remove(self._aliveCharacters, characterIndex)
    end

    self:_tableRemove(self._characters, character)
    self:_tableRemove(self._characterMaids[character]):Destroy()
end

function characterManager:_tableRemove(tbl, obj)
    table.remove(tbl, table.find(tbl, obj)) -- yes i made a func so i didnt have to type 4 more characters (workflow so gofly)[rella]

    return obj
end

function characterManager:GetCharacters()
    return self._characters
end

function characterManager:GetAliveCharacters()
    return self._aliveCharacters
end

function characterManager:Destroy()

end

return characterManager