local players = game:GetService("Players")
local repStorage = game:GetService("ReplicatedStorage")

local toolName = "Кирка"
local initializedPlayers = {}
local swingSoundIds = {
	"rbxassetid://139011979653451",
	"rbxassetid://111183902071818",
	"rbxassetid://85757055867499",
	"rbxassetid://97630645073247",
}

local mineEvent = repStorage:FindFirstChild("MineCrystalEvent")
if not mineEvent then
	mineEvent = Instance.new("RemoteEvent")
	mineEvent.Name = "MineCrystalEvent"
	mineEvent.Parent = repStorage
elseif not mineEvent:IsA("RemoteEvent") then
	error("ReplicatedStorage.MineCrystalEvent must be a RemoteEvent")
end

local function createPickaxe()
	local tool = Instance.new("Tool")
	tool.Name = toolName
	tool.ToolTip = "Кликай по кристаллу, чтобы ударить киркой"
	tool.RequiresHandle = true
	tool.CanBeDropped = false

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.22, 2.2, 0.22)
	handle.Material = Enum.Material.Wood
	handle.Color = Color3.fromRGB(116, 72, 39)
	handle.CanCollide = false
	handle.Massless = true
	handle.Parent = tool

	local head = Instance.new("Part")
	head.Name = "PickaxeHead"
	head.Size = Vector3.new(1.35, 0.28, 0.32)
	head.CFrame = handle.CFrame * CFrame.new(0, 0.95, 0) * CFrame.Angles(0, math.rad(90), 0)
	head.Material = Enum.Material.Metal
	head.Color = Color3.fromRGB(170, 185, 198)
	head.CanCollide = false
	head.Massless = true
	head.Parent = tool

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = handle
	weld.Part1 = head
	weld.Parent = handle

	for index, soundId in ipairs(swingSoundIds) do
		local swingSound = Instance.new("Sound")
		swingSound.Name = "SwingSound" .. index
		swingSound.SoundId = soundId
		swingSound.Volume = 0.45
		swingSound.Parent = handle
	end

	return tool
end

local function givePickaxe(player)
	if initializedPlayers[player] then return end
	initializedPlayers[player] = true

	local starterGear = player:WaitForChild("StarterGear")
	local backpack = player:WaitForChild("Backpack")

	if not starterGear:FindFirstChild(toolName) then
		createPickaxe().Parent = starterGear
	end
	if not backpack:FindFirstChild(toolName) then
		createPickaxe().Parent = backpack
	end
end

players.PlayerAdded:Connect(givePickaxe)
for _, player in ipairs(players:GetPlayers()) do
	task.spawn(givePickaxe, player)
end
