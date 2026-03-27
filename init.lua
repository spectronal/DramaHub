local BASE_URL = "https://dramahub.up.railway.app"
local SCRIPT_TOKEN = "SPECTRONAL_DRAMAHUB_PRIVATETOKEN"

local SUPPORTED_GAMES = {
	[101640913672688] = BASE_URL .. "/script/main?token=" .. SCRIPT_TOKEN, -- Anime Ghost
}

local gameId = game.PlaceId
local CoreGui = game:GetService("StarterGui")
local url = SUPPORTED_GAMES[gameId]

local function Notifier(Title, Text, Duration)
	CoreGui:SetCore("SendNotification", {
		Title = Title,
		Text = Text,
		Duration = Duration,
	})
end

Notifier("Verifying supported games", "Searching game in script data", 3)

if not url then
	Notifier("Denied", "DramaHub doesnt have support for this game!", 3)
	return
end

local ok, err = pcall(function()
	Notifier("Sucess", "Game found!", 2)
	task.wait(1)
	Notifier("Loading", "It may take a few seconds", 11)
	loadstring(game:HttpGet(url))()
end)

if not ok then
	Notifier("Error", tostring(err), 3)
end
