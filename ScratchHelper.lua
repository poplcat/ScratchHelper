
-- CarSketch v5
-- Rayfield Gen2 + Image Overlay

local Rayfield = loadstring(game:HttpGet(
    "https://sirius.menu/gen2"
))()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

local ROOT = "CarSketch"
local IMAGES = ROOT .. "/Images"

local function has(name)
    return type(getgenv and getgenv()[name] or _G[name]) == "function"
end

local function safe(fn, ...)
    local ok, result = pcall(fn, ...)
    if not ok then
        warn("[CarSketch] " .. tostring(result))
    end
    return ok, result
end

-- File system
if not isfolder(ROOT) then makefolder(ROOT) end
if not isfolder(IMAGES) then makefolder(IMAGES) end

local function scanImages()
    local files = {}

    if not has("listfiles") then
        return files
    end

    local ok, result = safe(listfiles, IMAGES)
    if not ok or type(result) ~= "table" then
        return files
    end

    for _, path in ipairs(result) do
        if string.lower(path):match("%.png$") then
            table.insert(files, path)
        end
    end

    table.sort(files)
    return files
end

local function asset(path)
    local fn = getcustomasset or getsynasset
    if not fn then
        return nil, "Asset loader unavailable"
    end

    local ok, result = pcall(fn, path)
    if not ok then
        return nil, tostring(result)
    end

    return result
end

-- Overlay
local GuiParent = (gethui and gethui()) or game:GetService("CoreGui")

local Old = GuiParent:FindFirstChild("CarSketchOverlay")
if Old then Old:Destroy() end

local Screen = Instance.new("ScreenGui")
Screen.Name = "CarSketchOverlay"
Screen.ResetOnSpawn = false
Screen.IgnoreGuiInset = true
Screen.DisplayOrder = 999
Screen.Parent = GuiParent

local Image = Instance.new("ImageLabel")
Image.Name = "ReferenceImage"
Image.BackgroundTransparency = 1
Image.AnchorPoint = Vector2.new(0.5, 0.5)
Image.Position = UDim2.fromScale(0.5, 0.5)
Image.Size = UDim2.fromOffset(300, 300)
Image.ScaleType = Enum.ScaleType.Fit
Image.ImageTransparency = 0
Image.Visible = false
Image.Active = true
Image.Parent = Screen

-- State
local State = {
    visible = false,
    locked = false,
    scale = 100,
    transparency = 0,
    rotation = 0,
    selected = nil,
}

local function updateImage()
    Image.Visible = State.visible
    Image.Size = UDim2.fromOffset(
        300 * State.scale / 100,
        300 * State.scale / 100
    )
    Image.ImageTransparency = State.transparency / 100
    Image.Rotation = State.rotation
end

local function loadImage(path)
    if not path or path == "" then return end

    local imageId, err = asset(path)
    if not imageId then
        warn("[CarSketch] " .. tostring(err))
        return
    end

    Image.Image = imageId
    State.selected = path
    State.visible = true
    updateImage()

    print("[CarSketch] Loaded:", path)
end

-- Mobile + mouse dragging
local dragging = false
local dragInput = nil
local dragStart = nil
local startPosition = nil

Image.InputBegan:Connect(function(input)
    if State.locked then return end

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragInput = input
        dragStart = input.Position
        startPosition = Image.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging or State.locked then return end

    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then

        if dragInput and dragInput.UserInputType == Enum.UserInputType.Touch
        and input ~= dragInput then
            return
        end

        local delta = input.Position - dragStart

        Image.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input == dragInput
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
        dragInput = nil
    end
end)

-- Window
local Window = Rayfield:CreateWindow({
    name = "CarSketch",
    subtitle = "Image Overlay v5",
    theme = "cobalt",
    sidebarLayout = true,
    showName = "CarSketch",
    configuration = {
        autoSave = true,
        autoLoad = true,
        fileName = "CarSketch",
        customFolder = "CarSketch",
    },
})

-- Tabs
local OverlayTab = Window:CreateTab({
    name = "Overlay",
    icon = "image",
})

local FilesTab = Window:CreateTab({
    name = "File Manager",
    icon = "folder",
})

local SettingsTab = Window:CreateTab({
    name = "Settings",
    icon = "settings",
})

-- File Manager
local ImageList = scanImages()
local SelectedImage = nil

local Dropdown = FilesTab:CreateDropdown({
    name = "Select PNG",
    options = ImageList,
    value = {},
    placeholder = "Choose an image",
    callback = function(value)
        SelectedImage = value
    end,
})

FilesTab:CreateButton({
    name = "Refresh image list",
    callback = function()
        ImageList = scanImages()
        Dropdown:Refresh(ImageList)
        print("[CarSketch] Found " .. #ImageList .. " PNG files")
    end,
})

FilesTab:CreateButton({
    name = "Load selected image",
    callback = function()
        if not SelectedImage then
            Window:Notify({
                title = "CarSketch",
                content = "Select a PNG first",
            })
            return
        end

        loadImage(SelectedImage)
    end,
})

-- Overlay controls
OverlayTab:CreateToggle({
    name = "Show Overlay",
    value = false,
    callback = function(value)
        State.visible = value
        updateImage()
    end,
})

OverlayTab:CreateToggle({
    name = "Lock Position",
    value = false,
    callback = function(value)
        State.locked = value
    end,
})

OverlayTab:CreateSlider({
    name = "Scale",
    range = {10, 300},
    value = 100,
    callback = function(value)
        State.scale = value
        updateImage()
    end,
})

OverlayTab:CreateSlider({
    name = "Transparency",
    range = {0, 100},
    value = 0,
    callback = function(value)
        State.transparency = value
        updateImage()
    end,
})

OverlayTab:CreateSlider({
    name = "Rotation",
    range = {-180, 180},
    value = 0,
    callback = function(value)
        State.rotation = value
        updateImage()
    end,
})

OverlayTab:CreateButton({
    name = "Reset position",
    callback = function()
        Image.Position = UDim2.fromScale(0.5, 0.5)
        Image.Size = UDim2.fromOffset(300, 300)
        State.scale = 100
        State.rotation = 0
        State.transparency = 0
        updateImage()
    end,
})

OverlayTab:CreateButton({
    name = "Close Overlay",
    callback = function()
        State.visible = false
        updateImage()
    end,
})

-- Settings
SettingsTab:CreateButton({
    name = "Save settings",
    callback = function()
        Window:Save()
        Window:Notify({
            title = "CarSketch",
            content = "Configuration saved",
        })
    end,
})

SettingsTab:CreateButton({
    name = "Load settings",
    callback = function()
        Window:Load()
    end,
})

SettingsTab:CreateButton({
    name = "Unload CarSketch",
    callback = function()
        Screen:Destroy()
        Window:Unload()
    end,
})

print("[CarSketch] v5 initialized")
