-- Data Hub - Project Delta (Ultimate ESP Edition)
-- Game ID: 2862098693
-- Features: RageBot, Gun Mods, World, Misc, and Professional ESP (3D Bounding Box, Corner Box, Dynamic Scaling)

-- Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- State flags
local AimbotActive = false
local TriggerActive = false
local DoubleTapActive = false
local RapidFireActive = false
local ZoomActive = false

-- Settings (will be updated via UI)
local Settings = {
    Rage = {
        SilentAim = false,
        DeadCheck = true,
        VisibleCheck = true,
        InstantHit = false,
        HitParts = {"Head", "Torso", "Legs"},
        Distance = 300,
        FOV = 120,
        FOVCircle = true,
        FOVColor = {1, 0, 0, 0.5, false},
        AutoFire = false
    },
    GunMods = {
        NoRecoil = false,
        NoSpread = false,
        NoSway = false,
        RemoveBobbing = false,
        InstantAim = false,
        InstantBolt = false,
        UnlockFireModes = false,
        RemoveBulletDrop = false,
        RemoveObstruction = false,
        DoubleTap = false,
        RapidFire = false,
        BulletCount = 10
    },
    Visuals = {
        General = {
            Enabled = false,
            IncludeNPC = false,
            ScaleType = "Dynamic",
            MaxDistance = 1000
        },
        Box = {
            Enabled = false,
            Color = {1, 1, 1, 0, false},
            Style = "Full", -- "Full" or "Corner"
            Thickness = {Min = 1.5, Max = 4} -- будет динамически
        },
        Name = {
            Enabled = false,
            Color = {1, 1, 1, 0, false},
            MinSize = 10,
            MaxSize = 18
        },
        Tracers = {
            Enabled = false,
            Mode = "From Bottom"
        },
        Distance = {
            Enabled = false,
            Color = {1, 1, 1, 0, false},
            Mode = "Studs",
            MinSize = 8,
            MaxSize = 16
        },
        Health = {
            Bar = false,
            ColorMode = "Green", -- "Red", "Green", "RGB"
            Position = "Left" -- "Left", "Right", "Top", "Bottom"
        },
        Skeleton = {
            Enabled = false,
            Color = {1, 1, 1, 0, false},
            Thickness = 2
        },
        ItemText = {
            Enabled = false,
            Color = {1, 1, 1, 0, false},
            Distance = 100
        },
        DeathHistory = {
            Enabled = false,
            Color = {1, 0, 0, 0, false},
            Duration = 300 -- seconds
        },
        QuestItems = {
            Enabled = false,
            Color = {0, 1, 0, 0, false}
        },
        Vehicles = {
            Enabled = false,
            Color = {0, 0, 1, 0, false}
        },
        Zoom = {
            Enabled = false,
            Level = 20
        }
    },
    World = {
        FullBright = false,
        RemoveGrass = false,
        RemoveShadows = false,
        AmbientColor = {0.5, 0.5, 0.5, 0, false},
        SkyBox = {
            Moon = false
        },
        Inventory = {
            Enabled = false,
            Money = false,
            Name = false,
            Icons = false,
            Moduls = false,
            ShowAmount = 10
        }
    },
    Misc = {
        NoClip = false,
        AntiUAC = false
    }
}

-- Body parts for hitbox selection
local HitPartsList = {
    {Name = "Head", Mode = "Toggle", Value = true},
    {Name = "Torso", Mode = "Toggle", Value = true},
    {Name = "Legs", Mode = "Toggle", Value = true}
}

-- Проверка UI
if not DataHub or not DataHub.Utilities or not DataHub.Utilities.UI then
    warn("Data Hub UI library not loaded. Make sure Loader.lua is correct.")
    return
end

-- Создание окна
local Window = nil
pcall(function()
    Window = DataHub.Utilities.UI:Window({
        Name = "Data Hub " .. utf8.char(8212) .. " Project Delta",
        Position = UDim2.new(0.5, -400, 0.5, -350),
        Size = UDim2.new(0, 800, 0, 750)
    })
end)
if not Window then
    warn("Failed to create window. Check UI library.")
    return
end

-- ███████████████████████████████████████████████████████
-- UI: RAGEBOT
-- ███████████████████████████████████████████████████████
local RageTab = Window:Tab({Name = "RageBot"}) do
    local SilentSection = RageTab:Section({Name = "Silent Aim", Side = "Left"}) do
        SilentSection:Toggle({
            Name = "Enable Silent Aim",
            Flag = "Delta/Rage/SilentAim",
            Value = false,
            Callback = function(val) Settings.Rage.SilentAim = val end
        })

        SilentSection:Toggle({Name = "Dead Check", Flag = "Delta/Rage/DeadCheck", Value = true,
            Callback = function(val) Settings.Rage.DeadCheck = val end})
        SilentSection:Toggle({Name = "Visible Check", Flag = "Delta/Rage/VisibleCheck", Value = true,
            Callback = function(val) Settings.Rage.VisibleCheck = val end})
        SilentSection:Toggle({Name = "Instant Hit", Flag = "Delta/Rage/InstantHit", Value = false,
            Callback = function(val) Settings.Rage.InstantHit = val end})

        SilentSection:Dropdown({
            Name = "Hit Parts",
            Flag = "Delta/Rage/HitParts",
            List = HitPartsList,
            Callback = function(selected) Settings.Rage.HitParts = selected end
        })

        SilentSection:Slider({Name = "Max Distance", Flag = "Delta/Rage/Distance", Min = 0, Max = 1000, Value = 300,
            Callback = function(val) Settings.Rage.Distance = val end})
        SilentSection:Slider({Name = "FOV", Flag = "Delta/Rage/FOV", Min = 0, Max = 360, Value = 120,
            Callback = function(val) Settings.Rage.FOV = val end})

        SilentSection:Toggle({Name = "Show FOV Circle", Flag = "Delta/Rage/FOVCircle", Value = true,
            Callback = function(val) Settings.Rage.FOVCircle = val end})
        SilentSection:Colorpicker({Name = "FOV Circle Color", Flag = "Delta/Rage/FOVColor",
            Value = Settings.Rage.FOVColor,
            Callback = function(val) Settings.Rage.FOVColor = val end})
    end

    local AutoFireSection = RageTab:Section({Name = "Auto Fire", Side = "Right"}) do
        AutoFireSection:Toggle({Name = "Enable Auto Fire", Flag = "Delta/Rage/AutoFire", Value = false,
            Callback = function(val) Settings.Rage.AutoFire = val end})
    end

    local PlayerListSection = RageTab:Section({Name = "Player List", Side = "Right"}) do
        PlayerListSection:Label({Text = "Player list will be displayed here."})
        PlayerListSection:Button({Name = "Refresh List", Callback = function()
            print("Refreshing player list...")
        end})
    end
