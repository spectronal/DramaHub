getgenv().AutoCollect = false

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Pathfinding = game:GetService("PathfindingService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Player = Players.LocalPlayer
local ImpossibleItems = {}

function RemoveFromTable(Table, Item)
	for i, TItem in pairs(ImpossibleItems) do
		if TItem == Item then
			table.remove(Table, i)
			break
		end
	end
end

local function FollowPath(Destination, Item)
	local Character = Player.Character
	if Character then
		local Path = Pathfinding:CreatePath({
			AgentHeight = 5,
			AgentRadius = 2,
			AgentCanJump = true,
			AgentCanClimb = true,
			AgentJumpHeight = 10,
			AgentMaxSlope = 89,
			WaypointSpacing = 1,
		})
		local Success, Error = pcall(function()
			Path:ComputeAsync(Character.HumanoidRootPart.Position, Destination)
		end)
		if Success and Path.Status == Enum.PathStatus.Success then
			if table.find(ImpossibleItems, Item) then
				RemoveFromTable(ImpossibleItems, Item)
			end
			local Waypoints = Path:GetWaypoints()
			for i, Waypoint in pairs(Waypoints) do
				if not Item.Parent then
					break
				end

				local dist = (Character.HumanoidRootPart.Position - Item.Position).Magnitude
				if dist <= 8 then
					break
				end

				if Waypoint.Action == Enum.PathWaypointAction.Jump then
					Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end
				Character.Humanoid:MoveTo(Waypoint.Position)
				Character.Humanoid.MoveToFinished:Wait(2)
			end
		else
			if not table.find(ImpossibleItems, Item) then
				table.insert(ImpossibleItems, Item)
			end
		end
	end
end

local function GetNearestItem()
	local Character = Player.Character
	if Character then
		local NearestDistance
		local NearestItem
		for _, v in pairs(workspace:GetChildren()) do
			if v:IsA("Model") and v.Name:find("egg_") or v.Name:find("_egg") then
				if not table.find(ImpossibleItems, v) then
					if v:IsA("Model") then
						local dist = (
							Character.HumanoidRootPart.Position - v:FindFirstChildOfClass("MeshPart").Position
						).Magnitude
						if not NearestDistance or dist < NearestDistance then
							NearestDistance = dist
							NearestItem = v
						end
					else
						local dist = (Character.HumanoidRootPart.Position - v.Position).Magnitude
						if not NearestDistance or dist < NearestDistance then
							NearestDistance = dist
							NearestItem = v
						end
					end
				end
			end
		end
		return NearestItem
	end
	return nil
end

local function SpammarE(Item)
	local Character = Player.Character
	if not Character then
		return
	end

	local prompt = Item:FindFirstChildOfClass("ProximityPrompt")
	if not prompt then
		return
	end

	local tecla = prompt.KeyboardKeyCode

	while Item and Item.Parent do
		VirtualInputManager:SendKeyEvent(true, tecla, false, game)
		task.wait(0.05)
		VirtualInputManager:SendKeyEvent(false, tecla, false, game)
		task.wait(0.05)
	end
end

while task.wait() do
	if AutoCollect then
		local Item = GetNearestItem()
		if Item then
			local Highlight = Instance.new("Highlight")
			Highlight.Parent = Item
			Highlight.FillTransparency = 0

			local ultimaPosicao = nil
			local tempoParado = 0
			local LIMITE_PARADO = 10

			local stuckChecker = RunService.Heartbeat:Connect(function(dt)
				local Character = Player.Character
				if not Character then
					return
				end
				local pos = Character.HumanoidRootPart.Position

				if ultimaPosicao then
					local moved = (pos - ultimaPosicao).Magnitude
					if moved < 0.5 then
						tempoParado += dt
					else
						tempoParado = 0
					end
				end
				ultimaPosicao = pos
			end)

			while Item and Item.Parent do
				local Character = Player.Character
				if not Character then
					break
				end

				if tempoParado >= LIMITE_PARADO then
					print("Travado! Resetando rota...")
					tempoParado = 0
					ultimaPosicao = nil
					Character.Humanoid:MoveTo(Character.HumanoidRootPart.Position)
					Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
					task.wait(0.5)
					break
				end

				local dist = (Character.HumanoidRootPart.Position - Item.Position).Magnitude
				if dist <= 8 then
					Character.Humanoid:MoveTo(Character.HumanoidRootPart.Position)
					SpammarE(Item)
					task.wait(0.5)
					break
				end

				FollowPath(Item.Position, Item)
			end

			stuckChecker:Disconnect()
			Highlight:Destroy()
		end
	end
end
