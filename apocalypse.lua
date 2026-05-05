local player = game.Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "TrollGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(1,0,1,0)
frame.BackgroundColor3 = Color3.new(0,0,0)
frame.Parent = gui

local text = Instance.new("TextLabel")
text.Size = UDim2.new(1,0,1,0)
text.BackgroundTransparency = 1
text.TextColor3 = Color3.new(1,1,1)
text.TextScaled = true
text.Font = Enum.Font.SourceSansBold
text.Text = ""
text.Parent = frame

-- Hiệu ứng gõ chữ
local message = "Phát hiện truy cập bất thường...\nĐang kiểm tra hệ thống..."
for i = 1, #message do
    text.Text = string.sub(message, 1, i)
    task.wait(0.03)
end

task.wait(2)

text.Text = "Đùa thôi, bị troll rồi :))"

task.wait(2)

gui:Destroy()
