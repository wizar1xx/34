local players = game:GetService("Players")
local marketplace = game:GetService("MarketplaceService")
local player = players.LocalPlayer

-- ВПИШИ СЮДА ТЕ ЖЕ САМЫЕ ID С САЙТА ://roblox.com:
local PASS_2X_CRYSTALS = 2100433750      -- ID геймпаса "2x Кристаллы и Fame"
local PASS_VIP_SPEED = 0       -- ID геймпаса "VIP Скорость"
local PRODUCT_METEOR_RAIN = 0  -- ID продукта "+250 Кристаллов"

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ShopScreenGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- 1. Кнопка открытия магазина слева на экране
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 140, 0, 48)
openBtn.Position = UDim2.new(0, 15, 0.5, -24)
openBtn.BackgroundColor3 = Color3.fromRGB(255, 185, 0)
openBtn.TextColor3 = Color3.fromRGB(25, 25, 25)
openBtn.Font = Enum.Font.GothamBlack
openBtn.TextSize = 18
openBtn.Text = "💎 МАГАЗИН"
openBtn.Parent = screenGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 12)
btnCorner.Parent = openBtn

-- 2. Главное окно магазина по центру экрана
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 420, 0, 320)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(22, 26, 38)
mainFrame.Visible = false
mainFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 16)
frameCorner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 0, 45)
title.Position = UDim2.new(0, 15, 0, 5)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.Font = Enum.Font.GothamBlack
title.TextSize = 22
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "💎 МАГАЗИН УСИЛЕНИЙ"
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

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

-- Функция создания карточки товара
local function createItemButton(yPos, itemName, descText, btnColor, onClick)
	local itemFrame = Instance.new("Frame")
	itemFrame.Size = UDim2.new(1, -30, 0, 72)
	itemFrame.Position = UDim2.new(0, 15, 0, yPos)
	itemFrame.BackgroundColor3 = Color3.fromRGB(34, 40, 58)
	itemFrame.Parent = mainFrame

	local itemCorner = Instance.new("UICorner")
	itemCorner.CornerRadius = UDim.new(0, 10)
	itemCorner.Parent = itemFrame

	local nameLbl = Instance.new("TextLabel")
	nameLbl.Size = UDim2.new(0.65, 0, 0, 28)
	nameLbl.Position = UDim2.new(0, 12, 0, 8)
	nameLbl.BackgroundTransparency = 1
	nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLbl.Font = Enum.Font.GothamBold
	nameLbl.TextSize = 17
	nameLbl.TextXAlignment = Enum.TextXAlignment.Left
	nameLbl.Text = itemName
	nameLbl.Parent = itemFrame

	local descLbl = Instance.new("TextLabel")
	descLbl.Size = UDim2.new(0.65, 0, 0, 24)
	descLbl.Position = UDim2.new(0, 12, 0, 38)
	descLbl.BackgroundTransparency = 1
	descLbl.TextColor3 = Color3.fromRGB(180, 190, 210)
	descLbl.Font = Enum.Font.Gotham
	descLbl.TextSize = 13
	descLbl.TextXAlignment = Enum.TextXAlignment.Left
	descLbl.Text = descText
	descLbl.Parent = itemFrame

	local buyBtn = Instance.new("TextButton")
	buyBtn.Size = UDim2.new(0.28, 0, 0, 44)
	buyBtn.Position = UDim2.new(0.69, 0, 0.5, -22)
	buyBtn.BackgroundColor3 = btnColor
	buyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	buyBtn.Font = Enum.Font.GothamBlack
	buyBtn.TextSize = 15
	buyBtn.Text = "КУПИТЬ"
	buyBtn.Parent = itemFrame

	local buyCorner = Instance.new("UICorner")
	buyCorner.CornerRadius = UDim.new(0, 8)
	buyCorner.Parent = buyBtn

	buyBtn.MouseButton1Click:Connect(onClick)
end

-- Добавляем 3 товара в окно магазина
createItemButton(60, "⚡ 2x Кристаллы и Fame", "Навсегда удваивает добычу!", Color3.fromRGB(40, 180, 90), function()
	if PASS_2X_CRYSTALS > 0 then
		marketplace:PromptGamePassPurchase(player, PASS_2X_CRYSTALS)
	end
end)

createItemButton(142, "👑 VIP Скорость (+50%)", "Бегай быстрее всех на сервере!", Color3.fromRGB(230, 150, 20), function()
	if PASS_VIP_SPEED > 0 then
		marketplace:PromptGamePassPurchase(player, PASS_VIP_SPEED)
	end
end)

createItemButton(224, "🌠 +250 Кристаллов", "Мгновенный буст для стройки!", Color3.fromRGB(140, 70, 230), function()
	if PRODUCT_METEOR_RAIN > 0 then
		marketplace:PromptProductPurchase(player, PRODUCT_METEOR_RAIN)
	end
end)

openBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
end)

closeBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
end)
