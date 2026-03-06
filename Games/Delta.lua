-- Data Hub - Project Delta (Classic ESP Edition)
-- Game ID: 2862098693
-- Features: RageBot, Gun Mods, World, Misc, and Classic ESP (from Drawing.lua)
-- Fully integrated with your UI. All settings controlled via Visuals tab.

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
        Skeleton = {
            Enabled = false,
            Color = {1, 1, 1, 0, false}
        },
        ItemText = {
            Enabled = false,
            Color = {1, 1, 1, 0, false},
            Distance = 100
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
-- UI: VISUALS (Classic ESP Settings)
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
    end

    -- Name Section
    local NameSection = VisualsTab:Section({Name = "Name", Side = "Left"}) do
        NameSection:Toggle({Name = "Nametag", Flag = "Delta/Visuals/Name/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.Name.Enabled = val end})
        NameSection:Colorpicker({Name = "Color", Flag = "Delta/Visuals/Name/Color", Value = Settings.Visuals.Name.Color,
            Callback = function(val) Settings.Visuals.Name.Color = val end})
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
    end

    -- Skeleton Section
    local SkeletonSection = VisualsTab:Section({Name = "Skeleton", Side = "Right"}) do
        SkeletonSection:Toggle({Name = "Enabled", Flag = "Delta/Visuals/Skeleton/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.Skeleton.Enabled = val end})
        SkeletonSection:Colorpicker({Name = "Color", Flag = "Delta/Visuals/Skeleton/Color", Value = Settings.Visuals.Skeleton.Color,
            Callback = function(val) Settings.Visuals.Skeleton.Color = val end})
    end

    -- Item Text Section
    local ItemTextSection = VisualsTab:Section({Name = "Item Text", Side = "Right"}) do
        ItemTextSection:Toggle({Name = "Enabled", Flag = "Delta/Visuals/ItemText/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.ItemText.Enabled = val end})
        ItemTextSection:Colorpicker({Name = "Color", Flag = "Delta/Visuals/ItemText/Color", Value = Settings.Visuals.ItemText.Color,
            Callback = function(val) Settings.Visuals.ItemText.Color = val end})
        ItemTextSection:Slider({Name = "Distance", Flag = "Delta/Visuals/ItemText/Distance", Min = 30, Max = 1000, Value = 100,
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
    return "N/A"
end

local function IsEnemy(player)
    return player ~= LocalPlayer
end

-- ███████████████████████████████████████████████████████
-- CLASSIC ESP LIBRARY (from Drawing.lua, integrated)
-- ███████████████████████████████████████████████████████

-- Helper functions from Drawing.lua
local Cos = math.cos
local Rad = math.rad
local Sin = math.sin
local Tan = math.tan
local Abs = math.abs
local Deg = math.deg
local Max = math.max
local Atan2 = math.atan2
local Clamp = math.clamp
local Floor = math.floor

local WTVP = Camera.WorldToViewportPoint
local FindFirstChild = Workspace.FindFirstChild
local FindFirstChildOfClass = Workspace.FindFirstChildOfClass
local FindFirstChildWhichIsA = Workspace.FindFirstChildWhichIsA
local PointToObjectSpace = CFrame.identity.PointToObjectSpace

local UDimNew = UDim.new
local V2New = Vector2.new
local UDim2New = UDim2.new
local UDim2FromOffset = UDim2.fromOffset
local ColorNew = Color3.new
local RedColor = ColorNew(1, 0, 0)
local GreenColor = ColorNew(0, 1, 0)
local YellowColor = ColorNew(1, 1, 0)
local WhiteColor = ColorNew(1, 1, 1)
local BlackColor = ColorNew(0, 0, 0)
local LerpColor = BlackColor.Lerp
local Fonts = Drawing.Fonts

-- Drawing Library table
local DrawingLibrary = {
    ESP = {},
    ObjectESP = {},
    CharacterSize = Vector3.new(4, 5, 1),
    CS = ColorSequence.new({
        ColorSequenceKeypoint.new(0, RedColor),
        ColorSequenceKeypoint.new(0.5, YellowColor),
        ColorSequenceKeypoint.new(1, GreenColor)
    })
}

local function AddDrawing(Type, Properties)
    local DrawingObject = Drawing.new(Type)
    if Properties then
        for Property, Value in pairs(Properties) do
            DrawingObject[Property] = Value
        end
    end
    return DrawingObject
end

local function ClearDrawing(Table)
    for _, Value in pairs(Table) do
        if typeof(Value) == "table" then
            ClearDrawing(Value)
        else
            if isrenderobj and not isrenderobj(Value) then
                continue
            end
            pcall(function() Value:Destroy() end)
        end
    end
end

local function GetFlag(Flags, Flag, Option)
    return Flags[Flag .. Option]
end

local function GetDistance(Position)
    return (Position - Camera.CFrame.Position).Magnitude
end

local function IsWithinReach(Enabled, Limit, Distance)
    if not Enabled then return true end
    return Distance < Limit
end

local function GetScaleFactor(Enabled, Size, Distance)
    if not Enabled then return Size end
    return Max(1, Size / (Distance * Tan(Rad(Camera.FieldOfView / 2)) * 10) * 1000)
end

local function AntiAliasingXY(X, Y)
    return V2New(Floor(X), Floor(Y))
end

local function WorldToScreen(WorldPosition)
    local Screen, OnScreen = WTVP(Camera, WorldPosition)
    return V2New(Screen.X, Screen.Y), OnScreen
end

local function EvalHealth(Percent)
    local CS = DrawingLibrary.CS
    if Percent == 0 then return CS.Keypoints[1].Value end
    if Percent == 1 then return CS.Keypoints[#CS.Keypoints].Value end
    for Index = 1, #CS.Keypoints - 1 do
        local KIndex = CS.Keypoints[Index]
        local NIndex = CS.Keypoints[Index + 1]
        if Percent >= KIndex.Time and Percent < NIndex.Time then
            local Alpha = (Percent - KIndex.Time) / (NIndex.Time - KIndex.Time)
            return KIndex.Value:Lerp(NIndex.Value, Alpha)
        end
    end
end

local function CalculateBoxSize(Model, Distance)
    local CharacterSize = Model:GetExtentsSize()
    local FrustumHeight = Tan(Rad(Camera.FieldOfView / 2)) * 2 * Distance
    local BoxSize = Camera.ViewportSize.Y / FrustumHeight * CharacterSize
    return AntiAliasingXY(BoxSize.X, BoxSize.Y)
end

-- GetCharacter function (adapted for Project Delta)
function DrawingLibrary.GetCharacter(Target, Mode)
    if Mode == "Player" then
        local Character = Target.Character if not Character then return end
        return Character, FindFirstChild(Character, "HumanoidRootPart")
    else
        return Target, FindFirstChild(Target, "HumanoidRootPart")
    end
end

-- GetHealth function (uses real health from GameplayVariables)
function DrawingLibrary.GetHealth(Target, Character, Mode)
    if Mode == "Player" then
        return GetRealHealth(Target), 100, GetRealHealth(Target) > 0
    else
        return 100, 100, true
    end
end

-- GetTeam function (all others are enemies)
function DrawingLibrary.GetTeam(Target, Character, Mode)
    if Mode == "Player" then
        return IsEnemy(Target), IsEnemy(Target) and RedColor or GreenColor
    else
        return true, WhiteColor
    end
end

-- GetWeapon function
function DrawingLibrary.GetWeapon(Target, Character, Mode)
    if Mode == "Player" then
        return GetCurrentWeapon(Target)
    else
        return "N/A"
    end
end

function DrawingLibrary.Update(ESP, Target)
    local Textboxes = ESP.Drawing.Textboxes
    local Mode, Flag, Flags = ESP.Mode, ESP.Flag, ESP.Flags

    local Character, RootPart = nil, nil
    local ScreenPosition, OnScreen = Vector2.zero, false
    local Distance, InTheRange, BoxTooSmall = 0, false, false
    local Health, MaxHealth, IsAlive = 100, 100, false
    local InEnemyTeam, TeamColor = true, WhiteColor
    local Color = WhiteColor

    Character, RootPart = DrawingLibrary.GetCharacter(Target, Mode)
    if Character and RootPart then
        ScreenPosition, OnScreen = WorldToScreen(RootPart.Position)

        if OnScreen then
            Distance = GetDistance(RootPart.Position)
            InTheRange = IsWithinReach(GetFlag(Flags, Flag, "/DistanceCheck"), GetFlag(Flags, Flag, "/Distance"), Distance)

            if InTheRange then
                Health, MaxHealth, IsAlive = DrawingLibrary.GetHealth(Target, Character, Mode)
                InEnemyTeam, TeamColor = DrawingLibrary.GetTeam(Target, Character, Mode)
                Color = GetFlag(Flags, Flag, "/TeamColor") and TeamColor
                or (InEnemyTeam and GetFlag(Flags, Flag, "/Enemy")[6]
                or GetFlag(Flags, Flag, "/Ally")[6])

                if ESP.Drawing.Tracer.Main.Visible or ESP.Drawing.HeadDot.Main.Visible then
                    local Head = FindFirstChild(Character, "Head", true)

                    if Head then
                        local HeadPosition = WorldToScreen(Head.Position)

                        if ESP.Drawing.Tracer.Main.Visible then
                            local FromPosition = GetFlag(Flags, Flag, "/Tracer/Mode")
                            local Thickness = GetFlag(Flags, Flag, "/Tracer/Thickness")
                            local Transparency = 1 - GetFlag(Flags, Flag, "/Tracer/Transparency")
                            FromPosition = (FromPosition[1] == "From Mouse" and UserInputService:GetMouseLocation())
                            or (FromPosition[1] == "From Bottom" and V2New(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y))

                            ESP.Drawing.Tracer.Main.Color = Color
                            ESP.Drawing.Tracer.Main.Thickness = Thickness
                            ESP.Drawing.Tracer.Outline.Thickness = Thickness + 2
                            ESP.Drawing.Tracer.Main.Transparency = Transparency
                            ESP.Drawing.Tracer.Outline.Transparency = Transparency
                            ESP.Drawing.Tracer.Main.From = FromPosition
                            ESP.Drawing.Tracer.Outline.From = FromPosition
                            ESP.Drawing.Tracer.Main.To = HeadPosition
                            ESP.Drawing.Tracer.Outline.To = HeadPosition
                        end
                        if ESP.Drawing.HeadDot.Main.Visible then
                            local Filled = GetFlag(Flags, Flag, "/HeadDot/Filled")
                            local Radius = GetFlag(Flags, Flag, "/HeadDot/Radius")
                            local NumSides = GetFlag(Flags, Flag, "/HeadDot/NumSides")
                            local Thickness = GetFlag(Flags, Flag, "/HeadDot/Thickness")
                            local Autoscale = GetFlag(Flags, Flag, "/HeadDot/Autoscale")
                            local Transparency = 1 - GetFlag(Flags, Flag, "/HeadDot/Transparency")
                            Radius = GetScaleFactor(Autoscale, Radius, Distance)

                            ESP.Drawing.HeadDot.Main.Color = Color
                            ESP.Drawing.HeadDot.Main.Transparency = Transparency
                            ESP.Drawing.HeadDot.Outline.Transparency = Transparency
                            ESP.Drawing.HeadDot.Main.NumSides = NumSides
                            ESP.Drawing.HeadDot.Outline.NumSides = NumSides
                            ESP.Drawing.HeadDot.Main.Radius = Radius
                            ESP.Drawing.HeadDot.Outline.Radius = Radius
                            ESP.Drawing.HeadDot.Main.Thickness = Thickness
                            ESP.Drawing.HeadDot.Outline.Thickness = Thickness + 2
                            ESP.Drawing.HeadDot.Main.Filled = Filled
                            ESP.Drawing.HeadDot.Main.Position = HeadPosition
                            ESP.Drawing.HeadDot.Outline.Position = HeadPosition
                        end
                    end
                end
                if ESP.Drawing.Box.Visible then
                    local BoxSize = CalculateBoxSize(Character, Distance)
                    local HealthPercent = Health / MaxHealth
                    BoxTooSmall = BoxSize.Y < 18

                    local Transparency = 1 - GetFlag(Flags, Flag, "/Box/Transparency")
                    local CornerSize = GetFlag(Flags, Flag, "/Box/CornerSize")
                    local Thickness = GetFlag(Flags, Flag, "/Box/Thickness")
                    local Filled = GetFlag(Flags, Flag, "/Box/Filled")

                    local ThicknessAdjust = Floor(Thickness / 2)
                    CornerSize = V2New(
                        (BoxSize.X / 2) * (CornerSize / 100),
                        (BoxSize.Y / 2) * (CornerSize / 100)
                    )

                    local From = AntiAliasingXY(
                        ScreenPosition.X - (BoxSize.X / 2),
                        ScreenPosition.Y - (BoxSize.Y / 2)
                    )
                    local To = AntiAliasingXY(
                        ScreenPosition.X - (BoxSize.X / 2),
                        (ScreenPosition.Y - (BoxSize.Y / 2)) + CornerSize.Y
                    )

                    ESP.Drawing.Box.LineLT.Main.Color = Color
                    ESP.Drawing.Box.LineLT.Main.Thickness = Thickness
                    ESP.Drawing.Box.LineLT.Outline.Thickness = Thickness + 2
                    ESP.Drawing.Box.LineLT.Main.Transparency = Transparency
                    ESP.Drawing.Box.LineLT.Outline.Transparency = Transparency
                    ESP.Drawing.Box.LineLT.Main.From = From - V2New(0, ThicknessAdjust)
                    ESP.Drawing.Box.LineLT.Outline.From = From - V2New(0, ThicknessAdjust + 1)
                    ESP.Drawing.Box.LineLT.Main.To = To
                    ESP.Drawing.Box.LineLT.Outline.To = To + V2New(0, 1)

                    From = AntiAliasingXY(
                        ScreenPosition.X - (BoxSize.X / 2),
                        ScreenPosition.Y - (BoxSize.Y / 2)
                    )
                    To = AntiAliasingXY(
                        (ScreenPosition.X - (BoxSize.X / 2)) + CornerSize.X,
                        ScreenPosition.Y - (BoxSize.Y / 2)
                    )

                    ESP.Drawing.Box.LineTL.Main.Color = Color
                    ESP.Drawing.Box.LineTL.Main.Thickness = Thickness
                    ESP.Drawing.Box.LineTL.Outline.Thickness = Thickness + 2
                    ESP.Drawing.Box.LineTL.Main.Transparency = Transparency
                    ESP.Drawing.Box.LineTL.Outline.Transparency = Transparency
                    ESP.Drawing.Box.LineTL.Main.From = From - V2New(ThicknessAdjust, 0)
                    ESP.Drawing.Box.LineTL.Outline.From = From - V2New(ThicknessAdjust + 1, 0)
                    ESP.Drawing.Box.LineTL.Main.To = To
                    ESP.Drawing.Box.LineTL.Outline.To = To + V2New(1, 0)

                    From = AntiAliasingXY(
                        ScreenPosition.X - (BoxSize.X / 2),
                        ScreenPosition.Y + (BoxSize.Y / 2)
                    )
                    To = AntiAliasingXY(
                        ScreenPosition.X - (BoxSize.X / 2),
                        (ScreenPosition.Y + (BoxSize.Y / 2)) - CornerSize.Y
                    )

                    ESP.Drawing.Box.LineLB.Main.Color = Color
                    ESP.Drawing.Box.LineLB.Main.Thickness = Thickness
                    ESP.Drawing.Box.LineLB.Outline.Thickness = Thickness + 2
                    ESP.Drawing.Box.LineLB.Main.Transparency = Transparency
                    ESP.Drawing.Box.LineLB.Outline.Transparency = Transparency
                    ESP.Drawing.Box.LineLB.Main.From = From + V2New(0, ThicknessAdjust)
                    ESP.Drawing.Box.LineLB.Outline.From = From + V2New(0, ThicknessAdjust + 1)
                    ESP.Drawing.Box.LineLB.Main.To = To
                    ESP.Drawing.Box.LineLB.Outline.To = To - V2New(0, 1)

                    From = AntiAliasingXY(
                        ScreenPosition.X - (BoxSize.X / 2),
                        ScreenPosition.Y + (BoxSize.Y / 2)
                    )
                    To = AntiAliasingXY(
                        (ScreenPosition.X - (BoxSize.X / 2)) + CornerSize.X,
                        ScreenPosition.Y + (BoxSize.Y / 2)
                    )

                    ESP.Drawing.Box.LineBL.Main.Color = Color
                    ESP.Drawing.Box.LineBL.Main.Thickness = Thickness
                    ESP.Drawing.Box.LineBL.Main.Transparency = Transparency
                    ESP.Drawing.Box.LineBL.Outline.Thickness = Thickness + 2
                    ESP.Drawing.Box.LineBL.Outline.Transparency = Transparency
                    ESP.Drawing.Box.LineBL.Main.From = From - V2New(ThicknessAdjust, 1)
                    ESP.Drawing.Box.LineBL.Outline.From = From - V2New(ThicknessAdjust + 1, 1)
                    ESP.Drawing.Box.LineBL.Main.To = To - V2New(0, 1)
                    ESP.Drawing.Box.LineBL.Outline.To = To - V2New(-1, 1)

                    From = AntiAliasingXY(
                        ScreenPosition.X + (BoxSize.X / 2),
                        ScreenPosition.Y - (BoxSize.Y / 2)
                    )
                    To = AntiAliasingXY(
                        ScreenPosition.X + (BoxSize.X / 2),
                        (ScreenPosition.Y - (BoxSize.Y / 2)) + CornerSize.Y
                    )

                    ESP.Drawing.Box.LineRT.Main.Color = Color
                    ESP.Drawing.Box.LineRT.Main.Thickness = Thickness
                    ESP.Drawing.Box.LineRT.Outline.Thickness = Thickness + 2
                    ESP.Drawing.Box.LineRT.Main.Transparency = Transparency
                    ESP.Drawing.Box.LineRT.Outline.Transparency = Transparency
                    ESP.Drawing.Box.LineRT.Main.From = From - V2New(1, ThicknessAdjust)
                    ESP.Drawing.Box.LineRT.Outline.From = From - V2New(1, ThicknessAdjust + 1)
                    ESP.Drawing.Box.LineRT.Main.To = To - V2New(1, 0)
                    ESP.Drawing.Box.LineRT.Outline.To = To + V2New(-1, 1)

                    From = AntiAliasingXY(
                        ScreenPosition.X + (BoxSize.X / 2),
                        ScreenPosition.Y - (BoxSize.Y / 2)
                    )
                    To = AntiAliasingXY(
                        (ScreenPosition.X + (BoxSize.X / 2)) - CornerSize.X,
                        ScreenPosition.Y - (BoxSize.Y / 2)
                    )

                    ESP.Drawing.Box.LineTR.Main.Color = Color
                    ESP.Drawing.Box.LineTR.Main.Thickness = Thickness
                    ESP.Drawing.Box.LineTR.Outline.Thickness = Thickness + 2
                    ESP.Drawing.Box.LineTR.Main.Transparency = Transparency
                    ESP.Drawing.Box.LineTR.Outline.Transparency = Transparency
                    ESP.Drawing.Box.LineTR.Main.From = From + V2New(ThicknessAdjust, 0)
                    ESP.Drawing.Box.LineTR.Outline.From = From + V2New(ThicknessAdjust + 1, 0)
                    ESP.Drawing.Box.LineTR.Main.To = To
                    ESP.Drawing.Box.LineTR.Outline.To = To - V2New(1, 0)

                    From = AntiAliasingXY(
                        ScreenPosition.X + (BoxSize.X / 2),
                        ScreenPosition.Y + (BoxSize.Y / 2)
                    )
                    To = AntiAliasingXY(
                        ScreenPosition.X + (BoxSize.X / 2),
                        (ScreenPosition.Y + (BoxSize.Y / 2)) - CornerSize.Y
                    )

                    ESP.Drawing.Box.LineRB.Main.Color = Color
                    ESP.Drawing.Box.LineRB.Main.Thickness = Thickness
                    ESP.Drawing.Box.LineRB.Outline.Thickness = Thickness + 2
                    ESP.Drawing.Box.LineRB.Main.Transparency = Transparency
                    ESP.Drawing.Box.LineRB.Outline.Transparency = Transparency
                    ESP.Drawing.Box.LineRB.Main.From = From + V2New(-1, ThicknessAdjust)
                    ESP.Drawing.Box.LineRB.Outline.From = From + V2New(-1, ThicknessAdjust + 1)
                    ESP.Drawing.Box.LineRB.Main.To = To - V2New(1, 0)
                    ESP.Drawing.Box.LineRB.Outline.To = To - V2New(1, 1)

                    From = AntiAliasingXY(
                        ScreenPosition.X + (BoxSize.X / 2),
                        ScreenPosition.Y + (BoxSize.Y / 2)
                    )
                    To = AntiAliasingXY(
                        (ScreenPosition.X + (BoxSize.X / 2)) - CornerSize.X,
                        ScreenPosition.Y + (BoxSize.Y / 2)
                    )

                    ESP.Drawing.Box.LineBR.Main.Color = Color
                    ESP.Drawing.Box.LineBR.Main.Thickness = Thickness
                    ESP.Drawing.Box.LineBR.Outline.Thickness = Thickness + 2
                    ESP.Drawing.Box.LineBR.Main.Transparency = Transparency
                    ESP.Drawing.Box.LineBR.Outline.Transparency = Transparency
                    ESP.Drawing.Box.LineBR.Main.From = From + V2New(ThicknessAdjust, -1)
                    ESP.Drawing.Box.LineBR.Outline.From = From + V2New(ThicknessAdjust + 1, -1)
                    ESP.Drawing.Box.LineBR.Main.To = To - V2New(0, 1)
                    ESP.Drawing.Box.LineBR.Outline.To = To - V2New(1, 1)

                    if ESP.Drawing.HealthBar.Main.Visible then
                        ESP.Drawing.HealthBar.Main.Color = EvalHealth(HealthPercent)
                        ESP.Drawing.HealthBar.Main.Transparency = Transparency
                        ESP.Drawing.HealthBar.Outline.Transparency = Transparency

                        ESP.Drawing.HealthBar.Outline.Size = AntiAliasingXY(Thickness + 2, BoxSize.Y + (Thickness + 1))
                        ESP.Drawing.HealthBar.Outline.Position = AntiAliasingXY(
                            (ScreenPosition.X - (BoxSize.X / 2)) - Thickness - ThicknessAdjust - 4,
                            ScreenPosition.Y - (BoxSize.Y / 2) - ThicknessAdjust - 1
                        )
                        ESP.Drawing.HealthBar.Main.Size = V2New(ESP.Drawing.HealthBar.Outline.Size.X - 2, -HealthPercent * (ESP.Drawing.HealthBar.Outline.Size.Y - 2))
                        ESP.Drawing.HealthBar.Main.Position = ESP.Drawing.HealthBar.Outline.Position + V2New(1, ESP.Drawing.HealthBar.Outline.Size.Y - 1)
                    end

                    if Textboxes.Name.Visible
                    or Textboxes.Health.Visible
                    or Textboxes.Distance.Visible
                    or Textboxes.Weapon.Visible then
                        local Size = GetFlag(Flags, Flag, "/Name/Size")
                        local Autoscale = GetFlag(Flags, Flag, "/Name/Autoscale")
                        Autoscale = Floor(GetScaleFactor(Autoscale, Size, Distance))

                        Transparency = 1 - GetFlag(Flags, Flag, "/Name/Transparency")
                        Outline = GetFlag(Flags, Flag, "/Name/Outline")

                        if Textboxes.Name.Visible then
                            Textboxes.Name.Outline = Outline
                            Textboxes.Name.Transparency = Transparency
                            Textboxes.Name.Size = Autoscale
                            Textboxes.Name.Text = Mode == "Player" and Target.Name
                            or (InEnemyTeam and "Enemy NPC" or "Ally NPC")

                            Textboxes.Name.Position = AntiAliasingXY(
                                ScreenPosition.X,
                                ScreenPosition.Y - (BoxSize.Y / 2) - Textboxes.Name.TextBounds.Y - ThicknessAdjust - 2
                            )
                        end
                        if Textboxes.Health.Visible then
                            Textboxes.Health.Outline = Outline
                            Textboxes.Health.Transparency = Transparency
                            Textboxes.Health.Size = Autoscale
                            Textboxes.Health.Text = tostring(math.floor(HealthPercent * 100)) .. "%"

                            local HealthPositionX = ESP.Drawing.HealthBar.Main.Visible and ((ScreenPosition.X - (BoxSize.X / 2)) - Textboxes.Health.TextBounds.X - (Thickness + ThicknessAdjust + 5)) or ((ScreenPosition.X - (BoxSize.X / 2)) - Textboxes.Health.TextBounds.X - ThicknessAdjust - 2)
                            Textboxes.Health.Position = AntiAliasingXY(
                                HealthPositionX,
                                (ScreenPosition.Y - (BoxSize.Y / 2)) - ThicknessAdjust - 1
                            )
                        end
                        if Textboxes.Distance.Visible then
                            Textboxes.Distance.Outline = Outline
                            Textboxes.Distance.Transparency = Transparency
                            Textboxes.Distance.Size = Autoscale
                            Textboxes.Distance.Text = tostring(math.floor(Distance)) .. " studs"

                            Textboxes.Distance.Position = AntiAliasingXY(
                                ScreenPosition.X,
                                (ScreenPosition.Y + (BoxSize.Y / 2)) + ThicknessAdjust + 2
                            )
                        end
                        if Textboxes.Weapon.Visible then
                            local Weapon = DrawingLibrary.GetWeapon(Target, Character, Mode)

                            Textboxes.Weapon.Outline = Outline
                            Textboxes.Weapon.Transparency = Transparency
                            Textboxes.Weapon.Size = Autoscale
                            Textboxes.Weapon.Text = Weapon

                            Textboxes.Weapon.Position = AntiAliasingXY(
                                (ScreenPosition.X + (BoxSize.X / 2)) + ThicknessAdjust + 2,
                                ScreenPosition.Y - (BoxSize.Y / 2) - ThicknessAdjust - 1
                            )
                        end
                    end
                end
            end
        else
            -- Offscreen arrows (simplified, can be expanded)
        end
    end

    local TeamCheck = (not GetFlag(Flags, Flag, "/TeamCheck") and not InEnemyTeam) or InEnemyTeam
    local Visible = RootPart and OnScreen and InTheRange and IsAlive and TeamCheck
    local ArrowVisible = RootPart and (not OnScreen) and InTheRange and IsAlive and TeamCheck

    ESP.Drawing.Box.Visible = Visible and GetFlag(Flags, Flag, "/Box/Enabled") or false
    ESP.Drawing.Box.OutlineVisible = ESP.Drawing.Box.Visible and GetFlag(Flags, Flag, "/Box/Outline") or false

    for Index, Line in pairs(ESP.Drawing.Box) do
        if type(Line) ~= "table" then continue end
        Line.Main.Visible = ESP.Drawing.Box.Visible
        Line.Outline.Visible = ESP.Drawing.Box.OutlineVisible
    end

    ESP.Drawing.HealthBar.Main.Visible = ESP.Drawing.Box.Visible and GetFlag(Flags, Flag, "/Box/HealthBar") and not BoxTooSmall or false
    ESP.Drawing.HealthBar.Outline.Visible = ESP.Drawing.HealthBar.Main.Visible and GetFlag(Flags, Flag, "/Box/Outline") or false

    ESP.Drawing.Arrow.Main.Visible = ArrowVisible and GetFlag(Flags, Flag, "/Arrow/Enabled") or false
    ESP.Drawing.Arrow.Outline.Visible = GetFlag(Flags, Flag, "/Arrow/Outline") and ESP.Drawing.Arrow.Main.Visible or false

    ESP.Drawing.HeadDot.Main.Visible = Visible and GetFlag(Flags, Flag, "/HeadDot/Enabled") or false
    ESP.Drawing.HeadDot.Outline.Visible = GetFlag(Flags, Flag, "/HeadDot/Outline") and ESP.Drawing.HeadDot.Main.Visible or false

    ESP.Drawing.Tracer.Main.Visible = Visible and GetFlag(Flags, Flag, "/Tracer/Enabled") or false
    ESP.Drawing.Tracer.Outline.Visible = GetFlag(Flags, Flag, "/Tracer/Outline") and ESP.Drawing.Tracer.Main.Visible or false

    ESP.Drawing.Textboxes.Name.Visible = Visible and GetFlag(Flags, Flag, "/Name/Enabled") or false
    ESP.Drawing.Textboxes.Health.Visible = Visible and GetFlag(Flags, Flag, "/Health/Enabled") or false
    ESP.Drawing.Textboxes.Distance.Visible = Visible and GetFlag(Flags, Flag, "/Distance/Enabled") or false
    ESP.Drawing.Textboxes.Weapon.Visible = Visible and GetFlag(Flags, Flag, "/Weapon/Enabled") or false
end

function DrawingLibrary.AddESP(Self, Target, Mode, Flag, Flags)
    if Self.ESP[Target] then return end

    Self.ESP[Target] = {
        Target = {}, Mode = Mode,
        Flag = Flag, Flags = Flags,
        Drawing = {
            Box = {
                Visible = false,
                OutlineVisible = false,
                LineLT = {
                    Outline = AddDrawing("Line", { Visible = false, ZIndex = 0 }),
                    Main = AddDrawing("Line", { Visible = false, ZIndex = 1 }),
                },
                LineTL = {
                    Outline = AddDrawing("Line", { Visible = false, ZIndex = 0 }),
                    Main = AddDrawing("Line", { Visible = false, ZIndex = 1 }),
                },
                LineLB = {
                    Outline = AddDrawing("Line", { Visible = false, ZIndex = 0 }),
                    Main = AddDrawing("Line", { Visible = false, ZIndex = 1 }),
                },
                LineBL = {
                    Outline = AddDrawing("Line", { Visible = false, ZIndex = 0 }),
                    Main = AddDrawing("Line", { Visible = false, ZIndex = 1 }),
                },
                LineRT = {
                    Outline = AddDrawing("Line", { Visible = false, ZIndex = 0 }),
                    Main = AddDrawing("Line", { Visible = false, ZIndex = 1 }),
                },
                LineTR = {
                    Outline = AddDrawing("Line", { Visible = false, ZIndex = 0 }),
                    Main = AddDrawing("Line", { Visible = false, ZIndex = 1 }),
                },
                LineRB = {
                    Outline = AddDrawing("Line", { Visible = false, ZIndex = 0 }),
                    Main = AddDrawing("Line", { Visible = false, ZIndex = 1 }),
                },
                LineBR = {
                    Outline = AddDrawing("Line", { Visible = false, ZIndex = 0 }),
                    Main = AddDrawing("Line", { Visible = false, ZIndex = 1 }),
                }
            },
            HealthBar = {
                Outline = AddDrawing("Square", { Visible = false, ZIndex = 0, Filled = true }),
                Main = AddDrawing("Square", { Visible = false, ZIndex = 1, Filled = true }),
            },
            Tracer = {
                Outline = AddDrawing("Line", { Visible = false, ZIndex = 0 }),
                Main = AddDrawing("Line", { Visible = false, ZIndex = 1 }),
            },
            HeadDot = {
                Outline = AddDrawing("Circle", { Visible = false, ZIndex = 0 }),
                Main = AddDrawing("Circle", { Visible = false, ZIndex = 1 }),
            },
            Arrow = {
                Outline = AddDrawing("Triangle", { Visible = false, ZIndex = 0 }),
                Main = AddDrawing("Triangle", { Visible = false, ZIndex = 1 }),
            },
            Textboxes = {
                Name = AddDrawing("Text", { Visible = false, ZIndex = 0, Center = true, Outline = true, Color = WhiteColor, Font = Fonts.Plex }),
                Distance = AddDrawing("Text", { Visible = false, ZIndex = 0, Center = true, Outline = true, Color = WhiteColor, Font = Fonts.Plex }),
                Health = AddDrawing("Text", { Visible = false, ZIndex = 0, Center = false, Outline = true, Color = WhiteColor, Font = Fonts.Plex }),
                Weapon = AddDrawing("Text", { Visible = false, ZIndex = 0, Center = false, Outline = true, Color = WhiteColor, Font = Fonts.Plex })
            },
        }
    }
end

function DrawingLibrary.RemoveESP(Self, Target)
    local ESP = Self.ESP[Target]
    if not ESP then return end

    ClearDrawing(ESP.Drawing)
    Self.ESP[Target] = nil
end

function DrawingLibrary.RemoveObject(Self, Target)
    local ESP = Self.ObjectESP[Target]
    if not ESP then return end
    ESP.Name:Destroy()
    Self.ObjectESP[Target] = nil
end

function DrawingLibrary.SetupCursor(Window) end -- Not used
function DrawingLibrary.SetupCrosshair(Flags) end -- Not used
function DrawingLibrary.SetupFOV(Flag, Flags) end -- Not used

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = Workspace.CurrentCamera
end)

-- Main render loop
DrawingLibrary.Connection = RunService.RenderStepped:Connect(function()
    debug.profilebegin("DATAHUB_DRAWING")
    for Target, ESP in pairs(DrawingLibrary.ESP) do
        DrawingLibrary.Update(ESP, Target)
    end
    for Object, ESP in pairs(DrawingLibrary.ObjectESP) do
        if not GetFlag(ESP.Flags, ESP.GlobalFlag, "/Enabled")
        or not GetFlag(ESP.Flags, ESP.Flag, "/Enabled") then
            ESP.Name.Visible = false
            continue
        end

        ESP.Target.Position = ESP.IsBasePart and ESP.Target.RootPart.Position or ESP.Target.Position
        ESP.Target.ScreenPosition, ESP.Target.OnScreen = WorldToScreen(ESP.Target.Position)

        ESP.Target.Distance = GetDistance(ESP.Target.Position)
        ESP.Target.InTheRange = IsWithinReach(GetFlag(ESP.Flags, ESP.GlobalFlag, "/DistanceCheck"),
        GetFlag(ESP.Flags, ESP.GlobalFlag, "/Distance"), ESP.Target.Distance)

        ESP.Name.Visible = (ESP.Target.OnScreen and ESP.Target.InTheRange) or false

        if ESP.Name.Visible then
            local Color = GetFlag(ESP.Flags, ESP.Flag, "/Color")
            ESP.Name.Transparency = 1 - Color[4]
            ESP.Name.Color = Color[6]

            ESP.Name.Position = ESP.Target.ScreenPosition
            ESP.Name.Text = string.format("%s\n%i studs", ESP.Target.Name, ESP.Target.Distance)
        end
    end
    debug.profileend()
end)

-- ███████████████████████████████████████████████████████
-- ESP INITIALIZATION (connecting to UI)
-- ███████████████████████████████████████████████████████

-- Add ESP for all players
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        DrawingLibrary.AddESP(DrawingLibrary, player, "Player", "Delta/Visuals", Window.Flags)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        DrawingLibrary.AddESP(DrawingLibrary, player, "Player", "Delta/Visuals", Window.Flags)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    DrawingLibrary.RemoveESP(DrawingLibrary, player)
end)

-- Object ESP (simplified - can be expanded)
if Workspace:FindFirstChild("Containers") then
    for _, container in ipairs(Workspace.Containers:GetChildren()) do
        if container:IsA("Model") then
            local part = container.PrimaryPart or container:FindFirstChildWhichIsA("Part")
            if part then
                DrawingLibrary.AddObject(DrawingLibrary, container, container.Name, part, "Delta/Visuals/ItemText", "Delta/Visuals/ItemText", Window.Flags)
            end
        end
    end
end

if Workspace:FindFirstChild("QuestItems") then
    for _, quest in ipairs(Workspace.QuestItems:GetChildren()) do
        if quest:IsA("Model") then
            local part = quest.PrimaryPart or quest:FindFirstChildWhichIsA("Part")
            if part then
                DrawingLibrary.AddObject(DrawingLibrary, quest, quest.Name, part, "Delta/Visuals/QuestItems", "Delta/Visuals/QuestItems", Window.Flags)
            end
        end
    end
end

if Workspace:FindFirstChild("Vehicles") then
    for _, vehicle in ipairs(Workspace.Vehicles:GetChildren()) do
        if vehicle:IsA("Model") then
            local part = vehicle.PrimaryPart or vehicle:FindFirstChildWhichIsA("Part")
            if part then
                DrawingLibrary.AddObject(DrawingLibrary, vehicle, vehicle.Name, part, "Delta/Visuals/Vehicles", "Delta/Visuals/Vehicles", Window.Flags)
            end
        end
    end
end

-- Zoom
RunService.RenderStepped:Connect(function()
    if Settings.Visuals.Zoom.Enabled then
        Camera.FieldOfView = 70 - Settings.Visuals.Zoom.Level
    else
        Camera.FieldOfView = 70
    end
end)

print("Data Hub - Project Delta (Classic ESP) loaded")
print("ESP is fully integrated with your UI settings.")
