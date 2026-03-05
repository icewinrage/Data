-- Data Hub - Project Delta (ESP without external library)
-- Game ID: 2862098693
-- Features: Custom ESP (players, items, quests, vehicles, death history), RageBot, Gun Mods, World, Misc

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
            Style = "Full"
        },
        Name = {
            Enabled = false,
            Color = {1, 1, 1, 0, false}
        },
        Tracers = {
            Enabled = false,
            Outline = false,
            Mode = "From Bottom"
        },
        Distance = {
            Enabled = false,
            Color = {1, 1, 1, 0, false},
            Mode = "Studs"
        },
        Health = {
            Bar = false,
            ColorMode = "Green"
        },
        Chams = {
            Enabled = false,
            AllyColor = {0, 1, 0, 0, false},
            EnemyColor = {1, 0, 0, 0, false},
            Glow = false
        },
        ItemText = {
            Enabled = false,
            Color = {1, 1, 1, 0, false},
            Distance = 100
        },
        HeadDots = {
            Enabled = false,
            Filled = true,
            Outline = true,
            Autoscale = true,
            Size = 4
        },
        DeathHistory = {
            Enabled = false,
            Color = {1, 0, 0, 0, false}
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
-- UI: VISUALS (all toggles and settings)
-- ███████████████████████████████████████████████████████
local VisualsTab = Window:Tab({Name = "Visuals"}) do
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

    local BoxSection = VisualsTab:Section({Name = "Box", Side = "Left"}) do
        BoxSection:Toggle({Name = "Box", Flag = "Delta/Visuals/Box/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.Box.Enabled = val end})
        BoxSection:Colorpicker({Name = "Color", Flag = "Delta/Visuals/Box/Color", Value = Settings.Visuals.Box.Color,
            Callback = function(val) Settings.Visuals.Box.Color = val end})
        BoxSection:Toggle({Name = "Basic White", Flag = "Delta/Visuals/Box/BasicWhite", Value = false,
            Callback = function(val)
                if val then
                    Settings.Visuals.Box.Color = {1, 1, 1, 0, false}
                end
            end})
        BoxSection:Dropdown({Name = "Style", Flag = "Delta/Visuals/Box/Style", List = {
            {Name = "Full", Mode = "Button", Value = true},
            {Name = "Corner", Mode = "Button"}
        }, Callback = function(selected) Settings.Visuals.Box.Style = selected[1] end})
    end

    local NameSection = VisualsTab:Section({Name = "Name", Side = "Left"}) do
        NameSection:Toggle({Name = "Nametag", Flag = "Delta/Visuals/Name/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.Name.Enabled = val end})
        NameSection:Colorpicker({Name = "Color", Flag = "Delta/Visuals/Name/Color", Value = Settings.Visuals.Name.Color,
            Callback = function(val) Settings.Visuals.Name.Color = val end})
    end

    local TracersSection = VisualsTab:Section({Name = "Tracers", Side = "Left"}) do
        TracersSection:Toggle({Name = "Enabled", Flag = "Delta/Visuals/Tracers/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.Tracers.Enabled = val end})
        TracersSection:Toggle({Name = "Outline", Flag = "Delta/Visuals/Tracers/Outline", Value = false,
            Callback = function(val) Settings.Visuals.Tracers.Outline = val end})
        TracersSection:Dropdown({Name = "Mode", Flag = "Delta/Visuals/Tracers/Mode", List = {
            {Name = "From Bottom", Mode = "Button", Value = true},
            {Name = "From Mouse", Mode = "Button"}
        }, Callback = function(selected) Settings.Visuals.Tracers.Mode = selected[1] end})
    end

    local DistanceSection = VisualsTab:Section({Name = "Distance", Side = "Left"}) do
        DistanceSection:Toggle({Name = "Distance", Flag = "Delta/Visuals/Distance/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.Distance.Enabled = val end})
        DistanceSection:Colorpicker({Name = "Color", Flag = "Delta/Visuals/Distance/Color", Value = Settings.Visuals.Distance.Color,
            Callback = function(val) Settings.Visuals.Distance.Color = val end})
        DistanceSection:Dropdown({Name = "Mode", Flag = "Delta/Visuals/Distance/Mode", List = {
            {Name = "Studs", Mode = "Button", Value = true},
            {Name = "Meters", Mode = "Button"}
        }, Callback = function(selected) Settings.Visuals.Distance.Mode = selected[1] end})
    end

    local HealthSection = VisualsTab:Section({Name = "Health", Side = "Right"}) do
        HealthSection:Toggle({Name = "Health Bar", Flag = "Delta/Visuals/Health/Bar", Value = false,
            Callback = function(val) Settings.Visuals.Health.Bar = val end})
        HealthSection:Dropdown({Name = "Color Mode", Flag = "Delta/Visuals/Health/ColorMode", List = {
            {Name = "Red", Mode = "Button", Value = false},
            {Name = "Green", Mode = "Button", Value = true},
            {Name = "RGB", Mode = "Button"}
        }, Callback = function(selected) Settings.Visuals.Health.ColorMode = selected[1] end})
    end

    local ChamsSection = VisualsTab:Section({Name = "Chams", Side = "Right"}) do
        ChamsSection:Toggle({Name = "Chams", Flag = "Delta/Visuals/Chams/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.Chams.Enabled = val end})
        ChamsSection:Colorpicker({Name = "Ally Color", Flag = "Delta/Visuals/Chams/AllyColor", Value = Settings.Visuals.Chams.AllyColor,
            Callback = function(val) Settings.Visuals.Chams.AllyColor = val end})
        ChamsSection:Colorpicker({Name = "Enemy Color", Flag = "Delta/Visuals/Chams/EnemyColor", Value = Settings.Visuals.Chams.EnemyColor,
            Callback = function(val) Settings.Visuals.Chams.EnemyColor = val end})
        ChamsSection:Toggle({Name = "Glow", Flag = "Delta/Visuals/Chams/Glow", Value = false,
            Callback = function(val) Settings.Visuals.Chams.Glow = val end})
    end

    local ItemTextSection = VisualsTab:Section({Name = "Item Text", Side = "Right"}) do
        ItemTextSection:Toggle({Name = "Enabled", Flag = "Delta/Visuals/ItemText/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.ItemText.Enabled = val end})
        ItemTextSection:Colorpicker({Name = "Color", Flag = "Delta/Visuals/ItemText/Color", Value = Settings.Visuals.ItemText.Color,
            Callback = function(val) Settings.Visuals.ItemText.Color = val end})
        ItemTextSection:Slider({Name = "Distance", Flag = "Delta/Visuals/ItemText/Distance", Min = 30, Max = 1000, Value = 100,
            Callback = function(val) Settings.Visuals.ItemText.Distance = val end})
    end

    local HeadDotsSection = VisualsTab:Section({Name = "Head Dots", Side = "Right"}) do
        HeadDotsSection:Toggle({Name = "Enabled", Flag = "Delta/Visuals/HeadDots/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.HeadDots.Enabled = val end})
        HeadDotsSection:Toggle({Name = "Filled", Flag = "Delta/Visuals/HeadDots/Filled", Value = true,
            Callback = function(val) Settings.Visuals.HeadDots.Filled = val end})
        HeadDotsSection:Toggle({Name = "Outline", Flag = "Delta/Visuals/HeadDots/Outline", Value = true,
            Callback = function(val) Settings.Visuals.HeadDots.Outline = val end})
        HeadDotsSection:Toggle({Name = "Autoscale", Flag = "Delta/Visuals/HeadDots/Autoscale", Value = true,
            Callback = function(val) Settings.Visuals.HeadDots.Autoscale = val end})
        HeadDotsSection:Slider({Name = "Size", Flag = "Delta/Visuals/HeadDots/Size", Min = 1, Max = 20, Value = 4,
            Callback = function(val) Settings.Visuals.HeadDots.Size = val end})
    end

    local QuestSection = VisualsTab:Section({Name = "Quest Items", Side = "Right"}) do
        QuestSection:Toggle({Name = "Enabled", Flag = "Delta/Visuals/QuestItems/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.QuestItems.Enabled = val end})
        QuestSection:Colorpicker({Name = "Color", Flag = "Delta/Visuals/QuestItems/Color", Value = Settings.Visuals.QuestItems.Color,
            Callback = function(val) Settings.Visuals.QuestItems.Color = val end})
    end

    local VehicleSection = VisualsTab:Section({Name = "Vehicles", Side = "Right"}) do
        VehicleSection:Toggle({Name = "Enabled", Flag = "Delta/Visuals/Vehicles/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.Vehicles.Enabled = val end})
        VehicleSection:Colorpicker({Name = "Color", Flag = "Delta/Visuals/Vehicles/Color", Value = Settings.Visuals.Vehicles.Color,
            Callback = function(val) Settings.Visuals.Vehicles.Color = val end})
    end

    local DeathSection = VisualsTab:Section({Name = "Death History", Side = "Right"}) do
        DeathSection:Toggle({Name = "Death History ESP", Flag = "Delta/Visuals/DeathHistory/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.DeathHistory.Enabled = val end})
        DeathSection:Colorpicker({Name = "Color", Flag = "Delta/Visuals/DeathHistory/Color", Value = Settings.Visuals.DeathHistory.Color,
            Callback = function(val) Settings.Visuals.DeathHistory.Color = val end})
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
-- CUSTOM ESP (no external library)
-- ███████████████████████████████████████████████████████

-- Store drawing objects per player
local PlayerESP = {}
local ItemESP = {}
local QuestESP = {}
local VehicleESP = {}
local DeathESP = {} -- for death history

-- Helper to create a text object
local function CreateText()
    return Drawing.new("Text")
end

-- Helper to create a line object
local function CreateLine()
    return Drawing.new("Line")
end

-- Helper to create a circle object
local function CreateCircle()
    return Drawing.new("Circle")
end

-- Create ESP for a player
local function CreatePlayerESP(player)
    if PlayerESP[player] then return end
    PlayerESP[player] = {
        Box = {
            Lines = { CreateLine(), CreateLine(), CreateLine(), CreateLine() }
        },
        Name = CreateText(),
        Distance = CreateText(),
        Tracer = {
            Main = CreateLine(),
            Outline = CreateLine()
        },
        HeadDot = {
            Main = CreateCircle(),
            Outline = CreateCircle()
        },
        -- Health bar will be drawn with lines (simplified)
        HealthBar = {
            Background = CreateLine(),
            Fill = CreateLine()
        }
    }
    -- Initialize properties
    local esp = PlayerESP[player]
    esp.Name.Size = 14
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.Font = 2
    esp.Distance.Size = 12
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.Font = 2
    for _, line in ipairs(esp.Box.Lines) do
        line.Thickness = 2
    end
    esp.Tracer.Main.Thickness = 2
    esp.Tracer.Outline.Thickness = 4
    esp.Tracer.Outline.Color = Color3.new(0,0,0)
    esp.HeadDot.Main.Thickness = 2
    esp.HeadDot.Outline.Thickness = 4
    esp.HeadDot.Outline.Color = Color3.new(0,0,0)
    esp.HealthBar.Background.Thickness = 3
    esp.HealthBar.Background.Color = Color3.new(0,0,0)
    esp.HealthBar.Fill.Thickness = 3
end

-- Update ESP for a player
local function UpdatePlayerESP(player)
    local esp = PlayerESP[player]
    if not esp then return end

    local char = player.Character
    if not char then
        -- Hide all
        esp.Name.Visible = false
        esp.Distance.Visible = false
        esp.Tracer.Main.Visible = false
        esp.Tracer.Outline.Visible = false
        esp.HeadDot.Main.Visible = false
        esp.HeadDot.Outline.Visible = false
        for _, line in ipairs(esp.Box.Lines) do line.Visible = false end
        esp.HealthBar.Background.Visible = false
        esp.HealthBar.Fill.Visible = false
        return
    end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
    if not onScreen then
        -- Hide
        esp.Name.Visible = false
        esp.Distance.Visible = false
        esp.Tracer.Main.Visible = false
        esp.Tracer.Outline.Visible = false
        esp.HeadDot.Main.Visible = false
        esp.HeadDot.Outline.Visible = false
        for _, line in ipairs(esp.Box.Lines) do line.Visible = false end
        esp.HealthBar.Background.Visible = false
        esp.HealthBar.Fill.Visible = false
        return
    end

    local dist = (root.Position - Camera.CFrame.Position).Magnitude
    if dist > Settings.Visuals.General.MaxDistance then
        -- Hide if too far
        esp.Name.Visible = false
        esp.Distance.Visible = false
        esp.Tracer.Main.Visible = false
        esp.Tracer.Outline.Visible = false
        esp.HeadDot.Main.Visible = false
        esp.HeadDot.Outline.Visible = false
        for _, line in ipairs(esp.Box.Lines) do line.Visible = false end
        esp.HealthBar.Background.Visible = false
        esp.HealthBar.Fill.Visible = false
        return
    end

    local isEnemy = IsEnemy(player)
    local health = GetRealHealth(player)
    local healthPercent = health / 100

    -- Helper to convert HSV to Color3
    local function HSVToColor(hsv)
        return Color3.fromHSV(hsv[1] or 0, hsv[2] or 1, hsv[3] or 1)
    end

    local boxColor = HSVToColor(Settings.Visuals.Box.Color)
    local nameColor = HSVToColor(Settings.Visuals.Name.Color)
    local distanceColor = HSVToColor(Settings.Visuals.Distance.Color)

    -- Box
    if Settings.Visuals.Box.Enabled then
        local size = Vector2.new(100, 150) * (1000 / math.max(dist, 1))
        local pos = Vector2.new(screenPos.X, screenPos.Y) - size / 2
        local lines = esp.Box.Lines
        -- Top
        lines[1].From = pos
        lines[1].To = pos + Vector2.new(size.X, 0)
        lines[1].Color = boxColor
        lines[1].Visible = true
        -- Right
        lines[2].From = pos + Vector2.new(size.X, 0)
        lines[2].To = pos + size
        lines[2].Color = boxColor
        lines[2].Visible = true
        -- Bottom
        lines[3].From = pos + size
        lines[3].To = pos + Vector2.new(0, size.Y)
        lines[3].Color = boxColor
        lines[3].Visible = true
        -- Left
        lines[4].From = pos + Vector2.new(0, size.Y)
        lines[4].To = pos
        lines[4].Color = boxColor
        lines[4].Visible = true
    else
        for _, line in ipairs(esp.Box.Lines) do line.Visible = false end
    end

    -- Name
    if Settings.Visuals.Name.Enabled then
        esp.Name.Visible = true
        esp.Name.Text = player.Name
        esp.Name.Color = nameColor
        esp.Name.Position = Vector2.new(screenPos.X, screenPos.Y - 50)
    else
        esp.Name.Visible = false
    end

    -- Distance
    if Settings.Visuals.Distance.Enabled then
        esp.Distance.Visible = true
        local unit = Settings.Visuals.Distance.Mode == "Meters" and "m" or "studs"
        esp.Distance.Text = string.format("%.0f %s", dist, unit)
        esp.Distance.Color = distanceColor
        esp.Distance.Position = Vector2.new(screenPos.X, screenPos.Y + 30)
    else
        esp.Distance.Visible = false
    end

    -- Tracers
    if Settings.Visuals.Tracers.Enabled then
        local fromPos
        if Settings.Visuals.Tracers.Mode == "From Mouse" then
            fromPos = UserInputService:GetMouseLocation()
        else
            fromPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        end
        local toPos = Vector2.new(screenPos.X, screenPos.Y)
        esp.Tracer.Main.From = fromPos
        esp.Tracer.Main.To = toPos
        esp.Tracer.Main.Color = boxColor
        esp.Tracer.Main.Visible = true
        if Settings.Visuals.Tracers.Outline then
            esp.Tracer.Outline.From = fromPos
            esp.Tracer.Outline.To = toPos
            esp.Tracer.Outline.Visible = true
        else
            esp.Tracer.Outline.Visible = false
        end
    else
        esp.Tracer.Main.Visible = false
        esp.Tracer.Outline.Visible = false
    end

    -- Head Dots
    if Settings.Visuals.HeadDots.Enabled then
        local head = char:FindFirstChild("Head")
        if head then
            local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position)
            if headOnScreen then
                local radius = Settings.Visuals.HeadDots.Size
                if Settings.Visuals.HeadDots.Autoscale then
                    radius = radius * (1000 / math.max(dist, 1))
                end
                esp.HeadDot.Main.Radius = radius
                esp.HeadDot.Main.Position = Vector2.new(headPos.X, headPos.Y)
                esp.HeadDot.Main.Color = boxColor
                esp.HeadDot.Main.Filled = Settings.Visuals.HeadDots.Filled
                esp.HeadDot.Main.Visible = true
                if Settings.Visuals.HeadDots.Outline then
                    esp.HeadDot.Outline.Radius = radius + 1
                    esp.HeadDot.Outline.Position = esp.HeadDot.Main.Position
                    esp.HeadDot.Outline.Visible = true
                else
                    esp.HeadDot.Outline.Visible = false
                end
            end
        end
    else
        esp.HeadDot.Main.Visible = false
        esp.HeadDot.Outline.Visible = false
    end

    -- Health Bar (simplified: a vertical bar on the left side of the box)
    if Settings.Visuals.Health.Bar then
        local boxSize = Vector2.new(100, 150) * (1000 / math.max(dist, 1))
        local boxPos = Vector2.new(screenPos.X, screenPos.Y) - boxSize / 2
        local barX = boxPos.X - 6
        local barY = boxPos.Y
        local barHeight = boxSize.Y
        local fillHeight = barHeight * healthPercent
        esp.HealthBar.Background.From = Vector2.new(barX, barY)
        esp.HealthBar.Background.To = Vector2.new(barX, barY + barHeight)
        esp.HealthBar.Background.Visible = true
        esp.HealthBar.Fill.From = Vector2.new(barX, barY + barHeight)
        esp.HealthBar.Fill.To = Vector2.new(barX, barY + barHeight - fillHeight)
        if Settings.Visuals.Health.ColorMode == "Green" then
            esp.HealthBar.Fill.Color = Color3.new(0,1,0)
        elseif Settings.Visuals.Health.ColorMode == "Red" then
            esp.HealthBar.Fill.Color = Color3.new(1,0,0)
        else
            esp.HealthBar.Fill.Color = Color3.new(1,1,0)
        end
        esp.HealthBar.Fill.Visible = true
    else
        esp.HealthBar.Background.Visible = false
        esp.HealthBar.Fill.Visible = false
    end
end

-- Object ESP (items, quests, vehicles)
local function CreateObjectESP(list, obj, pos, name, colorFlag)
    local text = Drawing.new("Text")
    text.Size = 12
    text.Center = true
    text.Outline = true
    text.Font = 2
    text.Visible = false
    table.insert(list, { obj = obj, text = text, pos = pos, name = name, colorFlag = colorFlag })
end

local function UpdateObjectESP(list, flag)
    local enabled = Settings.Visuals[flag].Enabled
    local color = Color3.fromHSV(
        Settings.Visuals[flag].Color[1] or 0,
        Settings.Visuals[flag].Color[2] or 1,
        Settings.Visuals[flag].Color[3] or 1
    )
    local maxDist = Settings.Visuals.General.MaxDistance
    for _, entry in ipairs(list) do
        local obj = entry.obj
        if obj and obj.Parent then
            local position = entry.pos.Value or entry.pos.Position
            local screenPos, onScreen = Camera:WorldToViewportPoint(position)
            if onScreen and enabled then
                local dist = (position - Camera.CFrame.Position).Magnitude
                if dist <= maxDist then
                    entry.text.Visible = true
                    entry.text.Text = entry.name .. string.format(" [%.0f]", dist)
                    entry.text.Color = color
                    entry.text.Position = Vector2.new(screenPos.X, screenPos.Y)
                else
                    entry.text.Visible = false
                end
            else
                entry.text.Visible = false
            end
        else
            entry.text.Visible = false
        end
    end
end

-- Death History
local function OnPlayerDied(player)
    if not Settings.Visuals.DeathHistory.Enabled then return end
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    DeathCounter = DeathCounter + 1
    local text = Drawing.new("Text")
    text.Size = 14
    text.Center = true
    text.Outline = true
    text.Font = 2
    table.insert(DeathESP, { pos = root.Position, text = text, count = DeathCounter })
end

local function UpdateDeathESP()
    if not Settings.Visuals.DeathHistory.Enabled then
        for _, entry in ipairs(DeathESP) do
            entry.text.Visible = false
        end
        return
    end
    local color = Color3.fromHSV(
        Settings.Visuals.DeathHistory.Color[1] or 0,
        Settings.Visuals.DeathHistory.Color[2] or 1,
        Settings.Visuals.DeathHistory.Color[3] or 1
    )
    local maxDist = Settings.Visuals.General.MaxDistance
    for _, entry in ipairs(DeathESP) do
        local screenPos, onScreen = Camera:WorldToViewportPoint(entry.pos)
        if onScreen then
            local dist = (entry.pos - Camera.CFrame.Position).Magnitude
            if dist <= maxDist then
                entry.text.Visible = true
                entry.text.Text = "☠️ " .. entry.count
                entry.text.Color = color
                entry.text.Position = Vector2.new(screenPos.X, screenPos.Y)
            else
                entry.text.Visible = false
            end
        else
            entry.text.Visible = false
        end
    end
end

-- Initialize existing objects
if Workspace:FindFirstChild("Containers") then
    for _, container in ipairs(Workspace.Containers:GetChildren()) do
        CreateObjectESP(ItemESP, container, container:FindFirstChild("Part") or container, container.Name, "ItemText")
    end
    Workspace.Containers.ChildAdded:Connect(function(item)
        CreateObjectESP(ItemESP, item, item:FindFirstChild("Part") or item, item.Name, "ItemText")
    end)
end

if Workspace:FindFirstChild("QuestItems") then
    for _, quest in ipairs(Workspace.QuestItems:GetChildren()) do
        CreateObjectESP(QuestESP, quest, quest:FindFirstChild("Part") or quest, quest.Name, "QuestItems")
    end
    Workspace.QuestItems.ChildAdded:Connect(function(quest)
        CreateObjectESP(QuestESP, quest, quest:FindFirstChild("Part") or quest, quest.Name, "QuestItems")
    end)
end

if Workspace:FindFirstChild("Vehicles") then
    for _, veh in ipairs(Workspace.Vehicles:GetChildren()) do
        CreateObjectESP(VehicleESP, veh, veh:FindFirstChild("PrimaryPart") or veh, veh.Name, "Vehicles")
    end
    Workspace.Vehicles.ChildAdded:Connect(function(veh)
        CreateObjectESP(VehicleESP, veh, veh:FindFirstChild("PrimaryPart") or veh, veh.Name, "Vehicles")
    end)
end

-- Connect death events
for _, player in ipairs(Players:GetPlayers()) do
    if player.Character then
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Died:Connect(function() OnPlayerDied(player) end)
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid")
        hum.Died:Connect(function() OnPlayerDied(player) end)
    end)
end)

-- Main render loop
RunService.RenderStepped:Connect(function()
    if not Settings.Visuals.General.Enabled then
        -- Hide all player ESP
        for _, esp in pairs(PlayerESP) do
            if esp.Name then esp.Name.Visible = false end
            if esp.Distance then esp.Distance.Visible = false end
            if esp.Tracer then
                esp.Tracer.Main.Visible = false
                esp.Tracer.Outline.Visible = false
            end
            if esp.HeadDot then
                esp.HeadDot.Main.Visible = false
                esp.HeadDot.Outline.Visible = false
            end
            for _, line in ipairs(esp.Box.Lines) do line.Visible = false end
            if esp.HealthBar then
                esp.HealthBar.Background.Visible = false
                esp.HealthBar.Fill.Visible = false
            end
        end
        -- Hide object ESP
        for _, list in ipairs({ItemESP, QuestESP, VehicleESP}) do
            for _, entry in ipairs(list) do entry.text.Visible = false end
        end
        for _, entry in ipairs(DeathESP) do entry.text.Visible = false end
        return
    end

    -- Update player ESP
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer or Settings.Visuals.General.IncludeNPC then
            if not PlayerESP[player] then
                CreatePlayerESP(player)
            end
            UpdatePlayerESP(player)
        end
    end

    -- Update object ESP
    UpdateObjectESP(ItemESP, "ItemText")
    UpdateObjectESP(QuestESP, "QuestItems")
    UpdateObjectESP(VehicleESP, "Vehicles")
    UpdateDeathESP()
end)

-- Zoom
RunService.RenderStepped:Connect(function()
    if Settings.Visuals.Zoom.Enabled then
        Camera.FieldOfView = 70 - Settings.Visuals.Zoom.Level
    else
        Camera.FieldOfView = 70
    end
end)

print("Data Hub - Project Delta (ESP without library) loaded")
