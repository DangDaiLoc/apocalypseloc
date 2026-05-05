local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local camera = workspace.CurrentCamera

-- Khởi tạo GUI
local gui = Instance.new("ScreenGui")
gui.Name = "MobileHub_V2"
gui.ResetOnSpawn = false

-- Thử đưa vào CoreGui (nếu exploit hỗ trợ), không thì vào PlayerGui
local success, err = pcall(function()
    gui.Parent = game:GetService("CoreGui")
end)
if not success then gui.Parent = player:WaitForChild("PlayerGui") end

-- Khung chính
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 280) -- Thu nhỏ lại cho gọn
frame.Position = UDim2.new(0, 50, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

-- Bo góc cho khung chính
local frameCorner = Instance.new("UICorner", frame)
frameCorner.CornerRadius = UDim.new(0, 10)

-- Hàm tạo Button (Đã fix lỗi UDim)
local function btn(text, x, y, color)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(0, 110, 0, 35)
    b.Position = UDim2.new(0, x, 0, y)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.BackgroundColor3 = color or Color3.fromRGB(50, 50, 50)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextSize = 12
    b.AutoButtonColor = true
    
    local corner = Instance.new("UICorner", b)
    corner.CornerRadius = UDim.new(0, 6) -- Fix lỗi ToolPoint ở đây
    return b
end

-- --- UI Elements ---
local saveBtn = btn("📍 Save Base", 10, 10, Color3.fromRGB(46, 125, 50))
local tpBtn = btn("🚀 Về Base", 130, 10, Color3.fromRGB(21, 101, 192))
local flyBtn = btn("🕊 Fly: OFF", 10, 55, Color3.fromRGB(183, 28, 28))
local flyBaseBtn = btn("🏠 Auto Base", 130, 55, Color3.fromRGB(245, 127, 23))

-- Nhãn tiêu đề cho phần điều khiển
local label = Instance.new("TextLabel", frame)
label.Text = "DI CHUYỂN (Khi Fly)"
label.Size = UDim2.new(1, 0, 0, 20)
label.Position = UDim2.new(0, 0, 0, 100)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.new(0.7, 0.7, 0.7)
label.TextSize = 10

-- Nút điều khiển
local up = btn("TIẾN", 70, 130)
local down = btn("LÙI", 70, 210)
local left = btn("TRÁI", 10, 170)
local right = btn("PHẢI", 130, 170)

-- --- Biến và Logic ---
local basePos = nil
local flying = false
local moveDir = Vector3.zero
local flySpeed = 50

-- Lưu vị trí
saveBtn.MouseButton1Click:Connect(function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        basePos = player.Character.HumanoidRootPart.CFrame
        saveBtn.Text = "✅ Đã Lưu!"
        task.wait(1)
        saveBtn.Text = "📍 Save Base"
    end
end)

-- Teleport
tpBtn.MouseButton1Click:Connect(function()
    if basePos and player.Character then
        player.Character:PivotTo(basePos)
    end
end)

-- Fly Logic
local function toggleFly()
    flying = not flying
    local char = player.Character
    if not char then return end
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")

    if flying then
        flyBtn.Text = "🕊 Fly: ON"
        flyBtn.BackgroundColor3 = Color3.fromRGB(67, 160, 71)
        hum.PlatformStand = true
        
        local bv = Instance.new("BodyVelocity", hrp)
        bv.Name = "FlyVel"
        bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        
        local bg = Instance.new("BodyGyro", hrp)
        bg.Name = "FlyGyro"
        bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)

        task.spawn(function()
            while flying do
                local look = camera.CFrame.LookVector
                local rightV = camera.CFrame.RightVector
                local vel = Vector3.zero

                if moveDir.Z > 0 then vel = vel + look end
                if moveDir.Z < 0 then vel = vel - look end
                if moveDir.X < 0 then vel = vel - rightV end
                if moveDir.X > 0 then vel = vel + rightV end

                bv.Velocity = vel * flySpeed
                bg.CFrame = camera.CFrame
                runService.RenderStepped:Wait()
            end
            bv:Destroy()
            bg:Destroy()
            hum.PlatformStand = false
        end)
    else
        flyBtn.Text = "🕊 Fly: OFF"
        flyBtn.BackgroundColor3 = Color3.fromRGB(183, 28, 28)
    end
end

flyBtn.MouseButton1Click:Connect(toggleFly)

-- Control Events
up.MouseButton1Down:Connect(function() moveDir = Vector3.new(0,0,1) end)
down.MouseButton1Down:Connect(function() moveDir = Vector3.new(0,0,-1) end)
left.MouseButton1Down:Connect(function() moveDir = Vector3.new(-1,0,0) end)
right.MouseButton1Down:Connect(function() moveDir = Vector3.new(1,0,0) end)

local function stop() moveDir = Vector3.zero end
up.MouseButton1Up:Connect(stop)
down.MouseButton1Up:Connect(stop)
left.MouseButton1Up:Connect(stop)
right.MouseButton1Up:Connect(stop)

-- Auto Base mượt
flyBaseBtn.MouseButton1Click:Connect(function()
    if not basePos or not player.Character then return end
    local hrp = player.Character.HumanoidRootPart
    local bv = Instance.new("BodyVelocity", hrp)
    bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    
    -- Bay lên rồi tới
    bv.Velocity = Vector3.new(0, 80, 0)
    task.wait(1)
    
    while (hrp.Position - basePos.Position).Magnitude > 15 do
        bv.Velocity = (basePos.Position - hrp.Position).Unit * 150
        task.wait()
    end
    bv:Destroy()
    player.Character:PivotTo(basePos)
end)
