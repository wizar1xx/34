local players = game:GetService("Players")
local repStorage = game:GetService("ReplicatedStorage")
local dataStoreService = game:GetService("DataStoreService")

local dailyStore = dataStoreService:GetDataStore("IslandEmpire_Daily_v1")
local claimEvent = repStorage:WaitForChild("ClaimDailyEvent")
local getStateFunc = repStorage:WaitForChild("GetDailyState")

-- Таблица наград за 7 дней подряд:
local REWARDS = {
	{Day = 1, Type = "Crystals", Amount = 100, Label = "100 Кристаллов"},
	{Day = 2, Type = "Crystals", Amount = 250, Label = "250 Кристаллов"},
	{Day = 3, Type = "Crystals", Amount = 500, Label = "500 Кристаллов"},
	{Day = 4, Type = "Speed",    Amount = 1,   Label = "+1 Ур. Скорости"},
	{Day = 5, Type = "Crystals", Amount = 1200, Label = "1 200 Кристаллов"},
	{Day = 6, Type = "Power",    Amount = 1,   Label = "+1 Ур. Силы"},
	{Day = 7, Type = "Rebirth",  Amount = 1,   Label = "+1 REBIRTH (+1000 Fame!)"}
}

local COOLDOWN = 20 * 3600 -- 20 часов (чтобы было удобно забирать каждый вечер)
local EXPIRE_TIME = 48 * 3600 -- 48 часов до сброса серии

local playerDailyCache = {}

players.PlayerAdded:Connect(function(player)
	local ok, data = pcall(function()
		return dailyStore:GetAsync("Daily_" .. player.UserId)
	end)

	local streak = 1
	local lastClaim = 0

	if ok and data then
		streak = data.Streak or 1
		lastClaim = data.LastClaim or 0

		-- Если прошло больше 48 часов с прошлой награды — серия сбрасывается на 1-й день
		if lastClaim > 0 and (os.time() - lastClaim) > EXPIRE_TIME then
			streak = 1
		end
	end

	playerDailyCache[player.UserId] = {
		Streak = streak,
		LastClaim = lastClaim
	}
end)

players.PlayerRemoving:Connect(function(player)
	local cache = playerDailyCache[player.UserId]
	if cache then
		pcall(function()
			dailyStore:SetAsync("Daily_" .. player.UserId, cache)
		end)
		playerDailyCache[player.UserId] = nil
	end
end)

-- Клиент запрашивает статус наград
getStateFunc.OnServerInvoke = function(player)
	local cache = playerDailyCache[player.UserId] or {Streak = 1, LastClaim = 0}
	local timePassed = os.time() - cache.LastClaim
	local canClaim = (cache.LastClaim == 0) or (timePassed >= COOLDOWN)
	local timeLeft = canClaim and 0 or (COOLDOWN - timePassed)

	return {
		Streak = cache.Streak,
		CanClaim = canClaim,
		TimeLeft = timeLeft,
		Rewards = REWARDS
	}
end

-- Игрок нажимает кнопку "Забрать награду"
claimEvent.OnServerEvent:Connect(function(player)
	local cache = playerDailyCache[player.UserId]
	if not cache then return end

	local timePassed = os.time() - cache.LastClaim
	if cache.LastClaim > 0 and timePassed < COOLDOWN then return end

	local rewardInfo = REWARDS[cache.Streak]
	if not rewardInfo then return end

	local leaderstats = player:FindFirstChild("leaderstats")
	local stats = player:FindFirstChild("Stats")
	if not leaderstats or not stats then return end

	-- Выдаём награду
	if rewardInfo.Type == "Crystals" then
		local gain = rewardInfo.Amount
		if player:GetAttribute("Has2x") then gain *= 2 end
		leaderstats.Crystals.Value += gain
		stats.TotalCrystalsMined.Value += gain
	elseif rewardInfo.Type == "Speed" then
		stats.SpeedLevel.Value += rewardInfo.Amount
	elseif rewardInfo.Type == "Power" then
		stats.ToolPower.Value += rewardInfo.Amount
	elseif rewardInfo.Type == "Rebirth" then
		leaderstats.Rebirths.Value += rewardInfo.Amount
	end

	-- Обновляем серию (после 7-го дня цикл идёт заново с 1-го)
	cache.LastClaim = os.time()
	cache.Streak = (cache.Streak % 7) + 1

	pcall(function()
		dailyStore:SetAsync("Daily_" .. player.UserId, cache)
	end)
end)
