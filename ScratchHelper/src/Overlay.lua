local Overlay = {}

function Overlay.new(Config, ImageManager)
    local self = {}
    self.Config = Config
    self.ImageManager = ImageManager
    self.Gui, self.Image, self.SelectedPath = nil, nil, nil
    self.State = {
        Visible = Config.Defaults.Visible,
        Locked = Config.Defaults.Locked,
        Scale = Config.Defaults.Scale,
        Transparency = Config.Defaults.Transparency,
        Rotation = Config.Defaults.Rotation
    }

    local function getParent()
        if type(gethui) == "function" then
            local ok, hui = pcall(gethui)
            if ok and hui then return hui end
        end
        return game:GetService("CoreGui")
    end

    function self:Create()
        if self.Gui then pcall(function() self.Gui:Destroy() end) end
        local gui = Instance.new("ScreenGui")
        gui.Name = "ScratchHelperOverlay"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.Parent = getParent()

        local image = Instance.new("ImageLabel")
        image.Name = "ReferenceImage"
        image.BackgroundTransparency = 1
        image.AnchorPoint = Vector2.new(0.5, 0.5)
        image.Position = Config.Defaults.Position
        image.Size = Config.Defaults.Size
        image.ScaleType = Enum.ScaleType.Fit
        image.ImageTransparency = self.State.Transparency
        image.Rotation = self.State.Rotation
        image.Visible = self.State.Visible
        image.Parent = gui

        local dragging, dragStart, startPos = false, nil, nil
        image.InputBegan:Connect(function(input)
            if self.State.Locked then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging, dragStart, startPos = true, input.Position, image.Position
            end
        end)
        image.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if not dragging or self.State.Locked then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - dragStart
                image.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)

        self.Gui, self.Image = gui, image
        self:Apply()
    end

    function self:Apply()
        if not self.Image then return end
        self.Image.Visible = self.State.Visible
        self.Image.ImageTransparency = self.State.Transparency
        self.Image.Rotation = self.State.Rotation
        self.Image.Size = UDim2.fromOffset(Config.Defaults.Size.X.Offset * self.State.Scale, Config.Defaults.Size.Y.Offset * self.State.Scale)
    end

    function self:SetImage(path)
        if not self.Image then self:Create() end
        local assetFn = getcustomasset or getsynasset
        if type(assetFn) ~= "function" then return false, "Executor lacks getcustomasset/getsynasset" end
        local ok, asset = pcall(assetFn, path)
        if not ok then return false, tostring(asset) end
        self.Image.Image = asset
        self.SelectedPath = path
        return true
    end

    function self:SetVisible(v) self.State.Visible = v; self:Apply() end
    function self:SetLocked(v) self.State.Locked = v end
    function self:SetScale(v) self.State.Scale = math.clamp(v, 0.25, 3); self:Apply() end
    function self:SetTransparency(v) self.State.Transparency = math.clamp(v, 0, 1); self:Apply() end
    function self:SetRotation(v) self.State.Rotation = v % 360; self:Apply() end
    function self:Reset()
        if self.Image then self.Image.Position = Config.Defaults.Position end
        self:SetScale(1); self:SetTransparency(0); self:SetRotation(0)
    end

    self:Create()
    return self
end

return Overlay
