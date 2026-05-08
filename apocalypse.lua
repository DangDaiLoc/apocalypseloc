-- Floater GUI - Fixed v3
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local cfg = {
    floatEnabled = false,
    noclipEnabled = false,
    blockEnabled = false,
    speed = 16,
    verticalSpeed = 33,
    upHeld = false,
    downHeld = false,
}

-- Noclip
RunService.Stepped:Connect(function()
    if cfg.noclipEnabled then
        for _, p in ipairs(character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

-- Float / Block physics
RunService.Heartbeat:Connect(function()
    if not rootPart or not humanoid then return end
    if cfg.blockEnabled then
        humanoid.PlatformStand = true
        rootPart.AssemblyLinearVelocity = Vector3.zero
        rootPart.AssemblyAngularVelocity = Vector3.zero
        return
    end
    if not cfg.floatEnabled then return end
    humanoid.PlatformStand = true
    local yVel = cfg.upHeld and cfg.verticalSpeed or cfg.downHeld and -cfg.verticalSpeed or 0
    local md = humanoid.MoveDirection
    rootPart.AssemblyLinearVelocity = Vector3.new(md.X * cfg.speed, yVel, md.Z * cfg.speed)
end)

-- ===================== GUI =====================
local gui = Instance.new("ScreenGui")
gui.Name = "FloaterGUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player.PlayerGui

-- Toggle button
local tog = Instance.new("TextButton")
tog.Size = UDim2.new(0, 80, 0, 32)
tog.Position = UDim2.new(0, 10, 0, 10)
tog.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
tog.Text = "☰ Menu"
tog.TextColor3 = Color3.new(1,1,1)
tog.Font = Enum.Font.GothamBold
tog.TextSize = 13
tog.BorderSizePixel = 0
tog.ZIndex = 20
tog.Parent = gui
Instance.new("UICorner", tog).CornerRadius = UDim.new(0, 7)

-- Main frame - dùng position thủ công, KHÔNG dùng UIListLayout
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 420)
frame.Position = UDim2.new(0, 10, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.ZIndex = 10
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

tog.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 36)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
title.Text = "  ✈️  Floater Menu"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.BorderSizePixel = 0
title.ZIndex = 11
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

-- Helper: nút full width
local function mkBtn(text, color, posY)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -20, 0, 44)
    b.Position = UDim2.new(0, 10, 0, posY)
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.BorderSizePixel = 0
    b.ZIndex = 11
    b.Parent = frame
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    return b
end

-- Helper: label
local function mkLabel(text, posY)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -20, 0, 26)
    l.Position = UDim2.new(0, 10, 0, posY)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(210, 210, 210)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 11
    l.Parent = frame
    return l
end

-- ======= Các nút =======
-- posY: 44 = title
-- spacing: 10px giữa các item

-- Float (posY 54)
local floatBtn = mkBtn("🚀  Float: OFF", Color3.fromRGB(60,60,60), 44)

-- Noclip (posY 108)
local noclipBtn = mkBtn("👻  Noclip: OFF", Color3.fromRGB(60,60,60), 98)

-- Block (posY 162)
local blockBtn = mkBtn("🧱  Block: OFF", Color3.fromRGB(60,60,60), 152)

-- Speed label (posY 216)
local speedLbl = mkLabel("⚡  Speed: " .. cfg.speed, 206)

-- Speed buttons (posY 232) — hai nút nhỏ cạnh nhau
local sDown = Instance.new("TextButton")
sDown.Size = UDim2.new(0, 103, 0, 40)
sDown.Position = UDim2.new(0, 10, 0, 234)
sDown.BackgroundColor3 = Color3.fromRGB(190, 50, 50)
sDown.Text = "−  Speed"
sDown.TextColor3 = Color3.new(1,1,1)
sDown.Font = Enum.Font.GothamBold
sDown.TextSize = 13
sDown.BorderSizePixel = 0
sDown.ZIndex = 11
sDown.Parent = frame
Instance.new("UICorner", sDown).CornerRadius = UDim.new(0, 8)

