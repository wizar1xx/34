local players = game:GetService("Players")
local repStorage = game:GetService("ReplicatedStorage")

local SoundManager = require(repStorage:WaitForChild("Shared"):WaitForChild("SoundManager"))

local buildingsFolder = workspace:WaitForChild("IslandBuildings")
local buttonsFolder = workspace:WaitForChild("BuildButtons")
local rebirthPad = workspace:WaitForChild("RebirthPad")
local powerPad = workspace:WaitForChild("UpgradePowerPad")
local speedPad = workspace:WaitForChild("UpgradeSpeedPad")

local debounce = {}

local function setPadLabel(part, text, color)
	local gui = part:FindFirstChildOfClass("BillboardGui") or Instance.new("BillboardGui")
	gui.Size = UDim2.new(0, 200, 0, 50)
	gui.StudsOffset = Vector3.new(0, 3, 0)
	gui.AlwaysOnTop = true
	gui.Parent = part

	local label = gui:FindFirstChildOfClass("TextLabel") or Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextStrokeTransparency = 0.2
	label.TextColor3 = color or Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.GothamBlack
	label.TextScaled = true
	label.Text = text
	label.Parent = gui
end

setPadLabel(rebirthPad, "REBIRTH (100+ Кристаллов)", Color3.fromRGB(255, 215, 0))
setPadLabel(powerPad, "СИЛА УДАРА (15 Кристаллов)", Color3.fromRGB(255, 100, 100))
setPadLabel(speedPad, "СКОРОСТЬ (15 Кристаллов)", Color3.fromRGB(100, 220, 255))

-- 1. Строительство зданий за кристаллы
for _, btn in ipairs(buttonsFolder:GetChildren()) do
	if btn:IsA("BasePart") then
		local targetVal = btn:FindFirstChild("Target")
		local building = targetVal and buildingsFolder:FindFirstChild(targetVal.Value)
		local priceVal = building and building:FindFirstChild("Price")
		local price = priceVal and priceVal.Value or 10

		setPadLabel(btn, "Построить (" .. price .. " Кристаллов)", Color3.fromRGB(100, 255, 100))

		btn.Touched:Connect(function(hit)
			local char = hit:FindFirstAncestorOfClass("Model")
			local player = players:GetPlayerFromCharacter(char)
			if not player or debounce[player] then return end
			if not building or building.Transparency == 0 then return end

			local leaderstats = player:FindFirstChild("leaderstats")
			local stats = player:FindFirstChild("Stats")
			if not leaderstats or not stats then return end

			if leaderstats.Crystals.Value >= price then
				debounce[player] = true
				leaderstats.Crystals.Value -= price
				building.Transparency = 0
				building.CanCollide = true
				btn.Transparency = 1
				if btn:FindFirstChildOfClass("BillboardGui") then
					btn:FindFirstChildOfClass("BillboardGui").Enabled = false
				end
				stats.BuiltCount.Value += 1

				-- Проигрываем звук постройки!
				SoundManager.Play("BuyUpgrade", building)

				task.wait(0.5)
				debounce[player] = nil
			end
		end)
	end
end

-- 2. Прокачка Силы инструмента
powerPad.Touched:Connect(function(hit)
	local char = hit:FindFirstAncestorOfClass("Model")
	local player = players:GetPlayerFromCharacter(char)
	if not player or debounce[player] then return end

	local leaderstats = player:FindFirstChild("leaderstats")
	local stats = player:FindFirstChild("Stats")
	if not leaderstats or not stats then return end

	local cost = 15 * stats.ToolPower.Value
	if leaderstats.Crystals.Value >= cost then
		debounce[player] = true
		leaderstats.Crystals.Value -= cost
		stats.ToolPower.Value += 1
		setPadLabel(powerPad, "СИЛА УДАРА (" .. (15 * stats.ToolPower.Value) .. " Кристаллов)", Color3.fromRGB(255, 100, 100))

		-- Звук покупки апгрейда
		SoundManager.Play("BuyUpgrade", powerPad)

		task.wait(0.6)
		debounce[player] = nil
	end
end)

-- 3. Прокачка Скорости бега
speedPad.Touched:Connect(function(hit)
	local char = hit:FindFirstAncestorOfClass("Model")
	local player = players:GetPlayerFromCharacter(char)
	if not player or debounce[player] then return end

	local leaderstats = player:FindFirstChild("leaderstats")
	local stats = player:FindFirstChild("Stats")
	if not leaderstats or not stats then return end

	local cost = 15 * stats.SpeedLevel.Value
	if leaderstats.Crystals.Value >= cost then
		debounce[player] = true
		leaderstats.Crystals.Value -= cost
		stats.SpeedLevel.Value += 1
		setPadLabel(speedPad, "СКОРОСТЬ (" .. (15 * stats.SpeedLevel.Value) .. " Кристаллов)", Color3.fromRGB(100, 220, 255))

		-- Звук покупки апгрейда
		SoundManager.Play("BuyUpgrade", speedPad)

		task.wait(0.6)
		debounce[player] = nil
	end
end)

-- 4. Перерождение (Rebirth): СБРАСЫВАЕМ силу, скорость и кристаллы!
rebirthPad.Touched:Connect(function(hit)
	local char = hit:FindFirstAncestorOfClass("Model")
	local player = players:GetPlayerFromCharacter(char)
	if not player or debounce[player] then return end

	local leaderstats = player:FindFirstChild("leaderstats")
	local stats = player:FindFirstChild("Stats")
	if not leaderstats or not stats then return end

	local rebirthCost = 100 * (leaderstats.Rebirths.Value + 1)
	if leaderstats.Crystals.Value >= rebirthCost then
		debounce[player] = true

		-- Сбрасываем кристаллы, силу и скорость на начальный 1-й уровень!
		leaderstats.Crystals.Value = 0
		stats.ToolPower.Value = 1
		stats.SpeedLevel.Value = 1 -- PlayerData автоматически вернёт скорость персонажа на 16!

		-- Начисляем +1 Rebirth (+1000 Fame и постоянный множитель кристаллов!)
		leaderstats.Rebirths.Value += 1

		-- Обновляем ценники на всех трёх плитах
		setPadLabel(powerPad, "СИЛА УДАРА (15 Кристаллов)", Color3.fromRGB(255, 100, 100))
		setPadLabel(speedPad, "СКОРОСТЬ (15 Кристаллов)", Color3.fromRGB(100, 220, 255))
		setPadLabel(rebirthPad, "REBIRTH (" .. (100 * (leaderstats.Rebirths.Value + 1)) .. " Кристаллов)", Color3.fromRGB(255, 215, 0))

		-- Эпичный звук перерождения!
		SoundManager.Play("Rebirth", rebirthPad)

		-- Сбрасываем постройки острова для нового цикла
		for _, b in ipairs(buildingsFolder:GetChildren()) do
			if b:IsA("BasePart") then b.Transparency = 1; b.CanCollide = false end
		end
		for _, btn in ipairs(buttonsFolder:GetChildren()) do
			if btn:IsA("BasePart") then
				btn.Transparency = 0
				if btn:FindFirstChildOfClass("BillboardGui") then
					btn:FindFirstChildOfClass("BillboardGui").Enabled = true
				end
			end
		end

		task.wait(1)
		debounce[player] = nil
	end
end)
