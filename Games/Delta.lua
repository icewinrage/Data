-- Data Hub - Project Delta (Ultimate ESP with 3D Box, Shifter & Pro HealthBar)
-- Game ID: 2862098693
-- Features: RageBot, Gun Mods, World, Misc, and Professional ESP (3D Box, Shifter, Pro HealthBar, Object ESP, Death History)

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
            Color = {1, 0, 0, 0, false},  -- красный
            Thickness = 2
        },
        Tracers = {
            Enabled = false,
            Color = {1, 0, 0, 0, false},
            Thickness = 2
        },
        Shifter = {
            Enabled = false,
            Color = {0, 1, 0, 0, false}   -- зелёный
        },
        Health = {
            Bar = false,
            ColorMode = "Gradient", -- будет работать как градиент
            Position = "Left" -- позиция фиксирована слева
        },
        AutoThickness = true,
        TeamCheck = true,
        DeadPlayers = false,  -- показывать мёртвых?
        -- Цвета для команды (используются при TeamCheck)
        AllyColor = {0, 1, 0, 0, false},
        EnemyColor = {1, 0, 0, 0, false},
        -- Остальные настройки
        ItemText = { Enabled = false, Color = {1,1,1,0,false}, Distance = 100 },
        QuestItems = { Enabled = false, Color = {0,1,0,0,false} },
        Vehicles = { Enabled = false, Color = {0,0,1,0,false} },
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
        -- Цветовой режим теперь будет управлять градиентом (оставим для совместимости)
        HealthSection:Dropdown({Name = "Color Mode", Flag = "Delta/Visuals/Health/ColorMode", List = {
            {Name = "Gradient", Mode = "Button", Value = true},
            {Name = "Red", Mode = "Button"},
            {Name = "Green", Mode = "Button"}
        }, Callback = function(selected) Settings.Visuals.Health.ColorMode = selected[1] end})
        HealthSection:Dropdown({Name = "Position", Flag = "Delta/Visuals/Health/Position", List = {
            {Name = "Left", Mode = "Button", Value = true},
            {Name = "Right", Mode = "Button"},
            {Name = "Top", Mode = "Button"},
            {Name = "Bottom", Mode = "Button"}
        }, Callback = function(selected) Settings.Visuals.Health.Position = selected[1] end})
    end

    -- Team Colors Section
    local TeamSection = VisualsTab:Section({Name = "Team Colors", Side = "Right"}) do
        TeamSection:Colorpicker({Name = "Ally Color", Flag = "Delta/Visuals/AllyColor", Value = Settings.Visuals.AllyColor,
            Callback = function(hsv, color) Settings.Visuals.AllyColor = hsv end})
        TeamSection:Colorpicker({Name = "Enemy Color", Flag = "Delta/Visuals/EnemyColor", Value = Settings.Visuals.EnemyColor,
            Callback = function(hsv, color) Settings.Visuals.EnemyColor = hsv end})
    end

    -- Object ESP Sections
    local ItemTextSection = VisualsTab:Section({Name = "Item Text", Side = "Right"}) do
        ItemTextSection:Toggle({Name = "Enabled", Flag = "Delta/Visuals/ItemText/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.ItemText.Enabled = val end})
        ItemTextSection:Colorpicker({Name = "Color", Flag = "Delta/Visuals/ItemText/Color", Value = Settings.Visuals.ItemText.Color,
            Callback = function(val) Settings.Visuals.ItemText.Color = val end})
        ItemTextSection:Slider({Name = "Distance", Flag = "Delta/Visuals/ItemText/Distance", Min = 30, Max = 1000, Value = 100,
            Callback = function(val) Settings.Visuals.ItemText.Distance = val end})
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
        DeathSection:Toggle({Name = "Enabled", Flag = "Delta/Visuals/DeathHistory/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.DeathHistory.Enabled = val end})
        DeathSection:Colorpicker({Name = "Color", Flag = "Delta/Visuals/DeathHistory/Color", Value = Settings.Visuals.DeathHistory.Color,
            Callback = function(val) Settings.Visuals.DeathHistory.Color = val end})
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
-- ULTIMATE ESP SYSTEM (3D Box, Shifter, Pro HealthBar, Objects, Deaths)
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

-- Helper: convert HSV table to Color3
local function HSVToColor(hsv)
    return Color3.fromHSV(hsv[1] or 0, hsv[2] or 1, hsv[3] or 1)
end

-- Data for each player
local PlayerESPData = {}
local ShifterDebounce = {}

local function CreatePlayerESP(player)
    if PlayerESPData[player] then return end
    local data = {
        -- 12 линий для 3D бокса
        lines = {
            line1 = NewLine(), line2 = NewLine(), line3 = NewLine(), line4 = NewLine(),
            line5 = NewLine(), line6 = NewLine(), line7 = NewLine(), line8 = NewLine(),
            line9 = NewLine(), line10 = NewLine(), line11 = NewLine(), line12 = NewLine(),
            Tracer = NewLine()
        },
        -- Шифтер (плоскость)
        Shifter = NewQuad(),
        -- Хилбар (фон и заполнение)
        HealthBarBG = NewLine(),   -- чёрный фон
        HealthBarFill = NewLine(), -- цветная полоса
        debounce = 0,
        shifteroffset = 0,
        connection = nil
    }
    -- Настройка цветов по умолчанию
    data.HealthBarBG.Color = Color3.new(0,0,0)
    data.HealthBarBG.Thickness = 3
    data.HealthBarFill.Thickness = 3
    PlayerESPData[player] = data
end

local function RemovePlayerESP(player)
    local data = PlayerESPData[player]
    if not data then return end
    for _, line in pairs(data.lines) do
        line:Destroy()
    end
    data.Shifter:Destroy()
    data.HealthBarBG:Destroy()
    data.HealthBarFill:Destroy()
    PlayerESPData[player] = nil
end

-- Object ESP storage (unchanged)
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
    local maxDist = Settings.Visuals.General.MaxDistance
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

-- Death history (unchanged)
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

-- Main render loop
RunService.RenderStepped:Connect(function()
    if not Settings.Visuals.General.Enabled then
        -- Hide everything
        for _, data in pairs(PlayerESPData) do
            for _, line in pairs(data.lines) do line.Visible = false end
            data.Shifter.Visible = false
            data.HealthBarBG.Visible = false
            data.HealthBarFill.Visible = false
        end
        for _, list in ipairs({ItemESP, QuestESP, VehicleESP}) do
            for _, e in ipairs(list) do e.text.Visible = false end
        end
        for _, e in ipairs(DeathESP) do e.text.Visible = false end
        return
    end

    -- Update players
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer or Settings.Visuals.General.IncludeNPC then
            if not PlayerESPData[player] then CreatePlayerESP(player) end
            local data = PlayerESPData[player]
            if not data then continue end

            local char = player.Character
            if not char then
                for _, line in pairs(data.lines) do line.Visible = false end
                data.Shifter.Visible = false
                data.HealthBarBG.Visible = false
                data.HealthBarFill.Visible = false
                continue
            end

            local hum = char:FindFirstChildOfClass("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")

            if not hum or not root or not head then
                for _, line in pairs(data.lines) do line.Visible = false end
                data.Shifter.Visible = false
                data.HealthBarBG.Visible = false
                data.HealthBarFill.Visible = false
                continue
            end

            -- Check alive
            if not Settings.Visuals.DeadPlayers and hum.Health <= 0 then
                for _, line in pairs(data.lines) do line.Visible = false end
                data.Shifter.Visible = false
                data.HealthBarBG.Visible = false
                data.HealthBarFill.Visible = false
                continue
            end

            -- Check distance
            local dist = (root.Position - Camera.CFrame.Position).Magnitude
            if dist > Settings.Visuals.General.MaxDistance then
                for _, line in pairs(data.lines) do line.Visible = false end
                data.Shifter.Visible = false
                data.HealthBarBG.Visible = false
                data.HealthBarFill.Visible = false
                continue
            end

            -- Get screen position of root
            local pos, vis = Camera:WorldToViewportPoint(root.Position)
            if not vis then
                for _, line in pairs(data.lines) do line.Visible = false end
                data.Shifter.Visible = false
                data.HealthBarBG.Visible = false
                data.HealthBarFill.Visible = false
                continue
            end

            -- Calculate box size based on head size
            local scale = head.Size.Y / 2
            local size = Vector3.new(2, 3, 1.5) * (scale * 2)

            -- Compute 8 corners of the box
            local corners = {}
            local offsets = {
                {-size.X, size.Y, -size.Z},  -- Top1
                {-size.X, size.Y,  size.Z},  -- Top2
                { size.X, size.Y,  size.Z},  -- Top3
                { size.X, size.Y, -size.Z},  -- Top4
                {-size.X, -size.Y, -size.Z}, -- Bottom1
                {-size.X, -size.Y,  size.Z}, -- Bottom2
                { size.X, -size.Y,  size.Z}, -- Bottom3
                { size.X, -size.Y, -size.Z}  -- Bottom4
            }
            for i, off in ipairs(offsets) do
                local worldPoint = (root.CFrame * CFrame.new(unpack(off))).p
                corners[i] = Camera:WorldToViewportPoint(worldPoint)
            end

            -- Determine colors based on team check
            local boxColor, tracerColor, shifterColor, healthBarColor
            if Settings.Visuals.TeamCheck then
                local isEnemy = IsEnemy(player)
                local allyHSV = Settings.Visuals.AllyColor
                local enemyHSV = Settings.Visuals.EnemyColor
                boxColor = isEnemy and HSVToColor(enemyHSV) or HSVToColor(allyHSV)
                tracerColor = boxColor
                shifterColor = HSVToColor(Settings.Visuals.Shifter.Color)
                -- Для хилбара цвет будет зависеть от здоровья (градиент), не от команды
            else
                boxColor = HSVToColor(Settings.Visuals.Box.Color)
                tracerColor = HSVToColor(Settings.Visuals.Tracers.Color)
                shifterColor = HSVToColor(Settings.Visuals.Shifter.Color)
            end

            -- Update line positions
            local lines = data.lines

            -- Top edges
            lines.line1.From = Vector2.new(corners[1].X, corners[1].Y); lines.line1.To = Vector2.new(corners[2].X, corners[2].Y)
            lines.line2.From = Vector2.new(corners[2].X, corners[2].Y); lines.line2.To = Vector2.new(corners[3].X, corners[3].Y)
            lines.line3.From = Vector2.new(corners[3].X, corners[3].Y); lines.line3.To = Vector2.new(corners[4].X, corners[4].Y)
            lines.line4.From = Vector2.new(corners[4].X, corners[4].Y); lines.line4.To = Vector2.new(corners[1].X, corners[1].Y)

            -- Bottom edges
            lines.line5.From = Vector2.new(corners[5].X, corners[5].Y); lines.line5.To = Vector2.new(corners[6].X, corners[6].Y)
            lines.line6.From = Vector2.new(corners[6].X, corners[6].Y); lines.line6.To = Vector2.new(corners[7].X, corners[7].Y)
            lines.line7.From = Vector2.new(corners[7].X, corners[7].Y); lines.line7.To = Vector2.new(corners[8].X, corners[8].Y)
            lines.line8.From = Vector2.new(corners[8].X, corners[8].Y); lines.line8.To = Vector2.new(corners[5].X, corners[5].Y)

            -- Vertical edges
            lines.line9.From = Vector2.new(corners[5].X, corners[5].Y); lines.line9.To = Vector2.new(corners[1].X, corners[1].Y)
            lines.line10.From = Vector2.new(corners[6].X, corners[6].Y); lines.line10.To = Vector2.new(corners[2].X, corners[2].Y)
            lines.line11.From = Vector2.new(corners[7].X, corners[7].Y); lines.line11.To = Vector2.new(corners[3].X, corners[3].Y)
            lines.line12.From = Vector2.new(corners[8].X, corners[8].Y); lines.line12.To = Vector2.new(corners[4].X, corners[4].Y)

            -- Tracer
            if Settings.Visuals.Tracers.Enabled then
                local tracePos = Camera:WorldToViewportPoint((root.CFrame * CFrame.new(0, -size.Y, 0)).p)
                lines.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                lines.Tracer.To = Vector2.new(tracePos.X, tracePos.Y)
            end

            -- Auto thickness
            local thickness = Settings.Visuals.Box.Thickness
            if Settings.Visuals.AutoThickness then
                local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude) or 100
                thickness = math.clamp(1/distance*100, 0.1, 4)
            end

            -- Apply properties to lines
            for _, line in pairs(lines) do
                if line ~= lines.Tracer then
                    line.Color = boxColor
                    line.Thickness = thickness
                    line.Visible = Settings.Visuals.Box.Enabled
                else
                    line.Color = tracerColor
                    line.Thickness = Settings.Visuals.Tracers.Thickness
                    line.Visible = Settings.Visuals.Tracers.Enabled
                end
            end

            -- Shifter animation
            if Settings.Visuals.Shifter.Enabled then
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

            -- PROFESSIONAL HEALTH BAR (from Blissful)
            if Settings.Visuals.Health.Bar then
                -- Используем координаты бокса для позиционирования хилбара слева
                local minX = math.min(corners[1].X, corners[2].X, corners[3].X, corners[4].X, corners[5].X, corners[6].X, corners[7].X, corners[8].X)
                local maxY = math.max(corners[1].Y, corners[2].Y, corners[3].Y, corners[4].Y, corners[5].Y, corners[6].Y, corners[7].Y, corners[8].Y)
                local minY = math.min(corners[1].Y, corners[2].Y, corners[3].Y, corners[4].Y, corners[5].Y, corners[6].Y, corners[7].Y, corners[8].Y)

                -- Высота бокса
                local boxHeight = maxY - minY
                local healthPercent = hum.Health / hum.MaxHealth
                local fillHeight = boxHeight * healthPercent

                -- Позиция хилбара слева от бокса
                local barX = minX - 6

                -- Фон (чёрный)
                data.HealthBarBG.From = Vector2.new(barX, maxY)
                data.HealthBarBG.To = Vector2.new(barX, minY)
                data.HealthBarBG.Thickness = 4
                data.HealthBarBG.Visible = true

                -- Заполнение (цвет градиента от красного к зелёному)
                data.HealthBarFill.From = Vector2.new(barX, maxY)
                data.HealthBarFill.To = Vector2.new(barX, maxY - fillHeight)
                data.HealthBarFill.Thickness = 4
                -- Градиент: красный (0 здоровья) -> зелёный (100% здоровья)
                data.HealthBarFill.Color = Color3.new(1 - healthPercent, healthPercent, 0)
                data.HealthBarFill.Visible = true
            else
                data.HealthBarBG.Visible = false
                data.HealthBarFill.Visible = false
            end
        end
    end

    -- Update objects
    UpdateObjectESP(ItemESP, "ItemText")
    UpdateObjectESP(QuestESP, "QuestItems")
    UpdateObjectESP(VehicleESP, "Vehicles")
    UpdateDeathESP()
end)

-- Initialize objects (unchanged)
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

-- Connect death events (unchanged)
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

print("Data Hub - Project Delta (Ultimate ESP with Pro HealthBar) loaded")
