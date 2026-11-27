local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local uis = game:GetService("UserInputService")
local hitmarkerEvent = game.ReplicatedStorage:WaitForChild("HitmarkerEvent")

-- Создаем экранный контейнер
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ShooterHUD"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Звук попадания (щелчок хитмаркера)
local hitSound = Instance.new("Sound")
hitSound.SoundId = "rbxassetid://160432334"
hitSound.Volume = 0.8
hitSound.Parent = screenGui

-- Центральная точка прицела
local centerDot = Instance.new("Frame")
centerDot.Size = UDim2.new(0, 4, 0, 4)
centerDot.Position = UDim2.new(0.5, -2, 0.5, -2)
centerDot.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
centerDot.BorderSizePixel = 0
centerDot.Visible = false
centerDot.Parent = screenGui

local lines = {} -- Запоминаем все полоски прицела, чтобы менять их цвет

local function createLine(sizeX, sizeY, offsetX, offsetY)
	local line = Instance.new("Frame")
	line.Size = UDim2.new(0, sizeX, 0, sizeY)
	line.Position = UDim2.new(0.5, offsetX, 0.5, offsetY)
	line.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
	line.BorderSizePixel = 0
	line.Parent = centerDot
	table.insert(lines, line)
end

createLine(2, 10, -1, -16) -- Верх
createLine(2, 10, -1, 6)   -- Низ
createLine(10, 2, -16, -1) -- Лево
createLine(10, 2, 6, -1)   -- Право

-- Функция смены цвета всего прицела
local function setCrosshairColor(color)
	centerDot.BackgroundColor3 = color
	for _, line in ipairs(lines) do
		line.BackgroundColor3 = color
	end
end

-- Реакция на попадание во врага
hitmarkerEvent.OnClientEvent:Connect(function(isKill)
	hitSound:Play()
	-- Если убили — ярко-красный цвет, если просто ранили — оранжевый
	if isKill then
		setCrosshairColor(Color3.fromRGB(255, 30, 30))
	else
		setCrosshairColor(Color3.fromRGB(255, 180, 0))
	end

	task.wait(0.12)
	setCrosshairColor(Color3.fromRGB(0, 255, 100)) -- Возвращаем зеленый
end)

-- Показываем прицел только с оружием в руках
local function watchCharacter(character)
	character.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then
			centerDot.Visible = true
			uis.MouseIconEnabled = false
		end
	end)

	character.ChildRemoved:Connect(function(child)
		if child:IsA("Tool") then
			centerDot.Visible = false
			uis.MouseIconEnabled = true
		end
	end)
end

if player.Character then
	watchCharacter(player.Character)
end
player.CharacterAdded:Connect(watchCharacter)
