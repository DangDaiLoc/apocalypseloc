-- GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "ApocalypseLitePlus"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 230, 0, 270)
Frame.Position = UDim2.new(0, 20, 0, 100)
Frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
Frame.Active = true
Frame.Draggable = true

local function btn(text, y)
    local b = Instance.new("TextButton", Frame)
    b.Size = UDim2.new(0, 210, 0, 35)
    b.Position = UDim2.new(0, 10, 0, y)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(45,45,45)
    b.TextColor3 = Color3.new(1,1,1)
    return b
end

-- biến
local basePos, flying, farming, autoLoot, autoFix = nil, false, false, false, false

-- nút
local save = btn("📍 Lưu Base", 10)
local tp = btn("🚀 Về Base", 50)
local fly = btn("🕊 Fly: OFF", 90)
local farm = btn("⚔ Aura Farm: OFF", 130)
local loot = btn("📦 Loot Rương: OFF", 170)
local fix = btn("⚡ Auto Fix Điện: OFF", 210)

-- lưu base
save.MouseButton1Click:Connect(function()
    basePos = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
    save.Text = "✅ Đã lưu!"
end)

-- tp base
tp.MouseButton1Click:Connect(function()
    if basePos then
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = basePos
    end
end)

-- fly
fly.MouseButton1Click:Connect(function()
    flying = not flying
    fly.Text = flying and "🕊 Fly: ON" or "🕊 Fly: OFF"

    if flying then
        local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
        local bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(9e9,9e9,9e9)

        game:GetService("RunService").RenderStepped:Connect(function()
            if not flying then bv:Destroy() return end
            bv.Velocity = workspace.CurrentCamera.CFrame.LookVector * 60
        end)
    end
end)

-- aura farm
farm.MouseButton1Click:Connect(function()
    farming = not farming
    farm.Text = farming and "⚔ Aura Farm: ON" or "⚔ Aura Farm: OFF"

    while farming do
        for _,v in pairs(workspace:GetDescendants()) do
            if v:FindFirstChild("Humanoid") and v.Name:lower():find("zombie") then
                local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
                local dist = (hrp.Position - v.HumanoidRootPart.Position).Magnitude
                
                if dist < 20 then
                    pcall(function()
                        v.Humanoid:TakeDamage(10)
                    end)
                end
            end
        end
        wait(0.2)
    end
end)

-- loot rương
loot.MouseButton1Click:Connect(function()
    autoLoot = not autoLoot
    loot.Text = autoLoot and "📦 Loot Rương: ON" or "📦 Loot Rương: OFF"

    while autoLoot do
        for _,v in pairs(workspace:GetDescendants()) do
            if v.Name:lower():find("crate") or v.Name:lower():find("chest") then
                pcall(function()
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame
                end)
                wait(0.3)
            end
        end
        wait(1)
    end
end)

-- auto fix điện (generator / power box)
fix.MouseButton1Click:Connect(function()
    autoFix = not autoFix
    fix.Text = autoFix and "⚡ Auto Fix Điện: ON" or "⚡ Auto Fix Điện: OFF"

    while autoFix do
        for _,v in pairs(workspace:GetDescendants()) do
            if v.Name:lower():find("generator") or v.Name:lower():find("power") then
                pcall(function()
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame
                end)
                
                -- spam interact (E)
                for i = 1,5 do
                    game:GetService("VirtualInputManager"):SendKeyEvent(true,"E",false,game)
                    wait(0.1)
                    game:GetService("VirtualInputManager"):SendKeyEvent(false,"E",false,game)
                end
            end
        end
        wait(2)
    end
end)
