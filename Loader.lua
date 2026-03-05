-- Data Hub Loader (fixed version)

repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.GameId ~= 0

-- Проверка на повторный запуск
if getgenv().DataHub and getgenv().DataHub.Loaded then
    if DataHub.Utilities and DataHub.Utilities.UI then
        DataHub.Utilities.UI:Push({
            Title = "Data Hub",
            Description = "Script already running!",
            Duration = 5
        })
    end
    return
end

local PlayerService = game:GetService("Players")
repeat task.wait() until PlayerService.LocalPlayer
local LocalPlayer = PlayerService.LocalPlayer

-- безопасный queue_on_teleport
local QueueOnTeleport = queue_on_teleport
if not QueueOnTeleport then
    QueueOnTeleport = function() end
end

-- Параметры
local Branch, NotificationTime, IsLocal = ...
NotificationTime = NotificationTime or 30
IsLocal = IsLocal or false

-- Базовая ссылка
local BASE_URL = "https://raw.githubusercontent.com/icewinrage/Data/main/"

-- Безопасный HttpGet
local function SafeHttpGet(url)
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)

    if not success or not result or result == "" then
        error("Failed to load: " .. url)
    end

    return result
end

-- Функция загрузки скриптов
local function LoadFromUrl(url, name)
    local content = SafeHttpGet(url)

    local fn, err = loadstring(content, name)
    if not fn then
        error("Compilation error in " .. name .. ": " .. tostring(err))
    end

    local success, result = pcall(fn)
    if not success then
        error("Runtime error in " .. name .. ": " .. tostring(result))
    end

    return result
end

-- Глобальная таблица
getgenv().DataHub = {
    Utilities = {},
    Games = {
        ["1168263273"] = { Name = "Bad Business", Script = "BB" },
        ["3360073263"] = { Name = "Bad Business PTR", Script = "BB" },
        ["1586272220"] = { Name = "Steel Titans", Script = "ST" },
        ["807930589"]  = { Name = "The Wild West", Script = "TWW" },
        ["580765040"]  = { Name = "RAGDOLL UNIVERSE", Script = "RU" },
        ["187796008"]  = { Name = "Those Who Remain", Script = "TWR" },
        ["358276974"]  = { Name = "Apocalypse Rising 2", Script = "AR2" },
        ["3495983524"] = { Name = "Apocalypse Rising 2 Dev.", Script = "AR2" },
        ["1054526971"] = { Name = "Blackhawk Rescue Mission 5", Script = "BRM5" },
        ["1793802713"] = { Name = "Deadline", Script = "DL" },
        ["2862098693"] = { Name = "Project Delta", Script = "Delta" }
    },
    Loaded = false
}

local DataHub = getgenv().DataHub

-- Загружаем утилиты
DataHub.Utilities = LoadFromUrl(BASE_URL .. "Utilities/Main.lua", "Main")
DataHub.Utilities.UI = LoadFromUrl(BASE_URL .. "Utilities/UI.lua", "UI")
DataHub.Utilities.Physics = LoadFromUrl(BASE_URL .. "Utilities/Physics.lua", "Physics")
DataHub.Utilities.Drawing = LoadFromUrl(BASE_URL .. "Utilities/Drawing.lua", "Drawing")

-- Дополнительные файлы
DataHub.Cursor = SafeHttpGet(BASE_URL .. "Utilities/ArrowCursor.png")

DataHub.Loadstring = SafeHttpGet(BASE_URL .. "Utilities/Loadstring")
DataHub.Loadstring = DataHub.Loadstring:format(
    BASE_URL,
    "main",
    NotificationTime,
    tostring(IsLocal)
)

-- Телепорт
LocalPlayer.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.InProgress then
        QueueOnTeleport(DataHub.Loadstring)
    end
end)

-- Определяем игру
local gameId = tostring(game.GameId)
local gameInfo = DataHub.Games[gameId]

if gameInfo then
    local scriptUrl = BASE_URL .. "Games/" .. gameInfo.Script .. ".lua"
    LoadFromUrl(scriptUrl, gameInfo.Script)
else
    LoadFromUrl(BASE_URL .. "Universal.lua", "Universal")
end

DataHub.Loaded = true

-- Уведомление
if DataHub.Utilities and DataHub.Utilities.UI then
    DataHub.Utilities.UI:Push({
        Title = "Data Hub",
        Description = (gameInfo and gameInfo.Name or "Universal") ..
        " loaded!\n\nThis script is open sourced\nIf you have paid for this script\nOr had to go thru ads\nYou have been scammed.",
        Duration = NotificationTime
    })
end
