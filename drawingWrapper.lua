local defaultDrawing = Drawing

local drawingProperties = {
    Base = {
        "Visible";
        "ZIndex";
        "Transparency";
        "Color";
        "Remove";
    };
    Line = {
        "Thickness";
        "From";
        "To";
    };
    Text = {
        "Text";
        "Size";
        "Center";
        "Outline";
        "OutlineColor";
        "Position";
        "TextBounds";
        "Font";
    };
    Image = {
        "Data";
        "Size";
        "Position";
        "Rounding";
    };
    Circle = {
        "Thickness";
        "NumSides";
        "Radius";
        "Filled";
        "Position";
    };
    Square = {
        "Thickness";
        "Size";
        "Position";
        "Filled";
    };
    Quad = {
        "Thickness";
        "PointA";
        "PointB";
        "PointC";
        "PointD";
        "Filled";
    };
    Triangle = {
        "Thickness";
        "PointA";
        "PointB";
        "PointC";
        "Filled";
    };
}

local propertyDictionary = {}

local readOnlyIndexes = {
    ["__index"] = true;
    ["_objects"] = true;
    ["_properties"] = true;
}

do -- init
    for i, v in pairs(drawingProperties) do
        if i == "Base" then
            continue
        end

        local allProperties = {}

        for _, property in ipairs(drawingProperties.Base) do
            allProperties[property] = true
        end

        for _, property in ipairs(v) do
            allProperties[property] = true
        end

        propertyDictionary[i] = allProperties
    end
end

local drawingMap; drawingMap = {
    new = function(name, properties)
        local drawing = defaultDrawing.new(name)
        local drawingIndex = #drawingMap.Drawings + 1

        local dataHolder = {
            _objects = {drawing};
            _class = name;
            _properties = propertyDictionary[name];
        }

        local base = setmetatable(
            {},
            {
                __index = function(_, index)
                    if index == "Remove" or index == "Destroy" then
                        return function()
                            for _, object in ipairs(dataHolder._objects) do
                                object:Remove()
                            end

                            drawingMap.Drawings[drawingIndex] = nil
                            setmetatable(dataHolder, nil)
                        end
                    elseif dataHolder._properties[index] then
                        return drawing[index]
                    else
                        return rawget(dataHolder, index)
                    end
                end,
                __newindex = function(_, index, value)
                    if dataHolder._properties[index] then
                        drawing[index] = value
                    elseif not readOnlyIndexes[index] then
                        return rawset(dataHolder, index, value)
                    else
                        return error("attempt to modify readonly index")
                    end
                end
            }
        )

        for property, value in pairs(properties or {}) do
            drawing[property] = value
        end

        drawingMap.Drawings[drawingIndex] = base

        return base
    end;

    Font = defaultDrawing.Font;
    Drawings = {};
}

return setmetatable(drawingMap, {
    __index = function(self, index)
        return self[index] or error("invalid type")
    end,
    __newindex = function()
        error("noob...")
    end
})