-- Floater GUI - Match Screenshot Style
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
    speed = 8,
    verticalSpeed = 33,
    upHeld = false,
    downHeld = false,
}

local blockPos = nil

-- Noclip
RunService.Stepped:Connect(function()
    if not cfg.noclipEnabled then return end
    for _, p in ipairs(character:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
end)

-- Float / Block
RunService.Heartbeat:Connect(function()
    if not rootPart or not humanoid then return end
    if cfg.blockEnabled and blockPos then
        humanoid.PlatformStand = true
        rootPart.CFrame = CFrame.new(blockPos)
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
gui.Parent = player.PlayerGui

-- Toggle Button (góc trên trái)
local tog = Instance.new("TextButton")
tog.Size = UDim2.new(0, 44, 0, 44)
tog.Position = UDim2.new(0, 4, 0, 60)
tog.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
tog.Text = "☰"
tog.TextColor3 = Color3.new(1,1,1)
tog.Font = Enum.Font.GothamBold
tog.TextSize = 18
tog.BorderSizePixel = 2
tog.BorderColor3 = Color3.fromRGB(80,80,80)
tog.ZIndex = 20
tog.Parent = gui

-- Main Frame (giống ảnh: hẹp, dọc, góc trái)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 150, 0, 230)
frame.Position = UDim2.new(0, 4, 0, 108)
frame.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
frame.Active = true
frame.Draggable = true
frame.ZIndex = 10
frame.Visible = true
frame.Parent = gui

tog.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

-- Helper tạo ô (giống các ô trong ảnh)
local function mkCell(text, posY, height, bgColor)
    height = height or 34
    bgColor = bgColor or Color3.fromRGB(55, 55, 55)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -4, 0, height)
    f.Position = UDim2.new(0, 2, 0, posY)
    f.BackgroundColor3 = bgColor
    f.BorderSizePixel = 1
    f.BorderColor3 = Color3.fromRGB(0,0,0)
    f.ZIndex = 11
    f.Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.ZIndex = 12
    lbl.Parent = f
    return f, lbl
end

-- Helper tombol klik
local function mkClickCell(text, posY, height, bgColor)
    local f, lbl = mkCell(text, posY, height, bgColor)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 13
    btn.Parent = f
    return f, lbl, btn
end

-- =====================
-- Baris 1: Speed display (angka 8)
-- =====================
local _, speedLbl = mkCell(cfg.speed, 2, 30)
speedLbl.Font = Enum.Font.GothamBold
speedLbl.TextSize = 15

-- Baris 2: Vertical speed display (angka 33)
local _, vSpeedLbl = mkCell(cfg.verticalSpeed, 34, 30)
vSpeedLbl.Font = Enum.Font.GothamBold
vSpeedLbl.TextSize = 15

-- Baris 3: Speed +/- dan Up/Down (dua kolom)
-- Speed −
local sDownF = Instance.new("Frame")
sDownF.Size = UDim2.new(0.48, -2, 0, 30)
sDownF.Position = UDim2.new(0, 2, 0, 66)
sDownF.BackgroundColor3 = Color3.fromRGB(55,55,55)
sDownF.BorderSizePixel = 1
sDownF.BorderColor3 = Color3.fromRGB(0,0,0)
sDownF.ZIndex = 11
sDownF.Parent = frame

local sDownBtn = Instance.new("TextButton")
sDownBtn.Size = UDim2.new(1,0,1,0)
sDownBtn.BackgroundTransparency = 1
sDownBtn.Text = "↑"
sDownBtn.TextColor3 = Color3.new(1,1,1)
sDownBtn.Font = Enum.Font.GothamBold
sDownBtn.TextSize = 16
sDownBtn.ZIndex = 12
sDownBtn.Parent = sDownF

-- Speed +
local sUpF = Instance.new("Frame")
sUpF.Size = UDim2.new(0.48, -2, 0, 30)
sUpF.Position = UDim2.new(0.52, 0, 0, 66)
sUpF.BackgroundColor3 = Color3.fromRGB(55,55,55)
sUpF.BorderSizePixel = 1
sUpF.BorderColor3 = Color3.fromRGB(0,0,0)
sUpF.ZIndex = 11
sUpF.Parent = frame

local sUpBtn = Instance.new("TextButton")
sUpBtn.Size = UDim2.new(1,0,1,0)
sUpBtn.BackgroundTransparency = 1
sUpBtn.Text = "↓"
sUpBtn.TextColor3 = Color3.new(1,1,1)
sUpBtn.Font = Enum.Font.GothamBold
sUpBtn.TextSize = 16
sUpBtn.ZIndex = 12
sUpBtn.Parent = sUpF

