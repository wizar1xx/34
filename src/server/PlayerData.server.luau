local players = game:GetService("Players")
local dataStoreService = game:GetService("DataStoreService")

local playerStoreAvailable, playerStore = pcall(function()
	return dataStoreService:GetDataStore("IslandEmpire_Player_v2")
end)
if not playerStoreAvailable then
	warn("Player data persistence is unavailable: " .. tostring(playerStore))
	playerStore = nil
end

local fameStoreAvailable, globalFameStore = pcall(function()
	return dataStoreService:GetOrderedDataStore("IslandEmpire_GlobalFame_v2")
end)
if not fameStoreAvailable then
	warn("Global fame persistence is unavailable: " .. tostring(globalFameStore))
	globalFameStore = nil
end

local function recalculateFame(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	local stats = player:FindFirstChild("Stats")
	if not leaderstats or not stats then return end

	local rebirths = leaderstats.Rebirths.Value
	local builtCount = stats.BuiltCount.Value
	local totalCrystals = stats.TotalCrystalsMined.Value

	local newFame = (rebirths * 1000) + (builtCount * 25) + totalCrystals
	leaderstats.Fame.Value = newFame
end

local function applyCharacterStats(player, char)
	local stats = player:FindFirstChild("Stats")
	local hum = char:WaitForChild("Humanoid", 5)
	if stats and hum then
		hum.WalkSpeed = 16 + (stats.SpeedLevel.Value - 1) * 3
	end
end

local function saveAllData(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	local stats = player:FindFirstChild("Stats")
	if not leaderstats or not stats then return end

	local dataToSave = {
		Crystals = leaderstats.Crystals.Value,
		Rebirths = leaderstats.Rebirths.Value,
		ToolPower = stats.ToolPower.Value,
		Capacity = stats.Capacity.Value,
		SpeedLevel = stats.SpeedLevel.Value,
		BuiltCount = stats.BuiltCount.Value,
		TotalCrystalsMined = stats.TotalCrystalsMined.Value,
		TutorialDone = player:GetAttribute("TutorialDone") == true
	}

	if playerStore then
		local success, err = pcall(function()
			playerStore:SetAsync("User_" .. player.UserId, dataToSave)
		end)
		if not success then
			warn("Failed to save player data for " .. player.Name .. ": " .. tostring(err))
		end
	end

	if globalFameStore and leaderstats.Fame.Value > 0 and player.UserId > 0 then
		local success, err = pcall(function()
			globalFameStore:SetAsync(tostring(player.UserId), leaderstats.Fame.Value)
		end)
		if not success then
			warn("Failed to save global fame for " .. player.Name .. ": " .. tostring(err))
		end
	end
end

local initializedPlayers = {}

local function initializePlayer(player)
	if initializedPlayers[player] then return end
	initializedPlayers[player] = true

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local crystals = Instance.new("IntValue")
	crystals.Name = "Crystals"
	crystals.Value = 0
	crystals.Parent = leaderstats

	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Rebirths"
	rebirths.Value = 0
	rebirths.Parent = leaderstats

	local fame = Instance.new("IntValue")
	fame.Name = "Fame"
	fame.Value = 0
	fame.Parent = leaderstats

	local stats = Instance.new("Folder")
	stats.Name = "Stats"
	stats.Parent = player

	local toolPower = Instance.new("IntValue")
	toolPower.Name = "ToolPower"
	toolPower.Value = 1
	toolPower.Parent = stats

	local capacity = Instance.new("IntValue")
	capacity.Name = "Capacity"
	capacity.Value = 10
	capacity.Parent = stats

	local speedLevel = Instance.new("IntValue")
	speedLevel.Name = "SpeedLevel"
	speedLevel.Value = 1
	speedLevel.Parent = stats

	local builtCount = Instance.new("IntValue")
	builtCount.Name = "BuiltCount"
	builtCount.Value = 0
	builtCount.Parent = stats

	local totalMined = Instance.new("IntValue")
	totalMined.Name = "TotalCrystalsMined"
	totalMined.Value = 0
	totalMined.Parent = stats

	local data
	if playerStore then
		local success, result = pcall(function()
			return playerStore:GetAsync("User_" .. player.UserId)
		end)
		if success then
			data = result
		else
			warn("Failed to load player data for " .. player.Name .. ": " .. tostring(result))
		end
	end

	local tutDone = false
	if data then
		crystals.Value = data.Crystals or 0
		rebirths.Value = data.Rebirths or 0
		toolPower.Value = data.ToolPower or 1
		capacity.Value = data.Capacity or 10
		speedLevel.Value = data.SpeedLevel or 1
		builtCount.Value = data.BuiltCount or 0
		totalMined.Value = data.TotalCrystalsMined or 0
		tutDone = data.TutorialDone or (builtCount.Value > 0) or (rebirths.Value > 0)
	end

	-- Передаём статус туториала клиенту
	player:SetAttribute("TutorialDone", tutDone)

	recalculateFame(player)

	if player.Character then
		applyCharacterStats(player, player.Character)
	end

	rebirths.Changed:Connect(function()
		recalculateFame(player)
		if rebirths.Value > 0 then player:SetAttribute("TutorialDone", true) end
	end)

	builtCount.Changed:Connect(function()
		recalculateFame(player)
		-- Как только игрок построил первую постройку — туториал пройден навсегда!
		if builtCount.Value > 0 then player:SetAttribute("TutorialDone", true) end
	end)

	totalMined.Changed:Connect(function() recalculateFame(player) end)

	speedLevel.Changed:Connect(function()
		if player.Character then
			applyCharacterStats(player, player.Character)
		end
	end)

	player.CharacterAdded:Connect(function(char)
		applyCharacterStats(player, char)
	end)
end

players.PlayerAdded:Connect(initializePlayer)
for _, player in ipairs(players:GetPlayers()) do
	initializePlayer(player)
end

players.PlayerRemoving:Connect(saveAllData)

task.spawn(function()
	while task.wait(30) do
		for _, player in ipairs(players:GetPlayers()) do
			saveAllData(player)
		end
	end
end)

game:BindToClose(function()
	for _, player in ipairs(players:GetPlayers()) do
		saveAllData(player)
	end
end)
local repStorage = game:GetService("ReplicatedStorage")
local skipEvent = repStorage:WaitForChild("SkipTutorialEvent")

skipEvent.OnServerEvent:Connect(function(player)
	player:SetAttribute("TutorialDone", true)
end)

