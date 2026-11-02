local ImageManager = {}

function ImageManager.new(Config)
    local self = {}
    self.Config = Config
    self.Files = {}

    local function ensureFolders()
        if not isfolder(Config.RootFolder) then makefolder(Config.RootFolder) end
        if not isfolder(Config.ImageFolder) then makefolder(Config.ImageFolder) end
    end

    function self:Refresh()
        ensureFolders()
        self.Files = {}
        local ok, body = pcall(function() return game:HttpGet(Config.ManifestUrl) end)
        if not ok then
            warn("[ScratchHelper] Could not read image manifest: " .. tostring(body))
            return self.Files
        end

        for line in string.gmatch(body, "[^\r\n]+") do
            local name = string.match(line, "^%s*(.-)%s*$")
            if name and name ~= "" and not string.match(name, "^#") and string.match(name, "%.png$") then
                table.insert(self.Files, name)
            end
        end
        return self.Files
    end

    function self:Download(name)
        ensureFolders()
        if not name or not string.match(name, "^[%w%._%-]+%.png$") then
            return false, "Invalid PNG filename"
        end
        local ok, data = pcall(function() return game:HttpGet(Config.BaseRaw .. name) end)
        if not ok or type(data) ~= "string" or #data == 0 then
            return false, "Image download failed"
        end
        local writeOk, writeErr = pcall(function()
            writefile(Config.ImageFolder .. "/" .. name, data)
        end)
        if not writeOk then return false, tostring(writeErr) end
        return true, Config.ImageFolder .. "/" .. name
    end

    function self:GetLocalFiles()
        ensureFolders()
        local result = {}
        local ok, paths = pcall(listfiles, Config.ImageFolder)
        if ok and type(paths) == "table" then
            for _, path in ipairs(paths) do
                if string.lower(path):match("%.png$") then table.insert(result, path) end
            end
        end
        return result
    end

    self:Refresh()
    return self
end

return ImageManager
