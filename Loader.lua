-- Data Hub Loader (финальная версия)
repeat task.wait() until game.IsLoaded
repeat task.wait() until game.GameId ~= 0

-- Проверка на повторный запуск
if DataHub and DataHub.Loaded then
    -- Если UI уже загружен, покажем уведомление
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
local QueueOnTeleport = queue_on_teleport

-- Параметры (можно не передавать)
local Branch, NotificationTime, IsLocal = ...
NotificationTime = NotificationTime or 30
IsLocal = IsLocal or false

-- Базовая ссылка (жёстко прописана)
local BASE_URL = "https://raw.githubusercontent.com/icewinrage/Data/main/"

-- Функция для загрузки и выполнения скрипта по URL
local function LoadFromUrl(url, name)
    local content = game:HttpGet(url)
    if not content or content == "" then
        error("Failed to load: " .. url)
    end
    local fn, err = loadstring(content, name)
    if not fn then
        error("Compilation error in " .. name .. ": " .. err)
    end
    local success, result = pcall(fn)
    if not success then
        error("Runtime error in " .. name .. ": " .. tostring(result))
    end
    return result
end

-- Создаём глобальную таблицу
getgenv().DataHub = {
    Utilities = {},
    Games = {
        ["1168263273"] = { Name = "Bad Business",               Script = "BB"   },
        ["3360073263"] = { Name = "Bad Business PTR",           Script = "BB"   },
        ["1586272220"] = { Name = "Steel Titans",               Script = "ST"   },
        ["807930589" ] = { Name = "The Wild West",              Script = "TWW"  },
        ["580765040" ] = { Name = "RAGDOLL UNIVERSE",           Script = "RU"   },
        ["187796008" ] = { Name = "Those Who Remain",           Script = "TWR"  },
        ["358276974" ] = { Name = "Apocalypse Rising 2",        Script = "AR2"  },
        ["3495983524"] = { Name = "Apocalypse Rising 2 Dev.",   Script = "AR2"  },
        ["1054526971"] = { Name = "Blackhawk Rescue Mission 5", Script = "BRM5" },
        ["1793802713"] = { Name = "Deadline",                   Script = "DL"   },
        ["2862098693"] = { Name = "Project Delta",              Script = "Delta" }
    },
    Loaded = false
}

-- Загружаем утилиты по прямым ссылкам
DataHub.Utilities = LoadFromUrl(BASE_URL .. "Utilities/Main.lua", "Main")
DataHub.Utilities.UI = LoadFromUrl(BASE_URL .. "Utilities/UI.lua", "UI")
DataHub.Utilities.Physics = LoadFromUrl(BASE_URL .. "Utilities/Physics.lua", "Physics")
DataHub.Utilities.Drawing = LoadFromUrl(BASE_URL .. "Utilities/Drawing.lua", "Drawing")

-- Загружаем дополнительные файлы
DataHub.Cursor = game:HttpGet(BASE_URL .. "Utilities/ArrowCursor.png")
DataHub.Loadstring = game:HttpGet(BASE_URL .. "Utilities/Loadstring")
DataHub.Loadstring = DataHub.Loadstring:format(
    BASE_URL, "main", NotificationTime, tostring(IsLocal)
)

-- Обработка телепортации
LocalPlayer.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.InProgress then
        QueueOnTeleport(DataHub.Loadstring)
    end
end)

-- Определяем игру и загружаем её скрипт
local gameId = tostring(game.GameId)
local gameInfo = DataHub.Games[gameId]
if gameInfo then
    -- Загружаем скрипт конкретной игры
    local scriptUrl = BASE_URL .. "Games/" .. gameInfo.Script .. ".lua"
    LoadFromUrl(scriptUrl, gameInfo.Script)
else
    -- Загружаем универсальный скрипт
    LoadFromUrl(BASE_URL .. "Universal.lua", "Universal")
end

DataHub.Loaded = true

-- Показываем уведомление о загрузке
DataHub.Utilities.UI:Push({
    Title = "Data Hub",
    Description = (gameInfo and gameInfo.Name or "Universal") .. " loaded!\n\nThis script is open sourced\nIf you have paid for this script\nOr had to go thru ads\nYou have been scammed.",
    Duration = NotificationTime
})
