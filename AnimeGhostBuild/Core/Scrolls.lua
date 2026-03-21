getgenv().DH = getgenv().DH or {}
getgenv().DH.Scrolls = {}

local Scrolls = getgenv().DH.Scrolls
local State = getgenv().DH.State
local Gamemode = getgenv().DH.Gamemode

local Framework = State.Framework

local mapFolder = workspace["_MAP"]

local function teleportToScroll()
	for _, model in pairs(mapFolder:GetDescendants()) do
		if model:IsA("Model") and model.Name == State.scriptSettings.ScrollsTab.SelectedScroll then
			local distance = (State.PlayerRootPart.Position - model.Range.Position).Magnitude

			if distance > 30 then
				local height = Vector3.new(0, 6, 0)
				State.PlayerRootPart.CFrame = CFrame.new(model.Range.Position + height)
			end
		end
	end
end

function Scrolls.autoOpen()
	if not Gamemode.InMode() then
		if not State.scriptSettings.ScrollsTab.TeleportToEgg then
			Framework.Remote:Fire("PetSystem", "Open", State.scriptSettings.ScrollsTab.SelectedScroll, "All")
		else
			teleportToScroll()
			Framework.Remote:Fire("PetSystem", "Open", State.scriptSettings.ScrollsTab.SelectedScroll, "All")
		end
	end
end
