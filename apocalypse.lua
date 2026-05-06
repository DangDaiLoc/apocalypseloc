-- SURVIVE THE APOCALYPSE - AUTO BASE + NE ZOMBIE
-- Chay bang Executor (Synapse X, KRNL, Fluxus...)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

-- === CAU HINH ===
local Config = {
    BasePosition = Vector3.new(0, 0, 0), -- Se cap nhat khi an Set Base
    AvoidRadius = 20,
    SafeDistance = 15,
    HPThreshold = 30,
    AutoReturn = false,
    AvoidZombies = true,
    EmergencyReturn = true,
}

-- === GUI ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ApocalypseBot"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = lp.PlayerGui

-- Toggle Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 48, 0, 48)
ToggleBtn.Position = UDim2.new(1, -70, 0, 20)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
ToggleBtn.Text = "☣"
ToggleBtn.TextSize = 22
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextColor3 = Color3.fromRGB(0,0,0)
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

-- Main Panel
local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 280, 0, 420)
Panel.Position = UDim2.new(1, -290, 0, 75)
Panel.BackgroundColor3 = Color3.fromRGB(5, 15, 5)
Panel.BorderSizePixel = 0
Panel.Visible = true
Panel.Parent = ScreenGui
Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", Panel).Color = Color3.fromRGB(0, 180, 0)

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 36)
Title.BackgroundColor3 = Color3.fromRGB(0, 30, 0)
Title.Text = "☣  APOCALYPSE BOT"
Title.TextColor3 = Color3.fromRGB(0, 255, 0)
Title.TextSize = 14
Title.Font = Enum.Font.Code
Title.Parent = Panel
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)

-- Status
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -10, 0, 24)
StatusLabel.Position = UDim2.new(0, 5, 0, 40)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "● STANDBY"
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = Panel

-- Helper: tao nut toggle
local function makeToggle(yPos, labelText, defaultOn)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -10, 0, 28)
    row.Position = UDim2.new(0, 5, 0, yPos)
    row.BackgroundTransparency = 1
    row.Parent = Panel

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 44, 0, 22)
    btn.Position = UDim2.new(1, -46, 0.5, -11)
    btn.Text = defaultOn and "BẬT" or "TẮT"
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = defaultOn and Color3.fromRGB(0,150,0) or Color3.fromRGB(80,0,0)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Parent = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,4)

    local state = defaultOn
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "BẬT" or "TẮT"
        btn.BackgroundColor3 = state and Color3.fromRGB(0,150,0) or Color3.fromRGB(80,0,0)
    end)
    return function() return state end
end

-- Helper: tao nut chinh
local function makeButton(yPos, txt, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.45, 0, 0, 30)
    btn.Position = UDim2.new(color == "stop" and 0.52 or 0.03, 0, 0, yPos)
    btn.BackgroundColor3 = color == "stop" and Color3.fromRGB(120,0,0) or color == "base" and Color3.fromRGB(0,0,120) or Color3.fromRGB(0,100,0)
    btn.Text = txt
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.Parent = Panel
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,5)
    return btn
end

local getAutoReturn = makeToggle(68, "Auto Về Base", false)
local getAvoidZombie = makeToggle(100, "Né Zombie", true)
local getEmergency = makeToggle(132, "Khẩn Cấp HP Thấp", true)

local BtnStart = makeButton(168, "▶ BẮT ĐẦU", "start")
local BtnStop = makeButton(168, "■ DỪNG", "stop")

local BtnBase = Instance.new("TextButton")
BtnBase.Size = UDim2.new(0.94, 0, 0, 28)
BtnBase.Position = UDim2.new(0.03, 0, 0, 206)
BtnBase.BackgroundColor3 = Color3.fromRGB(0, 0, 100)
BtnBase.Text = "📍 ĐẶT VỊ TRÍ BASE (đứng tại base rồi nhấn)"
BtnBase.TextColor3 = Color3.fromRGB(150, 180, 255)
BtnBase.TextSize = 11
BtnBase.Font = Enum.Font.Gotham
BtnBase.Parent = Panel
Instance.new("UICorner", BtnBase).CornerRadius = UDim.new(0,5)

-- HP Bar
local HPLabel = Instance.new("TextLabel")
HPLabel.Size = UDim2.new(1,-10,0,16)
HPLabel.Position = UDim2.new(0,5,0,242)
HPLabel.BackgroundTransparency=1
HPLabel.Text="HP: 100%"
HPLabel.TextColor3=Color3.fromRGB(0,220,0)
HPLabel.TextSize=11
HPLabel.Font=Enum.Font.Code
HPLabel.TextXAlignment=Enum.TextXAlignment.Left
HPLabel.Parent=Panel

local HPTrack = Instance.new("Frame")
HPTrack.Size = UDim2.new(1,-10,0,8)
HPTrack.Position = UDim2.new(0,5,0,260)
HPTrack.BackgroundColor3 = Color3.fromRGB(20,40,20)
HPTrack.Parent = Panel
Instance.new("UICorner",HPTrack).CornerRadius=UDim.new(0,4)

local HPFill = Instance.new("Frame")
HPFill.Size = UDim2.new(1,0,1,0)
HPFill.BackgroundColor3 = Color3.fromRGB(0,200,0)
HPFill.Parent = HPTrack
Instance.new("UICorner",HPFill).CornerRadius=UDim.new(0,4)

