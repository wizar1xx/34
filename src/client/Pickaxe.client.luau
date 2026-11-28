local players = game:GetService("Players")
local repStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")

local player = players.LocalPlayer
local mineEvent = repStorage:WaitForChild("MineCrystalEvent")
local boundTools = {}
local activeTool
local activeMouse
local lastActivation = 0
local swingCooldown = 0.5
local impactDelay = 0.18
local activeSwing

local function isCrystal(target)
	return target
		and target:IsA("BasePart")
		and target:FindFirstChildOfClass("ClickDetector") ~= nil
end

local function findCrystalTarget(mouse, input)
	local target = mouse and mouse.Target
	if isCrystal(target) then return target end

	local camera = workspace.CurrentCamera
	if not camera then return nil end

	local screenPosition
	if input and input.UserInputType == Enum.UserInputType.Touch then
		screenPosition = input.Position
	else
		screenPosition = userInputService:GetMouseLocation()
	end

	local ray = camera:ScreenPointToRay(screenPosition.X, screenPosition.Y)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {player.Character}
	local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
	return result and result.Instance or nil
end

local function playHitSound(tool)
	local handle = tool:FindFirstChild("Handle")
	if not handle then return end

	local sounds = {}
	for index = 1, 4 do
		local sound = handle:FindFirstChild("SwingSound" .. index)
		if sound then table.insert(sounds, sound) end
	end

	if #sounds == 0 then return end
	for _, sound in ipairs(sounds) do
		sound:Stop()
	end
	local sound = sounds[math.random(1, #sounds)]
	sound:Play()
end

mineEvent.OnClientEvent:Connect(function(message)
	if message == "Hit" and activeTool then
		playHitSound(activeTool)
	end
end)

local function swingPose(elapsed, windup, strike)
	if elapsed <= 0.13 then
		return CFrame.identity:Lerp(windup, elapsed / 0.13)
	elseif elapsed <= 0.24 then
		return windup:Lerp(strike, (elapsed - 0.13) / 0.11)
	end
	return strike:Lerp(CFrame.identity, (elapsed - 0.24) / 0.18)
end

local function animatePickaxeSwing(character)
	local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
	local shoulder = torso and (torso:FindFirstChild("RightShoulder") or torso:FindFirstChild("Right Shoulder"))
	local grip = character:FindFirstChild("RightGrip", true)
	if not shoulder and not grip then
		warn("Cannot animate pickaxe swing: character has no shoulder or RightGrip Motor6D")
		return
	end

	activeSwing = {
		StartedAt = os.clock(),
		Shoulder = shoulder,
		Grip = grip,
	}
end

local function triggerToolAnimation(tool)
	local previousAnimation = tool:FindFirstChild("toolanim")
	if previousAnimation then previousAnimation:Destroy() end

	local toolAnimation = Instance.new("StringValue")
	toolAnimation.Name = "toolanim"
	toolAnimation.Value = "Slash"
	toolAnimation.Parent = tool
	task.delay(0.25, function()
		toolAnimation:Destroy()
	end)
end

runService.PreSimulation:Connect(function()
	local swing = activeSwing
	if not swing then return end

	local elapsed = os.clock() - swing.StartedAt
	if elapsed >= 0.42 then
		activeSwing = nil
		return
	end

	if swing.Shoulder and swing.Shoulder.Parent then
		swing.Shoulder.Transform *= swingPose(
			elapsed,
			CFrame.Angles(math.rad(-90), 0, math.rad(30)),
			CFrame.Angles(math.rad(55), 0, math.rad(-20))
		)
	end
	if swing.Grip and swing.Grip.Parent then
		swing.Grip.Transform *= swingPose(
			elapsed,
			CFrame.Angles(math.rad(-55), 0, math.rad(25)),
			CFrame.Angles(math.rad(70), 0, math.rad(-25))
		)
	end
end)

local function activate(tool, mouse, input)
	local now = os.clock()
	if now - lastActivation < swingCooldown then return end
	lastActivation = now

	local character = player.Character
	if not character then return end

	local target = findCrystalTarget(mouse, input)
	animatePickaxeSwing(character)
	triggerToolAnimation(tool)

	if isCrystal(target) then
		task.delay(impactDelay, function()
			if target.Parent and isCrystal(target) then
				mineEvent:FireServer(target)
			end
		end)
	end
end

local function bindTool(tool)
	if not tool:IsA("Tool") or tool.Name ~= "Кирка" or boundTools[tool] then return end
	boundTools[tool] = true

	local mouse
	tool.Equipped:Connect(function(equippedMouse)
		mouse = equippedMouse
		activeTool = tool
		activeMouse = mouse
	end)
	tool.Unequipped:Connect(function()
		mouse = nil
		if activeTool == tool then
			activeTool = nil
			activeMouse = nil
		end
	end)
end

local function watchContainer(container)
	if not container then return end
	for _, child in ipairs(container:GetChildren()) do
		bindTool(child)
	end
	container.ChildAdded:Connect(bindTool)
end

watchContainer(player:WaitForChild("Backpack"))
if player.Character then
	watchContainer(player.Character)
end
player.CharacterAdded:Connect(watchContainer)

userInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not activeTool then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		activate(activeTool, activeMouse, input)
	end
end)
