local players = game:GetService("Players")
local repStorage = game:GetService("ReplicatedStorage")

local player = players.LocalPlayer
local claimEvent = repStorage:WaitForChild("ClaimDailyEvent")
local getStateFunc = repStorage:WaitForChild("GetDailyState")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DailyRewardsGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- 1. Кнопка открытия слева над магазином
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 140, 0, 48)
openBtn.Position = UDim2.new(0, 15, 0.5, -82)
openBtn.BackgroundColor3 = Color3.fromRGB(45, 195, 110)
openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
openBtn.Font = Enum.Font.GothamBlack
openBtn.TextSize = 17
openBtn.Text = "🎁 НАГРАДЫ"
openBtn.Parent = screenGui
local c1 = Instance.new("UICorner")
c1.CornerRadius = UDim.new(0, 12)
c1.Parent = openBtn

-- 2. Главное окно наград
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 520, 0, 360)
mainFrame.Position = UDim2.new(0.5, -260, 0.5, -180)
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
title.TextColor3 = Color3.fromRGB(100, 255, 150)
title.Font = Enum.Font.GothamBlack
title.TextSize = 22
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "🎁 ЕЖЕДНЕВНЫЕ НАГРАДЫ (7 ДНЕЙ)"
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

-- Контейнер для карточек 7 дней
local gridFrame = Instance.new("Frame")
gridFrame.Size = UDim2.new(1, -30, 0, 220)
gridFrame.Position = UDim2.new(0, 15, 0, 58)
gridFrame.BackgroundTransparency = 1
gridFrame.Parent = mainFrame

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0, 115, 0, 102)
gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
gridLayout.Parent = gridFrame

-- Нижняя кнопка "Забрать" / Таймер
local claimBtn = Instance.new("TextButton")
claimBtn.Size = UDim2.new(1, -30, 0, 52)
claimBtn.Position = UDim2.new(0, 15, 1, -66)
claimBtn.BackgroundColor3 = Color3.fromRGB(40, 190, 95)
claimBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
claimBtn.Font = Enum.Font.GothamBlack
claimBtn.TextSize = 20
claimBtn.Text = "ЗАБРАТЬ НАГРАДУ!"
claimBtn.Parent = mainFrame
local c4 = Instance.new("UICorner")
c4.CornerRadius = UDim.new(0, 12)
c4.Parent = claimBtn

local currentState = nil

local function formatTime(sec)
	local h = math.floor(sec / 3600)
	local m = math.floor((sec % 3600) / 60)
	local s = sec % 60
	return string.format("%02d:%02d:%02d", h, m, s)
end

local function refreshUI()
	currentState = getStateFunc:InvokeServer()
	if not currentState then return end

	for _, child in ipairs(gridFrame:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	for _, item in ipairs(currentState.Rewards) do
		local card = Instance.new("Frame")
		local isToday = (item.Day == currentState.Streak)
		local isDone = (item.Day < currentState.Streak)

		if isToday and currentState.CanClaim then
			card.BackgroundColor3 = Color3.fromRGB(40, 140, 80)
		elseif isToday then
			card.BackgroundColor3 = Color3.fromRGB(55, 65, 95)
		else
			card.BackgroundColor3 = Color3.fromRGB(34, 40, 58)
		end
		card.Parent = gridFrame
		local cc = Instance.new("UICorner")
		cc.CornerRadius = UDim.new(0, 10)
		cc.Parent = card

		local dayLbl = Instance.new("TextLabel")
		dayLbl.Size = UDim2.new(1, 0, 0, 26)
		dayLbl.BackgroundTransparency = 1
		dayLbl.TextColor3 = (item.Day == 7) and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(180, 210, 255)
		dayLbl.Font = Enum.Font.GothamBlack
		dayLbl.TextSize = 15
		dayLbl.Text = "ДЕНЬ " .. item.Day .. (isDone and " ✅" or "")
		dayLbl.Parent = card

		local rewLbl = Instance.new("TextLabel")
		rewLbl.Size = UDim2.new(1, -10, 0, 65)
		rewLbl.Position = UDim2.new(0, 5, 0, 28)
		rewLbl.BackgroundTransparency = 1
		rewLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
		rewLbl.Font = Enum.Font.GothamBold
		rewLbl.TextWrapped = true
		rewLbl.TextSize = 14
		rewLbl.Text = item.Label
		rewLbl.Parent = card
	end

	if currentState.CanClaim then
		claimBtn.BackgroundColor3 = Color3.fromRGB(40, 190, 95)
		claimBtn.Text = "🎁 ЗАБРАТЬ НАГРАДУ ДНЯ " .. currentState.Streak .. "!"
		openBtn.BackgroundColor3 = Color3.fromRGB(45, 195, 110)
	else
		claimBtn.BackgroundColor3 = Color3.fromRGB(80, 85, 105)
		claimBtn.Text = "⏳ СЛЕДУЮЩАЯ ЧЕРЕЗ: " .. formatTime(currentState.TimeLeft)
		openBtn.BackgroundColor3 = Color3.fromRGB(70, 80, 105)
	end
end

claimBtn.MouseButton1Click:Connect(function()
	if currentState and currentState.CanClaim then
		claimEvent:FireServer()
		task.wait(0.3)
		refreshUI()
	end
end)

openBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
	if mainFrame.Visible then
		refreshUI()
	end
end)

closeBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
end)

-- Автоматически открываем окно наград при входе, если награда доступна!
task.spawn(function()
	task.wait(2.5)
	refreshUI()
	if currentState and currentState.CanClaim then
		mainFrame.Visible = true
	end
end)

-- Живой обратный отсчёт таймера каждую секунду
task.spawn(function()
	while task.wait(1) do
		if currentState and not currentState.CanClaim and currentState.TimeLeft > 0 then
			currentState.TimeLeft -= 1
			if mainFrame.Visible then
				claimBtn.Text = "⏳ СЛЕДУЮЩАЯ ЧЕРЕЗ: " .. formatTime(currentState.TimeLeft)
			end
			if currentState.TimeLeft <= 0 then
				refreshUI()
			end
		end
	end
end)
