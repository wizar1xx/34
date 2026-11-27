local players = game:GetService("Players")
local repStorage = game:GetService("ReplicatedStorage")

local statusVal = repStorage:WaitForChild("GameStatus")
local redScore = repStorage:WaitForChild("RedScore")
local blueScore = repStorage:WaitForChild("BlueScore")

local redSpawn = workspace:WaitForChild("RedArenaSpawn")
local blueSpawn = workspace:WaitForChild("BlueArenaSpawn")

local intermissionTime = 15 -- Ожидание в лобби (сек)
local matchDuration = 120   -- Длительность раунда (сек)
local roundActive = false

-- Функция телепортации игрока на базу его команды
local function sendToTeamBase(player)
	local char = player.Character
	local root = char and char:WaitForChild("HumanoidRootPart", 5)
	if not root then return end

	task.wait(0.1) -- Небольшая пауза, чтобы персонаж успел загрузиться
	if player.Team and player.Team.Name == "Red" then
		root.CFrame = redSpawn.CFrame + Vector3.new(0, 3, 0)
	elseif player.Team and player.Team.Name == "Blue" then
		root.CFrame = blueSpawn.CFrame + Vector3.new(0, 3, 0)
	end
end

-- Отслеживаем вход игроков, их возрождение и командные убийства
players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		-- Если раунд прямо сейчас идет, сразу отправляем возродившегося игрока на базу команды
		if roundActive then
			sendToTeamBase(player)
		end

		local hum = char:WaitForChild("Humanoid")
		hum.Died:Connect(function()
			if not roundActive then return end
			local tag = hum:FindFirstChild("creator")
			if tag and tag.Value and tag.Value:IsA("Player") then
				local killer = tag.Value
				if killer.Team and killer.Team.Name == "Red" then
					redScore.Value += 1
				elseif killer.Team and killer.Team.Name == "Blue" then
					blueScore.Value += 1
				end
			end
		end)
	end)
end)

-- Бесконечный цикл смены раундов
while true do
	-- 1. Фаза ожидания в лобби
	roundActive = false
	for i = intermissionTime, 1, -1 do
		statusVal.Value = "Ожидание игроков: " .. i .. " сек."
		task.wait(1)
	end

	-- Сбрасываем счет и начинаем бой
	redScore.Value = 0
	blueScore.Value = 0
	roundActive = true

	-- Отправляем всех на арену
	for _, player in ipairs(players:GetPlayers()) do
		sendToTeamBase(player)
	end

	-- 2. Идет раунд
	for i = matchDuration, 1, -1 do
		statusVal.Value = "Бой идет! Осталось: " .. i .. " сек."
		task.wait(1)
	end

	-- 3. Итоги раунда
	roundActive = false
	if redScore.Value > blueScore.Value then
		statusVal.Value = "Победили КРАСНЫЕ! (" .. redScore.Value .. " : " .. blueScore.Value .. ")"
	elseif blueScore.Value > redScore.Value then
		statusVal.Value = "Победили СИНИЕ! (" .. blueScore.Value .. " : " .. redScore.Value .. ")"
	else
		statusVal.Value = "НИЧЬЯ! (" .. redScore.Value .. " : " .. blueScore.Value .. ")"
	end

	task.wait(5)

	-- Возвращаем всех в лобби
	for _, player in ipairs(players:GetPlayers()) do
		player:LoadCharacter()
	end
end
