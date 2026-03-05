-- Data Hub Loader
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
local QueueOnTeleport = queue_on_teleport

local function GetFile(File)
    return IsLocal and readfile("DataHub/" .. File)
    or game:HttpGet(("%s%s"):format(DataHub.Source, File))
end

local function LoadScript(Script)
    local code = GetFile(Script .. ".lua")
    if not code or code == "" then
        error("Failed to load file: " .. Script)
    end
    local fn, err = loadstring(code, Script)
    if not fn then
        error("Compilation error in " .. Script .. ": " .. err)
    end
    local success, result = pcall(fn)
    if not success then
        error("Runtime error in " .. Script .. ": " .. tostring(result))
    end
    return result
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
        ["1168263273"] = { Name = "Bad Business",               Script = "Games/BB.lua"   },
        ["3360073263"] = { Name = "Bad Business PTR",           Script = "Games/BB.lua"   },
        ["1586272220"] = { Name = "Steel Titans",               Script = "Games/ST.lua"   },
        ["807930589" ] = { Name = "The Wild West",              Script = "Games/TWW.lua"  },
        ["580765040" ] = { Name = "RAGDOLL UNIVERSE",           Script = "Games/RU.lua"   },
        ["187796008" ] = { Name = "Those Who Remain",           Script = "Games/TWR.lua"  },
        ["358276974" ] = { Name = "Apocalypse Rising 2",        Script = "Games/AR2.lua"  },
        ["3495983524"] = { Name = "Apocalypse Rising 2 Dev.",   Script = "Games/AR2.lua"  },
        ["1054526971"] = { Name = "Blackhawk Rescue Mission 5", Script = "Games/BRM5.lua" },
        ["1793802713"] = { Name = "Deadline",                   Script = "Games/DL.lua"   },
        ["2862098693"] = { Name = "Project Delta",              Script = "Games/Delta.lua" }
    }
}

DataHub.Utilities = LoadScript("Utilities/Main")
DataHub.Utilities.UI = LoadScript("Utilities/UI")
DataHub.Utilities.Physics = LoadScript("Utilities/Physics")
DataHub.Utilities.Drawing = LoadScript("Utilities/Drawing")

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


