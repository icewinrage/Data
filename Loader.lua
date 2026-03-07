-- Data Hub Loader (Full Version with ArrowCursor)
-- Author: icewinrage
-- Description: Universal loader for Data Hub scripts

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

-- Получаем сервисы
local PlayerService = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

repeat task.wait() until PlayerService.LocalPlayer
local LocalPlayer = PlayerService.LocalPlayer

-- безопасный queue_on_teleport
local QueueOnTeleport = queue_on_teleport
if not QueueOnTeleport then
    QueueOnTeleport = function() end
end

-- Параметры
local Branch, NotificationTime, IsLocal = ...
Branch = Branch or "main"
NotificationTime = NotificationTime or 30
IsLocal = IsLocal or false

-- Базовая ссылка
local BASE_URL = "https://raw.githubusercontent.com/icewinrage/Data/" .. Branch .. "/"

-- Функция для безопасного получения файла
local function GetFile(path)
    if IsLocal then
        -- Локальное чтение (для тестирования)
        return readfile("DataHub/" .. path)
    else
        -- Загрузка с GitHub
        local url = BASE_URL .. path
        local success, result = pcall(function()
            return game:HttpGet(url)
        end)
        if not success or not result or result == "" then
            error("Failed to load: " .. url)
        end
        return result
    end
end

-- Функция загрузки и выполнения скрипта
local function LoadScript(path, name)
    local content = GetFile(path)
    if not content or content == "" then
        error("Failed to load script: " .. path)
    end
    
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

-- Функция для загрузки бинарных файлов (изображения)
local function GetBinaryFile(path)
    if IsLocal then
        return readfile("DataHub/" .. path)
    else
        local url = BASE_URL .. path
        return game:HttpGet(url)
    end
end

-- Создаём глобальную таблицу
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
    Loaded = false,
    Source = BASE_URL,
    Branch = Branch,
    NotificationTime = NotificationTime,
    IsLocal = IsLocal
}

local DataHub = getgenv().DataHub

-- Загружаем утилиты (с правильными путями)
print("Loading Utilities/Main.lua...")
DataHub.Utilities = LoadScript("Utilities/Main.lua", "Main")

print("Loading Utilities/UI.lua...")
DataHub.Utilities.UI = LoadScript("Utilities/UI.lua", "UI")

print("Loading Utilities/Physics.lua...")
DataHub.Utilities.Physics = LoadScript("Utilities/Physics.lua", "Physics")

print("Loading Utilities/Drawing.lua...")
DataHub.Utilities.Drawing = LoadScript("Utilities/Drawing.lua", "Drawing")

-- Загружаем курсор (изображение)
print("Loading ArrowCursor.png...")
local cursorData = GetBinaryFile("Utilities/ArrowCursor.png")
if cursorData and cursorData ~= "" then
    DataHub.Cursor = cursorData
    print("ArrowCursor loaded, size:", #cursorData)
else
    warn("Failed to load ArrowCursor.png")
    DataHub.Cursor = nil
end

-- Загружаем шаблон для телепортации
print("Loading Loadstring...")
local loadstringContent = GetFile("Utilities/Loadstring")
if loadstringContent and loadstringContent ~= "" then
    DataHub.Loadstring = loadstringContent:format(
        BASE_URL,
        Branch,
        NotificationTime,
        tostring(IsLocal)
    )
else
    warn("Failed to load Loadstring")
    DataHub.Loadstring = ""
end

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
    print("Loading game script: Games/" .. gameInfo.Script .. ".lua")
    LoadScript("Games/" .. gameInfo.Script .. ".lua", gameInfo.Script)
else
    print("Loading Universal.lua")
    LoadScript("Universal.lua", "Universal")
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

print("Data Hub Loader completed successfully!")
