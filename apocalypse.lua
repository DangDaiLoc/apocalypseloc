-- Floater GUI Script (Mobile + PC)
-- Features: Float, Speed, Noclip, Up/Down Controls, Toggle Menu

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- =====================
-- Settings
-- =====================
local settings = {
    floatEnabled = false,
    noclipEnabled = false,
    speed = 16,
    floatHeight = 8,
    verticalSpeed = 33,
    upHeld = false,
    downHeld = false,
}

-- =====================
-- Noclip Logic
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
-- Float + Up/Down Logic
-- =====================
RunService.Heartbeat:Connect(function(dt)
    if not settings.floatEnabled then return end
    if not rootPart or not humanoid then return end

    humanoid.PlatformStand = true

    local vel = rootPart.AssemblyLinearVelocity
    local moveDir = humanoid.MoveDirection

    local newVelocity = Vector3.new(
        moveDir.X * settings.speed,
        0,
        moveDir.Z * settings.speed
    )

    if settings.upHeld then
        newVelocity = Vector3.new(newVelocity.X, settings.verticalSpeed, newVelocity.Z)
    elseif settings.downHeld then
        newVelocity = Vector3.new(newVelocity.X, -settings.verticalSpeed, newVelocity.Z)
    else
        newVelocity = Vector3.new(newVelocity.X, 0, newVelocity.Z)
    end

    rootPart.AssemblyLinearVelocity = newVelocity
end)

-- Restore when float off
local function disableFloat()
    settings.floatEnabled = false
    humanoid.PlatformStand = false
end

-- =====================
-- GUI
-- =====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FloaterGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player.PlayerGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 320)
mainFrame.Position = UDim2.new(0.5, -110, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = true
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 36)
titleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 8)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "✈️ Floater Menu"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Toggle Menu Button (always visible)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 60, 0, 28)
toggleBtn.Position = UDim2.new(0, 5, 0.5, -14)
toggleBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
toggleBtn.Text = "☰ Menu"
toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 12
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = screenGui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)

toggleBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Helper: Create Button
local function makeButton(text, color, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 38)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.BackgroundColor3 = color or Color3.fromRGB(80, 80, 80)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    btn.Parent = mainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

-- Helper: Label
local function makeLabel(text, posY)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 24)
    lbl.Position = UDim2.new(0, 10, 0, posY)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = mainFrame
    return lbl
end

-- Float Toggle
local floatBtn = makeButton("🚀 Float: OFF", Color3.fromRGB(60, 60, 60), 46)
floatBtn.MouseButton1Click:Connect(function()
    settings.floatEnabled = not settings.floatEnabled
    if settings.floatEnabled then
        floatBtn.Text = "🚀 Float: ON"
        floatBtn.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
    else
        floatBtn.Text = "🚀 Float: OFF"
        floatBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        disableFloat()
    end
end)

-- Noclip Toggle
local noclipBtn = makeButton("👻 Noclip: OFF", Color3.fromRGB(60, 60, 60), 94)
noclipBtn.MouseButton1Click:Connect(function()
    settings.noclipEnabled = not settings.noclipEnabled
    if settings.noclipEnabled then
        noclipBtn.Text = "👻 Noclip: ON"
        noclipBtn.BackgroundColor3 = Color3.fromRGB(139, 34, 139)
    else
        noclipBtn.Text = "👻 Noclip: OFF"
        noclipBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end)

-- Speed Controls
makeLabel("⚡ Speed: " .. settings.speed, 142)
local speedLabel = makeLabel("⚡ Speed: " .. settings.speed, 142)

local speedRow = Instance.new("Frame")
speedRow.Size = UDim2.new(1, -20, 0, 34)
speedRow.Position = UDim2.new(0, 10, 0, 166)
speedRow.BackgroundTransparency = 1
speedRow.Parent = mainFrame

local speedDown = Instance.new("TextButton")
speedDown.Size = UDim2.new(0.45, 0, 1, 0)
speedDown.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
speedDown.Text = "− Speed"
speedDown.TextColor3 = Color3.fromRGB(255,255,255)
speedDown.Font = Enum.Font.GothamBold
speedDown.TextSize = 12
speedDown.BorderSizePixel = 0
speedDown.Parent = speedRow
Instance.new("UICorner", speedDown).CornerRadius = UDim.new(0, 6)

local speedUp = Instance.new("TextButton")
speedUp.Size = UDim2.new(0.45, 0, 1, 0)
speedUp.Position = UDim2.new(0.55, 0, 0, 0)
speedUp.BackgroundColor3 = Color3.fromRGB(60, 140, 60)
speedUp.Text = "+ Speed"
speedUp.TextColor3 = Color3.fromRGB(255,255,255)
speedUp.Font = Enum.Font.GothamBold
speedUp.TextSize = 12
speedUp.BorderSizePixel = 0
speedUp.Parent = speedRow
Instance.new("UICorner", speedUp).CornerRadius = UDim.new(0, 6)

speedDown.MouseButton1Click:Connect(function()
    settings.speed = math.max(4, settings.speed - 4)
    speedLabel.Text = "⚡ Speed: " .. settings.speed
end)
speedUp.MouseButton1Click:Connect(function()
    settings.speed = math.min(200, settings.speed + 4)
    speedLabel.Text = "⚡ Speed: " .. settings.speed
end)

-- Up / Down Buttons (Mobile)
local upBtn = makeButton("⬆️ LÊN (Giữ)", Color3.fromRGB(30, 100, 200), 210)
local downBtn = makeButton("⬇️ XUỐNG (Giữ)", Color3.fromRGB(200, 100, 30), 258)

-- Mobile touch hold
upBtn.MouseButton1Down:Connect(function() settings.upHeld = true end)
upBtn.MouseButton1Up:Connect(function() settings.upHeld = false end)
downBtn.MouseButton1Down:Connect(function() settings.downHeld = true end)
downBtn.MouseButton1Up:Connect(function() settings.downHeld = false end)

-- PC Keyboard Support (E = Up, Q = Down)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.E then settings.upHeld = true end
    if input.KeyCode == Enum.KeyCode.Q then settings.downHeld = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.E then settings.upHeld = false end
    if input.KeyCode == Enum.KeyCode.Q then settings.downHeld = false end
end)

-- Respawn handling
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    rootPart = char:WaitForChild("HumanoidRootPart")
    settings.floatEnabled = false
    settings.noclipEnabled = false
    floatBtn.Text = "🚀 Float: OFF"
    floatBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    noclipBtn.Text = "👻 Noclip: OFF"
    noclipBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
end)
