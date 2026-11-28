local players = game:GetService("Players")
local repStorage = game:GetService("ReplicatedStorage")
local dataStoreService = game:GetService("DataStoreService")

local codesStore = dataStoreService:GetDataStore("IslandEmpire_Codes_v1")
local redeemFunc = repStorage:WaitForChild("RedeemCodeFunc")

-- СПИСОК ВАШИХ ПРОМОКОДОВ (пишите ключи ЗАГЛАВНЫМИ буквами):
local CODES = {
	["RELEASE"]  = {Type = "Crystals", Amount = 250,  Text = "+250 Кристаллов!"},
	["ISLAND"]   = {Type = "Crystals", Amount = 500,  Text = "+500 Кристаллов!"},
	["SPEED100"] = {Type = "Speed",    Amount = 1,    Text = "+1 Уровень Скорости!"},
	["TOP1"]     = {Type = "Rebirth",  Amount = 1,    Text = "+1 Rebirth (+1000 Fame)!"}
}

-- Кэш активированных кодов для каждого игрока
local usedCodesCache = {}

players.PlayerAdded:Connect(function(player)
	local ok, data = pcall(function()
		return codesStore:GetAsync("Codes_" .. player.UserId)
	end)
	usedCodesCache[player.UserId] = (ok and type(data) == "table") and data or {}
end)

players.PlayerRemoving:Connect(function(player)
	local used = usedCodesCache[player.UserId]
	if used then
		pcall(function()
			codesStore:SetAsync("Codes_" .. player.UserId, used)
		end)
		usedCodesCache[player.UserId] = nil
	end
end)

redeemFunc.OnServerInvoke = function(player, rawCode)
	if type(rawCode) ~= "string" then
		return false, "Введите код!"
	end

	-- Убираем пробелы и переводим в заглавные буквы, чтобы работало в любом регистре
	local code = string.upper(string.gsub(rawCode, "%s+", ""))
	if code == "" then
		return false, "Поле пустое!"
	end

	local reward = CODES[code]
	if not reward then
		return false, "❌ Неверный или устаревший код!"
	end

	local used = usedCodesCache[player.UserId]
	if not used then
		used = {}
		usedCodesCache[player.UserId] = used
	end

	if used[code] then
		return false, "⚠️ Вы уже активировали этот код!"
	end

	local leaderstats = player:FindFirstChild("leaderstats")
	local stats = player:FindFirstChild("Stats")
	if not leaderstats or not stats then
		return false, "Ошибка загрузки профиля."
	end

	-- Отмечаем код как использованный и выдаём награду
	used[code] = true

	if reward.Type == "Crystals" then
		local gain = reward.Amount
		if player:GetAttribute("Has2x") then gain *= 2 end
		leaderstats.Crystals.Value += gain
		stats.TotalCrystalsMined.Value += gain
	elseif reward.Type == "Speed" then
		stats.SpeedLevel.Value += reward.Amount
	elseif reward.Type == "Power" then
		stats.ToolPower.Value += reward.Amount
	elseif reward.Type == "Rebirth" then
		leaderstats.Rebirths.Value += reward.Amount
	end

	pcall(function()
		codesStore:SetAsync("Codes_" .. player.UserId, used)
	end)

	return true, "🎉 Успешно: " .. reward.Text
end
