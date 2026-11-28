local players = game:GetService("Players")
local debris = game:GetService("Debris")
local crystalZone = workspace:WaitForChild("CrystalZone")

local maxCrystals = 15 -- Сколько кристаллов одновременно на карте
local activeCrystals = 0

-- Типы кристаллов: цвет, здоровье и награда
local crystalTypes = {
	{Name = "Обычный Кристалл", Color = Color3.fromRGB(0, 220, 255), HP = 3, Reward = 1},
	{Name = "Золотой Кристалл", Color = Color3.fromRGB(255, 200, 0), HP = 6, Reward = 3},
	{Name = "Радужный Метеорит", Color = Color3.fromRGB(255, 50, 200), HP = 12, Reward = 10}
}

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

	local currentHP = cType.HP

	-- Клик мышкой или тап на телефоне по кристаллу
	local clickDetector = Instance.new("ClickDetector")
	clickDetector.MaxActivationDistance = 18
	clickDetector.Parent = crystal

	clickDetector.MouseClick:Connect(function(player)
		local leaderstats = player:FindFirstChild("leaderstats")
		local stats = player:FindFirstChild("Stats")
		if not leaderstats or not stats then return end

		local power = stats.ToolPower.Value
		currentHP -= power

		-- Визуальный отклик при ударе
		crystal.Size = crystal.Size * 0.9

		if currentHP <= 0 then
			-- Вычисляем добычу с учетом перерождений (Rebirths)
			local rebirthMult = 1 + leaderstats.Rebirths.Value
			local gain = cType.Reward * rebirthMult
            if player:GetAttribute("Has2x") then gain *= 2 end


			leaderstats.Crystals.Value += gain
			stats.TotalCrystalsMined.Value += gain

			activeCrystals -= 1
			crystal:Destroy()
		end
	end)
end

-- Бесконечный спавн кристаллов каждые 2 секунды
while true do
	spawnCrystal()
	task.wait(2)
end
