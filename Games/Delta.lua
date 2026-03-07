-- Data Hub - Project Delta (Complete ESP: 3D Box, Shifter, Pro HealthBar, Nametag, Distance, Weapon, Skeleton, Dead ESP, Radar, ViewTracer)
-- Game ID: 2862098693
-- Features: RageBot, Gun Mods, World, Misc, and Ultimate ESP (all elements, dead players in gray, fixed corpse tracking)

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
            MaxDistance = 1000
        },
        Box = {
            Enabled = false,
            Color = {1, 0, 0, 0, false},  -- красный (базовый)
            Thickness = 2
        },
        Tracers = {
            Enabled = false,
            Color = {1, 0, 0, 0, false},
            Thickness = 2,
            Mode = "From Bottom"
        },
        Shifter = {
            Enabled = false,
            Color = {0, 1, 0, 0, false}   -- зелёный
        },
        Health = {
            Bar = false,
            ColorMode = "Gradient",
            Position = "Left"
        },
        Name = {
            Enabled = false,
            Color = {1, 1, 1, 0, false}   -- белый
        },
        Distance = {
            Enabled = false,
            Color = {1, 1, 1, 0, false},
            Mode = "Studs"
        },
        Weapon = {
            Enabled = false,
            Color = {1, 1, 1, 0, false}
        },
        Skeleton = {
            Enabled = false,
            Color = {1, 1, 1, 0, false},
            Thickness = 2
        },
        Radar = {
            Enabled = false,
            Position = {200, 200},
            Radius = 100,
            Scale = 1,
            RadarBack = {0.0, 1, 0.04, 0.9, false},  -- тёмно-серый
            RadarBorder = {0.67, 0, 0.3, 0.75, false}, -- серый
            LocalPlayerDot = {0, 0, 1, 1, false}, -- белый
            PlayerDot = {0.6, 1, 1, 1, false}, -- голубой
            HealthColor = true,
            TeamCheck = true
        },
        ViewTracer = {
            Enabled = false,
            Color = {0.1, 1, 1, 1, false}, -- оранжевый
            Thickness = 1,
            AutoThickness = true,
            Length = 15,
            Smoothness = 0.2
        },
        AutoThickness = true,
        TeamCheck = true,
        DeadPlayers = false,
        DeadColor = {0.5, 0.5, 0.5, 0, false}, -- серый
        ItemText = { Enabled = false, Color = {0.1, 1, 1, 0, false}, Distance = 100 }, -- оранжевый
        QuestItems = { Enabled = false, Color = {0,1,0,0,false}, Distance = 100 },
        Vehicles = { Enabled = false, Color = {0,0,1,0,false}, Distance = 100 },
        DeathHistory = { Enabled = false, Color = {1,0,0,0,false}, Duration = 300 },
        Zoom = { Enabled = false, Level = 20 }
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
-- UI: VISUALS (полные настройки)
-- ███████████████████████████████████████████████████████
local VisualsTab = Window:Tab({Name = "Visuals"}) do
    -- General Section
    local GeneralSection = VisualsTab:Section({Name = "General", Side = "Left"}) do
        GeneralSection:Toggle({Name = "ESP Enabled", Flag = "Delta/Visuals/General/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.General.Enabled = val end})
        GeneralSection:Toggle({Name = "Include NPC", Flag = "Delta/Visuals/General/IncludeNPC", Value = false,
            Callback = function(val) Settings.Visuals.General.IncludeNPC = val end})
        GeneralSection:Slider({Name = "Max Distance", Flag = "Delta/Visuals/General/MaxDistance", Min = 0, Max = 5000, Value = 1000,
            Callback = function(val) Settings.Visuals.General.MaxDistance = val end})
        GeneralSection:Toggle({Name = "Auto Thickness", Flag = "Delta/Visuals/AutoThickness", Value = true,
            Callback = function(val) Settings.Visuals.AutoThickness = val end})
        GeneralSection:Toggle({Name = "Team Check", Flag = "Delta/Visuals/TeamCheck", Value = true,
            Callback = function(val) Settings.Visuals.TeamCheck = val end})
        GeneralSection:Toggle({Name = "Show Dead Players", Flag = "Delta/Visuals/DeadPlayers", Value = false,
            Callback = function(val) Settings.Visuals.DeadPlayers = val end})
        GeneralSection:Colorpicker({Name = "Dead Color", Flag = "Delta/Visuals/DeadColor", Value = Settings.Visuals.DeadColor,
            Callback = function(hsv, color) Settings.Visuals.DeadColor = hsv end})
    end

    -- Box Section
    local BoxSection = VisualsTab:Section({Name = "Box", Side = "Left"}) do
        BoxSection:Toggle({Name = "Enable Box", Flag = "Delta/Visuals/Box/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.Box.Enabled = val end})
        BoxSection:Colorpicker({Name = "Box Color", Flag = "Delta/Visuals/Box/Color", Value = Settings.Visuals.Box.Color,
            Callback = function(hsv, color) Settings.Visuals.Box.Color = hsv end})
        BoxSection:Slider({Name = "Box Thickness", Flag = "Delta/Visuals/Box/Thickness", Min = 1, Max = 10, Value = 2,
            Callback = function(val) Settings.Visuals.Box.Thickness = val end})
    end

    -- Tracers Section
    local TracersSection = VisualsTab:Section({Name = "Tracers", Side = "Left"}) do
        TracersSection:Toggle({Name = "Enable Tracers", Flag = "Delta/Visuals/Tracers/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.Tracers.Enabled = val end})
        TracersSection:Colorpicker({Name = "Tracer Color", Flag = "Delta/Visuals/Tracers/Color", Value = Settings.Visuals.Tracers.Color,
            Callback = function(hsv, color) Settings.Visuals.Tracers.Color = hsv end})
        TracersSection:Slider({Name = "Tracer Thickness", Flag = "Delta/Visuals/Tracers/Thickness", Min = 1, Max = 10, Value = 2,
            Callback = function(val) Settings.Visuals.Tracers.Thickness = val end})
        TracersSection:Dropdown({Name = "Mode", Flag = "Delta/Visuals/Tracers/Mode", List = {
            {Name = "From Bottom", Mode = "Button", Value = true},
            {Name = "From Mouse", Mode = "Button"}
        }, Callback = function(selected) Settings.Visuals.Tracers.Mode = selected[1] end})
    end

    -- Shifter Section
    local ShifterSection = VisualsTab:Section({Name = "Shifter", Side = "Left"}) do
        ShifterSection:Toggle({Name = "Enable Shifter", Flag = "Delta/Visuals/Shifter/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.Shifter.Enabled = val end})
        ShifterSection:Colorpicker({Name = "Shifter Color", Flag = "Delta/Visuals/Shifter/Color", Value = Settings.Visuals.Shifter.Color,
            Callback = function(hsv, color) Settings.Visuals.Shifter.Color = hsv end})
    end

    -- Health Bar Section
    local HealthSection = VisualsTab:Section({Name = "Health Bar", Side = "Right"}) do
        HealthSection:Toggle({Name = "Enable Health Bar", Flag = "Delta/Visuals/Health/Bar", Value = false,
            Callback = function(val) Settings.Visuals.Health.Bar = val end})
        HealthSection:Dropdown({Name = "Color Mode", Flag = "Delta/Visuals/Health/ColorMode", List = {
            {Name = "Gradient", Mode = "Button", Value = true},
            {Name = "Red", Mode = "Button"},
            {Name = "Green", Mode = "Button"}
        }, Callback = function(selected) Settings.Visuals.Health.ColorMode = selected[1] end})
    end

    -- Name Section
    local NameSection = VisualsTab:Section({Name = "Name", Side = "Right"}) do
        NameSection:Toggle({Name = "Enable Name", Flag = "Delta/Visuals/Name/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.Name.Enabled = val end})
        NameSection:Colorpicker({Name = "Name Color", Flag = "Delta/Visuals/Name/Color", Value = Settings.Visuals.Name.Color,
            Callback = function(hsv, color) Settings.Visuals.Name.Color = hsv end})
    end

    -- Distance Section
    local DistanceSection = VisualsTab:Section({Name = "Distance", Side = "Right"}) do
        DistanceSection:Toggle({Name = "Enable Distance", Flag = "Delta/Visuals/Distance/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.Distance.Enabled = val end})
        DistanceSection:Colorpicker({Name = "Distance Color", Flag = "Delta/Visuals/Distance/Color", Value = Settings.Visuals.Distance.Color,
            Callback = function(hsv, color) Settings.Visuals.Distance.Color = hsv end})
        DistanceSection:Dropdown({Name = "Mode", Flag = "Delta/Visuals/Distance/Mode", List = {
            {Name = "Studs", Mode = "Button", Value = true},
            {Name = "Meters", Mode = "Button"}
        }, Callback = function(selected) Settings.Visuals.Distance.Mode = selected[1] end})
    end

    -- Weapon Section
    local WeaponSection = VisualsTab:Section({Name = "Weapon", Side = "Right"}) do
        WeaponSection:Toggle({Name = "Enable Weapon", Flag = "Delta/Visuals/Weapon/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.Weapon.Enabled = val end})
        WeaponSection:Colorpicker({Name = "Weapon Color", Flag = "Delta/Visuals/Weapon/Color", Value = Settings.Visuals.Weapon.Color,
            Callback = function(hsv, color) Settings.Visuals.Weapon.Color = hsv end})
    end

    -- Skeleton Section
    local SkeletonSection = VisualsTab:Section({Name = "Skeleton", Side = "Right"}) do
        SkeletonSection:Toggle({Name = "Enable Skeleton", Flag = "Delta/Visuals/Skeleton/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.Skeleton.Enabled = val end})
        SkeletonSection:Colorpicker({Name = "Skeleton Color", Flag = "Delta/Visuals/Skeleton/Color", Value = Settings.Visuals.Skeleton.Color,
            Callback = function(hsv, color) Settings.Visuals.Skeleton.Color = hsv end})
        SkeletonSection:Slider({Name = "Thickness", Flag = "Delta/Visuals/Skeleton/Thickness", Min = 1, Max = 5, Value = 2,
            Callback = function(val) Settings.Visuals.Skeleton.Thickness = val end})
    end

    -- Radar Section
    local RadarSection = VisualsTab:Section({Name = "Player Radar", Side = "Left"}) do
        RadarSection:Toggle({Name = "Enable Radar", Flag = "Delta/Visuals/Radar/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.Radar.Enabled = val end})
        RadarSection:Slider({Name = "Radius", Flag = "Delta/Visuals/Radar/Radius", Min = 50, Max = 300, Value = 100,
            Callback = function(val) Settings.Visuals.Radar.Radius = val end})
        RadarSection:Slider({Name = "Scale", Flag = "Delta/Visuals/Radar/Scale", Min = 0.1, Max = 3, Precise = 2, Value = 1,
            Callback = function(val) Settings.Visuals.Radar.Scale = val end})
        RadarSection:Colorpicker({Name = "Radar Background", Flag = "Delta/Visuals/Radar/RadarBack", Value = Settings.Visuals.Radar.RadarBack,
            Callback = function(hsv, color) Settings.Visuals.Radar.RadarBack = hsv end})
        RadarSection:Colorpicker({Name = "Radar Border", Flag = "Delta/Visuals/Radar/RadarBorder", Value = Settings.Visuals.Radar.RadarBorder,
            Callback = function(hsv, color) Settings.Visuals.Radar.RadarBorder = hsv end})
        RadarSection:Colorpicker({Name = "Local Player Dot", Flag = "Delta/Visuals/Radar/LocalPlayerDot", Value = Settings.Visuals.Radar.LocalPlayerDot,
            Callback = function(hsv, color) Settings.Visuals.Radar.LocalPlayerDot = hsv end})
        RadarSection:Colorpicker({Name = "Player Dot", Flag = "Delta/Visuals/Radar/PlayerDot", Value = Settings.Visuals.Radar.PlayerDot,
            Callback = function(hsv, color) Settings.Visuals.Radar.PlayerDot = hsv end})
        RadarSection:Toggle({Name = "Health Color", Flag = "Delta/Visuals/Radar/HealthColor", Value = true,
            Callback = function(val) Settings.Visuals.Radar.HealthColor = val end})
        RadarSection:Toggle({Name = "Team Check", Flag = "Delta/Visuals/Radar/TeamCheck", Value = true,
            Callback = function(val) Settings.Visuals.Radar.TeamCheck = val end})
    end

    -- View Tracer Section
    local ViewTracerSection = VisualsTab:Section({Name = "View Tracer", Side = "Right"}) do
        ViewTracerSection:Toggle({Name = "Enable View Tracer", Flag = "Delta/Visuals/ViewTracer/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.ViewTracer.Enabled = val end})
        ViewTracerSection:Colorpicker({Name = "Color", Flag = "Delta/Visuals/ViewTracer/Color", Value = Settings.Visuals.ViewTracer.Color,
            Callback = function(hsv, color) Settings.Visuals.ViewTracer.Color = hsv end})
        ViewTracerSection:Slider({Name = "Thickness", Flag = "Delta/Visuals/ViewTracer/Thickness", Min = 1, Max = 5, Value = 1,
            Callback = function(val) Settings.Visuals.ViewTracer.Thickness = val end})
        ViewTracerSection:Toggle({Name = "Auto Thickness", Flag = "Delta/Visuals/ViewTracer/AutoThickness", Value = true,
            Callback = function(val) Settings.Visuals.ViewTracer.AutoThickness = val end})
        ViewTracerSection:Slider({Name = "Length", Flag = "Delta/Visuals/ViewTracer/Length", Min = 5, Max = 50, Value = 15,
            Callback = function(val) Settings.Visuals.ViewTracer.Length = val end})
        ViewTracerSection:Slider({Name = "Smoothness", Flag = "Delta/Visuals/ViewTracer/Smoothness", Min = 0.01, Max = 1, Precise = 2, Value = 0.2,
            Callback = function(val) Settings.Visuals.ViewTracer.Smoothness = val end})
    end

    -- Object ESP Sections
    local ItemTextSection = VisualsTab:Section({Name = "Item Text", Side = "Right"}) do
        ItemTextSection:Toggle({Name = "Enabled", Flag = "Delta/Visuals/ItemText/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.ItemText.Enabled = val end})
        ItemTextSection:Colorpicker({Name = "Color", Flag = "Delta/Visuals/ItemText/Color", Value = Settings.Visuals.ItemText.Color,
            Callback = function(hsv, color) Settings.Visuals.ItemText.Color = hsv end})
        ItemTextSection:Slider({Name = "Max Distance", Flag = "Delta/Visuals/ItemText/Distance", Min = 30, Max = 1000, Value = 100,
            Callback = function(val) Settings.Visuals.ItemText.Distance = val end})
    end

    local QuestSection = VisualsTab:Section({Name = "Quest Items", Side = "Right"}) do
        QuestSection:Toggle({Name = "Enabled", Flag = "Delta/Visuals/QuestItems/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.QuestItems.Enabled = val end})
        QuestSection:Colorpicker({Name = "Color", Flag = "Delta/Visuals/QuestItems/Color", Value = Settings.Visuals.QuestItems.Color,
            Callback = function(hsv, color) Settings.Visuals.QuestItems.Color = hsv end})
        QuestSection:Slider({Name = "Max Distance", Flag = "Delta/Visuals/QuestItems/Distance", Min = 30, Max = 1000, Value = 100,
            Callback = function(val) Settings.Visuals.QuestItems.Distance = val end})
    end

    local VehicleSection = VisualsTab:Section({Name = "Vehicles", Side = "Right"}) do
        VehicleSection:Toggle({Name = "Enabled", Flag = "Delta/Visuals/Vehicles/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.Vehicles.Enabled = val end})
        VehicleSection:Colorpicker({Name = "Color", Flag = "Delta/Visuals/Vehicles/Color", Value = Settings.Visuals.Vehicles.Color,
            Callback = function(hsv, color) Settings.Visuals.Vehicles.Color = hsv end})
        VehicleSection:Slider({Name = "Max Distance", Flag = "Delta/Visuals/Vehicles/Distance", Min = 30, Max = 1000, Value = 100,
            Callback = function(val) Settings.Visuals.Vehicles.Distance = val end})
    end

    local DeathSection = VisualsTab:Section({Name = "Death History", Side = "Right"}) do
        DeathSection:Toggle({Name = "Enabled", Flag = "Delta/Visuals/DeathHistory/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.DeathHistory.Enabled = val end})
        DeathSection:Colorpicker({Name = "Color", Flag = "Delta/Visuals/DeathHistory/Color", Value = Settings.Visuals.DeathHistory.Color,
            Callback = function(hsv, color) Settings.Visuals.DeathHistory.Color = hsv end})
        DeathSection:Slider({Name = "Duration (sec)", Flag = "Delta/Visuals/DeathHistory/Duration", Min = 10, Max = 600, Value = 300,
            Callback = function(val) Settings.Visuals.DeathHistory.Duration = val end})
    end

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
-- PROJECT DELTA SPECIFIC FUNCTIONS (Health, Weapon, Team)
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

local function GetCurrentWeapon(player)
    local vars = GetPlayerGameplayVars(player)
    if vars then
        local tool = vars:FindFirstChild("CurrentTool")
        if tool then
            return tool.Value
        end
    end
    local char = player.Character
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            return tool.Name
        end
    end
    return "None"
end

local function IsEnemy(player)
    return player ~= LocalPlayer
end

-- ███████████████████████████████████████████████████████
-- ULTIMATE ESP SYSTEM (Full Feature)
-- ███████████████████████████████████████████████████████

-- Helper: create a line
local function NewLine()
    local line = Drawing.new("Line")
    line.Visible = false
    line.From = Vector2.new(0, 0)
    line.To = Vector2.new(1, 1)
    line.Color = Color3.fromHSV(1,0,0)
    line.Thickness = 2
    line.Transparency = 1
    return line
end

-- Helper: create a quad
local function NewQuad()
    local quad = Drawing.new("Quad")
    quad.Visible = false
    quad.PointA = Vector2.new(0,0)
    quad.PointB = Vector2.new(0,0)
    quad.PointC = Vector2.new(0,0)
    quad.PointD = Vector2.new(0,0)
    quad.Color = Color3.fromHSV(1,0,0)
    quad.Filled = false
    quad.Thickness = 2
    quad.Transparency = 1
    return quad
end

-- Helper: create a text
local function NewText()
    local text = Drawing.new("Text")
    text.Size = 14
    text.Center = true
    text.Outline = true
    text.Font = 2
    text.Visible = false
    return text
end

-- Helper: create a circle
local function NewCircle(Transparency, Color, Radius, Filled, Thickness)
    local c = Drawing.new("Circle")
    c.Transparency = Transparency
    c.Color = Color
    c.Visible = false
    c.Thickness = Thickness
    c.Position = Vector2.new(0, 0)
    c.Radius = Radius
    c.NumSides = math.clamp(Radius*55/100, 10, 75)
    c.Filled = Filled
    return c
end

-- Helper: create a triangle
local function NewTriangle()
    local t = Drawing.new("Triangle")
    t.Visible = false
    t.Thickness = 1
    t.Filled = true
    t.Color = Color3.fromHSV(1,1,1)
    return t
end

-- Helper: convert HSV table to Color3
local function HSVToColor(hsv)
    return Color3.fromHSV(hsv[1] or 0, hsv[2] or 1, hsv[3] or 1)
end

-- Данные для каждого игрока
local PlayerESPData = {}
local RadarData = {}
local ViewTracerData = {}

-- Функция для поиска трупа игрока
local function FindCorpse(player)
    local corpse = Workspace:FindFirstChild(player.Name)
    if corpse and corpse:IsA("Model") then
        return corpse
    end
    local corpsesFolder = Workspace:FindFirstChild("Corpses")
    if corpsesFolder then
        corpse = corpsesFolder:FindFirstChild(player.Name)
        if corpse and corpse:IsA("Model") then
            return corpse
        end
    end
    return nil
end

-- ███████████████████████████████████████████████████████
-- RADAR SYSTEM (from Blissful)
-- ███████████████████████████████████████████████████████
local RadarInfo = {
    Position = Vector2.new(200, 200),
    Radius = 100,
    Scale = 1,
    RadarBack = Color3.fromRGB(10, 10, 10),
    RadarBorder = Color3.fromRGB(75, 75, 75),
    LocalPlayerDot = Color3.fromRGB(255, 255, 255),
    PlayerDot = Color3.fromRGB(60, 170, 255),
    Health_Color = true,
    Team_Check = true
}

local RadarBackground = NewCircle(0.9, RadarInfo.RadarBack, RadarInfo.Radius, true, 1)
RadarBackground.Visible = false

local RadarBorder = NewCircle(0.75, RadarInfo.RadarBorder, RadarInfo.Radius, false, 3)
RadarBorder.Visible = false

local LocalPlayerDot = NewTriangle()
LocalPlayerDot.Visible = false

local function UpdateRadar()
    if not Settings.Visuals.Radar.Enabled then
        RadarBackground.Visible = false
        RadarBorder.Visible = false
        LocalPlayerDot.Visible = false
        for _, data in pairs(RadarData) do
            if data.dot then data.dot.Visible = false end
        end
        return
    end

    RadarBackground.Visible = true
    RadarBorder.Visible = true
    LocalPlayerDot.Visible = true

    -- Update settings
    RadarInfo.Radius = Settings.Visuals.Radar.Radius
    RadarInfo.Scale = Settings.Visuals.Radar.Scale
    RadarInfo.RadarBack = HSVToColor(Settings.Visuals.Radar.RadarBack)
    RadarInfo.RadarBorder = HSVToColor(Settings.Visuals.Radar.RadarBorder)
    RadarInfo.LocalPlayerDot = HSVToColor(Settings.Visuals.Radar.LocalPlayerDot)
    RadarInfo.PlayerDot = HSVToColor(Settings.Visuals.Radar.PlayerDot)
    RadarInfo.Health_Color = Settings.Visuals.Radar.HealthColor
    RadarInfo.Team_Check = Settings.Visuals.Radar.TeamCheck

    RadarBackground.Position = RadarInfo.Position
    RadarBackground.Radius = RadarInfo.Radius
    RadarBackground.Color = RadarInfo.RadarBack

    RadarBorder.Position = RadarInfo.Position
    RadarBorder.Radius = RadarInfo.Radius
    RadarBorder.Color = RadarInfo.RadarBorder

    LocalPlayerDot.Color = RadarInfo.LocalPlayerDot
    LocalPlayerDot.PointA = RadarInfo.Position + Vector2.new(0, -6)
    LocalPlayerDot.PointB = RadarInfo.Position + Vector2.new(-3, 6)
    LocalPlayerDot.PointC = RadarInfo.Position + Vector2.new(3, 6)
end

local function GetRelative(pos)
    local char = LocalPlayer.Character
    if char and char.PrimaryPart then
        local pmpart = char.PrimaryPart
        local camerapos = Vector3.new(Camera.CFrame.Position.X, pmpart.Position.Y, Camera.CFrame.Position.Z)
        local newcf = CFrame.new(pmpart.Position, camerapos)
        local r = newcf:PointToObjectSpace(pos)
        return r.X, r.Z
    else
        return 0, 0
    end
end

local function CreateRadarDot(player)
    if RadarData[player] then return end
    local dot = NewCircle(1, RadarInfo.PlayerDot, 3, true, 1)
    RadarData[player] = { dot = dot }
end

local function UpdateRadarDot(player)
    local data = RadarData[player]
    if not data then return end
    local dot = data.dot
    if not dot then return end

    local char = player.Character
    if not char or not char.PrimaryPart then
        dot.Visible = false
        return
    end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then
        dot.Visible = false
        return
    end

    local relx, rely = GetRelative(char.PrimaryPart.Position)
    local newpos = RadarInfo.Position - Vector2.new(relx * RadarInfo.Scale, rely * RadarInfo.Scale)

    if (newpos - RadarInfo.Position).Magnitude < RadarInfo.Radius - 2 then
        dot.Radius = 3
        dot.Position = newpos
        dot.Visible = true
    else
        local dist = (RadarInfo.Position - newpos).Magnitude
        local calc = (RadarInfo.Position - newpos).Unit * (dist - RadarInfo.Radius)
        local inside = Vector2.new(newpos.X + calc.X, newpos.Y + calc.Y)
        dot.Radius = 2
        dot.Position = inside
        dot.Visible = true
    end

    if RadarInfo.Health_Color then
        local healthPercent = hum.Health / hum.MaxHealth
        dot.Color = Color3.new(1 - healthPercent, healthPercent, 0)
    elseif RadarInfo.Team_Check then
        if player.TeamColor == LocalPlayer.TeamColor then
            dot.Color = RadarInfo.LocalPlayerDot -- используем цвет локального игрока для союзников
        else
            dot.Color = RadarInfo.PlayerDot
        end
    else
        dot.Color = RadarInfo.PlayerDot
    end
end

-- ███████████████████████████████████████████████████████
-- VIEW TRACER SYSTEM (from Blissful)
-- ███████████████████████████████████████████████████████
local function CreateViewTracer(player)
    if ViewTracerData[player] then return end
    local line = Drawing.new("Line")
    line.Visible = false
    line.From = Vector2.new(0, 0)
    line.To = Vector2.new(0, 0)
    line.Color = HSVToColor(Settings.Visuals.ViewTracer.Color)
    line.Thickness = Settings.Visuals.ViewTracer.Thickness
    line.Transparency = 1
    ViewTracerData[player] = { line = line }
end

local function UpdateViewTracer(player)
    local data = ViewTracerData[player]
    if not data then return end
    local line = data.line
    if not line then return end

    if not Settings.Visuals.ViewTracer.Enabled then
        line.Visible = false
        return
    end

    local char = player.Character
    if not char then
        line.Visible = false
        return
    end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local head = char:FindFirstChild("Head")
    if not hum or hum.Health <= 0 or not head then
        line.Visible = false
        return
    end

    local headpos, onScreen = Camera:WorldToViewportPoint(head.Position)
    if not onScreen then
        line.Visible = false
        return
    end

    line.Color = HSVToColor(Settings.Visuals.ViewTracer.Color)

    if Settings.Visuals.ViewTracer.AutoThickness then
        local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and 
                         (LocalPlayer.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude) or 100
        line.Thickness = math.clamp(1/distance*100, 0.1, 3)
    else
        line.Thickness = Settings.Visuals.ViewTracer.Thickness
    end

    local offsetCFrame = CFrame.new(0, 0, -Settings.Visuals.ViewTracer.Length)
    local check = false
    line.From = Vector2.new(headpos.X, headpos.Y)

    repeat
        local dir = head.CFrame:ToWorldSpace(offsetCFrame)
        offsetCFrame = offsetCFrame * CFrame.new(0, 0, Settings.Visuals.ViewTracer.Smoothness)
        local dirpos, vis = Camera:WorldToViewportPoint(Vector3.new(dir.X, dir.Y, dir.Z))
        if vis then
            check = true
            line.To = Vector2.new(dirpos.X, dirpos.Y)
            line.Visible = true
        end
    until check == true
end

-- Основная структура ESP (игроки)
local function CreatePlayerESP(player)
    if PlayerESPData[player] then return end
    local data = {
        lines = {
            line1 = NewLine(), line2 = NewLine(), line3 = NewLine(), line4 = NewLine(),
            line5 = NewLine(), line6 = NewLine(), line7 = NewLine(), line8 = NewLine(),
            line9 = NewLine(), line10 = NewLine(), line11 = NewLine(), line12 = NewLine(),
            Tracer = NewLine()
        },
        Shifter = NewQuad(),
        HealthBarBG = NewLine(),
        HealthBarFill = NewLine(),
        Name = NewText(),
        Distance = NewText(),
        Weapon = NewText(),
        SkeletonLines = {},
        debounce = 0,
        shifteroffset = 0,
        isDead = false,
        lastPosition = nil,
        lastSize = nil,
        lastRootCFrame = nil,
        corpse = nil
    }
    data.HealthBarBG.Color = Color3.new(0,0,0)
    data.HealthBarBG.Thickness = 4
    data.HealthBarFill.Thickness = 4
    for i = 1, 15 do
        local line = NewLine()
        line.Thickness = Settings.Visuals.Skeleton.Thickness or 2
        data.SkeletonLines[i] = line
    end
    PlayerESPData[player] = data
    CreateRadarDot(player)
    CreateViewTracer(player)
end

local function RemovePlayerESP(player)
    local data = PlayerESPData[player]
    if data then
        for _, line in pairs(data.lines) do line:Destroy() end
        data.Shifter:Destroy()
        data.HealthBarBG:Destroy()
        data.HealthBarFill:Destroy()
        data.Name:Destroy()
        data.Distance:Destroy()
        data.Weapon:Destroy()
        for _, line in ipairs(data.SkeletonLines) do line:Destroy() end
        PlayerESPData[player] = nil
    end
    if RadarData[player] then
        RadarData[player].dot:Destroy()
        RadarData[player] = nil
    end
    if ViewTracerData[player] then
        ViewTracerData[player].line:Destroy()
        ViewTracerData[player] = nil
    end
end

-- Object ESP storage
local ItemESP = {}
local QuestESP = {}
local VehicleESP = {}

local function CreateObjectESP(list, obj, part, name, flag)
    local text = Drawing.new("Text")
    text.Size = 12; text.Center = true; text.Outline = true; text.Font = 2; text.Visible = false
    table.insert(list, { obj = obj, part = part, text = text, name = name, flag = flag })
end

local function UpdateObjectESP(list, flagName)
    local enabled = Settings.Visuals[flagName] and Settings.Visuals[flagName].Enabled or false
    local color = HSVToColor(Settings.Visuals[flagName] and Settings.Visuals[flagName].Color or {1,1,1,0,false})
    local maxDist = Settings.Visuals[flagName] and Settings.Visuals[flagName].Distance or Settings.Visuals.General.MaxDistance
    for _, e in ipairs(list) do
        if e.obj and e.obj.Parent and e.part and e.part.Parent then
            local pos = e.part.Position
            local scr, on = Camera:WorldToViewportPoint(pos)
            if on and enabled then
                local dist = (pos - Camera.CFrame.Position).Magnitude
                if dist <= maxDist then
                    e.text.Visible = true
                    e.text.Text = e.name .. string.format(" [%.0f]", dist)
                    e.text.Color = color
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
local DeathESP = {}
local DeathCounter = 0

local function OnPlayerDied(player)
    if not Settings.Visuals.DeathHistory.Enabled then return end
    task.wait(0.1)
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    DeathCounter = DeathCounter + 1
    local text = Drawing.new("Text")
    text.Size = 18; text.Center = true; text.Outline = true; text.Font = 2
    text.Visible = false
    table.insert(DeathESP, { pos = root.Position, text = text, count = DeathCounter, time = tick() })
end

local function UpdateDeathESP()
    if not Settings.Visuals.DeathHistory.Enabled then
        for _, e in ipairs(DeathESP) do e.text.Visible = false end
        return
    end
    local color = HSVToColor(Settings.Visuals.DeathHistory.Color)
    local maxDist = Settings.Visuals.General.MaxDistance
    local duration = Settings.Visuals.DeathHistory.Duration or 300
    for i = #DeathESP, 1, -1 do
        local e = DeathESP[i]
        if tick() - e.time > duration then
            e.text:Destroy()
            table.remove(DeathESP, i)
        else
            local scr, on = Camera:WorldToViewportPoint(e.pos)
            if on then
                local dist = (e.pos - Camera.CFrame.Position).Magnitude
                if dist <= maxDist then
                    e.text.Visible = true
                    e.text.Text = "☠️ " .. e.count
                    e.text.Color = color
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

-- Skeleton update function
local function UpdateSkeleton(data, char, color, thickness)
    local lines = data.SkeletonLines
    for i = 1, #lines do lines[i].Visible = false end

    local function getPos(part)
        if not part then return nil end
        local p, on = Camera:WorldToViewportPoint(part.Position)
        return on and Vector2.new(p.X, p.Y) or nil
    end

    local head = getPos(char:FindFirstChild("Head"))
    local torso = getPos(char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
    local la = getPos(char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftUpperArm"))
    local ra = getPos(char:FindFirstChild("Right Arm") or char:FindFirstChild("RightUpperArm"))
    local ll = getPos(char:FindFirstChild("Left Leg") or char:FindFirstChild("LeftUpperLeg"))
    local rl = getPos(char:FindFirstChild("Right Leg") or char:FindFirstChild("RightUpperLeg"))
    local lh = getPos(char:FindFirstChild("LeftHand"))
    local rh = getPos(char:FindFirstChild("RightHand"))
    local lf = getPos(char:FindFirstChild("LeftFoot"))
    local rf = getPos(char:FindFirstChild("RightFoot"))

    local idx = 1
    if head and torso then
        lines[idx].From = head; lines[idx].To = torso; lines[idx].Color = color; lines[idx].Thickness = thickness; lines[idx].Visible = true; idx = idx + 1
    end
    if torso and la then
        lines[idx].From = torso; lines[idx].To = la; lines[idx].Color = color; lines[idx].Thickness = thickness; lines[idx].Visible = true; idx = idx + 1
    end
    if torso and ra then
        lines[idx].From = torso; lines[idx].To = ra; lines[idx].Color = color; lines[idx].Thickness = thickness; lines[idx].Visible = true; idx = idx + 1
    end
    if la and lh then
        lines[idx].From = la; lines[idx].To = lh; lines[idx].Color = color; lines[idx].Thickness = thickness; lines[idx].Visible = true; idx = idx + 1
    end
    if ra and rh then
        lines[idx].From = ra; lines[idx].To = rh; lines[idx].Color = color; lines[idx].Thickness = thickness; lines[idx].Visible = true; idx = idx + 1
    end
    if torso and ll then
        lines[idx].From = torso; lines[idx].To = ll; lines[idx].Color = color; lines[idx].Thickness = thickness; lines[idx].Visible = true; idx = idx + 1
    end
    if torso and rl then
        lines[idx].From = torso; lines[idx].To = rl; lines[idx].Color = color; lines[idx].Thickness = thickness; lines[idx].Visible = true; idx = idx + 1
    end
    if ll and lf then
        lines[idx].From = ll; lines[idx].To = lf; lines[idx].Color = color; lines[idx].Thickness = thickness; lines[idx].Visible = true; idx = idx + 1
    end
    if rl and rf then
        lines[idx].From = rl; lines[idx].To = rf; lines[idx].Color = color; lines[idx].Thickness = thickness; lines[idx].Visible = true; idx = idx + 1
    end
end

-- Main render loop
RunService.RenderStepped:Connect(function()
    if not Settings.Visuals.General.Enabled then
        for _, data in pairs(PlayerESPData) do
            for _, line in pairs(data.lines) do line.Visible = false end
            data.Shifter.Visible = false
            data.HealthBarBG.Visible = false
            data.HealthBarFill.Visible = false
            data.Name.Visible = false
            data.Distance.Visible = false
            data.Weapon.Visible = false
            for _, line in ipairs(data.SkeletonLines) do line.Visible = false end
        end
        for _, list in ipairs({ItemESP, QuestESP, VehicleESP}) do
            for _, e in ipairs(list) do e.text.Visible = false end
        end
        for _, e in ipairs(DeathESP) do e.text.Visible = false end
        RadarBackground.Visible = false
        RadarBorder.Visible = false
        LocalPlayerDot.Visible = false
        for _, data in pairs(RadarData) do if data.dot then data.dot.Visible = false end end
        for _, data in pairs(ViewTracerData) do if data.line then data.line.Visible = false end end
        return
    end

    -- Обновляем радар
    UpdateRadar()

    -- Обновляем игроков
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then
            -- Пропускаем себя
            if RadarData[player] then RadarData[player].dot.Visible = false end
            if ViewTracerData[player] then ViewTracerData[player].line.Visible = false end
        else
            if not PlayerESPData[player] then CreatePlayerESP(player) end
            local data = PlayerESPData[player]
            if not data then continue end

            local char = player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local isAlive = hum and hum.Health > 0

            if isAlive then
                data.isDead = false
            else
                if not Settings.Visuals.DeadPlayers then
                    for _, line in pairs(data.lines) do line.Visible = false end
                    data.Shifter.Visible = false
                    data.HealthBarBG.Visible = false
                    data.HealthBarFill.Visible = false
                    data.Name.Visible = false
                    data.Distance.Visible = false
                    data.Weapon.Visible = false
                    for _, line in ipairs(data.SkeletonLines) do line.Visible = false end
                    if RadarData[player] then RadarData[player].dot.Visible = false end
                    if ViewTracerData[player] then ViewTracerData[player].line.Visible = false end
                    continue
                end

                local corpse = FindCorpse(player)
                if corpse then
                    char = corpse
                    data.corpse = corpse
                    data.isDead = true
                else
                    for _, line in pairs(data.lines) do line.Visible = false end
                    data.Shifter.Visible = false
                    data.HealthBarBG.Visible = false
                    data.HealthBarFill.Visible = false
                    data.Name.Visible = false
                    data.Distance.Visible = false
                    data.Weapon.Visible = false
                    for _, line in ipairs(data.SkeletonLines) do line.Visible = false end
                    if RadarData[player] then RadarData[player].dot.Visible = false end
                    if ViewTracerData[player] then ViewTracerData[player].line.Visible = false end
                    continue
                end
            end

            -- Обновляем радар для этого игрока
            UpdateRadarDot(player)

            -- Обновляем вью трейсер
            UpdateViewTracer(player)

            -- Основной ESP для игрока
            local root = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")

            if not root or not head then
                for _, line in pairs(data.lines) do line.Visible = false end
                data.Shifter.Visible = false
                data.HealthBarBG.Visible = false
                data.HealthBarFill.Visible = false
                data.Name.Visible = false
                data.Distance.Visible = false
                data.Weapon.Visible = false
                for _, line in ipairs(data.SkeletonLines) do line.Visible = false end
                continue
            end

            local dist = (root.Position - Camera.CFrame.Position).Magnitude
            if dist > Settings.Visuals.General.MaxDistance then
                for _, line in pairs(data.lines) do line.Visible = false end
                data.Shifter.Visible = false
                data.HealthBarBG.Visible = false
                data.HealthBarFill.Visible = false
                data.Name.Visible = false
                data.Distance.Visible = false
                data.Weapon.Visible = false
                for _, line in ipairs(data.SkeletonLines) do line.Visible = false end
                continue
            end

            local pos, vis = Camera:WorldToViewportPoint(root.Position)
            if not vis then
                for _, line in pairs(data.lines) do line.Visible = false end
                data.Shifter.Visible = false
                data.HealthBarBG.Visible = false
                data.HealthBarFill.Visible = false
                data.Name.Visible = false
                data.Distance.Visible = false
                data.Weapon.Visible = false
                for _, line in ipairs(data.SkeletonLines) do line.Visible = false end
                continue
            end

            -- Calculate box size based on head size
            local scale = head.Size.Y / 2
            local size = Vector3.new(2, 3, 1.5) * (scale * 2)

            -- Compute 8 corners of the box
            local corners = {}
            local offsets = {
                {-size.X, size.Y, -size.Z},
                {-size.X, size.Y,  size.Z},
                { size.X, size.Y,  size.Z},
                { size.X, size.Y, -size.Z},
                {-size.X, -size.Y, -size.Z},
                {-size.X, -size.Y,  size.Z},
                { size.X, -size.Y,  size.Z},
                { size.X, -size.Y, -size.Z}
            }
            for i, off in ipairs(offsets) do
                local worldPoint = (root.CFrame * CFrame.new(unpack(off))).p
                corners[i] = Camera:WorldToViewportPoint(worldPoint)
            end

            -- Determine colors based on alive/dead
            local mainColor, tracerColor, shifterColor, textColor, skeletonColor
            local deadHSV = Settings.Visuals.DeadColor or {0.5, 0.5, 0.5, 0, false}
            if data.isDead then
                mainColor = HSVToColor(deadHSV)
                tracerColor = mainColor
                shifterColor = mainColor
                textColor = mainColor
                skeletonColor = mainColor
            else
                mainColor = HSVToColor(Settings.Visuals.Box.Color)
                tracerColor = HSVToColor(Settings.Visuals.Tracers.Color)
                shifterColor = HSVToColor(Settings.Visuals.Shifter.Color)
                textColor = HSVToColor(Settings.Visuals.Name.Color)
                skeletonColor = HSVToColor(Settings.Visuals.Skeleton.Color)
            end

            -- Update line positions
            local lines = data.lines

            lines.line1.From = Vector2.new(corners[1].X, corners[1].Y); lines.line1.To = Vector2.new(corners[2].X, corners[2].Y)
            lines.line2.From = Vector2.new(corners[2].X, corners[2].Y); lines.line2.To = Vector2.new(corners[3].X, corners[3].Y)
            lines.line3.From = Vector2.new(corners[3].X, corners[3].Y); lines.line3.To = Vector2.new(corners[4].X, corners[4].Y)
            lines.line4.From = Vector2.new(corners[4].X, corners[4].Y); lines.line4.To = Vector2.new(corners[1].X, corners[1].Y)
            lines.line5.From = Vector2.new(corners[5].X, corners[5].Y); lines.line5.To = Vector2.new(corners[6].X, corners[6].Y)
            lines.line6.From = Vector2.new(corners[6].X, corners[6].Y); lines.line6.To = Vector2.new(corners[7].X, corners[7].Y)
            lines.line7.From = Vector2.new(corners[7].X, corners[7].Y); lines.line7.To = Vector2.new(corners[8].X, corners[8].Y)
            lines.line8.From = Vector2.new(corners[8].X, corners[8].Y); lines.line8.To = Vector2.new(corners[5].X, corners[5].Y)
            lines.line9.From = Vector2.new(corners[5].X, corners[5].Y); lines.line9.To = Vector2.new(corners[1].X, corners[1].Y)
            lines.line10.From = Vector2.new(corners[6].X, corners[6].Y); lines.line10.To = Vector2.new(corners[2].X, corners[2].Y)
            lines.line11.From = Vector2.new(corners[7].X, corners[7].Y); lines.line11.To = Vector2.new(corners[3].X, corners[3].Y)
            lines.line12.From = Vector2.new(corners[8].X, corners[8].Y); lines.line12.To = Vector2.new(corners[4].X, corners[4].Y)

            -- Tracer
            if Settings.Visuals.Tracers.Enabled then
                local tracePos = Camera:WorldToViewportPoint((root.CFrame * CFrame.new(0, -size.Y, 0)).p)
                if Settings.Visuals.Tracers.Mode == "From Mouse" then
                    lines.Tracer.From = UserInputService:GetMouseLocation()
                else
                    lines.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                end
                lines.Tracer.To = Vector2.new(tracePos.X, tracePos.Y)
            end

            -- Auto thickness
            local thickness = Settings.Visuals.Box.Thickness
            if Settings.Visuals.AutoThickness then
                local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude) or 100
                thickness = math.clamp(1/distance*100, 0.1, 4)
            end

            for _, line in pairs(lines) do
                if line ~= lines.Tracer then
                    line.Color = mainColor
                    line.Thickness = thickness
                    line.Visible = Settings.Visuals.Box.Enabled
                else
                    line.Color = tracerColor
                    line.Thickness = Settings.Visuals.Tracers.Thickness
                    line.Visible = Settings.Visuals.Tracers.Enabled
                end
            end

            -- Shifter animation (только для живых)
            if Settings.Visuals.Shifter.Enabled and not data.isDead then
                if data.debounce == 0 then
                    data.debounce = 1
                    task.spawn(function()
                        local function lerp(a, b, t) return a + (b-a)*t end
                        for i = 0, size.Y, 0.1 do
                            data.shifteroffset = lerp(data.shifteroffset, i, 0.5)
                            task.wait()
                        end
                        for i = data.shifteroffset, 0, -0.1 do
                            data.shifteroffset = lerp(data.shifteroffset, i, 0.5)
                            task.wait()
                        end
                        for i = 0, -size.Y, -0.1 do
                            data.shifteroffset = lerp(data.shifteroffset, i, 0.5)
                            task.wait()
                        end
                        for i = data.shifteroffset, 0, 0.1 do
                            data.shifteroffset = lerp(data.shifteroffset, i, 0.5)
                            task.wait()
                        end
                        data.debounce = 0
                    end)
                end

                local shifterCorners = {}
                local shifterOffsets = {
                    {-size.X, data.shifteroffset, -size.Z},
                    {-size.X, data.shifteroffset,  size.Z},
                    { size.X, data.shifteroffset,  size.Z},
                    { size.X, data.shifteroffset, -size.Z}
                }
                for i, off in ipairs(shifterOffsets) do
                    local worldPoint = (root.CFrame * CFrame.new(unpack(off))).p
                    shifterCorners[i] = Camera:WorldToViewportPoint(worldPoint)
                end

                data.Shifter.PointA = Vector2.new(shifterCorners[1].X, shifterCorners[1].Y)
                data.Shifter.PointB = Vector2.new(shifterCorners[2].X, shifterCorners[2].Y)
                data.Shifter.PointC = Vector2.new(shifterCorners[3].X, shifterCorners[3].Y)
                data.Shifter.PointD = Vector2.new(shifterCorners[4].X, shifterCorners[4].Y)
                data.Shifter.Color = shifterColor
                data.Shifter.Thickness = thickness
                data.Shifter.Visible = true
            else
                data.Shifter.Visible = false
            end

            -- Health Bar (только для живых)
            if Settings.Visuals.Health.Bar and not data.isDead then
                local minX = math.min(corners[1].X, corners[2].X, corners[3].X, corners[4].X, corners[5].X, corners[6].X, corners[7].X, corners[8].X)
                local maxY = math.max(corners[1].Y, corners[2].Y, corners[3].Y, corners[4].Y, corners[5].Y, corners[6].Y, corners[7].Y, corners[8].Y)
                local minY = math.min(corners[1].Y, corners[2].Y, corners[3].Y, corners[4].Y, corners[5].Y, corners[6].Y, corners[7].Y, corners[8].Y)

                local boxHeight = maxY - minY
                local healthPercent = hum.Health / hum.MaxHealth
                local fillHeight = boxHeight * healthPercent

                local barX = minX - 6

                data.HealthBarBG.From = Vector2.new(barX, maxY)
                data.HealthBarBG.To = Vector2.new(barX, minY)
                data.HealthBarBG.Thickness = 4
                data.HealthBarBG.Visible = true

                data.HealthBarFill.From = Vector2.new(barX, maxY)
                data.HealthBarFill.To = Vector2.new(barX, maxY - fillHeight)
                data.HealthBarFill.Thickness = 4
                data.HealthBarFill.Color = Color3.new(1 - healthPercent, healthPercent, 0)
                data.HealthBarFill.Visible = true
            else
                data.HealthBarBG.Visible = false
                data.HealthBarFill.Visible = false
            end

            -- Name
            if Settings.Visuals.Name.Enabled then
                data.Name.Visible = true
                data.Name.Text = player.Name
                data.Name.Color = textColor
                data.Name.Size = 14
                data.Name.Position = Vector2.new(pos.X, pos.Y - 50)
            else
                data.Name.Visible = false
            end

            -- Distance
            if Settings.Visuals.Distance.Enabled then
                data.Distance.Visible = true
                local unit = Settings.Visuals.Distance.Mode == "Meters" and "m" or "studs"
                data.Distance.Text = string.format("%.0f %s", dist, unit)
                data.Distance.Color = textColor
                data.Distance.Size = 12
                data.Distance.Position = Vector2.new(pos.X, pos.Y + 30)
            else
                data.Distance.Visible = false
            end

            -- Weapon (только для живых)
            if Settings.Visuals.Weapon.Enabled and not data.isDead then
                local weaponName = GetCurrentWeapon(player)
                if weaponName ~= "None" then
                    data.Weapon.Visible = true
                    data.Weapon.Text = weaponName
                    data.Weapon.Color = textColor
                    data.Weapon.Size = 12
                    data.Weapon.Position = Vector2.new(pos.X, pos.Y + 50)
                else
                    data.Weapon.Visible = false
                end
            else
                data.Weapon.Visible = false
            end

            -- Skeleton (только для живых)
            if Settings.Visuals.Skeleton.Enabled and not data.isDead then
                UpdateSkeleton(data, char, skeletonColor, Settings.Visuals.Skeleton.Thickness)
            else
                for _, line in ipairs(data.SkeletonLines) do line.Visible = false end
            end
        end
    end

    UpdateObjectESP(ItemESP, "ItemText")
    UpdateObjectESP(QuestESP, "QuestItems")
    UpdateObjectESP(VehicleESP, "Vehicles")
    UpdateDeathESP()
end)

-- Initialize objects
if Workspace:FindFirstChild("Containers") then
    for _, obj in ipairs(Workspace.Containers:GetChildren()) do
        if obj:IsA("Model") then
            local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("Part")
            if part then CreateObjectESP(ItemESP, obj, part, obj.Name, "ItemText") end
        end
    end
    Workspace.Containers.ChildAdded:Connect(function(obj)
        if obj:IsA("Model") then
            local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("Part")
            if part then CreateObjectESP(ItemESP, obj, part, obj.Name, "ItemText") end
        end
    end)
end

if Workspace:FindFirstChild("QuestItems") then
    for _, obj in ipairs(Workspace.QuestItems:GetChildren()) do
        if obj:IsA("Model") then
            local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("Part")
            if part then CreateObjectESP(QuestESP, obj, part, obj.Name, "QuestItems") end
        end
    end
    Workspace.QuestItems.ChildAdded:Connect(function(obj)
        if obj:IsA("Model") then
            local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("Part")
            if part then CreateObjectESP(QuestESP, obj, part, obj.Name, "QuestItems") end
        end
    end)
end

if Workspace:FindFirstChild("Vehicles") then
    for _, obj in ipairs(Workspace.Vehicles:GetChildren()) do
        if obj:IsA("Model") then
            local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("Part")
            if part then CreateObjectESP(VehicleESP, obj, part, obj.Name, "Vehicles") end
        end
    end
    Workspace.Vehicles.ChildAdded:Connect(function(obj)
        if obj:IsA("Model") then
            local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("Part")
            if part then CreateObjectESP(VehicleESP, obj, part, obj.Name, "Vehicles") end
        end
    end)
end

-- Connect death events (для Death History)
for _, player in ipairs(Players:GetPlayers()) do
    if player.Character then
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.Died:Connect(function() OnPlayerDied(player) end) end
    end
end
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid")
        hum.Died:Connect(function() OnPlayerDied(player) end)
    end)
end)

-- Cleanup on player removal
Players.PlayerRemoving:Connect(RemovePlayerESP)

-- Zoom
RunService.RenderStepped:Connect(function()
    if Settings.Visuals.Zoom.Enabled then
        Camera.FieldOfView = 70 - Settings.Visuals.Zoom.Level
    else
        Camera.FieldOfView = 70
    end
end)

-- Draggable radar
local inset = game:GetService("GuiService"):GetGuiInset()
local dragging = false
local offset = Vector2.new(0, 0)
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and Settings.Visuals.Radar.Enabled then
        local mousePos = Vector2.new(Mouse.X, Mouse.Y + inset.Y)
        if (mousePos - RadarInfo.Position).Magnitude < RadarInfo.Radius then
            offset = RadarInfo.Position - mousePos
            dragging = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Radar mouse position tracking
local mouseDot = NewCircle(1, Color3.fromRGB(255, 255, 255), 3, true, 1)
coroutine.wrap(function()
    while true do
        task.wait()
        if Settings.Visuals.Radar.Enabled then
            local mousePos = Vector2.new(Mouse.X, Mouse.Y + inset.Y)
            if (mousePos - RadarInfo.Position).Magnitude < RadarInfo.Radius then
                mouseDot.Position = mousePos
                mouseDot.Visible = true
            else
                mouseDot.Visible = false
            end
            if dragging then
                RadarInfo.Position = mousePos + offset
            end
        else
            mouseDot.Visible = false
        end
    end
end)()

print("Data Hub - Project Delta (Complete ESP with Radar, ViewTracer, RGB colors) loaded")
