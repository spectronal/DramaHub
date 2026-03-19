local BASE_URL     = "https://dramahub.up.railway.app"
local SCRIPT_TOKEN = "SPECTRONAL_DRAMAHUB_PRIVATETOKEN"

local SUPPORTED_GAMES = {
    [101640913672688] = BASE_URL .. "/script/main?token=" .. SCRIPT_TOKEN, -- Anime Ghost
}

local gameId = game.PlaceId
local notify = game:GetService("StarterGui")
local url = SUPPORTED_GAMES[gameId]

CoreGui:SetCore("SendNotification", {
	Title = "DramaHub | Verify";
	Text = "Verifying if game have support";
	Duration = 3;
})

if not url then
    CoreGui:SetCore("SendNotification", {
	Title = "DramaHub | Denied";
	Text = "Game not supported";
	Duration = 5;
})
    return
end

local ok, err = pcall(function()
    CoreGui:SetCore("SendNotification", {
	Title = "DramaHub | Sucess";
	Text = "Game found!";
	Duration = 3;
})
    loadstring(game:HttpGet(url))()
end)

if not ok then
    warn("[DramaHub] Fail to load: " .. tostring(err))
end
