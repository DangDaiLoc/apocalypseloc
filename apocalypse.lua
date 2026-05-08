-- Floater GUI - Final Fixed Version
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

local blockPart = nil

local function removeBlock()
    if blockPart then
        blockPart:Destroy()
        blockPart = nil
    end
end

-- Tạo block hiện hình dưới chân, nhân vật bước lên được
local function createBlock()
    removeBlock()
    -- Đặt block ngay dưới chân nhân vật
    local floorY = rootPart.Position.Y - 3.5
    blockPart = Instance.new("Part")
    blockPart.Size = Vector3.new(6, 1, 6)
    blockPart.CFrame = CFrame.new(rootPart.Position.X, floorY, rootPart.Position.Z)
    blockPart.Anchored = true
    blockPart.CanCollide = true
    blockPart.Material = Enum.Material.SmoothPlastic
    blockPart.BrickColor = BrickColor.new("Medium stone grey")
    blockPart.CastShadow = true
    blockPart.Parent = workspace

    -- Teleport nhân vật lên trên mặt block
    local standY = floorY + 0.5 + 2.5 -- top of block + half char height
    rootPart.CFrame = CFrame.new(rootPart.Position.X, standY, rootPart.Position.Z)
end

-- Noclip
RunService.Stepped:Connect(function()
    if not cfg.noclipEnabled then return end
    for _, p in ipairs(character:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
end)

-- Float logic
RunService.Heartbeat:Connect(function()
    if not rootPart or not humanoid then return end
    if cfg.blockEnabled then return end -- block mode: pakai gravity normal
    if not cfg.floatEnabled then return end

    humanoid.PlatformStand = true
    local yVel = cfg.upHeld and cfg.verticalSpeed
        or cfg.downHeld and -cfg.verticalSpeed or 0
    local md = humanoid.MoveDirection
    rootPart.AssemblyLinearVelocity = Vector3.new(
        md.X * cfg.speed,
        yVel,
        md.Z * cfg.speed
    )
end)

-- ===================== GUI =====================
local gui = Instance.new("ScreenGui")
gui.Name = "FloaterGUI"
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui

-- Toggle button
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

-- Main frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 160, 0, 210)
frame.Position = UDim2.new(0, 4, 0, 108)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(0,0,0)
frame.Active = true
frame.Draggable = true
frame.ZIndex = 10
frame.Visible = true
frame.Parent = gui

tog.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

local function mkRow(posY, height)
    height = height or 36
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -4, 0, height)
    f.Position = UDim2.new(0, 2, 0, posY)
    f.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    f.BorderSizePixel = 1
    f.BorderColor3 = Color3.fromRGB(0,0,0)
    f.ZIndex = 11
    f.Parent = frame
    return f
end

local function mkLabelIn(parent, text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.new(1,1,1)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 13
    l.ZIndex = 12
    l.Parent = parent
    return l
end

local function mkBtnOver(parent)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 1, 0)
    b.BackgroundTransparency = 1
    b.Text = ""
    b.ZIndex = 13
    b.Parent = parent
    return b
end

-- Row 1: Speed (chỉ hiện "Speed: 16", không có số trần)
local row1 = mkRow(2, 36)
local speedLbl = mkLabelIn(row1, "Speed: " .. cfg.speed)

-- Row 2: tăng/giảm speed
local row2 = mkRow(40, 36)
row2.BackgroundTransparency = 1

local leftCell = Instance.new("Frame")
leftCell.Size = UDim2.new(0.5, -1, 1, 0)
leftCell.BackgroundColor3 = Color3.fromRGB(55,55,55)
leftCell.BorderSizePixel = 1
leftCell.BorderColor3 = Color3.fromRGB(0,0,0)
leftCell.ZIndex = 11
leftCell.Parent = row2
mkLabelIn(leftCell, "↑ Speed")
local upSpeedBtn = mkBtnOver(leftCell)

local rightCell = Instance.new("Frame")
rightCell.Size = UDim2.new(0.5, -1, 1, 0)
rightCell.Position = UDim2.new(0.5, 1, 0, 0)
rightCell.BackgroundColor3 = Color3.fromRGB(55,55,55)
rightCell.BorderSizePixel = 1
rightCell.BorderColor3 = Color3.fromRGB(0,0,0)
rightCell.ZIndex = 11
rightCell.Parent = row2
mkLabelIn(rightCell, "↓ Speed")
local downSpeedBtn = mkBtnOver(rightCell)

-- Row 3: Float toggle
local row3 = mkRow(78, 38)
local floatLbl = mkLabelIn(row3, "Float: OFF")
local floatBtn = mkBtnOver(row3)

-- Row 4: Noclip
local row4 = mkRow(118, 38)
local noclipLbl = mkLabelIn(row4, "Noclip: OFF")
local noclipBtn = mkBtnOver(row4)