-- Log
local LogLabel = Instance.new("TextLabel")
LogLabel.Size = UDim2.new(1,-10,0,100)
LogLabel.Position = UDim2.new(0,5,0,278)
LogLabel.BackgroundColor3 = Color3.fromRGB(0,10,0)
LogLabel.TextColor3 = Color3.fromRGB(0,200,0)
LogLabel.TextSize = 10
LogLabel.Font = Enum.Font.Code
LogLabel.TextXAlignment = Enum.TextXAlignment.Left
LogLabel.TextYAlignment = Enum.TextYAlignment.Top
LogLabel.TextWrapped = true
LogLabel.Text = "[ Nhật ký ]\n"
LogLabel.Parent = Panel
Instance.new("UICorner",LogLabel).CornerRadius=UDim.new(0,5)

local logs = {}
local function addLog(msg)
    table.insert(logs, 1, os.date("%H:%M:%S").." "..msg)
    if #logs > 8 then table.remove(logs) end
    LogLabel.Text = "[ Nhật ký ]\n"..table.concat(logs,"\n")
end

-- === LOGIC ===
local running = false
local botConn = nil

local function getZombies()
    local result = {}
    local pos = hrp.Position
    for _, obj in ipairs(workspace:GetDescendants()) do
        local name = obj.Name:lower()
        if (name:find("zombie") or name:find("enemy") or name:find("infected")) then
            local zhrp = obj:FindFirstChild("HumanoidRootPart")
            if zhrp then
                local d = (pos - zhrp.Position).Magnitude
                if d < Config.AvoidRadius * 2 then
                    table.insert(result, {pos=zhrp.Position, dist=d, name=obj.Name})
                end
            end
        end
    end
    return result
end

local function computeTarget()
    local cur = hrp.Position
    local base = Config.BasePosition
    local toBase = (base - cur)
    local dist = toBase.Magnitude
    if dist < 3 then return nil, dist end

    local dir = toBase.Unit
    local zombies = getZombies()
    local avoidX, avoidZ = 0, 0

    for _, z in ipairs(zombies) do
        if z.dist < Config.AvoidRadius then
            local away = (cur - z.pos)
            local strength = math.max(0, Config.AvoidRadius - z.dist) / Config.AvoidRadius
            avoidX = avoidX + away.X/z.dist * strength * 2
            avoidZ = avoidZ + away.Z/z.dist * strength * 2
        end
    end

    local weight = math.min(#zombies * 0.35, 0.85)
    local fx = dir.X*(1-weight) + avoidX*weight
    local fz = dir.Z*(1-weight) + avoidZ*weight
    local fmag = math.sqrt(fx*fx+fz*fz)
    if fmag < 0.001 then fmag = 0.001 end

    local target = Vector3.new(cur.X + fx/fmag*5, base.Y, cur.Z + fz/fmag*5)
    return target, dist, #zombies
end

local function updateHP()
    local pct = (hum.Health / hum.MaxHealth) * 100
    HPFill.Size = UDim2.new(math.clamp(pct/100,0,1),0,1,0)
    HPFill.BackgroundColor3 = pct<=30 and Color3.fromRGB(200,0,0) or pct<=60 and Color3.fromRGB(200,150,0) or Color3.fromRGB(0,200,0)
    HPLabel.Text = string.format("HP: %.0f%%  (%.0f / %.0f)", pct, hum.Health, hum.MaxHealth)
    return pct
end

local function startBot()
    if running then return end
    running = true
    addLog("Bot khởi động")
    StatusLabel.Text = "● ĐANG HOẠT ĐỘNG"
    StatusLabel.TextColor3 = Color3.fromRGB(0,255,0)

    botConn = RunService.Heartbeat:Connect(function()
        -- Cap nhat HP
        local hpPct = updateHP()

        -- Kiem tra emergency
        if Config.EmergencyReturn and hpPct <= Config.HPThreshold and not Config.AutoReturn then
            Config.AutoReturn = true
            addLog("⚠ HP thấp! Về base khẩn cấp!")
            StatusLabel.Text = "● KHẨN CẤP - VỀ BASE"
            StatusLabel.TextColor3 = Color3.fromRGB(255,80,0)
        end

        if not (getAutoReturn() or Config.AutoReturn) then return end

        local target, dist, zombieCount = computeTarget()

        if target == nil then
            addLog("✅ Đã về base!")
            Config.AutoReturn = false
            StatusLabel.Text = "● TẠI BASE"
            StatusLabel.TextColor3 = Color3.fromRGB(0,200,255)
            return
        end

        hum:MoveTo(target)

        if zombieCount and zombieCount > 0 then
            StatusLabel.Text = string.format("● NÉ %d ZOMBIE | %.1fm", zombieCount, dist)
            StatusLabel.TextColor3 = Color3.fromRGB(255,50,50)
        else
            StatusLabel.Text = string.format("● VỀ BASE | %.1fm còn lại", dist)
            StatusLabel.TextColor3 = Color3.fromRGB(0,255,100)
        end
    end)
end

local function stopBot()
    running = false
    Config.AutoReturn = false
    if botConn then botConn:Disconnect(); botConn = nil end
    addLog("Bot đã dừng")
    StatusLabel.Text = "● STANDBY"
    StatusLabel.TextColor3 = Color3.fromRGB(150,150,150)
end

-- Events
ToggleBtn.MouseButton1Click:Connect(function()
    Panel.Visible = not Panel.Visible
end)

BtnStart.MouseButton1Click:Connect(function()
    Config.AutoReturn = true
    startBot()
    addLog("Auto về base: BẬT")
end)

BtnStop.MouseButton1Click:Connect(function()
    stopBot()
end)

BtnBase.MouseButton1Click:Connect(function()
    Config.BasePosition = hrp.Position
    addLog(string.format("📍 Base: X=%.1f Z=%.1f", hrp.Position.X, hrp.Position.Z))
end)

-- Khoi dong
startBot()
addLog("Đứng tại base → nhấn ĐẶT VỊ TRÍ BASE")
addLog("Sau đó nhấn BẮT ĐẦU để bot hoạt động")
