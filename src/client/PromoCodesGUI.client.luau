local players = game:GetService("Players")
local repStorage = game:GetService("ReplicatedStorage")

local player = players.LocalPlayer
local redeemFunc = repStorage:WaitForChild("RedeemCodeFunc")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PromoCodesGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- 1. Кнопка открытия слева над наградами
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 140, 0, 48)
openBtn.Position = UDim2.new(0, 15, 0.5, -140)
openBtn.BackgroundColor3 = Color3.fromRGB(50, 140, 240)
openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
openBtn.Font = Enum.Font.GothamBlack
openBtn.TextSize = 17
openBtn.Text = "🎟️ КОДЫ"
openBtn.Parent = screenGui
local c1 = Instance.new("UICorner")
c1.CornerRadius = UDim.new(0, 12)
c1.Parent = openBtn

-- 2. Окно ввода промокода
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 380, 0, 230)
mainFrame.Position = UDim2.new(0.5, -190, 0.5, -115)
mainFrame.BackgroundColor3 = Color3.fromRGB(22, 26, 38)
mainFrame.Visible = false
mainFrame.Parent = screenGui
local c2 = Instance.new("UICorner")
c2.CornerRadius = UDim.new(0, 16)
c2.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 0, 45)
title.Position = UDim2.new(0, 15, 0, 5)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(100, 185, 255)
title.Font = Enum.Font.GothamBlack
title.TextSize = 21
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "🎟️ ВВЕДИТЕ ПРОМОКОД"
title.Parent = mainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 36, 0, 36)
closeBtn.Position = UDim2.new(1, -44, 0, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Text = "X"
closeBtn.Parent = mainFrame
local c3 = Instance.new("UICorner")
c3.CornerRadius = UDim.new(0, 8)
c3.Parent = closeBtn

local codeBox = Instance.new("TextBox")
codeBox.Size = UDim2.new(1, -30, 0, 48)
codeBox.Position = UDim2.new(0, 15, 0, 58)
codeBox.BackgroundColor3 = Color3.fromRGB(35, 42, 62)
codeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
codeBox.PlaceholderText = "Например: RELEASE"
codeBox.Text = ""
codeBox.Font = Enum.Font.GothamBold
codeBox.TextSize = 18
codeBox.Parent = mainFrame
local c4 = Instance.new("UICorner")
c4.CornerRadius = UDim.new(0, 10)
c4.Parent = codeBox

local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(1, -30, 0, 28)
statusLbl.Position = UDim2.new(0, 15, 0, 114)
statusLbl.BackgroundTransparency = 1
statusLbl.TextColor3 = Color3.fromRGB(180, 195, 220)
statusLbl.Font = Enum.Font.GothamBold
statusLbl.TextSize = 14
statusLbl.Text = "Ищи новые коды в описании игры!"
statusLbl.Parent = mainFrame

local submitBtn = Instance.new("TextButton")
submitBtn.Size = UDim2.new(1, -30, 0, 48)
submitBtn.Position = UDim2.new(0, 15, 1, -62)
submitBtn.BackgroundColor3 = Color3.fromRGB(45, 185, 100)
submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
submitBtn.Font = Enum.Font.GothamBlack
submitBtn.TextSize = 18
submitBtn.Text = "АКТИВИРОВАТЬ"
submitBtn.Parent = mainFrame
local c5 = Instance.new("UICorner")
c5.CornerRadius = UDim.new(0, 10)
c5.Parent = submitBtn

local busy = false
submitBtn.MouseButton1Click:Connect(function()
	if busy then return end
	busy = true
	statusLbl.Text = "Проверка кода..."
	statusLbl.TextColor3 = Color3.fromRGB(200, 200, 200)

	local success, message = redeemFunc:InvokeServer(codeBox.Text)
	statusLbl.Text = message or "Ошибка"
	statusLbl.TextColor3 = success and Color3.fromRGB(80, 255, 130) or Color3.fromRGB(255, 95, 95)

	if success then
		codeBox.Text = ""
	end
	task.wait(0.5)
	busy = false
end)

openBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
end)

closeBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
end)