-- Noclip row
local _, noclipLbl, noclipBtn = mkClickCell("Noclip: OFF", 98, 34)

-- Block row
local _, blockLbl, blockBtn = mkClickCell("Block: OFF", 134, 34)

-- =====================
-- Nút LÊN / XUỐNG riêng (bên phải màn hình)
-- =====================
local upBtn = Instance.new("TextButton")
upBtn.Size = UDim2.new(0, 64, 0, 64)
upBtn.Position = UDim2.new(1, -78, 0.5, -80)
upBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
upBtn.Text = "⬆"
upBtn.TextColor3 = Color3.new(1,1,1)
upBtn.Font = Enum.Font.GothamBold
upBtn.TextSize = 22
upBtn.BorderSizePixel = 2
upBtn.BorderColor3 = Color3.fromRGB(80,80,80)
upBtn.ZIndex = 20
upBtn.Parent = gui
Instance.new("UICorner", upBtn).CornerRadius = UDim.new(1, 0)

local downBtn = Instance.new("TextButton")
downBtn.Size = UDim2.new(0, 64, 0, 64)
downBtn.Position = UDim2.new(1, -78, 0.5, 16)
downBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
downBtn.Text = "⬇"
downBtn.TextColor3 = Color3.new(1,1,1)
downBtn.Font = Enum.Font.GothamBold
downBtn.TextSize = 22
downBtn.BorderSizePixel = 2
downBtn.BorderColor3 = Color3.fromRGB(80,80,80)
downBtn.ZIndex = 20
downBtn.Parent = gui
Instance.new("UICorner", downBtn).CornerRadius = UDim.new(1, 0)

-- Float bật khi chạm nút lên hoặc xuống lần đầu
local function ensureFloat()
    if not cfg.floatEnabled then
        cfg.floatEnabled = true
        cfg.blockEnabled = false
        blockPos = nil
        blockLbl.Text = "Block: OFF"
    end
end

-- =====================
-- Logic Speed (↑ tăng, ↓ giảm — theo style ảnh)
-- =====================
sDownBtn.MouseButton1Click:Connect(function()
    cfg.speed = math.min(500, cfg.speed + 4)
    speedLbl.Text = tostring(cfg.speed)
end)
sUpBtn.MouseButton1Click:Connect(function()
    cfg.speed = math.max(4, cfg.speed - 4)
    speedLbl.Text = tostring(cfg.speed)
end)

-- =====================
-- Logic Noclip
-- =====================
noclipBtn.MouseButton1Click:Connect(function()
    cfg.noclipEnabled = not cfg.noclipEnabled
    if cfg.noclipEnabled then
        noclipLbl.Text = "Noclip: ON"
    else
        noclipLbl.Text = "Noclip: OFF"
        for _, p in ipairs(character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = true end
        end
    end
end)

-- =====================
-- Logic Block
-- =====================
blockBtn.MouseButton1Click:Connect(function()
    cfg.blockEnabled = not cfg.blockEnabled
    if cfg.blockEnabled then
        cfg.floatEnabled = false
        blockPos = rootPart.Position
        humanoid.PlatformStand = true
        blockLbl.Text = "Block: ON"
    else
        blockPos = nil
        blockLbl.Text = "Block: OFF"
        humanoid.PlatformStand = false
    end
end)

-- =====================
-- Lên / Xuống
-- =====================
upBtn.MouseButton1Down:Connect(function()
    ensureFloat()
    cfg.upHeld = true
end)
upBtn.MouseButton1Up:Connect(function() cfg.upHeld = false end)

downBtn.MouseButton1Down:Connect(function()
    ensureFloat()
    cfg.downHeld = true
end)
downBtn.MouseButton1Up:Connect(function() cfg.downHeld = false end)

UserInputService.InputBegan:Connect(function(i, gpe)
    if gpe then return end
    if i.KeyCode == Enum.KeyCode.E then ensureFloat(); cfg.upHeld = true end
    if i.KeyCode == Enum.KeyCode.Q then ensureFloat(); cfg.downHeld = true end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.E then cfg.upHeld = false end
    if i.KeyCode == Enum.KeyCode.Q then cfg.downHeld = false end
end)

-- =====================
-- Respawn
-- =====================
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    rootPart = char:WaitForChild("HumanoidRootPart")
    cfg.floatEnabled = false
    cfg.noclipEnabled = false
    cfg.blockEnabled = false
    blockPos = nil
    speedLbl.Text = tostring(cfg.speed)
    noclipLbl.Text = "Noclip: OFF"
    blockLbl.Text = "Block: OFF"
end)
