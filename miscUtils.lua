local fileExtension = ".frick"

local prefixes = {
    "apathy_",
    "varyex_",
    "apatvy_",
    "varyexx_",
    "appathy_",
    "busyCity_",
    "gungaging_",
    "doto_",
    "frick_"
}

local chars = {}

for i = 65, 90 do
  table.insert(chars, string.char(i))
end

for i = 1, 10 do
    table.insert(chars, tostring(i - 1))
end

local function stringRemove(str, ...)
	for _, v in pairs({...}) do
		str = str:gsub(v, "")
	end

	return str
end

local function getFile(path)
	return (isfile(path) and readfile(path)) or nil
end

local utils = {}

utils.__index = utils

function utils:getFormattedTime()
    return ("%s:%s:%s %s %s. %s, %s"):format(os.date("%I"), os.date("%M"), os.date("%S"), string.upper(os.date("%p")), os.date("%b"), os.date("%d"), os.date("%Y"))
end

function utils:loadImage(imageLink)
	if not isfolder("_fricklib") then
		makefolder("_fricklib")
		makefolder("_fricklib/cache")
	elseif not isfolder("_fricklib/cache") then
		makefolder("_fricklib/cache")
	end
	
	local formattedUrl = stringRemove(imageLink, "/", ":", ".png", ".jpg")
	local dataFile = getFile(("_fricklib/cache/%s%s"):format(formattedUrl, fileExtension))

	if dataFile then
		return dataFile
	else
		local data = syn.request({
			Url = imageLink;
			Method = "GET";
		}).Body

		task.spawn(writefile, ("_fricklib/cache/%s%s"):format(formattedUrl, fileExtension), data)
		
		return data
	end
end

function utils:getEncryptedName(labelEncrypted)
    local str = prefixes[math.random(1, #prefixes)]

    for _ = 1, 10 do
        str..= chars[math.random(1, #chars)]
    end

    return str..((labelEncrypted and " (Encrypted)") or "")
end

function utils:formatHMS(seconds)
    return ("%02i:%02i:%02i"):format(seconds / 60 ^ 2, seconds / 60 % 60, seconds % 60)
end

function utils:dictionaryLen(dictionary)
    local dictionaryLen = 0

    for _, _ in pairs(dictionary) do
        dictionaryLen += 1
    end

    return dictionaryLen
end

function utils:tableToString(Data) -- Made by ComoEsteban on v3rm :troll:
    local Table = Data.Table or Data
    local Indent = Data.Indent or 4
    local ShowKeys = true
    local LastIndent = Data.LastBracketIndent or 0
    if Data.ShowKeys ~= nil then
        ShowKeys = Data.ShowKeys
    end
    local function ConvertValue(Value)
        if type(Value) == "table" then
            return self:tableToString({
                ["Table"] = Value,
                ["Indent"] = (Indent + (Data.LastBracketIndent or Indent)),
                ["ShowKeys"] = Data.ShowKeys,
                ["LastBracketIndent"] = Indent
            })
        end
        if type(Value) == "string" then
            return '"'..Value..'"'
        end
        if typeof(Value) == "Instance" then
            Origin = "game."
            if not Value:FindFirstAncestorOfClass("game") then
                Origin = ""
            end
            return Origin..Value:GetFullName()
        end
        if typeof(Value) == "CFrame" then
            return "CFrame.new("..tostring(Value)..")"
        end  
        if typeof(Value) == "Vector3" then
            return "Vector3.new("..tostring(Value)..")"
        end    
        if typeof(Value) == "Vector2" then
             return "Vector2.new("..tostring(Value)..")"
        end 
        if typeof(Value) == "Color3" then
            return "Color3.new("..tostring(Value)..")"
        end
        if typeof(Value) == "BrickColor" then
            return "BrickColor.new("..tostring(Value)..")"
        end
        return tostring(Value)
    end
    local Indent = Data.Indent or 4
    local Result = "{\n"
    for Key,Value in pairs(Table) do
        KeyString = "[\""..tostring(Key).."\"] = "
        if type(Key) == "number" then
            KeyString = "["..tostring(Key).."] = "
        end
        if not ShowKeys then
            KeyString = ""
        end
        Result = Result..string.rep(" ",Indent)..KeyString..ConvertValue(Value)..",\n"
    end
    Result = Result..string.rep(" ",LastIndent).."}"
    return Result
end

return utils