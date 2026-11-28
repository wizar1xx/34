local players = game:GetService("Players")
local repStorage = game:GetService("ReplicatedStorage")
local SoundManager = require(repStorage:WaitForChild("Shared"):WaitForChild("SoundManager"))

local crystalZone = workspace:WaitForChild("CrystalZone")

local maxCrystals = 15 -- Сколько кристаллов одновременно на карте
local activeCrystals = 0
local activeCrystalData = {}
local lastHitAt = {}
local mineEvent = repStorage:WaitForChild("MineCrystalEvent")

-- Типы кристаллов: цвет, здоровье и награда
local crystalTypes = {
	{Name = "Обычный Кристалл", Color = Color3.fromRGB(0, 220, 255), HP = 3, Reward = 1},
	{Name = "Золотой Кристалл", Color = Color3.fromRGB(255, 200, 0), HP = 6, Reward = 3},
	{Name = "Радужный Метеорит", Color = Color3.fromRGB(255, 50, 200), HP = 12, Reward = 10}
}

local function applyHit(player, crystal)
	local data = activeCrystalData[crystal]
	if not data then return end

	local character = player.Character
	local pickaxe = character and character:FindFirstChild("Кирка")
	if not pickaxe or not pickaxe:IsA("Tool") then
		data.FeedbackLabel.Text = "Сначала возьми кирку"
		return
	end

	local clickDetector = crystal:FindFirstChildOfClass("ClickDetector")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not clickDetector or not root then return end
	if (root.Position - crystal.Position).Magnitude > clickDetector.MaxActivationDistance then return end

	local now = os.clock()
	if lastHitAt[player] and now - lastHitAt[player] < 0.42 then return end

	local leaderstats = player:FindFirstChild("leaderstats")
	local stats = player:FindFirstChild("Stats")
	local toolPower = stats and stats:FindFirstChild("ToolPower")
	local crystals = leaderstats and leaderstats:FindFirstChild("Crystals")
	local rebirths = leaderstats and leaderstats:FindFirstChild("Rebirths")
	local totalMined = stats and stats:FindFirstChild("TotalCrystalsMined")
	if not toolPower or not crystals or not rebirths or not totalMined then
		data.FeedbackLabel.Text = "Ошибка: статы не загружены"
		warn("Cannot mine crystal: player stats are missing for " .. player.Name)
		return
	end

	lastHitAt[player] = now

	local power = math.max(1, toolPower.Value)
	data.HP -= power
	mineEvent:FireClient(player, "Hit")
	data.FeedbackLabel.Text = "Урон -" .. power .. " • HP " .. math.max(data.HP, 0) .. "/" .. data.Type.HP
	crystal.Size = crystal.Size * 0.9

	-- Звук удара и мелкие искры цвета кристалла
	SoundManager.Play("HitCrystal", crystal, crystal.Color)

	if data.HP <= 0 then
		local rebirthMult = 1 + rebirths.Value
		local gain = data.Type.Reward * rebirthMult
		if player:GetAttribute("Has2x") then gain *= 2 end

		crystals.Value += gain
		totalMined.Value += gain

		-- Звонкий сбор и взрыв частиц цвета кристалла!
		SoundManager.Play("BreakCrystal", crystal, crystal.Color)

		activeCrystals -= 1
		activeCrystalData[crystal] = nil
		crystal:Destroy()
	end
end

mineEvent.OnServerEvent:Connect(function(player, crystal)
	if typeof(crystal) == "Instance" and crystal:IsA("BasePart") then
		applyHit(player, crystal)
	end
end)

players.PlayerRemoving:Connect(function(player)
	lastHitAt[player] = nil
end)

local function spawnCrystal()
	if activeCrystals >= maxCrystals then return end
	activeCrystals += 1

	-- Выбираем случайную редкость
	local roll = math.random(1, 100)
	local cType = crystalTypes[1]
	if roll > 90 then
		cType = crystalTypes[3]
	elseif roll > 65 then
		cType = crystalTypes[2]
	end

	-- Случайная точка внутри CrystalZone
	local halfX = crystalZone.Size.X / 2
	local halfZ = crystalZone.Size.Z / 2
	local randX = crystalZone.Position.X + math.random(-halfX, halfX)
	local randZ = crystalZone.Position.Z + math.random(-halfZ, halfZ)

	local crystal = Instance.new("Part")
	crystal.Name = cType.Name
	crystal.Shape = Enum.PartType.Ball
	crystal.Material = Enum.Material.Neon
	crystal.Color = cType.Color
	crystal.Size = Vector3.new(3.5, 4.5, 3.5)
	crystal.Position = Vector3.new(randX, crystalZone.Position.Y + 2.5, randZ)
	crystal.Anchored = true
	crystal.CanCollide = true
	crystal.Parent = workspace

	-- Клик мышкой или тап на телефоне по кристаллу
	local clickDetector = Instance.new("ClickDetector")
	clickDetector.MaxActivationDistance = 18
	clickDetector.Parent = crystal

	local feedbackGui = Instance.new("BillboardGui")
	feedbackGui.Size = UDim2.fromOffset(170, 34)
	feedbackGui.StudsOffset = Vector3.new(0, 3, 0)
	feedbackGui.MaxDistance = clickDetector.MaxActivationDistance
	feedbackGui.AlwaysOnTop = true
	feedbackGui.Parent = crystal

	local feedbackLabel = Instance.new("TextLabel")
	feedbackLabel.Size = UDim2.fromScale(1, 1)
	feedbackLabel.BackgroundColor3 = Color3.fromRGB(20, 25, 38)
	feedbackLabel.BackgroundTransparency = 0.15
	feedbackLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	feedbackLabel.TextStrokeTransparency = 0.5
	feedbackLabel.Font = Enum.Font.GothamBold
	feedbackLabel.TextScaled = true
	feedbackLabel.Text = "КЛИК / ТАП • HP " .. cType.HP .. "/" .. cType.HP
	feedbackLabel.Parent = feedbackGui

	local feedbackCorner = Instance.new("UICorner")
	feedbackCorner.CornerRadius = UDim.new(0, 8)
	feedbackCorner.Parent = feedbackLabel

	activeCrystalData[crystal] = {
		HP = cType.HP,
		Type = cType,
		FeedbackLabel = feedbackLabel,
	}

	clickDetector.MouseClick:Connect(function(player)
		local character = player.Character
		if not character or not character:FindFirstChild("Кирка") then
			applyHit(player, crystal)
		end
	end)
end

-- Бесконечный спавн кристаллов каждые 2 секунды
while true do
	spawnCrystal()
	task.wait(2)
end
