local player = game.Players.LocalPlayer
local repStorage = game:GetService("ReplicatedStorage")

local statusVal = repStorage:WaitForChild("GameStatus")
local redScore = repStorage:WaitForChild("RedScore")
local blueScore = repStorage:WaitForChild("BlueScore")

local gui = Instance.new("ScreenGui")
gui.Name = "MatchTopHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Плашка таймера сверху по центру
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 340, 0, 36)
statusLabel.Position = UDim2.new(0.5, -170, 0, 10)
statusLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
statusLabel.BackgroundTransparency = 0.2
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 15
statusLabel.Text = statusVal.Value
statusLabel.Parent = gui

-- Счет Красных (слева)
local redLabel = Instance.new("TextLabel")
redLabel.Size = UDim2.new(0, 55, 0, 36)
redLabel.Position = UDim2.new(0.5, -230, 0, 10)
redLabel.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
redLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
redLabel.Font = Enum.Font.GothamBlack
redLabel.TextSize = 20
redLabel.Text = tostring(redScore.Value)
redLabel.Parent = gui

-- Счет Синих (справа)
local blueLabel = Instance.new("TextLabel")
blueLabel.Size = UDim2.new(0, 55, 0, 36)
blueLabel.Position = UDim2.new(0.5, 175, 0, 10)
blueLabel.BackgroundColor3 = Color3.fromRGB(40, 100, 220)
blueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
blueLabel.Font = Enum.Font.GothamBlack
blueLabel.TextSize = 20
blueLabel.Text = tostring(blueScore.Value)
blueLabel.Parent = gui

statusVal.Changed:Connect(function(val) statusLabel.Text = val end)
redScore.Changed:Connect(function(val) redLabel.Text = tostring(val) end)
blueScore.Changed:Connect(function(val) blueLabel.Text = tostring(val) end)

