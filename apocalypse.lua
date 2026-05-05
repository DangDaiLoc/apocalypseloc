local player = game.Players.LocalPlayer
local guiParent = game:GetService("CoreGui")

local gui = Instance.new("ScreenGui")
gui.Name = "TrollGui_MAX"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = guiParent

local frame = Instance.new("Frame")
frame.Size = UDim2.new(1,0,1,0)
frame.BackgroundColor3 = Color3.new(0,0,0)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui

local text = Instance.new("TextLabel")
text.Size = UDim2.new(1,0,0.7,0)
text.Position = UDim2.new(0,0,0.15,0)
text.BackgroundTransparency = 1
text.TextColor3 = Color3.fromRGB(255, 0, 0)
text.TextScaled = true
text.Font = Enum.Font.Code
text.Text = ""
text.Parent = frame

-- Dòng ký tự chạy loạn
local randomText = Instance.new("TextLabel")
randomText.Size = UDim2.new(1,0,0.2,0)
randomText.Position = UDim2.new(0,0,0.8,0)
randomText.BackgroundTransparency = 1
randomText.TextColor3 = Color3.fromRGB(0,255,0)
randomText.TextScaled = true
randomText.Font = Enum.Font.Code
randomText.Parent = frame

task.spawn(function()
    local chars = {"#", "%", "@", "!", "$", "&", "*"}
    while true do
        local str = ""
        for i = 1, 40 do
            str = str .. chars[math.random(1,#chars)]
        end
        randomText.Text = str
        task.wait(0.1)
    end
end)

-- Nhấp nháy
task.spawn(function()
    while true do
        text.Visible = not text.Visible
        task.wait(0.6)
    end
end)

-- Nội dung chính
local message = ">>> CANH BAO !!!\n>>> ERROR CODE: 0x9F23A\n>>> DANG TRUY XUAT DU LIEU..."
for i = 1, #message do
    text.Text = string.sub(message, 1, i)
    task.wait(0.03)
end

task.wait(8)

-- Lật kèo
text.Visible = true
text.TextColor3 = Color3.new(1,1,1)
text.Text = ">>> OK ROI :))\n>>> BAN VUA BI TROLL BOI LOC SHADOW <<<"

task.wait(3)

gui:Destroy()