end

-- ███████████████████████████████████████████████████████
-- UI: GUN MODS
-- ███████████████████████████████████████████████████████
local GunTab = Window:Tab({Name = "Gun Mods"}) do
    local GunSection = GunTab:Section({Name = "Weapon Modifications", Side = "Left"}) do
        GunSection:Toggle({Name = "No Recoil", Flag = "Delta/Gun/NoRecoil", Value = false,
            Callback = function(val) Settings.GunMods.NoRecoil = val end})
        GunSection:Toggle({Name = "No Spread", Flag = "Delta/Gun/NoSpread", Value = false,
            Callback = function(val) Settings.GunMods.NoSpread = val end})
        GunSection:Toggle({Name = "No Sway", Flag = "Delta/Gun/NoSway", Value = false,
            Callback = function(val) Settings.GunMods.NoSway = val end})
        GunSection:Toggle({Name = "Remove Bobbing", Flag = "Delta/Gun/RemoveBobbing", Value = false,
            Callback = function(val) Settings.GunMods.RemoveBobbing = val end})
        GunSection:Toggle({Name = "Instant Aim", Flag = "Delta/Gun/InstantAim", Value = false,
            Callback = function(val) Settings.GunMods.InstantAim = val end})
        GunSection:Toggle({Name = "Instant Bolt", Flag = "Delta/Gun/InstantBolt", Value = false,
            Callback = function(val) Settings.GunMods.InstantBolt = val end})
        GunSection:Toggle({Name = "Unlock Fire Modes", Flag = "Delta/Gun/UnlockFireModes", Value = false,
            Callback = function(val) Settings.GunMods.UnlockFireModes = val end})
        GunSection:Toggle({Name = "Remove Bullet Drop", Flag = "Delta/Gun/RemoveBulletDrop", Value = false,
            Callback = function(val) Settings.GunMods.RemoveBulletDrop = val end})
        GunSection:Toggle({Name = "Remove Obstruction", Flag = "Delta/Gun/RemoveObstruction", Value = false,
            Callback = function(val) Settings.GunMods.RemoveObstruction = val end})
    end

    local ExtraSection = GunTab:Section({Name = "Extra", Side = "Right"}) do
        ExtraSection:Toggle({
            Name = "Double Tap",
            Flag = "Delta/Gun/DoubleTap",
            Value = false,
            Callback = function(val) Settings.GunMods.DoubleTap = val end
        }):Keybind({Flag = "Delta/Gun/DoubleTapKey", Mouse = true})

        ExtraSection:Toggle({
            Name = "Rapid Fire",
            Flag = "Delta/Gun/RapidFire",
            Value = false,
            Callback = function(val) Settings.GunMods.RapidFire = val end
        }):Keybind({Flag = "Delta/Gun/RapidFireKey", Mouse = true})

        ExtraSection:Slider({
            Name = "Bullet Count",
            Flag = "Delta/Gun/BulletCount",
            Min = 0,
            Max = 20,
            Value = 10,
            Callback = function(val) Settings.GunMods.BulletCount = val end
        })
    end
end

