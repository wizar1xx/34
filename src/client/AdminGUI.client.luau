local players = game:GetService("Players")
local repStorage = game:GetService("ReplicatedStorage")
local player = players.LocalPlayer
local adminEvent = repStorage:WaitForChild("AdminEvent")

-- Надёжно ждём атрибут IsAdmin до 10 секунд
local waited = 0
while not player:GetAttribute("IsAdmin") and waited < 10 do
	task.wait(0.5)
	waited += 0.5
end
if not player:GetAttribute("IsAdmin") then return end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdminScreenGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 140, 0, 44)
openBtn.Position = UDim2.new(0, 15, 0.5, 34)
openBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 50)
openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
openBtn.Font = Enum.Font.GothamBlack
openBtn.TextSize = 17
openBtn.Text = "🛡️ АДМИН"
openBtn.Parent = screenGui
local c1 = Instance.new("UICorner")
c1.CornerRadius = UDim.new(0, 12)
c1.Parent = openBtn

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 380, 0, 380)
mainFrame.Position = UDim2.new(0.5, -190, 0.5, -190)
mainFrame.BackgroundColor3 = Color3.fromRGB(26, 22, 34)
mainFrame.Visible = false
mainFrame.Parent = screenGui
local c2 = Instance.new("UICorner")
c2.CornerRadius = UDim.new(0, 16)
c2.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 0, 40)
title.Position = UDim2.new(0, 15, 0, 5)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 90, 90)
title.Font = Enum.Font.GothamBlack
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "🛡️ ПУЛЬТ АДМИНИСТРАТОРА"
title.Parent = mainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 34, 0, 34)
closeBtn.Position = UDim2.new(1, -42, 0, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Text = "X"
closeBtn.Parent = mainFrame
local c3 = Instance.new("UICorner")
c3.CornerRadius = UDim.new(0, 8)
c3.Parent = closeBtn

local targetBox = Instance.new("TextBox")
targetBox.Size = UDim2.new(1, -30, 0, 38)
targetBox.Position = UDim2.new(0, 15, 0, 50)
targetBox.BackgroundColor3 = Color3.fromRGB(45, 38, 55)
targetBox.TextColor3 = Color3.fromRGB(255, 255, 255)
targetBox.PlaceholderText = "Ник игрока (пусто = себе) или текст объявления"
targetBox.Text = ""
targetBox.Font = Enum.Font.Gotham
targetBox.TextSize = 14
targetBox.Parent = mainFrame
local c4 = Instance.new("UICorner")
c4.CornerRadius = UDim.new(0, 8)
c4.Parent = targetBox

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -30, 1, -105)
scroll.Position = UDim2.new(0, 15, 0, 96)
scroll.BackgroundTransparency = 1
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 6
scroll.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.Parent = scroll

local function addCmd(text, color, action, extra)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 40)
	btn.BackgroundColor3 = color
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.Text = text
	btn.Parent = scroll
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = btn

	btn.MouseButton1Click:Connect(function()
		adminEvent:FireServer(action, targetBox.Text, extra)
	end)
end

addCmd("💎 Выдать +5 000 Кристаллов", Color3.fromRGB(40, 170, 100), "GiveCrystals", 5000)
addCmd("🔄 Выдать +1 Rebirth (+1000 Fame)", Color3.fromRGB(220, 145, 30), "GiveRebirth", 1)
addCmd("🌠 ИВЕНТ: Метеоритный Дождь (15 радужных)", Color3.fromRGB(180, 50, 210), "MeteorShower")
addCmd("📢 Отправить Объявление на экран всем", Color3.fromRGB(230, 110, 20), "Announce")
addCmd("⚡ Супер-Скорость (Вкл / Выкл)", Color3.fromRGB(45, 120, 220), "SuperSpeed")
addCmd("🦘 Супер-Прыжок (Вкл / Выкл)", Color3.fromRGB(45, 150, 200), "SuperJump")
addCmd("🎈 Космическая Гравитация на сервере", Color3.fromRGB(90, 80, 200), "LowGravity")
addCmd("📍 Телепорт к игроку (TP To)", Color3.fromRGB(60, 140, 140), "TeleportTo")
addCmd("🧲 Притянуть игрока к себе (Bring)", Color3.fromRGB(60, 140, 140), "BringPlayer")
addCmd("👻 Невидимость (Вкл / Выкл)", Color3.fromRGB(90, 90, 110), "Invisible")
addCmd("❄️ Заморозить / Разморозить игрока", Color3.fromRGB(70, 160, 210), "Freeze")
addCmd("👢 Кикнуть игрока с сервера", Color3.fromRGB(190, 45, 45), "KickPlayer")

openBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
end)

closeBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
end)
