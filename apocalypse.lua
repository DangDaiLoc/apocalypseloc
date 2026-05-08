--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

-- Fix respawn
plr.CharacterAdded:Connect(function(c)
	char = c
	hrp = char:WaitForChild("HumanoidRootPart")
	hum = char:WaitForChild("Humanoid")
end)

--// GUI
local gui = Instance.new("ScreenGui", game.CoreGui)

local toggle = Instance.new("TextButton", gui)
toggle.Size = UDim2.new(0,40,0,40)
toggle.Position = UDim2.new(0,10,0,10)
toggle.Text = "☰"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,160,0,190)
frame.Position = UDim2.new(0,20,0,60)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)

-- Input
local heightBox = Instance.new("TextBox", frame)
heightBox.PlaceholderText = "Power"
heightBox.Size = UDim2.new(1,-10,0,25)
heightBox.Position = UDim2.new(0,5,0,5)

local speedBox = Instance.new("TextBox", frame)
speedBox.PlaceholderText = "Speed"
speedBox.Size = UDim2.new(1,-10,0,25)
speedBox.Position = UDim2.new(0,5,0,35)

-- Buttons
local upBtn = Instance.new("TextButton", frame)
upBtn.Text = "↑"
upBtn.Size = UDim2.new(0.5,-7,0,30)
upBtn.Position = UDim2.new(0,5,0,70)

local downBtn = Instance.new("TextButton", frame)
downBtn.Text = "↓"
downBtn.Size = UDim2.new(0.5,-7,0,30)
downBtn.Position = UDim2.new(0.5,2,0,70)

local noclipBtn = Instance.new("TextButton", frame)
noclipBtn.Text = "Noclip: OFF"
noclipBtn.Size = UDim2.new(1,-10,0,30)
noclipBtn.Position = UDim2.new(0,5,0,105)

local blockBtn = Instance.new("TextButton", frame)
blockBtn.Text = "Block: OFF"
blockBtn.Size = UDim2.new(1,-10,0,30)
blockBtn.Position = UDim2.new(0,5,0,140)

-- Toggle menu
local open = true
toggle.MouseButton1Click:Connect(function()
	open = not open
	frame.Visible = open
end)

--// HOLD MOVE (GIỮ NÚT)
local holdingUp = false
local holdingDown = false

upBtn.MouseButton1Down:Connect(function()
	holdingUp = true
end)

upBtn.MouseButton1Up:Connect(function()
	holdingUp = false
end)

downBtn.MouseButton1Down:Connect(function()
	holdingDown = true
end)

downBtn.MouseButton1Up:Connect(function()
	holdingDown = false
end)

-- Loop di chuyển
RunService.RenderStepped:Connect(function()
	if hrp and hum then
		local speed = tonumber(speedBox.Text) or 16
		local power = tonumber(heightBox.Text) or 2
		
		hum.WalkSpeed = speed
		
		if holdingUp then
			hrp.CFrame = hrp.CFrame + Vector3.new(0, power * 0.2, 0)
		end
		
		if holdingDown then
			hrp.CFrame = hrp.CFrame - Vector3.new(0, power * 0.2, 0)
		end
	end
end)

--// NOCLIP
local noclip = false
noclipBtn.MouseButton1Click:Connect(function()
	noclip = not noclip
	noclipBtn.Text = noclip and "Noclip: ON" or "Noclip: OFF"
end)

RunService.Stepped:Connect(function()
	if noclip and char then
		for _,v in pairs(char:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
	end
end)

--// BLOCK DƯỚI CHÂN
local block = Instance.new("Part")
block.Size = Vector3.new(6,1,6)
block.Anchored = true
block.CanCollide = true
block.Massless = true
block.Transparency = 0.4
block.Parent = workspace

local blockOn = false

blockBtn.MouseButton1Click:Connect(function()
	blockOn = not blockOn
	blockBtn.Text = blockOn and "Block: ON" or "Block: OFF"
end)

RunService.RenderStepped:Connect(function()
	if blockOn and hrp then
		block.Position = hrp.Position - Vector3.new(0,3.5,0)
	end
end)
