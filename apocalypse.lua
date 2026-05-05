local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local camera = workspace.CurrentCamera

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "MobileHub_V2"
gui.ResetOnSpawn = false

pcall(function()
    gui.Parent = game:GetService("CoreGui")
end)
if not gui.Parent then gui.Parent = player:WaitForChild("PlayerGui") end

-- Frame
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 150)
frame.Position = UDim2.new(0, 50, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

-- Button
local function btn(text, x, y, color)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(0, 200, 0, 40)
    b.Position = UDim2.new(0, x, 0, y)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.BackgroundColor3 = color or Color3.fromRGB(50,50,50)
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 14
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    return b
end

-- Buttons
local saveBtn = btn("📍 Save Base", 25, 15, Color3.fromRGB(46,125,50))
local flyBaseBtn = btn("🕊 Fly Base Mượt", 25, 70, Color3.fromRGB(245,127,23))

-- Data
local basePos

-- Save base
saveBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        basePos = char.HumanoidRootPart.CFrame
        saveBtn.Text = "✅ Đã Lưu!"
        task.wait(1)
        saveBtn.Text = "📍 Save Base"
    end
end)

-- Fly mượt tối ưu
flyBaseBtn.MouseButton1Click:Connect(function()
    if not basePos or not player.Character then return end
    
    local char = player.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end

    hum.PlatformStand = true

    local bv = Instance.new("BodyVelocity", hrp)
    bv.MaxForce = Vector3.new(1e6,1e6,1e6)

    local bg = Instance.new("BodyGyro", hrp)
    bg.MaxTorque = Vector3.new(1e6,1e6,1e6)

    -- Bay lên cao mượt
    for i = 1,30 do
        bv.Velocity = Vector3.new(0,70,0)
        bg.CFrame = camera.CFrame
        runService.RenderStepped:Wait()
    end

    -- Bay tới base (tăng giảm tốc mượt)
    while true do
        local dist = (hrp.Position - basePos.Position).Magnitude
        if dist < 8 then break end

        local dir = (basePos.Position - hrp.Position).Unit
        
        -- tốc độ thay đổi theo khoảng cách (mượt hơn)
        local speed = math.clamp(dist * 2, 40, 150)

        bv.Velocity = dir * speed
        bg.CFrame = CFrame.lookAt(hrp.Position, basePos.Position)

        runService.RenderStepped:Wait()
    end

    bv:Destroy()
    bg:Destroy()
    hum.PlatformStand = false

    char:PivotTo(basePos)
end)
