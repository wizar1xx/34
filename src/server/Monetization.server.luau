local marketplace = game:GetService("MarketplaceService")
local players = game:GetService("Players")

-- ВПИШИ СЮДА СВОИ ID С САЙТА ://roblox.com:
local PASS_2X_CRYSTALS = 2100433750      -- ID геймпаса "2x Кристаллы и Fame"
local PASS_VIP_SPEED = 0       -- ID геймпаса "VIP Скорость"
local PRODUCT_METEOR_RAIN = 0  -- ID продукта "+250 Кристаллов"

-- Проверка геймпасов при входе игрока
players.PlayerAdded:Connect(function(player)
	local has2x = false
	local hasVip = false

	pcall(function()
		if PASS_2X_CRYSTALS > 0 then
			has2x = marketplace:UserOwnsGamePassAsync(player.UserId, PASS_2X_CRYSTALS)
		end
		if PASS_VIP_SPEED > 0 then
			hasVip = marketplace:UserOwnsGamePassAsync(player.UserId, PASS_VIP_SPEED)
		end
	end)

	player:SetAttribute("Has2x", has2x)
	player:SetAttribute("HasVip", hasVip)

	if hasVip then
		player.CharacterAdded:Connect(function(char)
			local hum = char:WaitForChild("Humanoid")
			hum.WalkSpeed += 8
		end)
	end
end)

-- Мгновенная активация геймпаса сразу после покупки в игре
marketplace.PromptGamePassPurchaseFinished:Connect(function(player, passId, wasPurchased)
	if not wasPurchased then return end
	if passId == PASS_2X_CRYSTALS then
		player:SetAttribute("Has2x", true)
	elseif passId == PASS_VIP_SPEED then
		player:SetAttribute("HasVip", true)
		if player.Character and player.Character:FindFirstChild("Humanoid") then
			player.Character.Humanoid.WalkSpeed += 8
		end
	end
end)

-- Обработка многоразовой покупки "+250 Кристаллов" (Developer Product)
marketplace.ProcessReceipt = function(receiptInfo)
	local player = players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	if receiptInfo.ProductId == PRODUCT_METEOR_RAIN then
		local leaderstats = player:FindFirstChild("leaderstats")
		local stats = player:FindFirstChild("Stats")
		if leaderstats and stats then
			leaderstats.Crystals.Value += 250
			stats.TotalCrystalsMined.Value += 250
		end
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	return Enum.ProductPurchaseDecision.NotProcessedYet
end
