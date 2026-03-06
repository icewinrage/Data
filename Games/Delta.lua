-- Data Hub - Project Delta (UnnamedESP Integration)
-- Game ID: 2862098693
-- Features: RageBot, Gun Mods, World, Misc, and UnnamedESP (powerful ESP)
-- All ESP functionality is handled by UnnamedESP, fully integrated into Data Hub menu.

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
-- UI: VISUALS (UnnamedESP integration)
-- ███████████████████████████████████████████████████████
local VisualsTab = Window:Tab({Name = "Visuals"}) do
    -- Zoom Section (kept separate)
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

    -- UnnamedESP control section
    local UnnamedSection = VisualsTab:Section({Name = "Unnamed ESP", Side = "Left"}) do

        UnnamedSection:Toggle({
            Name = "Enable Unnamed ESP",
            Flag = "Delta/UnnamedESP/Enabled",
            Value = false,
            Callback = function(val)
                if not UnnamedESP_Loaded then
                    LoadUnnamedESPWithDeltaSupport()
                end
                if shared.UESP_Config then
                    shared.UESP_Config.Enabled = val
                end
            end
        })

        UnnamedSection:Toggle({
            Name = "Player Boxes",
            Flag = "Delta/UnnamedESP/Boxes",
            Value = true,
            Callback = function(val)
                if shared.UESP_Config then shared.UESP_Config.Boxes = val end
            end
        })

        UnnamedSection:Toggle({
            Name = "Player Names",
            Flag = "Delta/UnnamedESP/Names",
            Value = true,
            Callback = function(val)
                if shared.UESP_Config then shared.UESP_Config.Names = val end
            end
        })

        UnnamedSection:Toggle({
            Name = "Player Health",
            Flag = "Delta/UnnamedESP/Health",
            Value = true,
            Callback = function(val)
                if shared.UESP_Config then shared.UESP_Config.Health = val end
            end
        })

        UnnamedSection:Toggle({
            Name = "Player Weapons",
            Flag = "Delta/UnnamedESP/Weapons",
            Value = true,
            Callback = function(val)
                if shared.UESP_Config then shared.UESP_Config.Weapons = val end
            end
        })

        UnnamedSection:Toggle({
            Name = "Player Distance",
            Flag = "Delta/UnnamedESP/Distance",
            Value = true,
            Callback = function(val)
                if shared.UESP_Config then shared.UESP_Config.Distance = val end
            end
        })

        UnnamedSection:Toggle({
            Name = "Skeleton",
            Flag = "Delta/UnnamedESP/Skeleton",
            Value = false,
            Callback = function(val)
                if shared.UESP_Config then shared.UESP_Config.Skeleton = val end
            end
        })

        UnnamedSection:Toggle({
            Name = "Tracers",
            Flag = "Delta/UnnamedESP/Tracers",
            Value = false,
            Callback = function(val)
                if shared.UESP_Config then shared.UESP_Config.Tracers = val end
            end
        })

        UnnamedSection:Divider({Text = "Object ESP"})

        UnnamedSection:Toggle({
            Name = "Item Text (Containers)",
            Flag = "Delta/UnnamedESP/ItemText",
            Value = false,
            Callback = function(val)
                if shared.UESP_Config then shared.UESP_Config.ItemText = val end
            end
        })

        UnnamedSection:Toggle({
            Name = "Quest Items",
            Flag = "Delta/UnnamedESP/QuestItems",
            Value = false,
            Callback = function(val)
                if shared.UESP_Config then shared.UESP_Config.QuestItems = val end
            end
        })

        UnnamedSection:Toggle({
            Name = "Vehicles",
            Flag = "Delta/UnnamedESP/Vehicles",
            Value = false,
            Callback = function(val)
                if shared.UESP_Config then shared.UESP_Config.Vehicles = val end
            end
        })

        UnnamedSection:Divider({Text = "Colors"})

        UnnamedSection:Colorpicker({
            Name = "Ally Color",
            Flag = "Delta/UnnamedESP/AllyColor",
            Value = {0, 1, 0, 0, false},
            Callback = function(hsv, color)
                if shared.UESP_Config then shared.UESP_Config.AllyColor = color end
            end
        })

        UnnamedSection:Colorpicker({
            Name = "Enemy Color",
            Flag = "Delta/UnnamedESP/EnemyColor",
            Value = {1, 0, 0, 0, false},
            Callback = function(hsv, color)
                if shared.UESP_Config then shared.UESP_Config.EnemyColor = color end
            end
        })

        UnnamedSection:Colorpicker({
            Name = "Item Color",
            Flag = "Delta/UnnamedESP/ItemColor",
            Value = {0.5, 1, 0.5, 0, false},
            Callback = function(hsv, color)
                if shared.UESP_Config then shared.UESP_Config.ItemColor = color end
            end
        })

        UnnamedSection:Colorpicker({
            Name = "Quest Color",
            Flag = "Delta/UnnamedESP/QuestColor",
            Value = {0.2, 0.8, 1, 0, false},
            Callback = function(hsv, color)
                if shared.UESP_Config then shared.UESP_Config.QuestColor = color end
            end
        })

        UnnamedSection:Colorpicker({
            Name = "Vehicle Color",
            Flag = "Delta/UnnamedESP/VehicleColor",
            Value = {1, 0.5, 0, 0, false},
            Callback = function(hsv, color)
                if shared.UESP_Config then shared.UESP_Config.VehicleColor = color end
            end
        })

        UnnamedSection:Button({
            Name = "Reload Unnamed ESP",
            Callback = function()
                if UnnamedESP_Loaded then
                    UnnamedESP_Loaded = false
                end
                LoadUnnamedESPWithDeltaSupport()
            end
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
-- PROJECT DELTA SPECIFIC FUNCTIONS (for RageBot etc.)
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

-- (Aimbot/Trigger logic can be added here if needed, but not required for ESP)

-- ███████████████████████████████████████████████████████
-- СОБСТВЕННЫЙ ESP (оптимизированный, красивый)
-- ███████████████████████████████████████████████████████

-- Настройки ESP (будут связаны с UI)
local ESP_Settings = {
    Enabled = false,
    Box = false,
    Name = false,
    Distance = false,
    Health = false,
    Tracer = false,
    Skeleton = false,
    Items = false,
    Quests = false,
    Vehicles = false,
    Deaths = false,
    MaxDistance = 1000,
    BoxColor = Color3.new(1, 1, 1),
    NameColor = Color3.new(1, 1, 1),
    DistanceColor = Color3.new(1, 1, 1),
    HealthColor = Color3.new(0, 1, 0),
    TracerColor = Color3.new(1, 1, 1),
    SkeletonColor = Color3.new(1, 1, 1),
    ItemColor = Color3.new(0, 1, 0),
    QuestColor = Color3.new(0, 1, 1),
    VehicleColor = Color3.new(1, 0.5, 0),
    DeathColor = Color3.new(1, 0, 0)
}

-- Связываем с флагами UI (эти флаги должны быть созданы в VisualsTab)
local function UpdateESPFromUI()
    ESP_Settings.Enabled = Window.Flags["Delta/ESP/Enabled"]
    ESP_Settings.Box = Window.Flags["Delta/ESP/Box"]
    ESP_Settings.Name = Window.Flags["Delta/ESP/Name"]
    ESP_Settings.Distance = Window.Flags["Delta/ESP/Distance"]
    ESP_Settings.Health = Window.Flags["Delta/ESP/Health"]
    ESP_Settings.Tracer = Window.Flags["Delta/ESP/Tracer"]
    ESP_Settings.Skeleton = Window.Flags["Delta/ESP/Skeleton"]
    ESP_Settings.Items = Window.Flags["Delta/ESP/Items"]
    ESP_Settings.Quests = Window.Flags["Delta/ESP/Quests"]
    ESP_Settings.Vehicles = Window.Flags["Delta/ESP/Vehicles"]
    ESP_Settings.Deaths = Window.Flags["Delta/ESP/Deaths"]
    ESP_Settings.MaxDistance = Window.Flags["Delta/ESP/MaxDistance"]
    -- цвета можно обновлять через колбэки Colorpicker, поэтому здесь не нужно
end

-- Хранилище объектов рисования для игроков
local PlayerDrawings = {}
local function CreatePlayerDrawings(player)
    if PlayerDrawings[player] then return end
    local drawings = {
        BoxLines = { Drawing.new("Line"), Drawing.new("Line"), Drawing.new("Line"), Drawing.new("Line") },
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Tracer = Drawing.new("Line"),
        HealthBar = { Drawing.new("Line"), Drawing.new("Line") },
        SkeletonLines = {}
    }
    -- Настройка текста
    drawings.Name.Size = 16
    drawings.Name.Center = true
    drawings.Name.Outline = true
    drawings.Name.Font = 2
    drawings.Distance.Size = 14
    drawings.Distance.Center = true
    drawings.Distance.Outline = true
    drawings.Distance.Font = 2
    -- Настройка линий
    for _, line in ipairs(drawings.BoxLines) do
        line.Thickness = 2
        line.Visible = false
    end
    drawings.Tracer.Thickness = 2
    drawings.Tracer.Visible = false
    drawings.HealthBar[1].Thickness = 3
    drawings.HealthBar[1].Color = Color3.new(0,0,0)
    drawings.HealthBar[1].Visible = false
    drawings.HealthBar[2].Thickness = 3
    drawings.HealthBar[2].Visible = false
    -- Создание линий скелета (14 линий для R15)
    for i = 1, 14 do
        local line = Drawing.new("Line")
        line.Thickness = 2
        line.Visible = false
        drawings.SkeletonLines[i] = line
    end
    PlayerDrawings[player] = drawings
end

local function RemovePlayerDrawings(player)
    local d = PlayerDrawings[player]
    if not d then return end
    for _, line in ipairs(d.BoxLines) do line:Remove() end
    d.Name:Remove()
    d.Distance:Remove()
    d.Tracer:Remove()
    for _, line in ipairs(d.HealthBar) do line:Remove() end
    for _, line in ipairs(d.SkeletonLines) do line:Remove() end
    PlayerDrawings[player] = nil
end

-- Функция получения позиции части тела с проверкой
local function GetPartPosition(part)
    if not part then return nil end
    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
    if onScreen then return Vector2.new(pos.X, pos.Y) end
    return nil
end

-- Обновление ESP для конкретного игрока
local function UpdatePlayerESP(player)
    local d = PlayerDrawings[player]
    if not d then return end

    local char = player.Character
    if not char then
        -- Скрыть всё
        for _, line in ipairs(d.BoxLines) do line.Visible = false end
        d.Name.Visible = false
        d.Distance.Visible = false
        d.Tracer.Visible = false
        for _, line in ipairs(d.HealthBar) do line.Visible = false end
        for _, line in ipairs(d.SkeletonLines) do line.Visible = false end
        return
    end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then
        for _, line in ipairs(d.BoxLines) do line.Visible = false end
        d.Name.Visible = false
        d.Distance.Visible = false
        d.Tracer.Visible = false
        for _, line in ipairs(d.HealthBar) do line.Visible = false end
        for _, line in ipairs(d.SkeletonLines) do line.Visible = false end
        return
    end

    local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
    if not onScreen then
        for _, line in ipairs(d.BoxLines) do line.Visible = false end
        d.Name.Visible = false
        d.Distance.Visible = false
        d.Tracer.Visible = false
        for _, line in ipairs(d.HealthBar) do line.Visible = false end
        for _, line in ipairs(d.SkeletonLines) do line.Visible = false end
        return
    end

    local dist = (root.Position - Camera.CFrame.Position).Magnitude
    if dist > ESP_Settings.MaxDistance then
        for _, line in ipairs(d.BoxLines) do line.Visible = false end
        d.Name.Visible = false
        d.Distance.Visible = false
        d.Tracer.Visible = false
        for _, line in ipairs(d.HealthBar) do line.Visible = false end
        for _, line in ipairs(d.SkeletonLines) do line.Visible = false end
        return
    end

    local health = GetRealHealth(player)
    local healthPercent = health / 100
    local isEnemy = IsEnemy(player)
    local boxColor = isEnemy and ESP_Settings.BoxColor or ESP_Settings.BoxColor -- можно разные цвета позже

    -- Бокс
    if ESP_Settings.Box then
        local size = char:GetExtentsSize()
        local projSize = (size * Camera.ViewportSize.Y) / (2 * dist * math.tan(math.rad(Camera.FieldOfView)/2))
        local w = math.clamp(projSize.X, 20, 150)
        local h = math.clamp(projSize.Y, 30, 200)
        local pos = Vector2.new(screenPos.X - w/2, screenPos.Y - h/2)
        local lines = d.BoxLines
        lines[1].From = pos
        lines[1].To = pos + Vector2.new(w, 0)
        lines[1].Color = boxColor
        lines[1].Visible = true
        lines[2].From = pos + Vector2.new(w, 0)
        lines[2].To = pos + Vector2.new(w, h)
        lines[2].Color = boxColor
        lines[2].Visible = true
        lines[3].From = pos + Vector2.new(w, h)
        lines[3].To = pos + Vector2.new(0, h)
        lines[3].Color = boxColor
        lines[3].Visible = true
        lines[4].From = pos + Vector2.new(0, h)
        lines[4].To = pos
        lines[4].Color = boxColor
        lines[4].Visible = true
    else
        for _, line in ipairs(d.BoxLines) do line.Visible = false end
    end

    -- Имя
    if ESP_Settings.Name then
        d.Name.Visible = true
        d.Name.Text = player.Name
        d.Name.Color = ESP_Settings.NameColor
        d.Name.Position = Vector2.new(screenPos.X, screenPos.Y - 50)
    else
        d.Name.Visible = false
    end

    -- Дистанция
    if ESP_Settings.Distance then
        d.Distance.Visible = true
        d.Distance.Text = string.format("%.0f studs", dist)
        d.Distance.Color = ESP_Settings.DistanceColor
        d.Distance.Position = Vector2.new(screenPos.X, screenPos.Y + 30)
    else
        d.Distance.Visible = false
    end

    -- Трейсер
    if ESP_Settings.Tracer then
        local fromPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        d.Tracer.From = fromPos
        d.Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
        d.Tracer.Color = ESP_Settings.TracerColor
        d.Tracer.Visible = true
    else
        d.Tracer.Visible = false
    end

    -- Хилбар
    if ESP_Settings.Health and ESP_Settings.Box then
        local size = char:GetExtentsSize()
        local projSize = (size * Camera.ViewportSize.Y) / (2 * dist * math.tan(math.rad(Camera.FieldOfView)/2))
        local h = math.clamp(projSize.Y, 30, 200)
        local w = math.clamp(projSize.X, 20, 150)
        local pos = Vector2.new(screenPos.X - w/2, screenPos.Y - h/2)
        local barX = pos.X - 8
        local barY = pos.Y
        d.HealthBar[1].From = Vector2.new(barX, barY)
        d.HealthBar[1].To = Vector2.new(barX, barY + h)
        d.HealthBar[1].Visible = true
        local fillH = h * healthPercent
        d.HealthBar[2].From = Vector2.new(barX, barY + h)
        d.HealthBar[2].To = Vector2.new(barX, barY + h - fillH)
        d.HealthBar[2].Color = ESP_Settings.HealthColor
        d.HealthBar[2].Visible = true
    else
        for _, line in ipairs(d.HealthBar) do line.Visible = false end
    end

    -- Скелет (упрощённый, только основные кости)
    if ESP_Settings.Skeleton then
        local head = char:FindFirstChild("Head")
        local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
        local rarm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightUpperArm")
        local larm = char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftUpperArm")
        local rleg = char:FindFirstChild("Right Leg") or char:FindFirstChild("RightUpperLeg")
        local lleg = char:FindFirstChild("Left Leg") or char:FindFirstChild("LeftUpperLeg")
        local rhand = char:FindFirstChild("RightHand")
        local lhand = char:FindFirstChild("LeftHand")
        local rfoot = char:FindFirstChild("RightFoot")
        local lfoot = char:FindFirstChild("LeftFoot")

        local lines = d.SkeletonLines
        local idx = 1
        local function addLine(a, b)
            if a and b then
                lines[idx].From = a
                lines[idx].To = b
                lines[idx].Color = ESP_Settings.SkeletonColor
                lines[idx].Visible = true
                idx = idx + 1
            end
        end

        local headPos = GetPartPosition(head)
        local torsoPos = GetPartPosition(torso)
        local rarmPos = GetPartPosition(rarm)
        local larmPos = GetPartPosition(larm)
        local rlegPos = GetPartPosition(rleg)
        local llegPos = GetPartPosition(lleg)
        local rhandPos = GetPartPosition(rhand)
        local lhandPos = GetPartPosition(lhand)
        local rfootPos = GetPartPosition(rfoot)
        local lfootPos = GetPartPosition(lfoot)

        addLine(headPos, torsoPos)
        addLine(torsoPos, rarmPos)
        addLine(torsoPos, larmPos)
        addLine(rarmPos, rhandPos)
        addLine(larmPos, lhandPos)
        addLine(torsoPos, rlegPos)
        addLine(torsoPos, llegPos)
        addLine(rlegPos, rfootPos)
        addLine(llegPos, lfootPos)

        -- Скрыть неиспользованные линии
        while idx <= #lines do
            lines[idx].Visible = false
            idx = idx + 1
        end
    else
        for _, line in ipairs(d.SkeletonLines) do line.Visible = false end
    end
end

-- ESP для объектов (предметы, квесты, машины)
local ObjectDrawings = {}
local function AddObjectDrawing(obj, category)
    if ObjectDrawings[obj] then return end
    local text = Drawing.new("Text")
    text.Size = 14
    text.Center = true
    text.Outline = true
    text.Font = 2
    text.Visible = false
    ObjectDrawings[obj] = { Text = text, Category = category, Obj = obj }
end

local function UpdateObjectESP()
    for obj, data in pairs(ObjectDrawings) do
        local enabled = false
        local color = ESP_Settings.ItemColor
        if data.Category == "Item" then
            enabled = ESP_Settings.Items
            color = ESP_Settings.ItemColor
        elseif data.Category == "Quest" then
            enabled = ESP_Settings.Quests
            color = ESP_Settings.QuestColor
        elseif data.Category == "Vehicle" then
            enabled = ESP_Settings.Vehicles
            color = ESP_Settings.VehicleColor
        end

        if not enabled or not obj or not obj.Parent then
            data.Text.Visible = false
            continue
        end

        local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("Part")
        if not part then
            data.Text.Visible = false
            continue
        end

        local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then
            data.Text.Visible = false
            continue
        end

        local dist = (part.Position - Camera.CFrame.Position).Magnitude
        if dist > ESP_Settings.MaxDistance then
            data.Text.Visible = false
            continue
        end

        data.Text.Visible = true
        data.Text.Text = obj.Name .. string.format(" [%.0f]", dist)
        data.Text.Color = color
        data.Text.Position = Vector2.new(pos.X, pos.Y)
    end
end

-- Death History ESP
local DeathDrawings = {}
local DeathCounter = 0
local function OnPlayerDied(player)
    if not ESP_Settings.Deaths then return end
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    DeathCounter = DeathCounter + 1
    local text = Drawing.new("Text")
    text.Size = 18
    text.Center = true
    text.Outline = true
    text.Font = 2
    text.Color = ESP_Settings.DeathColor
    text.Text = "☠️ " .. DeathCounter
    table.insert(DeathDrawings, { Text = text, Pos = root.Position, Time = tick() })
end

local function UpdateDeathESP()
    for i = #DeathDrawings, 1, -1 do
        local entry = DeathDrawings[i]
        if tick() - entry.Time > 60 then -- удалять через 60 секунд
            entry.Text:Remove()
            table.remove(DeathDrawings, i)
        else
            local pos, onScreen = Camera:WorldToViewportPoint(entry.Pos)
            if onScreen then
                local dist = (entry.Pos - Camera.CFrame.Position).Magnitude
                if dist <= ESP_Settings.MaxDistance then
                    entry.Text.Visible = true
                    entry.Text.Position = Vector2.new(pos.X, pos.Y)
                else
                    entry.Text.Visible = false
                end
            else
                entry.Text.Visible = false
            end
        end
    end
end

-- Подключение событий смерти
local function HookPlayerDeath(player)
    if player == LocalPlayer then return end
    local function onCharAdded(char)
        local hum = char:WaitForChild("Humanoid")
        hum.Died:Connect(function()
            OnPlayerDied(player)
        end)
    end
    if player.Character then
        onCharAdded(player.Character)
    end
    player.CharacterAdded:Connect(onCharAdded)
end

for _, p in ipairs(Players:GetPlayers()) do HookPlayerDeath(p) end
Players.PlayerAdded:Connect(HookPlayerDeath)

-- Сканирование объектов при старте и при добавлении
local function ScanContainers()
    if Workspace:FindFirstChild("Containers") then
        for _, obj in ipairs(Workspace.Containers:GetChildren()) do
            if obj:IsA("Model") then
                AddObjectDrawing(obj, "Item")
            end
        end
    end
end

local function ScanQuests()
    if Workspace:FindFirstChild("QuestItems") then
        for _, obj in ipairs(Workspace.QuestItems:GetChildren()) do
            if obj:IsA("Model") then
                AddObjectDrawing(obj, "Quest")
            end
        end
    end
end

local function ScanVehicles()
    if Workspace:FindFirstChild("Vehicles") then
        for _, obj in ipairs(Workspace.Vehicles:GetChildren()) do
            if obj:IsA("Model") then
                AddObjectDrawing(obj, "Vehicle")
            end
        end
    end
end

ScanContainers()
ScanQuests()
ScanVehicles()

Workspace.ChildAdded:Connect(function(child)
    if child.Name == "Containers" then
        child.ChildAdded:Connect(function(obj)
            if obj:IsA("Model") then AddObjectDrawing(obj, "Item") end
        end)
    elseif child.Name == "QuestItems" then
        child.ChildAdded:Connect(function(obj)
            if obj:IsA("Model") then AddObjectDrawing(obj, "Quest") end
        end)
    elseif child.Name == "Vehicles" then
        child.ChildAdded:Connect(function(obj)
            if obj:IsA("Model") then AddObjectDrawing(obj, "Vehicle") end
        end)
    end
end)

-- Главный цикл обновления
RunService.RenderStepped:Connect(function()
    if not ESP_Settings.Enabled then
        -- Скрыть всё
        for _, d in pairs(PlayerDrawings) do
            for _, line in ipairs(d.BoxLines) do line.Visible = false end
            d.Name.Visible = false
            d.Distance.Visible = false
            d.Tracer.Visible = false
            for _, line in ipairs(d.HealthBar) do line.Visible = false end
            for _, line in ipairs(d.SkeletonLines) do line.Visible = false end
        end
        for _, d in pairs(ObjectDrawings) do d.Text.Visible = false end
        for _, d in ipairs(DeathDrawings) do d.Text.Visible = false end
        return
    end

    -- Обновить игроков
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not PlayerDrawings[player] then
                CreatePlayerDrawings(player)
            end
            UpdatePlayerESP(player)
        end
    end

    -- Обновить объекты
    UpdateObjectESP()
    UpdateDeathESP()
end)

-- Очистка при удалении игрока
Players.PlayerRemoving:Connect(RemovePlayerDrawings)

print("Custom ESP loaded successfully")
