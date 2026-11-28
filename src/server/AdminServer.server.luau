local players = game:GetService("Players")
local repStorage = game:GetService("ReplicatedStorage")
local debris = game:GetService("Debris")

local adminEvent = repStorage:WaitForChild("AdminEvent")

-- ВПИШИ СЮДА СВОЙ USERID И USERID ДРУГА В КВАДРАТНЫХ СКОБКАХ:
local ADMINS = {
	[8284210867] = true, -- Замени 123456789 на свой UserId!
	[987654321] = true  -- Замени 987654321 на UserId друга!
}

local function isAdmin(player)
	return ADMINS[player.UserId] == true or player.UserId < 0
end

players.PlayerAdded:Connect(function(player)
	if isAdmin(player) then
		player:SetAttribute("IsAdmin", true)
	end
end)

-- На случай если скрипт загрузился позже входа игрока
for _, p in ipairs(players:GetPlayers()) do
	if isAdmin(p) then
		p:SetAttribute("IsAdmin", true)
	end
end

local function findPlayerByPartialName(partial, fallbackPlayer)
	if not partial or partial == "" then return fallbackPlayer end
	partial = string.lower(partial)
	for _, p in ipairs(players:GetPlayers()) do
		if string.sub(string.lower(p.Name), 1, #partial) == partial then
			return p
		end
	end
	return fallbackPlayer
end

adminEvent.OnServerEvent:Connect(function(player, action, targetText, extraData)
	if not isAdmin(player) then return end

	local target = findPlayerByPartialName(targetText, player)
	local leaderstats = target:FindFirstChild("leaderstats")
	local stats = target:FindFirstChild("Stats")
	local char = target.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")

	if action == "GiveCrystals" and leaderstats and stats then
		local add = tonumber(extraData) or 5000
		leaderstats.Crystals.Value += add
		stats.TotalCrystalsMined.Value += add

	elseif action == "GiveRebirth" and leaderstats then
		leaderstats.Rebirths.Value += 1

	elseif action == "SuperSpeed" and hum then
		hum.WalkSpeed = (hum.WalkSpeed > 50) and 16 or 85

	elseif action == "SuperJump" and hum then
		hum.UseJumpPower = true
		hum.JumpPower = (hum.JumpPower > 100) and 50 or 160

	elseif action == "TeleportTo" and root and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		player.Character.HumanoidRootPart.CFrame = root.CFrame + Vector3.new(0, 3, 4)

	elseif action == "BringPlayer" and root and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		root.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 4)

	elseif action == "Freeze" and root then
		root.Anchored = not root.Anchored

	elseif action == "Invisible" and char then
		local makeInvis = not char:GetAttribute("Invis")
		char:SetAttribute("Invis", makeInvis)
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
				part.Transparency = makeInvis and 1 or 0
			elseif part:IsA("Decal") then
				part.Transparency = makeInvis and 1 or 0
			end
		end

	elseif action == "LowGravity" then
		workspace.Gravity = (workspace.Gravity < 100) and 196.2 or 45

	elseif action == "MeteorShower" then
		local zone = workspace:FindFirstChild("CrystalZone")
		if zone then
			for i = 1, 15 do
				local halfX = math.max(1, zone.Size.X / 2)
				local halfZ = math.max(1, zone.Size.Z / 2)
				local crystal = Instance.new("Part")
				crystal.Name = "Радужный Метеорит (ИВЕНТ)"
				crystal.Shape = Enum.PartType.Ball
				crystal.Material = Enum.Material.Neon
				crystal.Color = Color3.fromRGB(255, 50, 200)
				crystal.Size = Vector3.new(5, 6, 5)
				crystal.Position = Vector3.new(
					zone.Position.X + math.random(-halfX, halfX),
					zone.Position.Y + 3,
					zone.Position.Z + math.random(-halfZ, halfZ)
				)
				crystal.Anchored = true
				crystal.Parent = workspace

				local click = Instance.new("ClickDetector")
				click.MaxActivationDistance = 24
				click.Parent = crystal

				click.MouseClick:Connect(function(miner)
					local ls = miner:FindFirstChild("leaderstats")
					local st = miner:FindFirstChild("Stats")
					if ls and st then
						local gain = 25 * (1 + ls.Rebirths.Value)
						if miner:GetAttribute("Has2x") then gain *= 2 end
						ls.Crystals.Value += gain
						st.TotalCrystalsMined.Value += gain
						crystal:Destroy()
					end
				end)
			end
		end

	elseif action == "Announce" and targetText and targetText ~= "" then
		for _, p in ipairs(players:GetPlayers()) do
			local pGui = p:FindFirstChild("PlayerGui")
			if pGui then
				local gui = Instance.new("ScreenGui")
				gui.Parent = pGui
				local lbl = Instance.new("TextLabel")
				lbl.Size = UDim2.new(0.8, 0, 0, 60)
				lbl.Position = UDim2.new(0.1, 0, 0.15, 0)
				lbl.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
				lbl.TextColor3 = Color3.fromRGB(20, 20, 20)
				lbl.Font = Enum.Font.GothamBlack
				lbl.TextScaled = true
				lbl.Text = "📢 АДМИН: " .. tostring(targetText)
				lbl.Parent = gui
				local corner = Instance.new("UICorner")
				corner.CornerRadius = UDim.new(0, 12)
				corner.Parent = lbl
				debris:AddItem(gui, 5)
			end
		end

	elseif action == "KickPlayer" and target ~= player then
		target:Kick("Вы были исключены администратором острова.")
	end
end)
