local BASE_URL     = "https://dramahub.up.railway.app"
local SCRIPT_TOKEN = "SPECTRONAL_DRAMAHUB_PRIVATETOKEN"

local SUPPORTED_GAMES = {
    [101640913672688] = BASE_URL .. "/main",
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
