local UI = {}

function UI.start(Config, Images, Overlay)
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local gui = Instance.new("ScreenGui")
    gui.Name = "ScratchHelperControls"
    gui.ResetOnSpawn = false
    gui.Parent = (type(gethui) == "function" and gethui()) or game:GetService("CoreGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(250, 330)
    frame.Position = UDim2.fromOffset(20, 100)
    frame.BackgroundColor3 = Color3.fromRGB(28, 30, 38)
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 34)
    title.BackgroundColor3 = Color3.fromRGB(45, 49, 62)
    title.Text = "ScratchHelper"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = frame

    local function button(label, y, callback)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -20, 0, 32)
        b.Position = UDim2.fromOffset(10, y)
        b.BackgroundColor3 = Color3.fromRGB(62, 68, 86)
        b.TextColor3 = Color3.new(1, 1, 1)
        b.Font = Enum.Font.Gotham
        b.TextSize = 13
        b.Text = label
        b.Parent = frame
        b.MouseButton1Click:Connect(callback)
        return b
    end

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 42)
    status.Position = UDim2.fromOffset(10, 278)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.fromRGB(210, 215, 225)
    status.TextWrapped = true
    status.TextSize = 11
    status.Font = Enum.Font.Gotham
    status.Text = "Refresh image list to begin."
    status.Parent = frame

    local names, index = Images:Refresh(), 1
    local function selected() return names[index] end
    local selectButton
    local function updateLabel()
        if selectButton then selectButton.Text = selected() or "No PNG images found" end
    end

    selectButton = button("Choose image", 44, function()
        if #names == 0 then status.Text = "No images in manifest."; return end
        index = index % #names + 1
        updateLabel()
    end)
    button("Refresh image list", 82, function()
        names, index = Images:Refresh(), 1
        updateLabel()
        status.Text = "Found " .. #names .. " image(s)."
    end)
    button("Download + load selected", 120, function()
        local name = selected()
        if not name then status.Text = "No image selected."; return end
        local ok, path = Images:Download(name)
        if not ok then status.Text = "Download error: " .. tostring(path); return end
        local loaded, err = Overlay:SetImage(path)
        status.Text = loaded and ("Loaded: " .. name) or ("Load error: " .. tostring(err))
    end)
    button("Show / hide overlay", 158, function() Overlay:SetVisible(not Overlay.State.Visible) end)
    button("Lock / unlock position", 196, function()
        Overlay:SetLocked(not Overlay.State.Locked)
        status.Text = Overlay.State.Locked and "Position locked." or "Position unlocked."
    end)
    button("Reset overlay", 234, function() Overlay:Reset(); status.Text = "Overlay reset." end)

    updateLabel()
    print("[ScratchHelper] UI ready for " .. tostring(player and player.Name or "player"))
end

return UI
