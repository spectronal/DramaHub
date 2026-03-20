getgenv().DH = getgenv().DH or {}
getgenv().DH.Scrolls = {}

local Scrolls = getgenv().DH.Scrolls
local State = getgenv().DH.State
local Gamemode = getgenv().DH.Gamemode

local Framework = State.Framework
local MapData = State.MapData

local mapFolder = workspace["_MAP"]

local function teleportToScroll()
	for _, model in pairs(mapFolder:GetDescendants()) do
		if model:IsA("Model") and model.Name == State.scriptSettings.ScrollsTab.SelectedScroll then
			print(model.Name)
			local distance = (State.PlayerRootPart.Position - model.Range.Position).Magnitude

			if distance > 15 then
				State.PlayerRootPart.Position = Vector3.new(model.Range.Position)
			end
		end
	end
end

function Scrolls.getScrollName()
	for map, scrollName in pairs(MapData) do
		table.insert(State.mapScrolls, scrollName["EggName"])
	end
end

function Scrolls.autoOpen()
	if not State.scriptSettings.ScrollsTab.TeleportToEgg then
		Framework.Remote:Fire("PetSystem", "Open", State.scriptSettings.ScrollsTab.SelectedScroll, "All")
	else
		teleportToScroll()
		task.wait(2)
		Framework.Remote:Fire("PetSystem", "Open", State.scriptSettings.ScrollsTab.SelectedScroll, "All")
	end
end
