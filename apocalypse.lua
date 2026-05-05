local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")

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
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

-- Button
local function btn(text, y, color)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(0, 200, 0, 40)
    b.Position = UDim2.new(0, 25, 0, y)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.BackgroundColor3 = color
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 14
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    return b
end

local saveBtn = btn("📍 Save Base", 15, Color3.fromRGB(46,125,50))
local moveBtn = btn("🚶 Về Base (Mượt)", 70, Color3.fromRGB(21,101,192))

-- Data
local basePos
local moving = false

-- Save
saveBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        basePos = char.HumanoidRootPart.Position
        saveBtn.Text = "✅ Đã Lưu!"
        task.wait(1)
        saveBtn.Text = "📍 Save Base"
    end
end)

-- Move legit
moveBtn.MouseButton1Click:Connect(function()
    if moving then return end
    if not basePos or not player.Character then return end
    
    moving = true

    local char = player.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    while (hrp.Position - basePos).Magnitude > 4 do
        local dir = (basePos - hrp.Position).Unit
        
        -- bước nhỏ (rất quan trọng để tránh detect)
        local step = math.clamp((basePos - hrp.Position).Magnitude / 10, 2, 6)

        hrp.CFrame = hrp.CFrame + dir * step
        
        -- quay mặt theo hướng đi
        hrp.CFrame = CFrame.lookAt(hrp.Position, basePos)

        runService.RenderStepped:Wait()
    end

    moving = false
end)
