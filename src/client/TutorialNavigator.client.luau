local players = game:GetService("Players")
local runService = game:GetService("RunService")
local repStorage = game:GetService("ReplicatedStorage")

local player = players.LocalPlayer
local skipEvent = repStorage:WaitForChild("SkipTutorialEvent")

task.wait(1.5)
if player:GetAttribute("TutorialDone") == true then
	return
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TutorialHUD"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local banner = Instance.new("Frame")
banner.Size = UDim2.new(0, 520, 0, 48)
banner.Position = UDim2.new(0.5, -260, 0, 14)
banner.BackgroundColor3 = Color3.fromRGB(20, 25, 38)
banner.BackgroundTransparency = 0.15
banner.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = banner

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 220, 255)
stroke.Thickness = 2
stroke.Parent = banner

local goalText = Instance.new("TextLabel")
goalText.Size = UDim2.new(1, -135, 1, 0)
goalText.Position = UDim2.new(0, 12, 0, 0)
goalText.BackgroundTransparency = 1
goalText.TextColor3 = Color3.fromRGB(255, 255, 255)
goalText.Font = Enum.Font.GothamBlack
goalText.TextScaled = true
goalText.Text = "⛏️ Кликай по светящимся кристаллам, чтобы добыть их!"
goalText.Parent = banner

-- Кнопка "Пропустить" справа внутри плашки
local skipBtn = Instance.new("TextButton")
skipBtn.Size = UDim2.new(0, 110, 0, 34)
skipBtn.Position = UDim2.new(1, -118, 0.5, -17)
skipBtn.BackgroundColor3 = Color3.fromRGB(200, 55, 65)
skipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
skipBtn.Font = Enum.Font.GothamBold
skipBtn.TextSize = 13
skipBtn.Text = "Пропустить ✖"
skipBtn.Parent = banner

local skipCorner = Instance.new("UICorner")
skipCorner.CornerRadius = UDim.new(0, 8)
skipCorner.Parent = skipBtn

local beam = Instance.new("Beam")
beam.Width0 = 1.2
beam.Width1 = 1.2
beam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 170))
beam.FaceCamera = true
beam.Texture = "rbxassetid://446111271"
beam.TextureMode = Enum.TextureMode.Wrap
beam.TextureLength = 4
beam.TextureSpeed = 2
beam.Parent = workspace

local targetAttachment = Instance.new("Attachment")
targetAttachment.Parent = workspace.Terrain

local function findNearestCrystal(rootPos)
	local nearest = nil
	local minDist = math.huge
	for _, obj in ipairs(workspace:GetChildren()) do
		if obj:IsA("BasePart") and obj:FindFirstChildOfClass("ClickDetector") then
			local dist = (obj.Position - rootPos).Magnitude
			if dist < minDist then
				minDist = dist
				nearest = obj
			end
		end
	end
	return nearest
end

local function findActiveBuildButton()
	local buttonsFolder = workspace:FindFirstChild("BuildButtons")
	if not buttonsFolder then return nil end
	for _, btn in ipairs(buttonsFolder:GetChildren()) do
		if btn:IsA("BasePart") and btn.Transparency < 0.9 then
			return btn
		end
	end
	return nil
end

local connection
local isClosing = false

local function closeTutorial(wasSkipped)
	if isClosing then return end
	isClosing = true
	if connection then connection:Disconnect() end
	if beam then beam:Destroy() end
	if targetAttachment then targetAttachment:Destroy() end

	if wasSkipped then
		skipEvent:FireServer()
		screenGui:Destroy()
	else
		skipBtn.Visible = false
		goalText.Size = UDim2.new(1, -24, 1, 0)
		goalText.Text = "🎉 Обучение завершено! Строй остров и стань #1 в мире!"
		stroke.Color = Color3.fromRGB(255, 215, 0)
		task.wait(3)
		screenGui:Destroy()
	end
end

skipBtn.MouseButton1Click:Connect(function()
	closeTutorial(true)
end)

connection = runService.Heartbeat:Connect(function()
	if player:GetAttribute("TutorialDone") == true then
		closeTutorial(false)
		return
	end

	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local leaderstats = player:FindFirstChild("leaderstats")
	if not root or not leaderstats then
		beam.Enabled = false
		return
	end

	local rootAtt = root:FindFirstChild("NavAttachment")
	if not rootAtt then
		rootAtt = Instance.new("Attachment")
		rootAtt.Name = "NavAttachment"
		rootAtt.Position = Vector3.new(0, -2.5, 0)
		rootAtt.Parent = root
	end
	beam.Attachment0 = rootAtt
	beam.Attachment1 = targetAttachment

	local crystals = leaderstats.Crystals.Value
	local targetPart = nil

	if crystals >= 15 and findActiveBuildButton() then
		targetPart = findActiveBuildButton()
		goalText.Text = "🏗️ Наступи на зелёную плиту, чтобы построить остров!"
		stroke.Color = Color3.fromRGB(80, 255, 100)
	else
		targetPart = findNearestCrystal(root.Position)
		goalText.Text = "⛏️ Кликай по светящимся кристаллам, чтобы добыть их!"
		stroke.Color = Color3.fromRGB(0, 220, 255)
	end

	if targetPart then
		targetAttachment.WorldPosition = targetPart.Position
		beam.Enabled = true
	else
		beam.Enabled = false
	end
end)
