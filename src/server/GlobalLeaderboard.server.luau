local dataStoreService = game:GetService("DataStoreService")
local players = game:GetService("Players")
local globalFameStore = dataStoreService:GetOrderedDataStore("IslandEmpire_GlobalFame_v2")


local board = workspace:WaitForChild("LeaderboardBoard")

-- Создаем экран на доске
local surfaceGui = board:FindFirstChildOfClass("SurfaceGui") or Instance.new("SurfaceGui")
surfaceGui.Face = Enum.NormalId.Front
surfaceGui.Parent = board

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0.15, 0)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.Font = Enum.Font.GothamBlack
title.TextScaled = true
title.Text = "МИРОВОЙ ТОП ОСТРОВА (FAME)"
title.Parent = surfaceGui

local listFrame = Instance.new("ScrollingFrame")
listFrame.Size = UDim2.new(1, 0, 0.85, 0)
listFrame.Position = UDim2.new(0, 0, 0.15, 0)
listFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
listFrame.Parent = surfaceGui

local layout = Instance.new("UIListLayout")
layout.Parent = listFrame

local function updateLeaderboard()
	-- Очищаем старые строчки
	for _, child in ipairs(listFrame:GetChildren()) do
		if child:IsA("TextLabel") then child:Destroy() end
	end

	-- Запрашиваем Топ-10 мира по убыванию (false = от большего к меньшему)
	local success, pages = pcall(function()
		return globalFameStore:GetSortedAsync(false, 10)
	end)

	if success and pages then
		local topList = pages:GetCurrentPage()
		for rank, entry in ipairs(topList) do
			local userId = tonumber(string.match(entry.key, "%d+"))
			local username = "Игрок"
			if userId then
				pcall(function()
					username = players:GetNameFromUserIdAsync(userId)
				end)
			end

			local row = Instance.new("TextLabel")
			row.Size = UDim2.new(1, 0, 0, 45)
			row.BackgroundTransparency = 0.5
			row.BackgroundColor3 = (rank == 1) and Color3.fromRGB(212, 175, 55) or Color3.fromRGB(40, 40, 50)
			row.TextColor3 = Color3.fromRGB(255, 255, 255)
			row.Font = Enum.Font.GothamBold
			row.TextScaled = true
			row.Text = "#" .. rank .. "  " .. username .. " — " .. entry.value .. " Fame"
			row.Parent = listFrame
		end
	end
end

-- Обновляем Мировой Топ при старте и каждые 30 секунд
while true do
	updateLeaderboard()
	task.wait(30)
end
