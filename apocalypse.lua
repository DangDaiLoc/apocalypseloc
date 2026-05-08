-- Floater GUI Script (Mobile + PC) - Fixed Version
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local settings = {
    floatEnabled = false,
    noclipEnabled = false,
    blockEnabled = false,
    speed = 16,
    verticalSpeed = 33,
    upHeld = false,
    downHeld = false,
}

-- =====================
-- Noclip
-- =====================
RunService.Stepped:Connect(function()
    if settings.noclipEnabled then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- =====================
-- Float + Block + Up/Down
-- =====================
RunService.Heartbeat:Connect(function()
    if not rootPart or not humanoid then return end

    -- BLOCK: đứng yên hoàn toàn
    if settings.blockEnabled then
        humanoid.PlatformStand = true
        rootPart.AssemblyLinearVelocity = Vector3.zero
        rootPart.AssemblyAngularVelocity = Vector3.zero
        return
    end

    if not settings.floatEnabled then return end

    humanoid.PlatformStand = true

    local moveDir = humanoid.MoveDirection
    local yVel = 0

    if settings.upHeld then
        yVel = settings.verticalSpeed
    elseif settings.downHeld then
        yVel = -settings.verticalSpeed
    end

    rootPart.AssemblyLinearVelocity = Vector3.new(
        moveDir.X * settings.speed,
        yVel,
        moveDir.Z * settings.speed
    )
end)

local function disableFloat()
    settings.floatEnabled = false
    if humanoid then humanoid.PlatformStand = false end
end

local function disableBlock()
    settings.blockEnabled = false
    if humanoid then humanoid.PlatformStand = false end
end

-- =====================
-- GUI Setup
-- =====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FloaterGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player.PlayerGui

-- Toggle Button (luôn hiện)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 80, 0, 30)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleBtn.Text = "☰ Menu"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 13
toggleBtn.BorderSizePixel = 0
toggleBtn.ZIndex = 10
toggleBtn.Parent = screenGui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 230, 0, 370)
mainFrame.Position = UDim2.new(0, 10, 0, 48)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = true
mainFrame.ZIndex = 5
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

-- UIListLayout để tự xếp nút
local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 6)
layout.Parent = mainFrame

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 8)
padding.PaddingBottom = UDim.new(0, 8)
padding.PaddingLeft = UDim.new(0, 8)
padding.PaddingRight = UDim.new(0, 8)
padding.Parent = mainFrame

toggleBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Helper tạo nút
local function makeBtn(text, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = color or Color3.fromRGB(60, 60, 60)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = true
    btn.Parent = mainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    return btn
end

-- Helper tạo label
local function makeLabel(text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 24)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(180, 180, 180)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.Parent = mainFrame
    return lbl
end

-- =====================
-- Float Button
-- =====================
local floatBtn = makeBtn("🚀 Float: OFF", Color3.fromRGB(60, 60, 60))
floatBtn.MouseButton1Click:Connect(function()
    settings.floatEnabled = not settings.floatEnabled
    if settings.floatEnabled then
        settings.blockEnabled = false
        blockBtn.Text = "🧱 Block: OFF"
        blockBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        floatBtn.Text = "🚀 Float: ON"
        floatBtn.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
    else
        floatBtn.Text = "🚀 Float: OFF"
        floatBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        disableFloat()
    end
end)

-- =====================
-- Noclip Button
-- =====================
local noclipBtn = makeBtn("👻 Noclip: OFF", Color3.fromRGB(60, 60, 60))
noclipBtn.MouseButton1Click:Connect(function()
    settings.noclipEnabled = not settings.noclipEnabled
    if settings.noclipEnabled then
        noclipBtn.Text = "👻 Noclip: ON"
        noclipBtn.BackgroundColor3 = Color3.fromRGB(139, 34, 139)
    else
        noclipBtn.Text = "👻 Noclip: OFF"
        noclipBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end)

-- =====================
-- Block Button (đứng yên)
-- =====================
blockBtn = makeBtn("🧱 Block: OFF", Color3.fromRGB(60, 60, 60))
blockBtn.MouseButton1Click:Connect(function()
    settings.blockEnabled = not settings.blockEnabled
    if settings.blockEnabled then
        settings.floatEnabled = false
        floatBtn.Text = "🚀 Float: OFF"
        floatBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        blockBtn.Text = "🧱 Block: ON"
        blockBtn.BackgroundColor3 = Color3.fromRGB(180, 120, 20)
    else
        blockBtn.Text = "🧱 Block: OFF"
        blockBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        disableBlock()
    end
end)

-- =====================
-- Speed Display + Controls
-- =====================
local speedLabel = makeLabel("⚡ Speed: " .. settings.speed)

local speedRow = Instance.new("Frame")
speedRow.Size = UDim2.new(1, 0, 0, 42)
speedRow.BackgroundTransparency = 1
speedRow.Parent = mainFrame

local rowLayout = Instance.new("UIListLayout")
rowLayout.FillDirection = Enum.FillDirection.Horizontal
rowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
rowLayout.Padding = UDim.new(0, 6)
rowLayout.Parent = speedRow

local function makeHalfBtn(text, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 100, 1, 0)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    btn.Parent = speedRow
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    return btn
end

local speedDown = makeHalfBtn("− Speed", Color3.fromRGB(180, 60, 60))
local speedUp = makeHalfBtn("+ Speed", Color3.fromRGB(60, 140, 60))

speedDown.MouseButton1Click:Connect(function()
    settings.speed = math.max(4, settings.speed - 4)
    speedLabel.Text = "⚡ Speed: " .. settings.speed
end)
speedUp.MouseButton1Click:Connect(function()
    settings.speed = math.min(500, settings.speed + 4)
    speedLabel.Text = "⚡ Speed: " .. settings.speed
end)

-- =====================
-- Up / Down Buttons
-- =====================
local upBtn = makeBtn("⬆️ LÊN (Giữ)", Color3.fromRGB(30, 100, 200))
local downBtn = makeBtn("⬇️ XUỐNG (Giữ)", Color3.fromRGB(160, 80, 20))

upBtn.MouseButton1Down:Connect(function() settings.upHeld = true end)
upBtn.MouseButton1Up:Connect(function() settings.upHeld = false end)
downBtn.MouseButton1Down:Connect(function() settings.downHeld = true end)
downBtn.MouseButton1Up:Connect(function() settings.downHeld = false end)

-- PC Keyboard: E = Lên, Q = Xuống
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.E then settings.upHeld = true end
    if input.KeyCode == Enum.KeyCode.Q then settings.downHeld = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.E then settings.upHeld = false end
    if input.KeyCode == Enum.KeyCode.Q then settings.downHeld = false end
end)

-- =====================
-- Respawn
-- =====================
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    rootPart = char:WaitForChild("HumanoidRootPart")
    settings.floatEnabled = false
    settings.noclipEnabled = false
    settings.blockEnabled = false
    floatBtn.Text = "🚀 Float: OFF"; floatBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    noclipBtn.Text = "👻 Noclip: OFF"; noclipBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    blockBtn.Text = "🧱 Block: OFF"; blockBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
end)