local sUp = Instance.new("TextButton")
sUp.Size = UDim2.new(0, 107, 0, 40)
sUp.Position = UDim2.new(0, 123, 0, 234)
sUp.BackgroundColor3 = Color3.fromRGB(50, 160, 50)
sUp.Text = "+  Speed"
sUp.TextColor3 = Color3.new(1,1,1)
sUp.Font = Enum.Font.GothamBold
sUp.TextSize = 13
sUp.BorderSizePixel = 0
sUp.ZIndex = 11
sUp.Parent = frame
Instance.new("UICorner", sUp).CornerRadius = UDim.new(0, 8)

-- LÊN (posY 284)
local upBtn = mkBtn("⬆️  LÊN (Giữ)", Color3.fromRGB(30, 100, 210), 284)

-- XUỐNG (posY 338)
local downBtn = mkBtn("⬇️  XUỐNG (Giữ)", Color3.fromRGB(190, 100, 20), 338)

-- ======= Logic nút =======
floatBtn.MouseButton1Click:Connect(function()
    cfg.floatEnabled = not cfg.floatEnabled
    if cfg.floatEnabled then
        cfg.blockEnabled = false
        blockBtn.Text = "🧱  Block: OFF"
        blockBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
        floatBtn.Text = "🚀  Float: ON"
        floatBtn.BackgroundColor3 = Color3.fromRGB(34,139,34)
    else
        floatBtn.Text = "🚀  Float: OFF"
        floatBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
        if humanoid then humanoid.PlatformStand = false end
    end
end)

noclipBtn.MouseButton1Click:Connect(function()
    cfg.noclipEnabled = not cfg.noclipEnabled
    if cfg.noclipEnabled then
        noclipBtn.Text = "👻  Noclip: ON"
        noclipBtn.BackgroundColor3 = Color3.fromRGB(139,34,139)
    else
        noclipBtn.Text = "👻  Noclip: OFF"
        noclipBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
        for _, p in ipairs(character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = true end
        end
    end
end)

blockBtn.MouseButton1Click:Connect(function()
    cfg.blockEnabled = not cfg.blockEnabled
    if cfg.blockEnabled then
        cfg.floatEnabled = false
        floatBtn.Text = "🚀  Float: OFF"
        floatBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
        blockBtn.Text = "🧱  Block: ON"
        blockBtn.BackgroundColor3 = Color3.fromRGB(200,130,0)
    else
        blockBtn.Text = "🧱  Block: OFF"
        blockBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
        if humanoid then humanoid.PlatformStand = false end
    end
end)

sDown.MouseButton1Click:Connect(function()
    cfg.speed = math.max(4, cfg.speed - 4)
    speedLbl.Text = "⚡  Speed: " .. cfg.speed
end)
sUp.MouseButton1Click:Connect(function()
    cfg.speed = math.min(500, cfg.speed + 4)
    speedLbl.Text = "⚡  Speed: " .. cfg.speed
end)

upBtn.MouseButton1Down:Connect(function() cfg.upHeld = true end)
upBtn.MouseButton1Up:Connect(function() cfg.upHeld = false end)
downBtn.MouseButton1Down:Connect(function() cfg.downHeld = true end)
downBtn.MouseButton1Up:Connect(function() cfg.downHeld = false end)

UserInputService.InputBegan:Connect(function(i, gpe)
    if gpe then return end
    if i.KeyCode == Enum.KeyCode.E then cfg.upHeld = true end
    if i.KeyCode == Enum.KeyCode.Q then cfg.downHeld = true end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.E then cfg.upHeld = false end
    if i.KeyCode == Enum.KeyCode.Q then cfg.downHeld = false end
end)

player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    rootPart = char:WaitForChild("HumanoidRootPart")
    cfg.floatEnabled = false; cfg.noclipEnabled = false; cfg.blockEnabled = false
    floatBtn.Text = "🚀  Float: OFF"; floatBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    noclipBtn.Text = "👻  Noclip: OFF"; noclipBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    blockBtn.Text = "🧱  Block: OFF"; blockBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
end)
