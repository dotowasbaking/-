return function(fileName)
    return loadstring(syn.request({
        Url = ("https://raw.githubusercontent.com/dotowasbaking/-/main/%s.lua"):format(fileName);
        Method = "GET";
    }).Body)() -- no error handling cus if u fuck this up ur speed
end