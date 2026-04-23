local BASE_URL = "https://raw.githubusercontent.com/spectronal/DramaHub/refs/heads/main/Games/World%20Fighters/"

local function import(path)
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(BASE_URL .. path))()
    end)
    if not ok then
        warn("Erro ao importar", path, "->", result)
        return nil
    end
    return result
end

local Click = import("Systems/Click.lua")
print("Click:", Click)
print("type:", type(Click))

local content = game:HttpGet(BASE_URL .. "Systems/Click.lua")
print(content)

Click.Attack()