local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
getgenv().Utils = {} 

local Utils = getgenv().Utils

Utils.Services = {
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    CoreGui = game:GetService("CoreGui"),
    Players = game:GetService("Players"),
    MarketplaceService = game:GetService("MarketplaceService"),
    LocalPlayer = game:GetService("Players").LocalPlayer,
    GameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
    RunService = game:GetService("RunService"),
    TweenService = game:GetService("TweenService")
}