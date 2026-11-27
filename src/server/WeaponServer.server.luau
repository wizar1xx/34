local fireEvent = game.ReplicatedStorage:WaitForChild("WeaponFireEvent")
local hitmarkerEvent = game.ReplicatedStorage:WaitForChild("HitmarkerEvent")
local players = game:GetService("Players")
local debris = game:GetService("Debris")

local range = 600 -- Дальность стрельбы

local function drawTracer(startPos, endPos, color)
	local distance = (endPos - startPos).Magnitude
	local tracer = Instance.new("Part")
	tracer.Anchored = true
	tracer.CanCollide = false
	tracer.Material = Enum.Material.Neon
	tracer.Color = color
	tracer.Size = Vector3.new(0.08, 0.08, distance)
	tracer.CFrame = CFrame.lookAt(startPos, endPos) * CFrame.new(0, 0, -distance / 2)
	tracer.Parent = workspace
	debris:AddItem(tracer, 0.08)
end

fireEvent.OnServerEvent:Connect(function(player, targetPos, weaponDamage)
	local character = player.Character
	if not character then return end

	local tool = character:FindFirstChildOfClass("Tool")
	if not tool or not tool:FindFirstChild("Handle") then return end

	local damage = math.clamp(weaponDamage or 20, 1, 100)
	local tracerColor = (damage >= 80) and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(255, 220, 50)

	-- Ищем точку Muzzle внутри оружия; если её нет, берем позицию Handle
	local muzzle = tool:FindFirstChild("Muzzle", true)
	local startPos = muzzle and muzzle.WorldPosition or tool.Handle.Position

	local direction = (targetPos - startPos).Unit * range

	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {character}
	rayParams.FilterType = Enum.RaycastFilterType.Exclude

	local result = workspace:Raycast(startPos, direction, rayParams)
	local hitPos = result and result.Position or (startPos + direction)

	drawTracer(startPos, hitPos, tracerColor)

	if result and result.Instance then
		local hitChar = result.Instance:FindFirstAncestorOfClass("Model")
		local humanoid = hitChar and hitChar:FindFirstChild("Humanoid")

		if humanoid and humanoid.Health > 0 then
			local targetPlayer = players:GetPlayerFromCharacter(hitChar)
			if targetPlayer and targetPlayer.Team == player.Team then
				return
			end

			local oldTag = humanoid:FindFirstChild("creator")
			if oldTag then oldTag:Destroy() end

			local tag = Instance.new("ObjectValue")
			tag.Name = "creator"
			tag.Value = player
			tag.Parent = humanoid
			debris:AddItem(tag, 2)

			humanoid:TakeDamage(damage)

			local isKill = (humanoid.Health <= 0)
			hitmarkerEvent:FireClient(player, isKill)
		end
	end
end)
