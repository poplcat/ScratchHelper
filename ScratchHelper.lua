-- ScratchHelper bootstrap
local OWNER = "poplcat"
local REPO = "ScratchHelper"
local BRANCH = "main"
local BASE = "https://raw.githubusercontent.com/" .. OWNER .. "/" .. REPO .. "/" .. BRANCH .. "/ScratchHelper/"

local function fetchModule(path)
    local source = game:HttpGet(BASE .. path)
    local chunk, err = loadstring(source)
    assert(chunk, "ScratchHelper: compile failed for " .. path .. ": " .. tostring(err))
    return chunk()
end

local Config = fetchModule("src/Config.lua")
local ImageManager = fetchModule("src/ImageManager.lua")
local Overlay = fetchModule("src/Overlay.lua")
local UI = fetchModule("src/UI.lua")

local images = ImageManager.new(Config)
local overlay = Overlay.new(Config, images)
UI.start(Config, images, overlay)

print("[ScratchHelper] Loaded. Add PNG names to Images/manifest.txt and upload matching files.")
