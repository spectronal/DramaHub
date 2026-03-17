--// Framework
local Framework = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"):WaitForChild("Library"))

--// Services
Framework:GetService("GFX")
Framework:GetService("Utils")
Framework:GetService("PetService")

local SoundService = Framework:GetService("SoundService")
local EnemyService = Framework:GetService("EnemyService")

Framework:GetService("NotifyService")

local DebounceService = Framework:GetService("DebounceService")
local AnimationService = Framework:GetService("AnimationService")
local AbbreviateService = Framework:GetService("AbbreviateService")
local MultiplierService = Framework:GetService("MultiplierService")

--// Data
local Keybinds = Framework:GetData("Keybinds")

--// Packages
local Janitor = Framework:GetPackage("Janitor")

--// UI
Framework:GetScreen("SideGUI")
Framework:GetScreen("Utils")

local AutoClickButton = Framework:GetSideButton("AutoClick")
local CastSkillButton = Framework:GetSideButton("CastSkill")

--// Workspace
workspace:WaitForChild("_PETS")

--// Variables
local lastClickTime = ti
ck()
local comboIndex = 0

local ClickJanitor = Janitor.new()

local ToggleColors = {
	[true] = Color3.fromRGB(0, 255, 0),
	[false] = Color3.fromRGB(255, 0, 0),
}

--------------------------------------------------
-- CLICK FUNCTION
--------------------------------------------------

local function executeClick()
	if Framework.LocalPlayer:GetAttribute("UsingSkill") then
		return
	end

	if DebounceService.Check(Framework.LocalPlayer, "Click", 0.05) then
		return
	end

	Framework.Remote:Fire("ClickSystem", "Execute", Framework.Target)

	local atkSpeed = MultiplierService.AtkSPD(Framework.LocalPlayer)
	local animationSpeed = 0.6 / atkSpeed

	if not DebounceService.Check(Framework.LocalPlayer, "ClickAnimation", atkSpeed * 1.1) then
		-- combo system
		comboIndex += 1

		if tick() - lastClickTime > 2 then
			comboIndex = 1
		end

		if comboIndex > 3 then
			comboIndex = 1
		end

		lastClickTime = tick()

		local animationType = "Punch"

		if not Framework.PlayerData.Settings.HideWeapon then
			local weaponTypes = {
				"Weapon",
				"DualWeapon",
				"TripleWeapon",
			}

			local equipped = #Framework.PlayerData.WeaponsEquipped

			if equipped > 0 then
				animationType = weaponTypes[equipped]
			end
		end

		if not Framework.LocalPlayer:GetAttribute("OnMount") then
			AnimationService.Load(
				Framework.LocalPlayer.Character.Humanoid.Animator,
				("%s %s"):format(animationType, comboIndex),
				animationSpeed,
				"Action2"
			)
		end
	end
end

--------------------------------------------------
-- AUTO CLICK
--------------------------------------------------

local function updateAutoClick()
	ClickJanitor:Cleanup()

	if Framework.PlayerData.Settings.AutoClick then
		ClickJanitor:Add(

			Framework.Run.Heartbeat:Connect(function()
				executeClick()
			end),

			"Disconnect"
		)
	end
end

--------------------------------------------------
-- SKILL CHARGE VISUAL
--------------------------------------------------

local function updateSkillButton()
	if
		(Framework.LocalPlayer:GetAttribute("SkillCharge") or 0)
		>= (MultiplierService.CastSkill(Framework.LocalPlayer) or 100)
	then
		Framework.Utils:SetPropertiesInObject(CastSkillButton, {
			ImageTransparency = 0,
			TextTransparency = 0,
		})
	else
		Framework.Utils:SetPropertiesInObject(CastSkillButton, {
			ImageTransparency = 0.5,
			TextTransparency = 0.5,
		})
	end
end

--------------------------------------------------
-- BUTTON EVENTS
--------------------------------------------------

AutoClickButton.MouseButton1Click:Connect(function()
	Framework.Remote:Fire("SettingSystem", "Toggle", "AutoClick")
end)

CastSkillButton.MouseButton1Click:Connect(function()
	if not DebounceService.Check(Framework.LocalPlayer, "CastSkill", 0.1) then
		Framework.Remote:Fire("ClickSystem", "CastSkill", Framework.Target)
	end
end)

--------------------------------------------------
-- KEYBINDS
--------------------------------------------------

Framework.UserInput.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if Keybinds.Click[input.KeyCode] then
		executeClick()
	end
end)

--------------------------------------------------
-- REMOTE EVENTS
--------------------------------------------------

