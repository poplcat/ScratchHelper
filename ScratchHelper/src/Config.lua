local Config = {}

Config.RootFolder = "ScratchHelper"
Config.ImageFolder = Config.RootFolder .. "/Images"
Config.BaseRaw = "https://raw.githubusercontent.com/poplcat/ScratchHelper/main/ScratchHelper/Images/"
Config.ManifestUrl = "https://raw.githubusercontent.com/poplcat/ScratchHelper/main/ScratchHelper/Images/manifest.txt"

Config.Defaults = {
    Visible = true,
    Locked = false,
    Scale = 1,
    Transparency = 0,
    Rotation = 0,
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(280, 280)
}

return Config