-- Row 5: Block
local row5 = mkRow(158, 38)
local blockLbl = mkLabelIn(row5, "Block: OFF")
local blockBtn = mkBtnOver(row5)

-- Nút LÊN / XUỐNG riêng bên phải
local upBtn = Instance.new("TextButton")
upBtn.Size = UDim2.new(0, 64, 0, 64)
upBtn.Position = UDim2.new(1, -78, 0.5, -80)
upBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
upBtn.Text = "⬆"
upBtn.TextColor3 = Color3.new(1,1,1)
upBtn.Font = Enum.Font.GothamBold
upBtn.TextSize = 24
upBtn.BorderSizePixel = 2
upBtn.BorderColor3 = Color3.fromRGB(80,80,80)
upBtn.ZIndex = 20
upBtn.Parent = gui
Instance.new("UICorner", upBtn).CornerRadius = UDim.new(1,0)

local downBtn = Instance.new("TextButton")
downBtn.Size = UDim2.new(0, 64, 0, 64)
downBtn.Position = UDim2.new(1, -78, 0.5, 16)
downBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
downBtn.Text = "⬇"
downBtn.TextColor3 = Color3.new(1,1,1)
downBtn.Font = Enum.Font.GothamBold
downBtn.TextSize = 24
downBtn.BorderSizePixel = 2
downBtn.BorderColor3 = Color3.fromRGB(80,80,80)
downBtn.ZIndex = 20
downBtn.Parent = gui
Instance.new("UICorner", downBtn).CornerRadius = UDim.new(1,0)

-- ===================== Logic =====================

-- Float: toggle rõ ràng, tắt block khi bật
floatBtn.MouseButton1Click:Connect(function()
    cfg.floatEnabled = not cfg.floatEnabled
    if cfg.floatEnabled then
        -- tắt block nếu đang bật
        if cfg.blockEnabled then
            cfg.blockEnabled = false
            removeBlock()
            blockLbl.Text = "Block: OFF"
        end
        humanoid.PlatformStand = true
        floatLbl.Text = "Float: ON"
    else
        humanoid.PlatformStand = false
        floatLbl.Text = "Float: OFF"
    end
end)

-- Speed
upSpeedBtn.MouseButton1Click:Connect(function()
    cfg.speed = math.min(500, cfg.speed + 4)
    speedLbl.Text = "Speed: " .. cfg.speed
end)
downSpeedBtn.MouseButton1Click:Connect(function()
    cfg.speed = math.max(4, cfg.speed - 4)
    speedLbl.Text = "Speed: " .. cfg.speed
end)

-- Noclip
noclipBtn.MouseButton1Click:Connect(function()
    cfg.noclipEnabled = not cfg.noclipEnabled
    noclipLbl.Text = cfg.noclipEnabled and "Noclip: ON" or "Noclip: OFF"
    if not cfg.noclipEnabled then
        for _, p in ipairs(character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = true end
        end
    end
end)

-- Block: tạo Part hiện hình, nhân vật đứng lên trên và đi được
blockBtn.MouseButton1Click:Connect(function()
    cfg.blockEnabled = not cfg.blockEnabled
    if cfg.blockEnabled then
        -- tắt float
        if cfg.floatEnabled then
            cfg.floatEnabled = false
            humanoid.PlatformStand = false
            floatLbl.Text = "Float: OFF"
        end
        createBlock()
        blockLbl.Text = "Block: ON"
    else
        removeBlock()
        blockLbl.Text = "Block: OFF"
        humanoid.PlatformStand = false
    end
end)

-- Lên / Xuống (chỉ hoạt động khi float bật)
upBtn.MouseButton1Down:Connect(function()
    if cfg.floatEnabled then cfg.upHeld = true end
end)
upBtn.MouseButton1Up:Connect(function() cfg.upHeld = false end)

downBtn.MouseButton1Down:Connect(function()
    if cfg.floatEnabled then cfg.downHeld = true end
end)
downBtn.MouseButton1Up:Connect(function() cfg.downHeld = false end)

UserInputService.InputBegan:Connect(function(i, gpe)
    if gpe then return end
    if i.KeyCode == Enum.KeyCode.E and cfg.floatEnabled then cfg.upHeld = true end
    if i.KeyCode == Enum.KeyCode.Q and cfg.floatEnabled then cfg.downHeld = true end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.E then cfg.upHeld = false end
    if i.KeyCode == Enum.KeyCode.Q then cfg.downHeld = false end
end)

-- Respawn
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    rootPart = char:WaitForChild("HumanoidRootPart")
    cfg.floatEnabled = false
    cfg.noclipEnabled = false
    cfg.blockEnabled = false
    cfg.upHeld = false
    cfg.downHeld = false
    removeBlock()
    speedLbl.Text = "Speed: " .. cfg.speed
    floatLbl.Text = "Float: OFF"
    noclipLbl.Text = "Noclip: OFF"
    blockLbl.Text = "Block: OFF"
end)