Framework.Remote:Connect(function(data)
	if data[1] ~= "ClickController" then
		return
	end

	-----------------------------------------
	-- SETTINGS UPDATE
	-----------------------------------------

	if data[2] == "Update" then
		AutoClickButton.ImageColor3 = ToggleColors[Framework.PlayerData.Settings.AutoClick]

		updateAutoClick()
	end

	-----------------------------------------
	-- DAMAGE EFFECT
	-----------------------------------------

	if data[2] == "Effect" then
		local effectName = data[3]
		local amount = data[4]
		local target = data[5]

		local character = Framework.LocalPlayer.Character
		local root = target and target.PrimaryPart or character.PrimaryPart

		if not character or not root then
			return
		end

		local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

		local randomOffset = root.CFrame * CFrame.new(math.random(-1, 1), math.random(-1, 1), math.random(-4, -2))

		local nearOffset = root.CFrame * CFrame.new(math.random(-1, 1), math.random(-1, 1), -1)

		local fastMode = Framework.PlayerData.Settings.FastMode

		-- weapon sound
		local soundType = "Punch"

		if not Framework.PlayerData.Settings.HideWeapon then
			local weaponTypes = {
				"Weapon",
				"DualWeapon",
				"TripleWeapon",
			}

			local equipped = #Framework.PlayerData.WeaponsEquipped

			if equipped > 0 then
				soundType = weaponTypes[equipped]
			end
		end

		SoundService:Play(soundType)

		local effect = Framework.Replicated.Assets.Effects[effectName]:Clone()

		if target then
			randomOffset = nearOffset or randomOffset
		end

		effect.CFrame = randomOffset
		effect.Parent = workspace._IGNORE

		local weld = Instance.new("WeldConstraint", effect)
		weld.Part0 = effect
		weld.Part1 = root

		local text = ("%s%s %s"):format(
			target and "-" or "+",
			AbbreviateService:Number(amount),
			string.gsub(effectName, "%d+", "")
		)

		local gui = effect.Gui.Frame

		gui.Size = UDim2.fromScale(0, 0)
		gui.Icon.Amount.Text = text

		Framework.Tween
			:Create(gui, tweenInfo, {
				Size = UDim2.fromScale(0.7, 0.2),
			})
			:Play()

		if not fastMode then
			Framework.Utils:EmitAll(effect)
		end

		task.delay(0.5, function()
			Framework.Tween
				:Create(gui, tweenInfo, {
					Size = UDim2.fromScale(0, 0),
				})
				:Play()

			task.wait(0.3)

			effect:Destroy()
		end)
	end

	-----------------------------------------
	-- SKILL USED
	-----------------------------------------

	if data[2] == "SkillUsed" then
		local success, errorMessage = pcall(function()
			local cache = EnemyService.CACHE
			local player = data[3]
			local skillName = data[4]
			local enemy = cache:Get(data[5])

			if not enemy then
				return
			end

			local enemyRoot = player.Character.PrimaryPart
			local myRoot = Framework.LocalPlayer.Character.PrimaryPart

			local hideMine = Framework.PlayerData.Settings.HideMySkills
			local hideOthers = Framework.PlayerData.Settings.HideOtherSkills

			if enemyRoot then
				local skill = Framework:GetSkill(skillName)

				if
					(enemyRoot.Position - myRoot.Position).Magnitude <= 200
					and (
						player == Framework.LocalPlayer and not hideMine
						or player ~= Framework.LocalPlayer and not hideOthers
					)
				then
					skill(player, enemy.Model)
				end
			end
		end)

		if not success then
			warn("SKILL: " .. errorMessage)
		end
	end
end)

--------------------------------------------------
-- INITIALIZATION
--------------------------------------------------

AutoClickButton.ImageColor3 = ToggleColors[Framework.PlayerData.Settings.AutoClick]

updateAutoClick()
updateSkillButton()

Framework:GetMouse().Button1Down:Connect(executeClick)

Framework.LocalPlayer:GetAttributeChangedSignal("SkillCharge"):Connect(updateSkillButton)

Framework.LocalPlayer:GetAttributeChangedSignal("UsingSkill"):Connect(function()
	local usingSkill = Framework.LocalPlayer:GetAttribute("UsingSkill")

	Framework.LocalPlayer.Character.Humanoid.AutoRotate = not usingSkill

	if Framework.LocalPlayer.Character.PrimaryPart then
		Framework.LocalPlayer.Character.PrimaryPart.Anchored = usingSkill
	end
end)

return true
