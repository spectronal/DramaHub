getgenv().DH = getgenv().DH or {}
getgenv().DH.Scrolls = {}

local Scrolls = getgenv().DH.Scrolls
local State = getgenv().DH.State
local Gamemode = getgenv().DH.Gamemode

local Framework = State.Framework
local MapData = State.MapData

local PlayerRoot = State.PlayerRootPart
local Selected = State.scriptSettings.ScrollsTab.SelectedScroll

local mapFolder = workspace["_MAP"]

local function teleportToScroll()
	for _, model in pairs(mapFolder:GetDescendants()) do
		if model:IsA("Model") and model.Name == Selected then
			local distance = (PlayerRoot.Position - scrollModel).Magnitude

			if distance > 10 then
				PlayerRoot.Position = Vector3.new(model.Position)
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
		Framework.Remote:Fire("PetSystem", "Open", Selected, "All")
	else
		teleportToScroll()
		task.wait(2)
		Framework.Remote:Fire("PetSystem", "Open", Selected, "All")
	end
end
