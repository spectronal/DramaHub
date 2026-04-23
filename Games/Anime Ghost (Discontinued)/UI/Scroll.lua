-- UI/Scroll.lua
-- Tab: Scroll

getgenv().DH = getgenv().DH or {}
getgenv().DH.UI = getgenv().DH.UI or {}
getgenv().DH.UI.Scroll = {}

local UIScroll = getgenv().DH.UI.Scroll

function UIScroll.build(Tabs)
	local State = getgenv().DH.State

	local mainScrolls = Tabs.Scroll:AddSection("Main")

	local selectScroll = mainScrolls:AddDropdown("selectScroll", {
		Title       = "Select Scroll",
		Description = "Select a scroll to open",
		Values      = State.mapScrolls,
		Multi       = false,
		Default     = "",
	})

	mainScrolls:AddToggle("teleportToEgg", {
		Title    = "Auto Teleport to Scroll",
		Default  = false,
		Callback = function(state)
			State.scriptSettings.ScrollsTab.TeleportToEgg = state
		end,
	})

	mainScrolls:AddToggle("autoOpenScroll", {
		Title    = "Auto Open Scroll",
		Default  = false,
		Callback = function(state)
			State.scriptSettings.ScrollsTab.AutoOpenScroll = state
		end,
	})

	-- OnChanged
	selectScroll:OnChanged(function(Value)
		State.scriptSettings.ScrollsTab.SelectedScroll = Value
		print(State.scriptSettings.ScrollsTab.SelectedScroll)
	end)
end
