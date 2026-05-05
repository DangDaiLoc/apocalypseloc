local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local camera = workspace.CurrentCamera

-- Khởi tạo GUI (Sử dụng Folder để quản lý nếu cần)
local gui = Instance.new("ScreenGui")
gui.Name = "MobileHub_Fixed"
-- Thử đưa vào CoreGui, nếu không được thì vào PlayerGui
local success, err = pcall(function()
    gui.Parent = game:GetService("CoreGui")
end)
if not success then gui.Parent = player:WaitForChild("PlayerGui") end

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 260, 0, 320)
frame.Position = UDim2.new(0, 20, 0, 80)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true -- Lưu ý: Draggable đã cũ nhưng vẫn chạy được trên nhiều bản exploit

-- Hàm tạo Button nhanh
local function btn(text, x, y, color)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(0, 110, 0, 40)
    b.Position = UDim2.new(0, x, 0, y)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.BackgroundColor3 = color or Color3.fromRGB(50, 50, 50)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextSize = 14
    
    local corner = Instance.new("UICorner", b)
    corner.CornerRadius = ToolPoint.new(0, 8)
    return b
end

-- UI Elements
local saveBtn = btn("📍 Save Base", 10, 10, Color3.fromRGB(40, 100, 40))
local tpBtn = btn("🚀 Teleport", 130, 10, Color3.fromRGB(40, 40, 100))
local flyBtn = btn("🕊 Fly: OFF", 10, 60, Color3.fromRGB(100, 40, 40))
local flyBaseBtn = btn("☁ Auto Base", 130, 60, Color3.fromRGB(100, 80, 0))

local up = btn("↑", 90, 130)
local down = btn("↓", 90, 200)
local left = btn("←", 10, 165)
local right = btn("→", 170, 165)

-- Biến điều khiển
local basePos = nil
local flying = false
local speed = 60
local moveDir = Vector3.zero
local flyConnection = nil

-- Lưu vị trí
saveBtn.MouseButton1Click:Connect(function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        basePos = player.Character.HumanoidRootPart.CFrame
        saveBtn.Text = "✅ Saved!"
        task.wait(1)
        saveBtn.Text = "📍 Save Base"
    end
end)

-- Teleport tức thời
tpBtn.MouseButton1Click:Connect(function()
    if basePos and player.Character then
        player.Character:PivotTo(basePos)
    end
end)

-- Hệ thống Fly
local function startFly()
    local char = player.Character
    if not char then return end
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")

    local bv = Instance.new("BodyVelocity")
    bv.Name = "FlyVelocity"
    bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    bv.Velocity = Vector3.zero
    bv.Parent = hrp

    local bg = Instance.new("BodyGyro") -- Giữ nhân vật thẳng đứng
    bg.Name = "FlyGyro"
    bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp

    hum.PlatformStand = true

    flyConnection = runService.RenderStepped:Connect(function()
        if not flying then 
            bv:Destroy()
            bg:Destroy()
            hum.PlatformStand = false
            flyConnection:Disconnect()
            return 
        end
        
        -- Tính toán hướng bay dựa trên Camera
        local look = camera.CFrame.LookVector
        local rightVec = camera.CFrame.RightVector
        local finalVel = Vector3.zero
        
        if moveDir.Z > 0 then finalVel = finalVel + look end
        if moveDir.Z < 0 then finalVel = finalVel - look end
        if moveDir.X > 0 then finalVel = finalVel + rightVec end
        if moveDir.X < 0 then finalVel = finalVel - rightVec end
        if moveDir.Y ~= 0 then finalVel = finalVel + Vector3.new(0, moveDir.Y, 0) end

        bv.Velocity = finalVel * speed
        bg.CFrame = camera.CFrame
    end)
end

flyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    if flying then
        flyBtn.Text = "🕊 Fly: ON"
        flyBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
        startFly()
    else
        flyBtn.Text = "🕊 Fly: OFF"
        flyBtn.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
    end
end)

-- Điều khiển hướng (Z là tiến lùi, X là trái phải, Y là lên xuống)
up.MouseButton1Down:Connect(function() moveDir = Vector3.new(0, 0, 1) end)
down.MouseButton1Down:Connect(function() moveDir = Vector3.new(0, 0, -1) end)
left.MouseButton1Down:Connect(function() moveDir = Vector3.new(-1, 0, 0) end)
right.MouseButton1Down:Connect(function() moveDir = Vector3.new(1, 0, 0) end)

-- Nút phụ cho Bay lên/xuống (Bạn có thể thêm nút nếu cần, ở đây mình gán tạm cho hướng)
-- Để đơn giản trên mobile, nút Up/Down sẽ là tiến/lùi theo camera.

local function stopMoving() moveDir = Vector3.zero end
up.MouseButton1Up:Connect(stopMoving)
down.MouseButton1Up:Connect(stopMoving)
left.MouseButton1Up:Connect(stopMoving)
right.MouseButton1Up:Connect(stopMoving)

-- Bay về Base mượt mà
flyBaseBtn.MouseButton1Click:Connect(function()
    if not basePos or not player.Character then return end
    local hrp = player.Character.HumanoidRootPart
    
    flying = false -- Tắt fly thường để tránh xung đột
    
    local bv = Instance.new("BodyVelocity", hrp)
    bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    
    -- Bay lên cao trước để tránh vật cản
    bv.Velocity = Vector3.new(0, 100, 0)
    task.wait(1.5)
    
    -- Di chuyển tới base
    while (hrp.Position - basePos.Position).Magnitude > 10 do
        local direction = (basePos.Position - hrp.Position).Unit
        bv.Velocity = direction * 150
        task.wait()
    end
    
    bv:Destroy()
    player.Character:PivotTo(basePos)
end)
