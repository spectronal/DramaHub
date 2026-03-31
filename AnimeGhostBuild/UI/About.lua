-- UI/About.lua
-- Tab: About

getgenv().DH = getgenv().DH or {}
getgenv().DH.UI = getgenv().DH.UI or {}
getgenv().DH.UI.About = {}

local About = getgenv().DH.UI.About

function About.build(Tabs)
	local mainAbout = Tabs.About:AddSection("Drama Hub")

	mainAbout:AddParagraph({
		Title = "Version Development Build",
		Content = "\nThis is a development build of Drama Hub, an all-in-one script for Anime Ghost. \nThis build is not intended for public use and may contain bugs or unfinished features.\n\nCreated by spectronal",
	})

	mainAbout:AddButton({
		Title = "Refresh Script",
		Callback = function()
			game.Players.LocalPlayer.PlayerGui:FindFirstChild("DramaHub"):Destroy()
			task.wait(0.5)
			Fluent:Notify({ Title = "Drama Hub | Developer Version", Content = "Reloading...", Duration = 2 })
			task.wait(2.2)
			loadstring(game:HttpGet("https://dramahub.up.railway.app/init"))()
		end,
	})
end
