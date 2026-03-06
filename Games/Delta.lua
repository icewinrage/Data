-- Data Hub - Project Delta (Optimized ESP without chams/outlines)
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
            Color = {1, 1, 1, 0, false}
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
        ItemText = {
            Enabled = false,
            Color = {1, 1, 1, 0, false},
            Distance = 100
        },
        Skeleton = {
            Enabled = false,
            Color = {1, 1, 1, 0, false}
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
-- UI: VISUALS (упрощённые настройки)
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

    local SkeletonSection = VisualsTab:Section({Name = "Skeleton", Side = "Right"}) do
        SkeletonSection:Toggle({Name = "Enabled", Flag = "Delta/Visuals/Skeleton/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.Skeleton.Enabled = val end})
        SkeletonSection:Colorpicker({Name = "Color", Flag = "Delta/Visuals/Skeleton/Color", Value = Settings.Visuals.Skeleton.Color,
            Callback = function(val) Settings.Visuals.Skeleton.Color = val end})
    end

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
-- EFFICIENT ESP SYSTEM
-- ███████████████████████████████████████████████████████

-- ███████████████████████████████████████████████████████
-- CUSTOM ESP SYSTEM (PROFESSIONAL, AUTO-SCALE)
-- Основан на примере usbkillerx, полностью интегрирован в твой UI
-- ███████████████████████████████████████████████████████

-- Вспомогательные функции для рисования
local function newLine() return Drawing.new("Line") end
local function newText() return Drawing.new("Text") end
local function HSVToColor(hsv) return Color3.fromHSV(hsv[1] or 0, hsv[2] or 1, hsv[3] or 1) end
local function clamp(v, mn, mx) return math.max(mn, math.min(mx, v)) end

-- Точный 3D bounding box через 8 углов
local function GetBoundingBox(character)
    local cf, size = character:GetBoundingBox()
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
    local anyVisible = false

    for _, corner in ipairs(corners) do
        local world = cf:PointToWorldSpace(corner)
        local screen, visible = Camera:WorldToViewportPoint(world)
        if visible then
            anyVisible = true
            minX = math.min(minX, screen.X)
            minY = math.min(minY, screen.Y)
            maxX = math.max(maxX, screen.X)
            maxY = math.max(maxY, screen.Y)
        end
    end

    if not anyVisible then
        return nil
    end
    return minX, minY, maxX, maxY
end

-- Хранилища ESP
local PlayerESP = {}
local ItemESP = {}
local QuestESP = {}
local VehicleESP = {}
local DeathESP = {}
local DeathCounter = 0

-- Создание ESP для игрока
local function CreatePlayerESP(player)
    if PlayerESP[player] then return end
    local esp = {
        BoxLines = { newLine(), newLine(), newLine(), newLine() }, -- для Full бокса
        Name = newText(),
        Distance = newText(),
        Weapon = newText(),
        Tracer = newLine(),
        HealthBar = { newLine(), newLine() }, -- фон и заполнение
        SkeletonLines = {}
    }

    esp.Name.Size = 14; esp.Name.Center = true; esp.Name.Outline = true; esp.Name.Font = 2
    esp.Distance.Size = 12; esp.Distance.Center = true; esp.Distance.Outline = true; esp.Distance.Font = 2
    esp.Weapon.Size = 12; esp.Weapon.Center = true; esp.Weapon.Outline = true; esp.Weapon.Font = 2

    esp.Tracer.Thickness = 2

    esp.HealthBar[1].Thickness = 4; esp.HealthBar[1].Color = Color3.new(0,0,0)
    esp.HealthBar[2].Thickness = 4

    for i = 1, 12 do
        local line = newLine()
        line.Thickness = Settings.Visuals.Skeleton.Thickness
        esp.SkeletonLines[i] = line
    end

    PlayerESP[player] = esp
end

local function RemovePlayerESP(player)
    local esp = PlayerESP[player]
    if not esp then return end
    for _, l in ipairs(esp.BoxLines) do l:Destroy() end
    esp.Name:Destroy(); esp.Distance:Destroy(); esp.Weapon:Destroy()
    esp.Tracer:Destroy()
    for _, l in ipairs(esp.HealthBar) do l:Destroy() end
    for _, l in ipairs(esp.SkeletonLines) do l:Destroy() end
    PlayerESP[player] = nil
end

-- Создание ESP для объектов
local function CreateObjectESP(list, obj, part, name, flag)
    local text = newText()
    text.Size = 12; text.Center = true; text.Outline = true; text.Font = 2; text.Visible = false
    table.insert(list, { obj = obj, part = part, text = text, name = name, flag = flag })
end

-- Обновление ESP объектов
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

-- История смертей
local function OnPlayerDied(player)
    if not Settings.Visuals.DeathHistory.Enabled then return end
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    DeathCounter = DeathCounter + 1
    local text = newText()
    text.Size = 16; text.Center = true; text.Outline = true; text.Font = 2
    table.insert(DeathESP, { pos = root.Position, text = text, count = DeathCounter, time = tick() })
end

local function UpdateDeathESP()
    if not Settings.Visuals.DeathHistory.Enabled then
        for _, e in ipairs(DeathESP) do e.text.Visible = false end
        return
    end
    local color = HSVToColor(Settings.Visuals.DeathHistory.Color)
    local maxDist = Settings.Visuals.General.MaxDistance
    local duration = Settings.Visuals.DeathHistory.Duration
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

-- Обновление скелета
local function UpdateSkeleton(esp, char, color, thickness)
    local lines = esp.SkeletonLines
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

-- Обновление ESP игрока
local function UpdatePlayerESP(player)
    local esp = PlayerESP[player]
    if not esp then return end
    local char = player.Character
    if not char then
        for _, l in ipairs(esp.BoxLines) do l.Visible = false end
        esp.Name.Visible = false; esp.Distance.Visible = false; esp.Weapon.Visible = false
        esp.Tracer.Visible = false
        for _, l in ipairs(esp.HealthBar) do l.Visible = false end
        for _, l in ipairs(esp.SkeletonLines) do l.Visible = false end
        return
    end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then
        for _, l in ipairs(esp.BoxLines) do l.Visible = false end
        esp.Name.Visible = false; esp.Distance.Visible = false; esp.Weapon.Visible = false
        esp.Tracer.Visible = false
        for _, l in ipairs(esp.HealthBar) do l.Visible = false end
        for _, l in ipairs(esp.SkeletonLines) do l.Visible = false end
        return
    end

    local scr, onScr = Camera:WorldToViewportPoint(root.Position)
    if not onScr then
        for _, l in ipairs(esp.BoxLines) do l.Visible = false end
        esp.Name.Visible = false; esp.Distance.Visible = false; esp.Weapon.Visible = false
        esp.Tracer.Visible = false
        for _, l in ipairs(esp.HealthBar) do l.Visible = false end
        for _, l in ipairs(esp.SkeletonLines) do l.Visible = false end
        return
    end

    local dist = (root.Position - Camera.CFrame.Position).Magnitude
    if dist > Settings.Visuals.General.MaxDistance then
        for _, l in ipairs(esp.BoxLines) do l.Visible = false end
        esp.Name.Visible = false; esp.Distance.Visible = false; esp.Weapon.Visible = false
        esp.Tracer.Visible = false
        for _, l in ipairs(esp.HealthBar) do l.Visible = false end
        for _, l in ipairs(esp.SkeletonLines) do l.Visible = false end
        return
    end

    local health = GetRealHealth(player)  -- функция из Project Delta
    local healthPerc = health / 100
    local weapon = GetCurrentWeapon(player)

    -- Цвета из настроек
    local boxColor = HSVToColor(Settings.Visuals.Box.Color)
    local nameColor = HSVToColor(Settings.Visuals.Name.Color)
    local distColor = HSVToColor(Settings.Visuals.Distance.Color)
    local skeletonColor = HSVToColor(Settings.Visuals.Skeleton.Color)

    -- Динамический размер текста и толщины (auto-scale)
    local nameSize = clamp(16 * (1000 / math.max(dist, 100)), 10, 18)
    local distSize = clamp(14 * (1000 / math.max(dist, 100)), 8, 16)
    local weapSize = clamp(12 * (1000 / math.max(dist, 100)), 8, 14)
    local thickness = clamp(4 - dist/200, 1.5, 4)

    -- === Box (точный 3D) ===
    if Settings.Visuals.Box.Enabled then
        local bb = GetBoundingBox(char)
        if bb then
            local minX, minY, maxX, maxY = bb[1], bb[2], bb[3], bb[4]
            -- Минимальный размер, чтобы не пропадало вдали
            local w = math.max(maxX - minX, 20)
            local h = math.max(maxY - minY, 30)
            maxX = minX + w; maxY = minY + h

            local lines = esp.BoxLines
            if Settings.Visuals.Box.Style == "Corner" then
                -- можно добавить позже, пока Full
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
            end
        else
            for _, l in ipairs(esp.BoxLines) do l.Visible = false end
        end
    else
        for _, l in ipairs(esp.BoxLines) do l.Visible = false end
    end

    -- === Name ===
    if Settings.Visuals.Name.Enabled then
        esp.Name.Visible = true
        esp.Name.Text = player.Name
        esp.Name.Color = nameColor
        esp.Name.Size = nameSize
        esp.Name.Position = Vector2.new(scr.X, scr.Y - 50 - (nameSize-14))
    else
        esp.Name.Visible = false
    end

    -- === Distance ===
    if Settings.Visuals.Distance.Enabled then
        esp.Distance.Visible = true
        local unit = Settings.Visuals.Distance.Mode == "Meters" and "m" or "studs"
        esp.Distance.Text = string.format("%.0f %s", dist, unit)
        esp.Distance.Color = distColor
        esp.Distance.Size = distSize
        esp.Distance.Position = Vector2.new(scr.X, scr.Y + 30 + (distSize-12))
    else
        esp.Distance.Visible = false
    end

    -- === Weapon (используем ItemText как оружие) ===
    if Settings.Visuals.ItemText.Enabled and weapon ~= "" then
        esp.Weapon.Visible = true
        esp.Weapon.Text = weapon
        esp.Weapon.Color = nameColor
        esp.Weapon.Size = weapSize
        esp.Weapon.Position = Vector2.new(scr.X, scr.Y + 50 + (weapSize-12))
    else
        esp.Weapon.Visible = false
    end

    -- === Tracers ===
    if Settings.Visuals.Tracers.Enabled then
        local from = (Settings.Visuals.Tracers.Mode == "From Mouse") and UserInputService:GetMouseLocation() or Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
        esp.Tracer.From = from
        esp.Tracer.To = Vector2.new(scr.X, scr.Y)
        esp.Tracer.Color = boxColor
        esp.Tracer.Visible = true
    else
        esp.Tracer.Visible = false
    end

    -- === Health Bar (привязан к боксу) ===
    if Settings.Visuals.Health.Bar and Settings.Visuals.Box.Enabled then
        local bb = GetBoundingBox(char)
        if bb then
            local minX, minY, maxX, maxY = bb[1], bb[2], bb[3], bb[4]
            local w = math.max(maxX - minX, 20)
            local h = math.max(maxY - minY, 30)
            maxX = minX + w; maxY = minY + h

            local barX, barY, barW, barH
            if Settings.Visuals.Health.Position == "Left" then
                barX, barY, barW, barH = minX - 8, minY, 4, h
            elseif Settings.Visuals.Health.Position == "Right" then
                barX, barY, barW, barH = maxX + 4, minY, 4, h
            elseif Settings.Visuals.Health.Position == "Top" then
                barX, barY, barW, barH = minX, minY - 8, w, 4
            else -- Bottom
                barX, barY, barW, barH = minX, maxY + 4, w, 4
            end

            esp.HealthBar[1].From = Vector2.new(barX, barY)
            esp.HealthBar[1].To = Vector2.new(barX + barW, barY + barH)
            esp.HealthBar[1].Visible = true

            local fill = (barW > barH) and barW * healthPerc or barH * healthPerc
            if Settings.Visuals.Health.Position == "Left" then
                esp.HealthBar[2].From = Vector2.new(barX, barY + barH)
                esp.HealthBar[2].To = Vector2.new(barX + barW, barY + barH - fill)
            elseif Settings.Visuals.Health.Position == "Right" then
                esp.HealthBar[2].From = Vector2.new(barX, barY)
                esp.HealthBar[2].To = Vector2.new(barX + barW, barY + fill)
            elseif Settings.Visuals.Health.Position == "Top" then
                esp.HealthBar[2].From = Vector2.new(barX, barY)
                esp.HealthBar[2].To = Vector2.new(barX + fill, barY + barH)
            else -- Bottom
                esp.HealthBar[2].From = Vector2.new(barX + barW, barY)
                esp.HealthBar[2].To = Vector2.new(barX + barW - fill, barY + barH)
            end

            if Settings.Visuals.Health.ColorMode == "Green" then
                esp.HealthBar[2].Color = Color3.new(0,1,0)
            elseif Settings.Visuals.Health.ColorMode == "Red" then
                esp.HealthBar[2].Color = Color3.new(1,0,0)
            else -- RGB
                esp.HealthBar[2].Color = Color3.new(1 - healthPerc, healthPerc, 0)
            end
            esp.HealthBar[2].Visible = true
        else
            esp.HealthBar[1].Visible = false; esp.HealthBar[2].Visible = false
        end
    else
        esp.HealthBar[1].Visible = false; esp.HealthBar[2].Visible = false
    end

    -- === Skeleton ===
    if Settings.Visuals.Skeleton.Enabled then
        UpdateSkeleton(esp, char, skeletonColor, Settings.Visuals.Skeleton.Thickness)
    else
        for _, l in ipairs(esp.SkeletonLines) do l.Visible = false end
    end
end

-- Инициализация объектов
if workspace:FindFirstChild("Containers") then
    for _, c in ipairs(workspace.Containers:GetChildren()) do
        if c:IsA("Model") then
            local part = c.PrimaryPart or c:FindFirstChildWhichIsA("Part")
            if part then CreateObjectESP(ItemESP, c, part, c.Name, "ItemText") end
        end
    end
    workspace.Containers.ChildAdded:Connect(function(c)
        if c:IsA("Model") then
            local part = c.PrimaryPart or c:FindFirstChildWhichIsA("Part")
            if part then CreateObjectESP(ItemESP, c, part, c.Name, "ItemText") end
        end
    end)
end
if workspace:FindFirstChild("QuestItems") then
    for _, q in ipairs(workspace.QuestItems:GetChildren()) do
        if q:IsA("Model") then
            local part = q.PrimaryPart or q:FindFirstChildWhichIsA("Part")
            if part then CreateObjectESP(QuestESP, q, part, q.Name, "QuestItems") end
        end
    end
    workspace.QuestItems.ChildAdded:Connect(function(q)
        if q:IsA("Model") then
            local part = q.PrimaryPart or q:FindFirstChildWhichIsA("Part")
            if part then CreateObjectESP(QuestESP, q, part, q.Name, "QuestItems") end
        end
    end)
end
if workspace:FindFirstChild("Vehicles") then
    for _, v in ipairs(workspace.Vehicles:GetChildren()) do
        if v:IsA("Model") then
            local part = v.PrimaryPart or v:FindFirstChildWhichIsA("Part")
            if part then CreateObjectESP(VehicleESP, v, part, v.Name, "Vehicles") end
        end
    end
    workspace.Vehicles.ChildAdded:Connect(function(v)
        if v:IsA("Model") then
            local part = v.PrimaryPart or v:FindFirstChildWhichIsA("Part")
            if part then CreateObjectESP(VehicleESP, v, part, v.Name, "Vehicles") end
        end
    end)
end

-- Подключение ESP для игроков
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreatePlayerESP(player)
    end
end
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        CreatePlayerESP(player)
    end
end)
Players.PlayerRemoving:Connect(RemovePlayerESP)

-- Подключение событий смерти
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

-- Главный рендер-цикл
RunService.RenderStepped:Connect(function()
    if not Settings.Visuals.General.Enabled then
        -- Скрыть всё
        for _, esp in pairs(PlayerESP) do
            for _, l in ipairs(esp.BoxLines) do l.Visible = false end
            esp.Name.Visible = false; esp.Distance.Visible = false; esp.Weapon.Visible = false
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

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            UpdatePlayerESP(player)
        end
    end

    UpdateObjectESP(ItemESP, "ItemText")
    UpdateObjectESP(QuestESP, "QuestItems")
    UpdateObjectESP(VehicleESP, "Vehicles")
    UpdateDeathESP()
end)

print("✅ Custom ESP (auto‑scale, pro) загружен и готов к работе!")
