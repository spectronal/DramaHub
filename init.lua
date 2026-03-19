local BASE_URL     = "https://dramahub.up.railway.app"
local SCRIPT_TOKEN = "SPECTRONAL_DRAMAHUB_PRIVATETOKEN"

local SUPPORTED_GAMES = {
    [12345678] = BASE_URL .. "/script/main?token=" .. SCRIPT_TOKEN, -- Anime Ghost
}

local gameId = game.PlaceId
local url = SUPPORTED_GAMES[gameId]

if not url then
    game.Players.LocalPlayer:Kick("[DramaHub] Game not supported. PlaceId: " .. tostring(gameId))
    return
end

local ok, err = pcall(function()
    loadstring(game:HttpGet(url))()
end)

if not ok then
    warn("[DramaHub] Fail to load: " .. tostring(err))
end
