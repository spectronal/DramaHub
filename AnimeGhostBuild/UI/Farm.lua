-- UI/Farm.lua
-- Tab: Farm

getgenv().DH = getgenv().DH or {}
getgenv().DH.UI = getgenv().DH.UI or {}
getgenv().DH.UI.Farm = {}

local UIFarm = getgenv().DH.UI.Farm

function UIFarm.build(Tabs)
	local State = getgenv().DH.State
	local Inserted = State.Inserted

	local farmAbout = Tabs.Farm:AddSection("Mobs")

	local selectFarmMob = farmAbout:AddDropdown("selectFarmMob", {
		Title = "Select Mobs",
		Description = "Select a enemy to farm",
		Values = State.Mobs,
		Multi = true,
		Default = { "" },
	})

	local selectPriority = farmAbout:AddDropdown("selectPriority", {
		Title = "Priority",
		Description = "Note: It may contain bugs based on your Enemy Range",
		Values = { "Weakest > Strongest", "Strongest > Weakest" },
		Multi = false,
		Default = 1,
	})

	farmAbout:AddButton({
		Title = "Refresh Mob List",
		Callback = function()
			table.clear(State.Mobs)
			table.clear(Inserted)

			for _, mob in pairs(State.enemiesFolder:GetDescendants()) do
				if mob:IsA("Part") and mob:GetAttribute("HP") then
					for _, mobClient in pairs(State.enemiesClientFolder:GetChildren()) do
						if mobClient:IsA("Model") then
							if mob.Name == mobClient.Name then
								local mobName = mob:GetAttribute("Name")

								if not Inserted[mobName] then
									Inserted[mobName] = true
									table.insert(State.Mobs, mobName)
								end
							end
						end
					end
				end
			end

			selectFarmMob:SetValue(State.Mobs)
		end,
	})

	farmAbout:AddToggle("Auto Farm", {
		Title = "Auto Farm",
		Default = false,
		Callback = function(state)
			State.scriptSettings.FarmTab.AutoFarm = state
		end,
	})

	-- OnChanged
	selectFarmMob:OnChanged(function(Value)
		State.scriptSettings.FarmTab.SelectMobs = Value
	end)

	selectPriority:OnChanged(function(Value)
		State.scriptSettings.FarmTab.Priority = Value
	end)
end
