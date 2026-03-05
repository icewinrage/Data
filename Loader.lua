-- Data Hub Loader (утилиты по прямым ссылкам)
repeat task.wait() until game.IsLoaded
repeat task.wait() until game.GameId ~= 0

if DataHub and DataHub.Loaded then
    DataHub.Utilities.UI:Push({
        Title = "Data Hub",
        Description = "Script already running!",
        Duration = 5
    }) return
end

local PlayerService = game:GetService("Players")
repeat task.wait() until PlayerService.LocalPlayer
local LocalPlayer = PlayerService.LocalPlayer

local Branch, NotificationTime, IsLocal = ...
Branch = Branch or "main"
NotificationTime = NotificationTime or 30
IsLocal = IsLocal or false

local QueueOnTeleport = queue_on_teleport

-- Функция для загрузки по полному URL (для утилит)
local function LoadFromUrl(url, name)
    local content = game:HttpGet(url)
    if not content or content == "" then
        error("Не удалось загрузить: " .. url)
    end
    local fn, err = loadstring(content, name)
    if not fn then
        error("Ошибка компиляции " .. name .. ": " .. err)
    end
    local success, result = pcall(fn)
    if not success then
        error("Ошибка выполнения " .. name .. ": " .. tostring(result))
    end
    return result
end

-- Функция для загрузки игровых скриптов (через Source)
local function GetFile(File)
    return IsLocal and readfile("DataHub/" .. File)
    or game:HttpGet(("%s%s"):format(DataHub.Source, File))
end

local function LoadScript(Script)
    return loadstring(GetFile(Script .. ".lua"), Script)()
end

local function GetGameInfo()
    for Id, Info in pairs(DataHub.Games) do
        if tostring(game.GameId) == Id then
            return Info
        end
    end
    return DataHub.Games.Universal
end

getgenv().DataHub = {
    Source = "https://raw.githubusercontent.com/icewinrage/Data/refs/heads/main/" .. Branch .. "/",

    Games = {
        ["Universal" ] = { Name = "Universal",                  Script = "Universal"  },
        ["1168263273"] = { Name = "Bad Business",               Script = "Games/BB"   },
        ["3360073263"] = { Name = "Bad Business PTR",           Script = "Games/BB"   },
        ["1586272220"] = { Name = "Steel Titans",               Script = "Games/ST"   },
        ["807930589" ] = { Name = "The Wild West",              Script = "Games/TWW"  },
        ["580765040" ] = { Name = "RAGDOLL UNIVERSE",           Script = "Games/RU"   },
        ["187796008" ] = { Name = "Those Who Remain",           Script = "Games/TWR"  },
        ["358276974" ] = { Name = "Apocalypse Rising 2",        Script = "Games/AR2"  },
        ["3495983524"] = { Name = "Apocalypse Rising 2 Dev.",   Script = "Games/AR2"  },
        ["1054526971"] = { Name = "Blackhawk Rescue Mission 5", Script = "Games/BRM5" },
        ["1793802713"] = { Name = "Deadline",                   Script = "Games/DL"   },
        ["2862098693"] = { Name = "Project Delta",              Script = "Games/Delta" }
    }
}

-- Загружаем утилиты по прямым ссылкам (с веткой main)
local baseUrl = "https://raw.githubusercontent.com/icewinrage/Data/refs/heads/main/Utilities/"
DataHub.Utilities = LoadFromUrl(baseUrl .. "Main.lua", "Utilities/Main")
DataHub.Utilities.UI = LoadFromUrl(baseUrl .. "UI.lua", "Utilities/UI")
DataHub.Utilities.Physics = LoadFromUrl(baseUrl .. "Physics.lua", "Utilities/Physics")
DataHub.Utilities.Drawing = LoadFromUrl(baseUrl .. "Drawing.lua", "Utilities/Drawing")

DataHub.Cursor = GetFile("Utilities/ArrowCursor.png")
DataHub.Loadstring = GetFile("Utilities/Loadstring")
DataHub.Loadstring = DataHub.Loadstring:format(
    DataHub.Source, Branch, NotificationTime, tostring(IsLocal)
)

LocalPlayer.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.InProgress then
        QueueOnTeleport(DataHub.Loadstring)
    end
end)

DataHub.Game = GetGameInfo()
LoadScript(DataHub.Game.Script)
DataHub.Loaded = true

DataHub.Utilities.UI:Push({
    Title = "Data Hub",
    Description = DataHub.Game.Name .. " loaded!\n\nThis script is open sourced\nIf you have paid for this script\nOr had to go thru ads\nYou have been scammed.",
    Duration = NotificationTime
})
