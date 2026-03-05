--// Data Hub Ultimate Loader v2

if getgenv().DataHub and getgenv().DataHub.Loaded then
    return
end

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local BASE_URL = "https://raw.githubusercontent.com/icewinrage/Data/main/"

-- глобальный кеш (переживает телепорты)
getgenv().DATAHUB_CACHE = getgenv().DATAHUB_CACHE or {}
local CACHE = getgenv().DATAHUB_CACHE

-- безопасный http
local function httpget(url)

    if CACHE[url] then
        return CACHE[url]
    end

    local success, result = pcall(function()
        return game:HttpGet(url)
    end)

    if not success or not result then
        warn("HTTP FAILED:", url)
        return nil
    end

    CACHE[url] = result
    return result
end

-- загрузка модулей
local function loadmodule(path,name)

    local url = BASE_URL..path
    local src = httpget(url)

    if not src then
        error("Failed loading "..name)
    end

    local fn,err = loadstring(src,name)

    if not fn then
        error(err)
    end

    return fn()
end

-- DataHub
local DataHub = {
    Loaded = false,
    Utilities = {},
    Cache = CACHE,

    Games = {
        ["1168263273"] = {Name="Bad Business", Script="BB"},
        ["3360073263"] = {Name="Bad Business PTR", Script="BB"},
        ["1586272220"] = {Name="Steel Titans", Script="ST"},
        ["807930589"]  = {Name="The Wild West", Script="TWW"},
        ["580765040"]  = {Name="RAGDOLL UNIVERSE", Script="RU"},
        ["187796008"]  = {Name="Those Who Remain", Script="TWR"},
        ["358276974"]  = {Name="Apocalypse Rising 2", Script="AR2"},
        ["3495983524"] = {Name="Apocalypse Rising 2 Dev", Script="AR2"},
        ["1054526971"] = {Name="Blackhawk Rescue Mission 5", Script="BRM5"},
        ["1793802713"] = {Name="Deadline", Script="DL"},
        ["2862098693"] = {Name="Project Delta", Script="Delta"}
    }
}

getgenv().DataHub = DataHub

--// параллельная загрузка utilities

local threads = {}

local function thread(fn)
    local t = task.spawn(fn)
    table.insert(threads,t)
end

thread(function()
    DataHub.Utilities.Main = loadmodule("Utilities/Main.lua","Main")
end)

thread(function()
    DataHub.Utilities.UI = loadmodule("Utilities/UI.lua","UI")
end)

thread(function()
    DataHub.Utilities.Physics = loadmodule("Utilities/Physics.lua","Physics")
end)

thread(function()
    DataHub.Utilities.Drawing = loadmodule("Utilities/Drawing.lua","Drawing")
end)

-- курсор
thread(function()
    DataHub.Cursor = httpget(BASE_URL.."Utilities/ArrowCursor.png")
end)

-- loadstring
thread(function()
    DataHub.Loadstring = httpget(BASE_URL.."Utilities/Loadstring")
end)

task.wait()

-- teleport persistence
local queue = queue_on_teleport

if queue then

    LocalPlayer.OnTeleport:Connect(function(state)

        if state == Enum.TeleportState.InProgress then
            queue(DataHub.Loadstring)
        end

    end)

end

-- игра
local id = tostring(game.GameId)
local gameinfo = DataHub.Games[id]

if gameinfo then

    loadmodule(
        "Games/"..gameinfo.Script..".lua",
        gameinfo.Script
    )

else

    loadmodule(
        "Universal.lua",
        "Universal"
    )

end

DataHub.Loaded = true

-- уведомление
if DataHub.Utilities.UI then

    DataHub.Utilities.UI:Push({
        Title = "Data Hub",
        Description = (gameinfo and gameinfo.Name or "Universal").." loaded",
        Duration = 10
    })

end
