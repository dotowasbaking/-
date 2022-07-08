return function(fileName)
    return loadstring(syn.request({
        Url = ("https://raw.githubusercontent.com/dotowasbaking/-/ab0a0dbbae1568d4440c9f03c630de47882b11e1/%s.lua"):format(fileName); -- HACK :SCREAM:
        Method = "GET";
    }).Body)() -- no error handling cus if u fuck this up ur speed
end