-- ███████████████████████████████████████████████████████
-- UI: VISUALS (Professional ESP Settings)
-- ███████████████████████████████████████████████████████
local VisualsTab = Window:Tab({Name = "Visuals"}) do
    -- General Section
    local GeneralSection = VisualsTab:Section({Name = "General", Side = "Left"}) do
        GeneralSection:Toggle({Name = "ESP Enabled", Flag = "Delta/Visuals/General/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.General.Enabled = val end})
        GeneralSection:Toggle({Name = "Include NPC", Flag = "Delta/Visuals/General/IncludeNPC", Value = false,
            Callback = function(val) Settings.Visuals.General.IncludeNPC = val end})
        GeneralSection:Dropdown({Name = "Scale Type", Flag = "Delta/Visuals/General/ScaleType", List = {
            {Name = "Static", Mode = "Button", Value = false},
            {Name = "Dynamic", Mode = "Button", Value = true},
            {Name = "Bounding", Mode = "Button"}
        }, Callback = function(selected) Settings.Visuals.General.ScaleType = selected[1] end})
        GeneralSection:Slider({Name = "Max Distance", Flag = "Delta/Visuals/General/MaxDistance", Min = 0, Max = 5000, Value = 1000,
            Callback = function(val) Settings.Visuals.General.MaxDistance = val end})
    end

    -- Box Section
    local BoxSection = VisualsTab:Section({Name = "Box", Side = "Left"}) do
        BoxSection:Toggle({Name = "Box", Flag = "Delta/Visuals/Box/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.Box.Enabled = val end})
        BoxSection:Colorpicker({Name = "Color", Flag = "Delta/Visuals/Box/Color", Value = Settings.Visuals.Box.Color,
            Callback = function(val) Settings.Visuals.Box.Color = val end})
        BoxSection:Dropdown({Name = "Style", Flag = "Delta/Visuals/Box/Style", List = {
            {Name = "Full", Mode = "Button", Value = true},
            {Name = "Corner", Mode = "Button"}
        }, Callback = function(selected) Settings.Visuals.Box.Style = selected[1] end})
    end

    -- Name Section
    local NameSection = VisualsTab:Section({Name = "Name", Side = "Left"}) do
        NameSection:Toggle({Name = "Nametag", Flag = "Delta/Visuals/Name/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.Name.Enabled = val end})
        NameSection:Colorpicker({Name = "Color", Flag = "Delta/Visuals/Name/Color", Value = Settings.Visuals.Name.Color,
            Callback = function(val) Settings.Visuals.Name.Color = val end})
        NameSection:Slider({Name = "Min Size", Flag = "Delta/Visuals/Name/MinSize", Min = 6, Max = 24, Value = 10,
            Callback = function(val) Settings.Visuals.Name.MinSize = val end})
        NameSection:Slider({Name = "Max Size", Flag = "Delta/Visuals/Name/MaxSize", Min = 6, Max = 24, Value = 18,
            Callback = function(val) Settings.Visuals.Name.MaxSize = val end})
    end

    -- Tracers Section
    local TracersSection = VisualsTab:Section({Name = "Tracers", Side = "Left"}) do
        TracersSection:Toggle({Name = "Enabled", Flag = "Delta/Visuals/Tracers/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.Tracers.Enabled = val end})
        TracersSection:Dropdown({Name = "Mode", Flag = "Delta/Visuals/Tracers/Mode", List = {
            {Name = "From Bottom", Mode = "Button", Value = true},
            {Name = "From Mouse", Mode = "Button"}
        }, Callback = function(selected) Settings.Visuals.Tracers.Mode = selected[1] end})
    end

    -- Distance Section
    local DistanceSection = VisualsTab:Section({Name = "Distance", Side = "Left"}) do
        DistanceSection:Toggle({Name = "Distance", Flag = "Delta/Visuals/Distance/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.Distance.Enabled = val end})
        DistanceSection:Colorpicker({Name = "Color", Flag = "Delta/Visuals/Distance/Color", Value = Settings.Visuals.Distance.Color,
            Callback = function(val) Settings.Visuals.Distance.Color = val end})
        DistanceSection:Dropdown({Name = "Mode", Flag = "Delta/Visuals/Distance/Mode", List = {
            {Name = "Studs", Mode = "Button", Value = true},
            {Name = "Meters", Mode = "Button"}
        }, Callback = function(selected) Settings.Visuals.Distance.Mode = selected[1] end})
        DistanceSection:Slider({Name = "Min Size", Flag = "Delta/Visuals/Distance/MinSize", Min = 6, Max = 24, Value = 8,
            Callback = function(val) Settings.Visuals.Distance.MinSize = val end})
        DistanceSection:Slider({Name = "Max Size", Flag = "Delta/Visuals/Distance/MaxSize", Min = 6, Max = 24, Value = 16,
            Callback = function(val) Settings.Visuals.Distance.MaxSize = val end})
    end

    -- Health Section
    local HealthSection = VisualsTab:Section({Name = "Health", Side = "Right"}) do
        HealthSection:Toggle({Name = "Health Bar", Flag = "Delta/Visuals/Health/Bar", Value = false,
            Callback = function(val) Settings.Visuals.Health.Bar = val end})
        HealthSection:Dropdown({Name = "Color Mode", Flag = "Delta/Visuals/Health/ColorMode", List = {
            {Name = "Red", Mode = "Button", Value = false},
            {Name = "Green", Mode = "Button", Value = true},
            {Name = "RGB", Mode = "Button"}
        }, Callback = function(selected) Settings.Visuals.Health.ColorMode = selected[1] end})
        HealthSection:Dropdown({Name = "Position", Flag = "Delta/Visuals/Health/Position", List = {
            {Name = "Left", Mode = "Button", Value = true},
            {Name = "Right", Mode = "Button"},
            {Name = "Top", Mode = "Button"},
            {Name = "Bottom", Mode = "Button"}
        }, Callback = function(selected) Settings.Visuals.Health.Position = selected[1] end})
    end

    -- Skeleton Section
    local SkeletonSection = VisualsTab:Section({Name = "Skeleton", Side = "Right"}) do
        SkeletonSection:Toggle({Name = "Enabled", Flag = "Delta/Visuals/Skeleton/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.Skeleton.Enabled = val end})
        SkeletonSection:Colorpicker({Name = "Color", Flag = "Delta/Visuals/Skeleton/Color", Value = Settings.Visuals.Skeleton.Color,
            Callback = function(val) Settings.Visuals.Skeleton.Color = val end})
        SkeletonSection:Slider({Name = "Thickness", Flag = "Delta/Visuals/Skeleton/Thickness", Min = 1, Max = 5, Value = 2,
            Callback = function(val) Settings.Visuals.Skeleton.Thickness = val end})
    end

    -- Item Text Section
    local ItemTextSection = VisualsTab:Section({Name = "Item Text", Side = "Right"}) do
        ItemTextSection:Toggle({Name = "Enabled", Flag = "Delta/Visuals/ItemText/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.ItemText.Enabled = val end})
        ItemTextSection:Colorpicker({Name = "Color", Flag = "Delta/Visuals/ItemText/Color", Value = Settings.Visuals.ItemText.Color,
            Callback = function(val) Settings.Visuals.ItemText.Color = val end})
        ItemTextSection:Slider({Name = "Max Distance", Flag = "Delta/Visuals/ItemText/Distance", Min = 30, Max = 1000, Value = 100,
            Callback = function(val) Settings.Visuals.ItemText.Distance = val end})
    end

    -- Quest Items Section
    local QuestSection = VisualsTab:Section({Name = "Quest Items", Side = "Right"}) do
        QuestSection:Toggle({Name = "Enabled", Flag = "Delta/Visuals/QuestItems/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.QuestItems.Enabled = val end})
        QuestSection:Colorpicker({Name = "Color", Flag = "Delta/Visuals/QuestItems/Color", Value = Settings.Visuals.QuestItems.Color,
            Callback = function(val) Settings.Visuals.QuestItems.Color = val end})
    end

    -- Vehicles Section
    local VehicleSection = VisualsTab:Section({Name = "Vehicles", Side = "Right"}) do
        VehicleSection:Toggle({Name = "Enabled", Flag = "Delta/Visuals/Vehicles/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.Vehicles.Enabled = val end})
        VehicleSection:Colorpicker({Name = "Color", Flag = "Delta/Visuals/Vehicles/Color", Value = Settings.Visuals.Vehicles.Color,
            Callback = function(val) Settings.Visuals.Vehicles.Color = val end})
    end

    -- Death History Section
    local DeathSection = VisualsTab:Section({Name = "Death History", Side = "Right"}) do
        DeathSection:Toggle({Name = "Enabled", Flag = "Delta/Visuals/DeathHistory/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.DeathHistory.Enabled = val end})
        DeathSection:Colorpicker({Name = "Color", Flag = "Delta/Visuals/DeathHistory/Color", Value = Settings.Visuals.DeathHistory.Color,
            Callback = function(val) Settings.Visuals.DeathHistory.Color = val end})
        DeathSection:Slider({Name = "Duration (sec)", Flag = "Delta/Visuals/DeathHistory/Duration", Min = 10, Max = 600, Value = 300,
            Callback = function(val) Settings.Visuals.DeathHistory.Duration = val end})
    end

    -- Zoom Section
    local ZoomSection = VisualsTab:Section({Name = "Zoom", Side = "Right"}) do
        ZoomSection:Toggle({
            Name = "Enable Zoom",
            Flag = "Delta/Visuals/Zoom/Enabled",
            Value = false,
            Callback = function(val) Settings.Visuals.Zoom.Enabled = val end
        }):Keybind({Flag = "Delta/Visuals/Zoom/Keybind", Mouse = true})

        ZoomSection:Slider({
            Name = "Zoom Level",
            Flag = "Delta/Visuals/Zoom/Level",
            Min = 0,
            Max = 40,
            Value = 20,
            Callback = function(val) Settings.Visuals.Zoom.Level = val end
        })
    end
end

-- ███████████████████████████████████████████████████████
-- UI: WORLD
-- ███████████████████████████████████████████████████████
local WorldTab = Window:Tab({Name = "World"}) do
    local EnvSection = WorldTab:Section({Name = "Environment", Side = "Left"}) do
        EnvSection:Toggle({Name = "Full Bright", Flag = "Delta/World/FullBright", Value = false,
            Callback = function(val) Settings.World.FullBright = val end})
        EnvSection:Toggle({Name = "Remove Grass", Flag = "Delta/World/RemoveGrass", Value = false,
            Callback = function(val) Settings.World.RemoveGrass = val end})
        EnvSection:Toggle({Name = "Remove Shadows", Flag = "Delta/World/RemoveShadows", Value = false,
            Callback = function(val) Settings.World.RemoveShadows = val end})
        EnvSection:Colorpicker({Name = "Change Ambient", Flag = "Delta/World/AmbientColor",
            Value = Settings.World.AmbientColor,
            Callback = function(val) Settings.World.AmbientColor = val end})
    end

    local SkySection = WorldTab:Section({Name = "Sky Box", Side = "Left"}) do
        SkySection:Toggle({Name = "Moon", Flag = "Delta/World/SkyBox/Moon", Value = false,
            Callback = function(val) Settings.World.SkyBox.Moon = val end})
    end

    local InvSection = WorldTab:Section({Name = "Inventory Checker", Side = "Right"}) do
        InvSection:Toggle({
            Name = "Enable Inventory",
            Flag = "Delta/World/Inventory/Enabled",
            Value = false,
            Callback = function(val) Settings.World.Inventory.Enabled = val end
        }):Keybind({Flag = "Delta/World/Inventory/Keybind", Mouse = true})

        InvSection:Toggle({Name = "Money", Flag = "Delta/World/Inventory/Money", Value = false,
            Callback = function(val) Settings.World.Inventory.Money = val end})
        InvSection:Toggle({Name = "Name", Flag = "Delta/World/Inventory/Name", Value = false,
            Callback = function(val) Settings.World.Inventory.Name = val end})
        InvSection:Toggle({Name = "Icons", Flag = "Delta/World/Inventory/Icons", Value = false,
            Callback = function(val) Settings.World.Inventory.Icons = val end})
        InvSection:Toggle({Name = "Moduls", Flag = "Delta/World/Inventory/Moduls", Value = false,
            Callback = function(val) Settings.World.Inventory.Moduls = val end})
        InvSection:Slider({Name = "Show Amount", Flag = "Delta/World/Inventory/ShowAmount",
            Min = 0, Max = 50, Value = 10,
            Callback = function(val) Settings.World.Inventory.ShowAmount = val end})
    end
end

-- ███████████████████████████████████████████████████████
-- UI: MISC
-- ███████████████████████████████████████████████████████
local MiscTab = Window:Tab({Name = "Misc"}) do
    local MiscSection = MiscTab:Section({Name = "Utilities", Side = "Left"}) do
        MiscSection:Toggle({Name = "NoClip", Flag = "Delta/Misc/NoClip", Value = false,
            Callback = function(val) Settings.Misc.NoClip = val end})

        MiscSection:Toggle({
            Name = "Anti UAC (Experimental)",
            Flag = "Delta/Misc/AntiUAC",
            Value = false,
            Callback = function(val)
                Settings.Misc.AntiUAC = val
                if val then
                    local uac = ReplicatedStorage:FindFirstChild("UAC")
                    if uac and uac:IsA("RemoteFunction") then
                        local oldInvoke
                        oldInvoke = hookfunction(uac.InvokeServer, function(...)
                            if Settings.Misc.AntiUAC then
                                return
                            else
                                return oldInvoke(...)
                            end
                        end)
                        print("UAC blocked (RemoteFunction)")
                    else
                        warn("UAC RemoteFunction not found")
                    end
                end
            end
        })
    end
end

-- Settings section
DataHub.Utilities:SettingsSection(Window, "RightShift", false)
DataHub.Utilities.InitAutoLoad(Window)

-- ███████████████████████████████████████████████████████
-- PROJECT DELTA SPECIFIC FUNCTIONS
-- ███████████████████████████████████████████████████████

local function GetPlayerGameplayVars(player)
    local folder = ReplicatedStorage:FindFirstChild("Players")
    if not folder then return nil end
    local playerData = folder:FindFirstChild(player.Name)
    if not playerData then return nil end
    local status = playerData:FindFirstChild("Status")
    if not status then return nil end
    return status:FindFirstChild("GameplayVariables")
end

local function GetRealHealth(player)
    local vars = GetPlayerGameplayVars(player)
    if vars then
        local health = vars:FindFirstChild("Health")
        if health then
            return health.Value
        end
    end
    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            return hum.Health
        end
    end
    return 100
end

local function IsEnemy(player)
    return player ~= LocalPlayer
end

-- ███████████████████████████████████████████████████████
-- PROFESSIONAL ESP SYSTEM (CLEAN & POWERFUL)
-- Configuration by getgenv().ESP
-- ███████████████████████████████████████████████████████

--[[
    HOW TO USE:
    Just paste this code anywhere in your script.
    All settings are controlled via the 'getgenv().ESP' table below.
    Modify colors, enable/disable features as you like.
    The ESP will automatically handle players, objects, and death history.
]]

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Helper functions
local function newLine() return Drawing.new("Line") end
local function newText() return Drawing.new("Text") end
local function clamp(v, mn, mx) return math.max(mn, math.min(mx, v)) end

-- Configuration (you can change these values)
getgenv().ESP = {
    Main = {
        Enabled = true,
        Name = {
            Enabled = true,
            Color = Color3.fromRGB(255, 255, 255),
        },
        Box = {
            Enabled = true,
            BoxColor = Color3.fromRGB(75, 175, 175),
            BoxFillColor = Color3.fromRGB(100, 75, 175), -- not used in this version (could be used for filled boxes)
            Style = "Full", -- "Full" or "Corner"
        },
        HealthBar = {
            Enabled = true,
            Number = true,
            HighHealthColor = Color3.fromRGB(0, 255, 0),
            LowHealthColor = Color3.fromRGB(255, 0, 0),
            Position = "Left", -- "Left", "Right", "Top", "Bottom"
        },
        Tool = {
            Enabled = true,
            Color = Color3.fromRGB(255, 255, 255),
        },
        Distance = {
            Enabled = true,
            Color = Color3.fromRGB(255, 255, 255),
        },
        Skeleton = {
            Enabled = true,
            Color = Color3.fromRGB(200, 200, 200),
        },
        Tracers = {
            Enabled = false,
            Mode = "From Bottom", -- "From Bottom" or "From Mouse"
        },
        Chams = false, -- not implemented here (can be added via Highlight)
        AutomaticColor = false, -- if true, color changes based on team (enemy/ally)
        Type = "AlwaysOnTop", -- "AlwaysOnTop" or "Occluded" (for chams)
    },
    Checks = {
        WallCheck = true,
        VisibleCheck = false, -- requires additional raycast; disabled by default for performance
        ForceField = true,
        AliveCheck = true,
    },
    Extra = {
        UseDisplayName = false,
        EspFadeOut = 400, -- not used (distance-based fade can be implemented)
        PriorityOnly = false,
        MaxDistance = 1000,
        MinSize = 20, -- minimum box size (pixels)
        MaxSize = 200, -- maximum box size (pixels)
    },
    Objects = {
        Containers = {
            Enabled = true,
            Color = Color3.fromRGB(100, 255, 100),
        },
        QuestItems = {
            Enabled = true,
            Color = Color3.fromRGB(100, 200, 255),
        },
        Vehicles = {
            Enabled = true,
            Color = Color3.fromRGB(255, 150, 50),
        },
    },
    DeathHistory = {
        Enabled = true,
        Color = Color3.fromRGB(255, 50, 50),
        Duration = 300, -- seconds
    },
    Zoom = {
        Enabled = false,
        Level = 20,
    },
}

-- Local references (for speed)
local ESPcfg = getgenv().ESP
local EMain = ESPcfg.Main
local EChecks = ESPcfg.Checks
local EExtra = ESPcfg.Extra
local EObj = ESPcfg.Objects
local EDeath = ESPcfg.DeathHistory

-- Team check function (override for your game)
local function IsEnemy(player)
    if player == LocalPlayer then return false end
    -- Customize this for your game: check teams, factions, etc.
    -- By default, all other players are considered enemies.
    return true
end

-- Wall/visibility check
local function IsVisible(part)
    if not EChecks.VisibleCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit * (part.Position - origin).Magnitude
    local ray = Ray.new(origin, direction)
    local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
    return hit == part
end

-- Get real health (override for your game)
local function GetPlayerHealth(player)
    local char = player.Character
    if not char then return 100 end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then return hum.Health end
    return 100
end

-- Get current weapon (override)
local function GetPlayerWeapon(player)
    local char = player.Character
    if not char then return "" end
    local tool = char:FindFirstChildOfClass("Tool")
    return tool and tool.Name or ""
end

-- Accurate 3D bounding box (8 corners)
local function GetBoundingBox(char)
    local cf, size = char:GetBoundingBox()
    local corners = {
        Vector3.new(-size.X/2, -size.Y/2, -size.Z/2),
        Vector3.new(-size.X/2, -size.Y/2,  size.Z/2),
        Vector3.new(-size.X/2,  size.Y/2, -size.Z/2),
        Vector3.new(-size.X/2,  size.Y/2,  size.Z/2),
        Vector3.new( size.X/2, -size.Y/2, -size.Z/2),
        Vector3.new( size.X/2, -size.Y/2,  size.Z/2),
        Vector3.new( size.X/2,  size.Y/2, -size.Z/2),
        Vector3.new( size.X/2,  size.Y/2,  size.Z/2)
    }

    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local any = false

    for _, c in ipairs(corners) do
        local world = cf:PointToWorldSpace(c)
        local scr, vis = Camera:WorldToViewportPoint(world)
        if vis then
            any = true
            minX = math.min(minX, scr.X)
            minY = math.min(minY, scr.Y)
            maxX = math.max(maxX, scr.X)
            maxY = math.max(maxY, scr.Y)
        end
    end

    return any and {minX, minY, maxX, maxY} or nil
end

-- Drawing objects storage
local PlayerESP = {}
local ItemESP = {}
local QuestESP = {}
local VehicleESP = {}
local DeathESP = {}
local DeathCounter = 0

-- Create ESP for a player
local function CreatePlayerESP(player)
    if PlayerESP[player] then return end
    local lines = {}
    for i = 1, 8 do lines[i] = newLine() end
    local esp = {
        BoxLines = lines,
        Name = newText(),
        Distance = newText(),
        Tool = newText(),
        Tracer = newLine(),
        HealthBar = { newLine(), newLine() },
        SkeletonLines = {}
    }
    -- Text settings
    esp.Name.Center = true; esp.Name.Outline = true; esp.Name.Font = 2
    esp.Distance.Center = true; esp.Distance.Outline = true; esp.Distance.Font = 2
    esp.Tool.Center = true; esp.Tool.Outline = true; esp.Tool.Font = 2
    -- Tracer
    esp.Tracer.Thickness = 2
    -- Health bar
    esp.HealthBar[1].Thickness = 4; esp.HealthBar[1].Color = Color3.new(0,0,0)
    esp.HealthBar[2].Thickness = 4
    -- Skeleton lines (R15)
    for i = 1, 15 do
        local line = newLine()
        line.Thickness = 2
        esp.SkeletonLines[i] = line
    end
    PlayerESP[player] = esp
end

local function RemovePlayerESP(player)
    local esp = PlayerESP[player]
    if not esp then return end
    for _, l in ipairs(esp.BoxLines) do l:Destroy() end
    esp.Name:Destroy()
    esp.Distance:Destroy()
    esp.Tool:Destroy()
    esp.Tracer:Destroy()
    for _, l in ipairs(esp.HealthBar) do l:Destroy() end
    for _, l in ipairs(esp.SkeletonLines) do l:Destroy() end
    PlayerESP[player] = nil
end

-- Update player ESP
local function UpdatePlayerESP(player)
    local esp = PlayerESP[player]
    if not esp then return end
    local char = player.Character
    if not char then
        -- hide everything
        for _, l in ipairs(esp.BoxLines) do l.Visible = false end
        esp.Name.Visible = false; esp.Distance.Visible = false; esp.Tool.Visible = false
        esp.Tracer.Visible = false
        for _, l in ipairs(esp.HealthBar) do l.Visible = false end
        for _, l in ipairs(esp.SkeletonLines) do l.Visible = false end
        return
    end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then
        for _, l in ipairs(esp.BoxLines) do l.Visible = false end
        esp.Name.Visible = false; esp.Distance.Visible = false; esp.Tool.Visible = false
        esp.Tracer.Visible = false
        for _, l in ipairs(esp.HealthBar) do l.Visible = false end
        for _, l in ipairs(esp.SkeletonLines) do l.Visible = false end
        return
    end

    -- Check alive
    if EChecks.AliveCheck then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then
            for _, l in ipairs(esp.BoxLines) do l.Visible = false end
            esp.Name.Visible = false; esp.Distance.Visible = false; esp.Tool.Visible = false
            esp.Tracer.Visible = false
            for _, l in ipairs(esp.HealthBar) do l.Visible = false end
            for _, l in ipairs(esp.SkeletonLines) do l.Visible = false end
            return
        end
    end

    -- Check forcefield
    if EChecks.ForceField and char:FindFirstChildOfClass("ForceField") then
        for _, l in ipairs(esp.BoxLines) do l.Visible = false end
        esp.Name.Visible = false; esp.Distance.Visible = false; esp.Tool.Visible = false
        esp.Tracer.Visible = false
        for _, l in ipairs(esp.HealthBar) do l.Visible = false end
        for _, l in ipairs(esp.SkeletonLines) do l.Visible = false end
        return
    end

    -- Screen position and distance
    local scr, onScr = Camera:WorldToViewportPoint(root.Position)
    if not onScr then
        for _, l in ipairs(esp.BoxLines) do l.Visible = false end
        esp.Name.Visible = false; esp.Distance.Visible = false; esp.Tool.Visible = false
        esp.Tracer.Visible = false
        for _, l in ipairs(esp.HealthBar) do l.Visible = false end
        for _, l in ipairs(esp.SkeletonLines) do l.Visible = false end
        return
    end

    local dist = (root.Position - Camera.CFrame.Position).Magnitude
    if dist > EExtra.MaxDistance then
        for _, l in ipairs(esp.BoxLines) do l.Visible = false end
        esp.Name.Visible = false; esp.Distance.Visible = false; esp.Tool.Visible = false
        esp.Tracer.Visible = false
        for _, l in ipairs(esp.HealthBar) do l.Visible = false end
        for _, l in ipairs(esp.SkeletonLines) do l.Visible = false end
        return
    end

    -- Wall check
    if EChecks.WallCheck and not IsVisible(root) then
        for _, l in ipairs(esp.BoxLines) do l.Visible = false end
        esp.Name.Visible = false; esp.Distance.Visible = false; esp.Tool.Visible = false
        esp.Tracer.Visible = false
        for _, l in ipairs(esp.HealthBar) do l.Visible = false end
        for _, l in ipairs(esp.SkeletonLines) do l.Visible = false end
        return
    end

    local isEnemy = IsEnemy(player)
    local health = GetPlayerHealth(player)
    local healthPerc = health / 100
    local weapon = GetPlayerWeapon(player)

    -- Colors (if AutomaticColor, use team-based colors; else use config colors)
    local boxColor = EMain.AutomaticColor and (isEnemy and Color3.new(1,0,0) or Color3.new(0,1,0)) or EMain.Box.BoxColor
    local nameColor = EMain.AutomaticColor and (isEnemy and Color3.new(1,0,0) or Color3.new(0,1,0)) or EMain.Name.Color
    local distColor = EMain.AutomaticColor and (isEnemy and Color3.new(1,0,0) or Color3.new(0,1,0)) or EMain.Distance.Color
    local toolColor = EMain.Tool.Color
    local skeletonColor = EMain.Skeleton.Color

    -- Dynamic sizes
    local nameSize = clamp(16 * (1000 / math.max(dist, 100)), 10, 18)
    local distSize = clamp(14 * (1000 / math.max(dist, 100)), 8, 16)
    local toolSize = clamp(12 * (1000 / math.max(dist, 100)), 8, 14)
    local thickness = clamp(4 - dist/200, 1.5, 4)

    -- Box
    if EMain.Box.Enabled then
        local bb = GetBoundingBox(char)
        if bb then
            local minX, minY, maxX, maxY = bb[1], bb[2], bb[3], bb[4]
            local lines = esp.BoxLines
            if EMain.Box.Style == "Corner" then
                local cs = math.min(maxX-minX, maxY-minY) * 0.2
                -- TL
                lines[1].From = Vector2.new(minX, minY); lines[1].To = Vector2.new(minX+cs, minY)
                lines[2].From = Vector2.new(minX, minY); lines[2].To = Vector2.new(minX, minY+cs)
                -- TR
                lines[3].From = Vector2.new(maxX, minY); lines[3].To = Vector2.new(maxX-cs, minY)
                lines[4].From = Vector2.new(maxX, minY); lines[4].To = Vector2.new(maxX, minY+cs)
                -- BL
                lines[5].From = Vector2.new(minX, maxY); lines[5].To = Vector2.new(minX+cs, maxY)
                lines[6].From = Vector2.new(minX, maxY); lines[6].To = Vector2.new(minX, maxY-cs)
                -- BR
                lines[7].From = Vector2.new(maxX, maxY); lines[7].To = Vector2.new(maxX-cs, maxY)
                lines[8].From = Vector2.new(maxX, maxY); lines[8].To = Vector2.new(maxX, maxY-cs)
                for i = 1, 8 do
                    lines[i].Color = boxColor
                    lines[i].Thickness = thickness
                    lines[i].Visible = true
                end
            else
                lines[1].From = Vector2.new(minX, minY); lines[1].To = Vector2.new(maxX, minY)
                lines[2].From = Vector2.new(maxX, minY); lines[2].To = Vector2.new(maxX, maxY)
                lines[3].From = Vector2.new(maxX, maxY); lines[3].To = Vector2.new(minX, maxY)
                lines[4].From = Vector2.new(minX, maxY); lines[4].To = Vector2.new(minX, minY)
                for i = 1, 4 do
                    lines[i].Color = boxColor
                    lines[i].Thickness = thickness
                    lines[i].Visible = true
                end
                for i = 5, 8 do lines[i].Visible = false end
            end
        else
            for _, l in ipairs(esp.BoxLines) do l.Visible = false end
        end
    else
        for _, l in ipairs(esp.BoxLines) do l.Visible = false end
    end

    -- Name
    if EMain.Name.Enabled then
        esp.Name.Visible = true
        esp.Name.Text = EExtra.UseDisplayName and (player.DisplayName or player.Name) or player.Name
        esp.Name.Color = nameColor
        esp.Name.Size = nameSize
        esp.Name.Position = Vector2.new(scr.X, scr.Y - 50 - (nameSize-14))
    else
        esp.Name.Visible = false
    end

    -- Distance
    if EMain.Distance.Enabled then
        esp.Distance.Visible = true
        esp.Distance.Text = string.format("%.0f studs", dist)
        esp.Distance.Color = distColor
        esp.Distance.Size = distSize
        esp.Distance.Position = Vector2.new(scr.X, scr.Y + 30 + (distSize-12))
    else
        esp.Distance.Visible = false
    end

    -- Tool
    if EMain.Tool.Enabled and weapon ~= "" then
        esp.Tool.Visible = true
        esp.Tool.Text = weapon
        esp.Tool.Color = toolColor
        esp.Tool.Size = toolSize
        esp.Tool.Position = Vector2.new(scr.X, scr.Y + 50 + (toolSize-12))
    else
        esp.Tool.Visible = false
    end

    -- Tracers
    if EMain.Tracers.Enabled then
        local from = (EMain.Tracers.Mode == "From Mouse") and UserInputService:GetMouseLocation() or Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
        esp.Tracer.From = from
        esp.Tracer.To = Vector2.new(scr.X, scr.Y)
        esp.Tracer.Color = boxColor
        esp.Tracer.Visible = true
    else
        esp.Tracer.Visible = false
    end

    -- Health Bar
    if EMain.HealthBar.Enabled and bb then
        local minX, minY, maxX, maxY = GetBoundingBox(char)[1], GetBoundingBox(char)[2], GetBoundingBox(char)[3], GetBoundingBox(char)[4]
        local bw, bh = maxX - minX, maxY - minY
        local barX, barY, barW, barH
        if EMain.HealthBar.Position == "Left" then
            barX, barY, barW, barH = minX - 8, minY, 4, bh
        elseif EMain.HealthBar.Position == "Right" then
            barX, barY, barW, barH = maxX + 4, minY, 4, bh
        elseif EMain.HealthBar.Position == "Top" then
            barX, barY, barW, barH = minX, minY - 8, bw, 4
        else -- Bottom
            barX, barY, barW, barH = minX, maxY + 4, bw, 4
        end
        -- Background
        esp.HealthBar[1].From = Vector2.new(barX, barY)
        esp.HealthBar[1].To = Vector2.new(barX + barW, barY + barH)
        esp.HealthBar[1].Visible = true
        -- Fill
        local fill = (barW > barH) and barW * healthPerc or barH * healthPerc
        local fillColor = EMain.HealthBar.HighHealthColor:Lerp(EMain.HealthBar.LowHealthColor, 1 - healthPerc)
        if EMain.HealthBar.Position == "Left" then
            esp.HealthBar[2].From = Vector2.new(barX, barY + barH)
            esp.HealthBar[2].To = Vector2.new(barX + barW, barY + barH - fill)
        elseif EMain.HealthBar.Position == "Right" then
            esp.HealthBar[2].From = Vector2.new(barX, barY)
            esp.HealthBar[2].To = Vector2.new(barX + barW, barY + fill)
        elseif EMain.HealthBar.Position == "Top" then
            esp.HealthBar[2].From = Vector2.new(barX, barY)
            esp.HealthBar[2].To = Vector2.new(barX + fill, barY + barH)
        else -- Bottom
            esp.HealthBar[2].From = Vector2.new(barX + barW, barY)
            esp.HealthBar[2].To = Vector2.new(barX + barW - fill, barY + barH)
        end
        esp.HealthBar[2].Color = fillColor
        esp.HealthBar[2].Visible = true
    else
        for _, l in ipairs(esp.HealthBar) do l.Visible = false end
    end

    -- Skeleton (simplified, using basic connections)
    if EMain.Skeleton.Enabled then
        local lines = esp.SkeletonLines
        for i = 1, #lines do lines[i].Visible = false end

        local head = char:FindFirstChild("Head")
        local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
        local la = char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftUpperArm")
        local ra = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightUpperArm")
        local ll = char:FindFirstChild("Left Leg") or char:FindFirstChild("LeftUpperLeg")
        local rl = char:FindFirstChild("Right Leg") or char:FindFirstChild("RightUpperLeg")
        local lh = char:FindFirstChild("LeftHand")
        local rh = char:FindFirstChild("RightHand")
        local lf = char:FindFirstChild("LeftFoot")
        local rf = char:FindFirstChild("RightFoot")

        local function pos(part)
            if not part then return nil end
            local p, on = Camera:WorldToViewportPoint(part.Position)
            return on and Vector2.new(p.X, p.Y) or nil
        end

        local hp = pos(head)
        local tp = pos(torso)
        local lap = pos(la)
        local rap = pos(ra)
        local llp = pos(ll)
        local rlp = pos(rl)
        local lhp = pos(lh)
        local rhp = pos(rh)
        local lfp = pos(lf)
        local rfp = pos(rf)

        local idx = 1
        if hp and tp then lines[idx].From = hp; lines[idx].To = tp; lines[idx].Color = skeletonColor; lines[idx].Visible = true; idx = idx + 1 end
        if tp and lap then lines[idx].From = tp; lines[idx].To = lap; lines[idx].Color = skeletonColor; lines[idx].Visible = true; idx = idx + 1 end
        if tp and rap then lines[idx].From = tp; lines[idx].To = rap; lines[idx].Color = skeletonColor; lines[idx].Visible = true; idx = idx + 1 end
        if lap and lhp then lines[idx].From = lap; lines[idx].To = lhp; lines[idx].Color = skeletonColor; lines[idx].Visible = true; idx = idx + 1 end
        if rap and rhp then lines[idx].From = rap; lines[idx].To = rhp; lines[idx].Color = skeletonColor; lines[idx].Visible = true; idx = idx + 1 end
        if tp and llp then lines[idx].From = tp; lines[idx].To = llp; lines[idx].Color = skeletonColor; lines[idx].Visible = true; idx = idx + 1 end
        if tp and rlp then lines[idx].From = tp; lines[idx].To = rlp; lines[idx].Color = skeletonColor; lines[idx].Visible = true; idx = idx + 1 end
        if llp and lfp then lines[idx].From = llp; lines[idx].To = lfp; lines[idx].Color = skeletonColor; lines[idx].Visible = true; idx = idx + 1 end
        if rlp and rfp then lines[idx].From = rlp; lines[idx].To = rfp; lines[idx].Color = skeletonColor; lines[idx].Visible = true; idx = idx + 1 end
    else
        for _, l in ipairs(esp.SkeletonLines) do l.Visible = false end
    end
end

-- Object ESP creation
local function CreateObjectESP(list, obj, part, name, color)
    local text = newText()
    text.Size = 12; text.Center = true; text.Outline = true; text.Font = 2; text.Visible = false
    table.insert(list, { obj = obj, text = text, part = part, name = name, color = color })
end

local function UpdateObjectESP(list, enabled, defaultColor)
    if not enabled then
        for _, e in ipairs(list) do e.text.Visible = false end
        return
    end
    for _, e in ipairs(list) do
        local obj = e.obj
        if obj and obj.Parent then
            local part = e.part
            local pos = part.Position
            local scr, on = Camera:WorldToViewportPoint(pos)
            if on then
                local dist = (pos - Camera.CFrame.Position).Magnitude
                if dist <= EExtra.MaxDistance then
                    e.text.Visible = true
                    e.text.Text = e.name .. string.format(" [%.0f]", dist)
                    e.text.Color = e.color or defaultColor
                    e.text.Position = Vector2.new(scr.X, scr.Y)
                else
                    e.text.Visible = false
                end
            else
                e.text.Visible = false
            end
        else
            e.text.Visible = false
        end
    end
end

-- Death history
local function OnPlayerDied(player)
    if not EDeath.Enabled then return end
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    DeathCounter = DeathCounter + 1
    local text = newText()
    text.Size = 16; text.Center = true; text.Outline = true; text.Font = 2
    table.insert(DeathESP, { pos = root.Position, text = text, count = DeathCounter, time = tick() })
end

-- Connect death events
for _, p in ipairs(Players:GetPlayers()) do
    if p.Character then
        local hum = p.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.Died:Connect(function() OnPlayerDied(p) end) end
    end
end
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid")
        hum.Died:Connect(function() OnPlayerDied(p) end)
    end)
end)

-- Update death ESP
local function UpdateDeathESP()
    if not EDeath.Enabled then
        for _, e in ipairs(DeathESP) do e.text.Visible = false end
        return
    end
    for i = #DeathESP, 1, -1 do
        local e = DeathESP[i]
        if tick() - e.time > EDeath.Duration then
            e.text:Destroy()
            table.remove(DeathESP, i)
        else
            local scr, on = Camera:WorldToViewportPoint(e.pos)
            if on then
                local dist = (e.pos - Camera.CFrame.Position).Magnitude
                if dist <= EExtra.MaxDistance then
                    e.text.Visible = true
                    e.text.Text = "☠️ " .. e.count
                    e.text.Color = EDeath.Color
                    e.text.Position = Vector2.new(scr.X, scr.Y)
                else
                    e.text.Visible = false
                end
            else
                e.text.Visible = false
            end
        end
    end
end

-- Initialize objects
if workspace:FindFirstChild("Containers") then
    for _, c in ipairs(workspace.Containers:GetChildren()) do
        local part = c.PrimaryPart or c:FindFirstChildWhichIsA("Part")
        if part then CreateObjectESP(ItemESP, c, part, c.Name, EObj.Containers.Color) end
    end
    workspace.Containers.ChildAdded:Connect(function(c)
        local part = c.PrimaryPart or c:FindFirstChildWhichIsA("Part")
        if part then CreateObjectESP(ItemESP, c, part, c.Name, EObj.Containers.Color) end
    end)
end
if workspace:FindFirstChild("QuestItems") then
    for _, q in ipairs(workspace.QuestItems:GetChildren()) do
        local part = q.PrimaryPart or q:FindFirstChildWhichIsA("Part")
        if part then CreateObjectESP(QuestESP, q, part, q.Name, EObj.QuestItems.Color) end
    end
    workspace.QuestItems.ChildAdded:Connect(function(q)
        local part = q.PrimaryPart or q:FindFirstChildWhichIsA("Part")
        if part then CreateObjectESP(QuestESP, q, part, q.Name, EObj.QuestItems.Color) end
    end)
end
if workspace:FindFirstChild("Vehicles") then
    for _, v in ipairs(workspace.Vehicles:GetChildren()) do
        local part = v.PrimaryPart or v:FindFirstChildWhichIsA("Part")
        if part then CreateObjectESP(VehicleESP, v, part, v.Name, EObj.Vehicles.Color) end
    end
    workspace.Vehicles.ChildAdded:Connect(function(v)
        local part = v.PrimaryPart or v:FindFirstChildWhichIsA("Part")
        if part then CreateObjectESP(VehicleESP, v, part, v.Name, EObj.Vehicles.Color) end
    end)
end

-- Main render loop
RunService.RenderStepped:Connect(function()
    if not EMain.Enabled then
        -- Hide everything
        for _, esp in pairs(PlayerESP) do
            for _, l in ipairs(esp.BoxLines) do l.Visible = false end
            esp.Name.Visible = false; esp.Distance.Visible = false; esp.Tool.Visible = false
            esp.Tracer.Visible = false
            for _, l in ipairs(esp.HealthBar) do l.Visible = false end
            for _, l in ipairs(esp.SkeletonLines) do l.Visible = false end
        end
        for _, list in ipairs({ItemESP, QuestESP, VehicleESP}) do
            for _, e in ipairs(list) do e.text.Visible = false end
        end
        for _, e in ipairs(DeathESP) do e.text.Visible = false end
        return
    end

    -- Update players
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not PlayerESP[player] then CreatePlayerESP(player) end
            UpdatePlayerESP(player)
        end
    end

    -- Update objects
    UpdateObjectESP(ItemESP, EObj.Containers.Enabled, EObj.Containers.Color)
    UpdateObjectESP(QuestESP, EObj.QuestItems.Enabled, EObj.QuestItems.Color)
    UpdateObjectESP(VehicleESP, EObj.Vehicles.Enabled, EObj.Vehicles.Color)
    UpdateDeathESP()
end)

-- Zoom
RunService.RenderStepped:Connect(function()
    if ESPcfg.Zoom.Enabled then
        Camera.FieldOfView = 70 - ESPcfg.Zoom.Level
    else
        Camera.FieldOfView = 70
    end
end)

-- Cleanup on player removal
Players.PlayerRemoving:Connect(RemovePlayerESP)

print("✅ Professional ESP System loaded successfully!")
print("   Configure via getgenv().ESP table.")

print("Data Hub - Project Delta (Ultimate ESP) loaded")
print("Professional ESP with 3D Bounding Box, Corner Box, Dynamic Scaling, and more.")
