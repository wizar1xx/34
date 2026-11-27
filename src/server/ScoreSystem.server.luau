[
    {
        "AirDensity": "0.00120000006",
        "AllowThirdPartySales": "false",
        "AirTurbulenceIntensity": "0",
        "ModelStreamingMode": "Default",
        "ReplicationFrequency": "Automatic",
        "Gravity": "196.199997",
        "DistributedGameTime": "0",
        "AuthorityMode": "Automatic",
        "NextGenerationPhysicsSolver": "Default",
        "FallenPartsDestroyHeight": "-500",
        "StreamingEnabled": "true",
        "FallHeightEnabled": "true",
        "ClientAnimatorThrottling": "Default",
        "GlobalWind": "0, 0, 0",
        "InsertPoint": "0, 0, 0",
        "LuauTypeCheckMode": "Default",
        "ReplicationThroughput": "Automatic",
        "PredictiveStreamingMode": "Default",
        "Retargeting": "Default",
        "StreamOutBehavior": "Opportunistic",
        "StreamingAdaptiveRadius": "false",
        "StreamingIntegrityMode": "PauseOutsideLoadedArea",
        "StreamingMinRadius": "64",
        "StreamingTargetRadius": "1024",
        "LevelOfDetail": "Automatic",
        "WorldPivot": "0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1",
        "Archivable": "true",
        "Capabilities": "",
        "Name": "Workspace",
        "Sandboxed": "false",
        "archivable": "true"
    },
    {
        "BanningEnabled": "true",
        "CharacterAutoLoads": "true",
        "Name": "Players",
        "Archivable": "true",
        "RespawnTime": "3",
        "Capabilities": "",
        "UseStrafingAnimations": "false",
        "Sandboxed": "false",
        "archivable": "true"
    },
    {
        "Ambient": "0.27451, 0.27451, 0.27451",
        "Outlines": "false",
        "Brightness": "3",
        "EnvironmentDiffuseScale": "1",
        "ClockTime": "14.5",
        "GlobalShadows": "true",
        "EnvironmentSpecularScale": "1",
        "FogColor": "0.752941, 0.752941, 0.752941",
        "GeographicLatitude": "0",
        "LightingStyle": "Soft",
        "OutdoorAmbient": "0.27451, 0.27451, 0.27451",
        "ShadowSoftness": "0.200000003",
        "TimeOfDay": "14:30:00"
    },
    {},
    {
        "archivable": "true",
        "Name": "NetworkClient",
        "Archivable": "true",
        "Capabilities": "",
        "Sandboxed": "false"
    },
    {},
    {},
    {},
    {
        "ClassName": "Script",
        "Source": "local players = game:GetService(\"Players\")\nlocal repStorage = game:GetService(\"ReplicatedStorage\")\n\nlocal statusVal = repStorage:WaitForChild(\"GameStatus\")\nlocal redScore = repStorage:WaitForChild(\"RedScore\")\nlocal blueScore = repStorage:WaitForChild(\"BlueScore\")\n\nlocal redSpawn = workspace:WaitForChild(\"RedArenaSpawn\")\nlocal blueSpawn = workspace:WaitForChild(\"BlueArenaSpawn\")\n\nlocal intermissionTime = 15 -- Ожидание в лобби (сек)\nlocal matchDuration = 120   -- Длительность раунда (сек)\nlocal roundActive = false\n\n-- Функция телепортации игрока на базу его команды\nlocal function sendToTeamBase(player)\n\tlocal char = player.Character\n\tlocal root = char and char:WaitForChild(\"HumanoidRootPart\", 5)\n\tif not root then return end\n\n\ttask.wait(0.1) -- Небольшая пауза, чтобы персонаж успел загрузиться\n\tif player.Team and player.Team.Name == \"Red\" then\n\t\troot.CFrame = redSpawn.CFrame + Vector3.new(0, 3, 0)\n\telseif player.Team and player.Team.Name == \"Blue\" then\n\t\troot.CFrame = blueSpawn.CFrame + Vector3.new(0, 3, 0)\n\tend\nend\n\n-- Отслеживаем вход игроков, их возрождение и командные убийства\nplayers.PlayerAdded:Connect(function(player)\n\tplayer.CharacterAdded:Connect(function(char)\n\t\t-- Если раунд прямо сейчас идет, сразу отправляем возродившегося игрока на базу команды\n\t\tif roundActive then\n\t\t\tsendToTeamBase(player)\n\t\tend\n\n\t\tlocal hum = char:WaitForChild(\"Humanoid\")\n\t\thum.Died:Connect(function()\n\t\t\tif not roundActive then return end\n\t\t\tlocal tag = hum:FindFirstChild(\"creator\")\n\t\t\tif tag and tag.Value and tag.Value:IsA(\"Player\") then\n\t\t\t\tlocal killer = tag.Value\n\t\t\t\tif killer.Team and killer.Team.Name == \"Red\" then\n\t\t\t\t\tredScore.Value += 1\n\t\t\t\telseif killer.Team and killer.Team.Name == \"Blue\" then\n\t\t\t\t\tblueScore.Value += 1\n\t\t\t\tend\n\t\t\tend\n\t\tend)\n\tend)\nend)\n\n-- Бесконечный цикл смены раундов\nwhile true do\n\t-- 1. Фаза ожидания в лобби\n\troundActive = false\n\tfor i = intermissionTime, 1, -1 do\n\t\tstatusVal.Value = \"Ожидание игроков: \" .. i .. \" сек.\"\n\t\ttask.wait(1)\n\tend\n\n\t-- Сбрасываем счет и начинаем бой\n\tredScore.Value = 0\n\tblueScore.Value = 0\n\troundActive = true\n\n\t-- Отправляем всех на арену\n\tfor _, player in ipairs(players:GetPlayers()) do\n\t\tsendToTeamBase(player)\n\tend\n\n\t-- 2. Идет раунд\n\tfor i = matchDuration, 1, -1 do\n\t\tstatusVal.Value = \"Бой идет! Осталось: \" .. i .. \" сек.\"\n\t\ttask.wait(1)\n\tend\n\n\t-- 3. Итоги раунда\n\troundActive = false\n\tif redScore.Value > blueScore.Value then\n\t\tstatusVal.Value = \"Победили КРАСНЫЕ! (\" .. redScore.Value .. \" : \" .. blueScore.Value .. \")\"\n\telseif blueScore.Value > redScore.Value then\n\t\tstatusVal.Value = \"Победили СИНИЕ! (\" .. blueScore.Value .. \" : \" .. redScore.Value .. \")\"\n\telse\n\t\tstatusVal.Value = \"НИЧЬЯ! (\" .. redScore.Value .. \" : \" .. blueScore.Value .. \")\"\n\tend\n\n\ttask.wait(5)\n\n\t-- Возвращаем всех в лобби\n\tfor _, player in ipairs(players:GetPlayers()) do\n\t\tplayer:LoadCharacter()\n\tend\nend\n",
        "Name": "MatchManager"
    },
    {
        "ClassName": "Script",
        "Source": "game.Players.PlayerAdded:Connect(function(player)\n\tlocal leaderstats = Instance.new(\"Folder\")\n\tleaderstats.Name = \"leaderstats\"\n\tleaderstats.Parent = player\n\n\tlocal kills = Instance.new(\"IntValue\")\n\tkills.Name = \"Kills\"\n\tkills.Value = 0\n\tkills.Parent = leaderstats\n\n\tlocal deaths = Instance.new(\"IntValue\")\n\tdeaths.Name = \"Deaths\"\n\tdeaths.Value = 0\n\tdeaths.Parent = leaderstats\n\n\tplayer.CharacterAdded:Connect(function(character)\n\t\tlocal humanoid = character:WaitForChild(\"Humanoid\")\n\t\thumanoid.Died:Connect(function()\n\t\t\tdeaths.Value += 1\n\n\t\t\t-- Ищем метку creator, которую повесил наш скрипт стрельбы\n\t\t\tlocal tag = humanoid:FindFirstChild(\"creator\")\n\t\t\tif tag and tag.Value and tag.Value:IsA(\"Player\") then\n\t\t\t\tlocal stats = tag.Value:FindFirstChild(\"leaderstats\")\n\t\t\t\tif stats and stats:FindFirstChild(\"Kills\") then\n\t\t\t\t\tstats.Kills.Value += 1\n\t\t\t\tend\n\t\t\tend\n\t\tend)\n\tend)\nend)\n",
        "Name": "ScoreSystem"
    },
    {
        "ClassName": "Script",
        "Source": "local fireEvent = game.ReplicatedStorage:WaitForChild(\"WeaponFireEvent\")\nlocal hitmarkerEvent = game.ReplicatedStorage:WaitForChild(\"HitmarkerEvent\")\nlocal players = game:GetService(\"Players\")\nlocal debris = game:GetService(\"Debris\")\n\nlocal range = 600 -- Дальность стрельбы\n\nlocal function drawTracer(startPos, endPos, color)\n\tlocal distance = (endPos - startPos).Magnitude\n\tlocal tracer = Instance.new(\"Part\")\n\ttracer.Anchored = true\n\ttracer.CanCollide = false\n\ttracer.Material = Enum.Material.Neon\n\ttracer.Color = color\n\ttracer.Size = Vector3.new(0.08, 0.08, distance)\n\ttracer.CFrame = CFrame.lookAt(startPos, endPos) * CFrame.new(0, 0, -distance / 2)\n\ttracer.Parent = workspace\n\tdebris:AddItem(tracer, 0.08)\nend\n\nfireEvent.OnServerEvent:Connect(function(player, targetPos, weaponDamage)\n\tlocal character = player.Character\n\tif not character then return end\n\n\tlocal tool = character:FindFirstChildOfClass(\"Tool\")\n\tif not tool or not tool:FindFirstChild(\"Handle\") then return end\n\n\tlocal damage = math.clamp(weaponDamage or 20, 1, 100)\n\tlocal tracerColor = (damage >= 80) and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(255, 220, 50)\n\n\t-- Ищем точку Muzzle внутри оружия; если её нет, берем позицию Handle\n\tlocal muzzle = tool:FindFirstChild(\"Muzzle\", true)\n\tlocal startPos = muzzle and muzzle.WorldPosition or tool.Handle.Position\n\n\tlocal direction = (targetPos - startPos).Unit * range\n\n\tlocal rayParams = RaycastParams.new()\n\trayParams.FilterDescendantsInstances = {character}\n\trayParams.FilterType = Enum.RaycastFilterType.Exclude\n\n\tlocal result = workspace:Raycast(startPos, direction, rayParams)\n\tlocal hitPos = result and result.Position or (startPos + direction)\n\n\tdrawTracer(startPos, hitPos, tracerColor)\n\n\tif result and result.Instance then\n\t\tlocal hitChar = result.Instance:FindFirstAncestorOfClass(\"Model\")\n\t\tlocal humanoid = hitChar and hitChar:FindFirstChild(\"Humanoid\")\n\n\t\tif humanoid and humanoid.Health > 0 then\n\t\t\tlocal targetPlayer = players:GetPlayerFromCharacter(hitChar)\n\t\t\tif targetPlayer and targetPlayer.Team == player.Team then\n\t\t\t\treturn\n\t\t\tend\n\n\t\t\tlocal oldTag = humanoid:FindFirstChild(\"creator\")\n\t\t\tif oldTag then oldTag:Destroy() end\n\n\t\t\tlocal tag = Instance.new(\"ObjectValue\")\n\t\t\ttag.Name = \"creator\"\n\t\t\ttag.Value = player\n\t\t\ttag.Parent = humanoid\n\t\t\tdebris:AddItem(tag, 2)\n\n\t\t\thumanoid:TakeDamage(damage)\n\n\t\t\tlocal isKill = (humanoid.Health <= 0)\n\t\t\thitmarkerEvent:FireClient(player, isKill)\n\t\tend\n\tend\nend)\n",
        "Name": "WeaponServer"
    },
    {
        "ClassName": "Script",
        "Source": "print(\"Hello world, from server!\")\n",
        "Name": "ServerScriptService"
    },
    {
        "ClassName": "Script",
        "Source": "local players = game:GetService(\"Players\")\nlocal repStorage = game:GetService(\"ReplicatedStorage\")\n\nlocal statusVal = repStorage:WaitForChild(\"GameStatus\")\nlocal redScore = repStorage:WaitForChild(\"RedScore\")\nlocal blueScore = repStorage:WaitForChild(\"BlueScore\")\n\nlocal redSpawn = workspace:WaitForChild(\"RedArenaSpawn\")\nlocal blueSpawn = workspace:WaitForChild(\"BlueArenaSpawn\")\n\nlocal intermissionTime = 15 -- Ожидание в лобби (сек)\nlocal matchDuration = 120   -- Длительность раунда (сек)\nlocal roundActive = false\n\n-- Функция телепортации игрока на базу его команды\nlocal function sendToTeamBase(player)\n\tlocal char = player.Character\n\tlocal root = char and char:WaitForChild(\"HumanoidRootPart\", 5)\n\tif not root then return end\n\n\ttask.wait(0.1) -- Небольшая пауза, чтобы персонаж успел загрузиться\n\tif player.Team and player.Team.Name == \"Red\" then\n\t\troot.CFrame = redSpawn.CFrame + Vector3.new(0, 3, 0)\n\telseif player.Team and player.Team.Name == \"Blue\" then\n\t\troot.CFrame = blueSpawn.CFrame + Vector3.new(0, 3, 0)\n\tend\nend\n\n-- Отслеживаем вход игроков, их возрождение и командные убийства\nplayers.PlayerAdded:Connect(function(player)\n\tplayer.CharacterAdded:Connect(function(char)\n\t\t-- Если раунд прямо сейчас идет, сразу отправляем возродившегося игрока на базу команды\n\t\tif roundActive then\n\t\t\tsendToTeamBase(player)\n\t\tend\n\n\t\tlocal hum = char:WaitForChild(\"Humanoid\")\n\t\thum.Died:Connect(function()\n\t\t\tif not roundActive then return end\n\t\t\tlocal tag = hum:FindFirstChild(\"creator\")\n\t\t\tif tag and tag.Value and tag.Value:IsA(\"Player\") then\n\t\t\t\tlocal killer = tag.Value\n\t\t\t\tif killer.Team and killer.Team.Name == \"Red\" then\n\t\t\t\t\tredScore.Value += 1\n\t\t\t\telseif killer.Team and killer.Team.Name == \"Blue\" then\n\t\t\t\t\tblueScore.Value += 1\n\t\t\t\tend\n\t\t\tend\n\t\tend)\n\tend)\nend)\n\n-- Бесконечный цикл смены раундов\nwhile true do\n\t-- 1. Фаза ожидания в лобби\n\troundActive = false\n\tfor i = intermissionTime, 1, -1 do\n\t\tstatusVal.Value = \"Ожидание игроков: \" .. i .. \" сек.\"\n\t\ttask.wait(1)\n\tend\n\n\t-- Сбрасываем счет и начинаем бой\n\tredScore.Value = 0\n\tblueScore.Value = 0\n\troundActive = true\n\n\t-- Отправляем всех на арену\n\tfor _, player in ipairs(players:GetPlayers()) do\n\t\tsendToTeamBase(player)\n\tend\n\n\t-- 2. Идет раунд\n\tfor i = matchDuration, 1, -1 do\n\t\tstatusVal.Value = \"Бой идет! Осталось: \" .. i .. \" сек.\"\n\t\ttask.wait(1)\n\tend\n\n\t-- 3. Итоги раунда\n\troundActive = false\n\tif redScore.Value > blueScore.Value then\n\t\tstatusVal.Value = \"Победили КРАСНЫЕ! (\" .. redScore.Value .. \" : \" .. blueScore.Value .. \")\"\n\telseif blueScore.Value > redScore.Value then\n\t\tstatusVal.Value = \"Победили СИНИЕ! (\" .. blueScore.Value .. \" : \" .. redScore.Value .. \")\"\n\telse\n\t\tstatusVal.Value = \"НИЧЬЯ! (\" .. redScore.Value .. \" : \" .. blueScore.Value .. \")\"\n\tend\n\n\ttask.wait(5)\n\n\t-- Возвращаем всех в лобби\n\tfor _, player in ipairs(players:GetPlayers()) do\n\t\tplayer:LoadCharacter()\n\tend\nend\n",
        "Name": "MatchManager"
    },
    {
        "ClassName": "Script",
        "Source": "local players = game:GetService(\"Players\")\nlocal repStorage = game:GetService(\"ReplicatedStorage\")\n\nlocal statusVal = repStorage:WaitForChild(\"GameStatus\")\nlocal redScore = repStorage:WaitForChild(\"RedScore\")\nlocal blueScore = repStorage:WaitForChild(\"BlueScore\")\n\nlocal redSpawn = workspace:WaitForChild(\"RedArenaSpawn\")\nlocal blueSpawn = workspace:WaitForChild(\"BlueArenaSpawn\")\n\nlocal intermissionTime = 15 -- Ожидание в лобби (сек)\nlocal matchDuration = 120   -- Длительность раунда (сек)\nlocal roundActive = false\n\n-- Функция телепортации игрока на базу его команды\nlocal function sendToTeamBase(player)\n\tlocal char = player.Character\n\tlocal root = char and char:WaitForChild(\"HumanoidRootPart\", 5)\n\tif not root then return end\n\n\ttask.wait(0.1) -- Небольшая пауза, чтобы персонаж успел загрузиться\n\tif player.Team and player.Team.Name == \"Red\" then\n\t\troot.CFrame = redSpawn.CFrame + Vector3.new(0, 3, 0)\n\telseif player.Team and player.Team.Name == \"Blue\" then\n\t\troot.CFrame = blueSpawn.CFrame + Vector3.new(0, 3, 0)\n\tend\nend\n\n-- Отслеживаем вход игроков, их возрождение и командные убийства\nplayers.PlayerAdded:Connect(function(player)\n\tplayer.CharacterAdded:Connect(function(char)\n\t\t-- Если раунд прямо сейчас идет, сразу отправляем возродившегося игрока на базу команды\n\t\tif roundActive then\n\t\t\tsendToTeamBase(player)\n\t\tend\n\n\t\tlocal hum = char:WaitForChild(\"Humanoid\")\n\t\thum.Died:Connect(function()\n\t\t\tif not roundActive then return end\n\t\t\tlocal tag = hum:FindFirstChild(\"creator\")\n\t\t\tif tag and tag.Value and tag.Value:IsA(\"Player\") then\n\t\t\t\tlocal killer = tag.Value\n\t\t\t\tif killer.Team and killer.Team.Name == \"Red\" then\n\t\t\t\t\tredScore.Value += 1\n\t\t\t\telseif killer.Team and killer.Team.Name == \"Blue\" then\n\t\t\t\t\tblueScore.Value += 1\n\t\t\t\tend\n\t\t\tend\n\t\tend)\n\tend)\nend)\n\n-- Бесконечный цикл смены раундов\nwhile true do\n\t-- 1. Фаза ожидания в лобби\n\troundActive = false\n\tfor i = intermissionTime, 1, -1 do\n\t\tstatusVal.Value = \"Ожидание игроков: \" .. i .. \" сек.\"\n\t\ttask.wait(1)\n\tend\n\n\t-- Сбрасываем счет и начинаем бой\n\tredScore.Value = 0\n\tblueScore.Value = 0\n\troundActive = true\n\n\t-- Отправляем всех на арену\n\tfor _, player in ipairs(players:GetPlayers()) do\n\t\tsendToTeamBase(player)\n\tend\n\n\t-- 2. Идет раунд\n\tfor i = matchDuration, 1, -1 do\n\t\tstatusVal.Value = \"Бой идет! Осталось: \" .. i .. \" сек.\"\n\t\ttask.wait(1)\n\tend\n\n\t-- 3. Итоги раунда\n\troundActive = false\n\tif redScore.Value > blueScore.Value then\n\t\tstatusVal.Value = \"Победили КРАСНЫЕ! (\" .. redScore.Value .. \" : \" .. blueScore.Value .. \")\"\n\telseif blueScore.Value > redScore.Value then\n\t\tstatusVal.Value = \"Победили СИНИЕ! (\" .. blueScore.Value .. \" : \" .. redScore.Value .. \")\"\n\telse\n\t\tstatusVal.Value = \"НИЧЬЯ! (\" .. redScore.Value .. \" : \" .. blueScore.Value .. \")\"\n\tend\n\n\ttask.wait(5)\n\n\t-- Возвращаем всех в лобби\n\tfor _, player in ipairs(players:GetPlayers()) do\n\t\tplayer:LoadCharacter()\n\tend\nend\n",
        "Name": "MatchManager"
    },
    {
        "ClassName": "Script",
        "Name": "ScoreSystem"
    },
    {
        "ClassName": "Script",
        "Name": "ScoreSystem"
    },
    {
        "ClassName": "Script",
        "Source": "local fireEvent = game.ReplicatedStorage:WaitForChild(\"WeaponFireEvent\")\nlocal hitmarkerEvent = game.ReplicatedStorage:WaitForChild(\"HitmarkerEvent\")\nlocal players = game:GetService(\"Players\")\nlocal debris = game:GetService(\"Debris\")\n\nlocal range = 600 -- Дальность стрельбы\n\nlocal function drawTracer(startPos, endPos, color)\n\tlocal distance = (endPos - startPos).Magnitude\n\tlocal tracer = Instance.new(\"Part\")\n\ttracer.Anchored = true\n\ttracer.CanCollide = false\n\ttracer.Material = Enum.Material.Neon\n\ttracer.Color = color\n\ttracer.Size = Vector3.new(0.08, 0.08, distance)\n\ttracer.CFrame = CFrame.lookAt(startPos, endPos) * CFrame.new(0, 0, -distance / 2)\n\ttracer.Parent = workspace\n\tdebris:AddItem(tracer, 0.08)\nend\n\nfireEvent.OnServerEvent:Connect(function(player, targetPos, weaponDamage)\n\tlocal character = player.Character\n\tif not character then return end\n\n\tlocal tool = character:FindFirstChildOfClass(\"Tool\")\n\tif not tool or not tool:FindFirstChild(\"Handle\") then return end\n\n\tlocal damage = math.clamp(weaponDamage or 20, 1, 100)\n\tlocal tracerColor = (damage >= 80) and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(255, 220, 50)\n\n\t-- Ищем точку Muzzle внутри оружия; если её нет, берем позицию Handle\n\tlocal muzzle = tool:FindFirstChild(\"Muzzle\", true)\n\tlocal startPos = muzzle and muzzle.WorldPosition or tool.Handle.Position\n\n\tlocal direction = (targetPos - startPos).Unit * range\n\n\tlocal rayParams = RaycastParams.new()\n\trayParams.FilterDescendantsInstances = {character}\n\trayParams.FilterType = Enum.RaycastFilterType.Exclude\n\n\tlocal result = workspace:Raycast(startPos, direction, rayParams)\n\tlocal hitPos = result and result.Position or (startPos + direction)\n\n\tdrawTracer(startPos, hitPos, tracerColor)\n\n\tif result and result.Instance then\n\t\tlocal hitChar = result.Instance:FindFirstAncestorOfClass(\"Model\")\n\t\tlocal humanoid = hitChar and hitChar:FindFirstChild(\"Humanoid\")\n\n\t\tif humanoid and humanoid.Health > 0 then\n\t\t\tlocal targetPlayer = players:GetPlayerFromCharacter(hitChar)\n\t\t\tif targetPlayer and targetPlayer.Team == player.Team then\n\t\t\t\treturn\n\t\t\tend\n\n\t\t\tlocal oldTag = humanoid:FindFirstChild(\"creator\")\n\t\t\tif oldTag then oldTag:Destroy() end\n\n\t\t\tlocal tag = Instance.new(\"ObjectValue\")\n\t\t\ttag.Name = \"creator\"\n\t\t\ttag.Value = player\n\t\t\ttag.Parent = humanoid\n\t\t\tdebris:AddItem(tag, 2)\n\n\t\t\thumanoid:TakeDamage(damage)\n\n\t\t\tlocal isKill = (humanoid.Health <= 0)\n\t\t\thitmarkerEvent:FireClient(player, isKill)\n\t\tend\n\tend\nend)\n",
        "Name": "WeaponServer"
    },
    {
        "ClassName": "Script",
        "Source": "local fireEvent = game.ReplicatedStorage:WaitForChild(\"WeaponFireEvent\")\nlocal hitmarkerEvent = game.ReplicatedStorage:WaitForChild(\"HitmarkerEvent\")\nlocal players = game:GetService(\"Players\")\nlocal debris = game:GetService(\"Debris\")\n\nlocal range = 600 -- Дальность стрельбы\n\nlocal function drawTracer(startPos, endPos, color)\n\tlocal distance = (endPos - startPos).Magnitude\n\tlocal tracer = Instance.new(\"Part\")\n\ttracer.Anchored = true\n\ttracer.CanCollide = false\n\ttracer.Material = Enum.Material.Neon\n\ttracer.Color = color\n\ttracer.Size = Vector3.new(0.08, 0.08, distance)\n\ttracer.CFrame = CFrame.lookAt(startPos, endPos) * CFrame.new(0, 0, -distance / 2)\n\ttracer.Parent = workspace\n\tdebris:AddItem(tracer, 0.08)\nend\n\nfireEvent.OnServerEvent:Connect(function(player, targetPos, weaponDamage)\n\tlocal character = player.Character\n\tif not character then return end\n\n\tlocal tool = character:FindFirstChildOfClass(\"Tool\")\n\tif not tool or not tool:FindFirstChild(\"Handle\") then return end\n\n\tlocal damage = math.clamp(weaponDamage or 20, 1, 100)\n\tlocal tracerColor = (damage >= 80) and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(255, 220, 50)\n\n\t-- Ищем точку Muzzle внутри оружия; если её нет, берем позицию Handle\n\tlocal muzzle = tool:FindFirstChild(\"Muzzle\", true)\n\tlocal startPos = muzzle and muzzle.WorldPosition or tool.Handle.Position\n\n\tlocal direction = (targetPos - startPos).Unit * range\n\n\tlocal rayParams = RaycastParams.new()\n\trayParams.FilterDescendantsInstances = {character}\n\trayParams.FilterType = Enum.RaycastFilterType.Exclude\n\n\tlocal result = workspace:Raycast(startPos, direction, rayParams)\n\tlocal hitPos = result and result.Position or (startPos + direction)\n\n\tdrawTracer(startPos, hitPos, tracerColor)\n\n\tif result and result.Instance then\n\t\tlocal hitChar = result.Instance:FindFirstAncestorOfClass(\"Model\")\n\t\tlocal humanoid = hitChar and hitChar:FindFirstChild(\"Humanoid\")\n\n\t\tif humanoid and humanoid.Health > 0 then\n\t\t\tlocal targetPlayer = players:GetPlayerFromCharacter(hitChar)\n\t\t\tif targetPlayer and targetPlayer.Team == player.Team then\n\t\t\t\treturn\n\t\t\tend\n\n\t\t\tlocal oldTag = humanoid:FindFirstChild(\"creator\")\n\t\t\tif oldTag then oldTag:Destroy() end\n\n\t\t\tlocal tag = Instance.new(\"ObjectValue\")\n\t\t\ttag.Name = \"creator\"\n\t\t\ttag.Value = player\n\t\t\ttag.Parent = humanoid\n\t\t\tdebris:AddItem(tag, 2)\n\n\t\t\thumanoid:TakeDamage(damage)\n\n\t\t\tlocal isKill = (humanoid.Health <= 0)\n\t\t\thitmarkerEvent:FireClient(player, isKill)\n\t\tend\n\tend\nend)\n",
        "Name": "WeaponServer"
    },
    {},
    {
        "ResetPlayerGuiOnSpawn": "true",
        "Sandboxed": "false",
        "ScreenOrientation": "Sensor",
        "ShowDevelopmentGui": "true",
        "archivable": "true",
        "Name": "StarterGui",
        "Archivable": "true",
        "Capabilities": ""
    },
    {
        "ClassName": "LocalScript",
        "Source": "local player = game.Players.LocalPlayer\nlocal playerGui = player:WaitForChild(\"PlayerGui\")\nlocal uis = game:GetService(\"UserInputService\")\nlocal hitmarkerEvent = game.ReplicatedStorage:WaitForChild(\"HitmarkerEvent\")\n\n-- Создаем экранный контейнер\nlocal screenGui = Instance.new(\"ScreenGui\")\nscreenGui.Name = \"ShooterHUD\"\nscreenGui.IgnoreGuiInset = true\nscreenGui.ResetOnSpawn = false\nscreenGui.Parent = playerGui\n\n-- Звук попадания (щелчок хитмаркера)\nlocal hitSound = Instance.new(\"Sound\")\nhitSound.SoundId = \"rbxassetid://160432334\"\nhitSound.Volume = 0.8\nhitSound.Parent = screenGui\n\n-- Центральная точка прицела\nlocal centerDot = Instance.new(\"Frame\")\ncenterDot.Size = UDim2.new(0, 4, 0, 4)\ncenterDot.Position = UDim2.new(0.5, -2, 0.5, -2)\ncenterDot.BackgroundColor3 = Color3.fromRGB(0, 255, 100)\ncenterDot.BorderSizePixel = 0\ncenterDot.Visible = false\ncenterDot.Parent = screenGui\n\nlocal lines = {} -- Запоминаем все полоски прицела, чтобы менять их цвет\n\nlocal function createLine(sizeX, sizeY, offsetX, offsetY)\n\tlocal line = Instance.new(\"Frame\")\n\tline.Size = UDim2.new(0, sizeX, 0, sizeY)\n\tline.Position = UDim2.new(0.5, offsetX, 0.5, offsetY)\n\tline.BackgroundColor3 = Color3.fromRGB(0, 255, 100)\n\tline.BorderSizePixel = 0\n\tline.Parent = centerDot\n\ttable.insert(lines, line)\nend\n\ncreateLine(2, 10, -1, -16) -- Верх\ncreateLine(2, 10, -1, 6)   -- Низ\ncreateLine(10, 2, -16, -1) -- Лево\ncreateLine(10, 2, 6, -1)   -- Право\n\n-- Функция смены цвета всего прицела\nlocal function setCrosshairColor(color)\n\tcenterDot.BackgroundColor3 = color\n\tfor _, line in ipairs(lines) do\n\t\tline.BackgroundColor3 = color\n\tend\nend\n\n-- Реакция на попадание во врага\nhitmarkerEvent.OnClientEvent:Connect(function(isKill)\n\thitSound:Play()\n\t-- Если убили — ярко-красный цвет, если просто ранили — оранжевый\n\tif isKill then\n\t\tsetCrosshairColor(Color3.fromRGB(255, 30, 30))\n\telse\n\t\tsetCrosshairColor(Color3.fromRGB(255, 180, 0))\n\tend\n\n\ttask.wait(0.12)\n\tsetCrosshairColor(Color3.fromRGB(0, 255, 100)) -- Возвращаем зеленый\nend)\n\n-- Показываем прицел только с оружием в руках\nlocal function watchCharacter(character)\n\tcharacter.ChildAdded:Connect(function(child)\n\t\tif child:IsA(\"Tool\") then\n\t\t\tcenterDot.Visible = true\n\t\t\tuis.MouseIconEnabled = false\n\t\tend\n\tend)\n\n\tcharacter.ChildRemoved:Connect(function(child)\n\t\tif child:IsA(\"Tool\") then\n\t\t\tcenterDot.Visible = false\n\t\t\tuis.MouseIconEnabled = true\n\t\tend\n\tend)\nend\n\nif player.Character then\n\twatchCharacter(player.Character)\nend\nplayer.CharacterAdded:Connect(watchCharacter)\n",
        "Name": "CrosshairUI"
    },
    {
        "ClassName": "LocalScript",
        "Source": "local player = game.Players.LocalPlayer\nlocal repStorage = game:GetService(\"ReplicatedStorage\")\n\nlocal statusVal = repStorage:WaitForChild(\"GameStatus\")\nlocal redScore = repStorage:WaitForChild(\"RedScore\")\nlocal blueScore = repStorage:WaitForChild(\"BlueScore\")\n\nlocal gui = Instance.new(\"ScreenGui\")\ngui.Name = \"MatchTopHUD\"\ngui.ResetOnSpawn = false\ngui.Parent = player:WaitForChild(\"PlayerGui\")\n\n-- Плашка таймера сверху по центру\nlocal statusLabel = Instance.new(\"TextLabel\")\nstatusLabel.Size = UDim2.new(0, 340, 0, 36)\nstatusLabel.Position = UDim2.new(0.5, -170, 0, 10)\nstatusLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)\nstatusLabel.BackgroundTransparency = 0.2\nstatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)\nstatusLabel.Font = Enum.Font.GothamBold\nstatusLabel.TextSize = 15\nstatusLabel.Text = statusVal.Value\nstatusLabel.Parent = gui\n\n-- Счет Красных (слева)\nlocal redLabel = Instance.new(\"TextLabel\")\nredLabel.Size = UDim2.new(0, 55, 0, 36)\nredLabel.Position = UDim2.new(0.5, -230, 0, 10)\nredLabel.BackgroundColor3 = Color3.fromRGB(200, 40, 40)\nredLabel.TextColor3 = Color3.fromRGB(255, 255, 255)\nredLabel.Font = Enum.Font.GothamBlack\nredLabel.TextSize = 20\nredLabel.Text = tostring(redScore.Value)\nredLabel.Parent = gui\n\n-- Счет Синих (справа)\nlocal blueLabel = Instance.new(\"TextLabel\")\nblueLabel.Size = UDim2.new(0, 55, 0, 36)\nblueLabel.Position = UDim2.new(0.5, 175, 0, 10)\nblueLabel.BackgroundColor3 = Color3.fromRGB(40, 100, 220)\nblueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)\nblueLabel.Font = Enum.Font.GothamBlack\nblueLabel.TextSize = 20\nblueLabel.Text = tostring(blueScore.Value)\nblueLabel.Parent = gui\n\nstatusVal.Changed:Connect(function(val) statusLabel.Text = val end)\nredScore.Changed:Connect(function(val) redLabel.Text = tostring(val) end)\nblueScore.Changed:Connect(function(val) blueLabel.Text = tostring(val) end)\n\n",
        "Name": "MatchHUD"
    },
    {
        "archivable": "true",
        "Name": "StarterPack",
        "Archivable": "true",
        "Capabilities": "",
        "Sandboxed": "false"
    },
    {
        "CameraMaxZoomDistance": "128",
        "CameraMode": "LockFirstPerson",
        "CharacterBreakJointsOnDeath": "false",
        "CharacterUseJumpPower": "false"
    },
    {
        "ClassName": "StarterCharacterScripts"
    },
    {
        "ClassName": "StarterPlayerScripts"
    },
    {},
    {
        "DefaultListenerLocation": "Camera",
        "RespectFilteringEnabled": "true"
    },
    {}
]