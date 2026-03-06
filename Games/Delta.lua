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
-- UTILITY FUNCTIONS
-- ███████████████████████████████████████████████████████

local function HSVToColor(hsv)
    return Color3.fromHSV(hsv[1] or 0, hsv[2] or 1, hsv[3] or 1)
end

-- Professional 3D Bounding Box Projection
local function GetBoundingBox(character)
    if not character then return math.huge, math.huge, -math.huge, -math.huge end
    local cf, size = character:GetBoundingBox()
    local corners = {
        cf:PointToWorldSpace(Vector3.new(-size.X/2, -size.Y/2, -size.Z/2)),
        cf:PointToWorldSpace(Vector3.new(-size.X/2, -size.Y/2, size.Z/2)),
        cf:PointToWorldSpace(Vector3.new(-size.X/2, size.Y/2, -size.Z/2)),
        cf:PointToWorldSpace(Vector3.new(-size.X/2, size.Y/2, size.Z/2)),
        cf:PointToWorldSpace(Vector3.new(size.X/2, -size.Y/2, -size.Z/2)),
        cf:PointToWorldSpace(Vector3.new(size.X/2, -size.Y/2, size.Z/2)),
        cf:PointToWorldSpace(Vector3.new(size.X/2, size.Y/2, -size.Z/2)),
        cf:PointToWorldSpace(Vector3.new(size.X/2, size.Y/2, size.Z/2)),
    }
    local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
    local anyVisible = false
    for _, world in ipairs(corners) do
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
        return math.huge, math.huge, -math.huge, -math.huge
    end
    -- Smart Distance Scaling: Enforce minimum size
    local width = maxX - minX
    local height = maxY - minY
    if width < Settings.Visuals.Dynamic.MinBoxSize then
        local expand = (Settings.Visuals.Dynamic.MinBoxSize - width) / 2
        minX = minX - expand
        maxX = maxX + expand
    end
    if height < Settings.Visuals.Dynamic.MinBoxSize then
        local expand = (Settings.Visuals.Dynamic.MinBoxSize - height) / 2
        minY = minY - expand
        maxY = maxY + expand
    end
    return minX, minY, maxX, maxY
end

-- ███████████████████████████████████████████████████████
-- DRAWING POOL (for FPS boost - reuse drawings instead of creating/destroying)
-- ███████████████████████████████████████████████████████

local DrawingPool = {
    Lines = {},
    Texts = {},
    Highlights = {},
}

local function GetPooledLine()
    if #DrawingPool.Lines > 0 then
        return table.remove(DrawingPool.Lines)
    end
    return Drawing.new("Line")
end

local function ReturnPooledLine(line)
    line.Visible = false
    table.insert(DrawingPool.Lines, line)
end

local function GetPooledText()
    if #DrawingPool.Texts > 0 then
        return table.remove(DrawingPool.Texts)
    end
    local text = Drawing.new("Text")
    text.Size = 14
    text.Center = true
    text.Outline = true
    text.Font = 2
    return text
end

local function ReturnPooledText(text)
    text.Visible = false
    table.insert(DrawingPool.Texts, text)
end

local function GetPooledHighlight()
    if #DrawingPool.Highlights > 0 then
        return table.remove(DrawingPool.Highlights)
    end
    local highlight = Instance.new("Highlight")
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = Workspace
    return highlight
end

local function ReturnPooledHighlight(highlight)
    highlight.Enabled = false
    highlight.Adornee = nil
    table.insert(DrawingPool.Highlights, highlight)
end

-- ███████████████████████████████████████████████████████
-- PLAYER ESP MANAGEMENT
-- ███████████████████████████████████████████████████████

local PlayerESP = {}

local function CreatePlayerESP(player)
    if PlayerESP[player] then return end
    local esp = {
        BoxLines = {},  -- Will be populated dynamically for full or corner
        Name = GetPooledText(),
        Distance = GetPooledText(),
        Tracer = GetPooledLine(),
        HealthBar = {GetPooledLine(), GetPooledLine()},  -- Background, Fill
        SkeletonLines = {},
        Cham = GetPooledHighlight(),
        ActiveLines = 0,  -- Track how many lines are in use
    }
    -- Pre-allocate lines for max (12 for skeleton + 8 for corner box + 1 tracer + 2 health)
    for _ = 1, 23 do
        table.insert(esp.SkeletonLines, GetPooledLine())  -- Reuse for all lines
    end
    esp.Name.Size = 14
    esp.Distance.Size = 12
    esp.Tracer.Thickness = 1  -- Will be dynamic
    esp.HealthBar[1].Thickness = 3  -- Background
    esp.HealthBar[2].Thickness = 3  -- Fill
    PlayerESP[player] = esp
end

local function RemovePlayerESP(player)
    local esp = PlayerESP[player]
    if not esp then return end
    ReturnPooledText(esp.Name)
    ReturnPooledText(esp.Distance)
    ReturnPooledLine(esp.Tracer)
    ReturnPooledLine(esp.HealthBar[1])
    ReturnPooledLine(esp.HealthBar[2])
    for _, line in ipairs(esp.SkeletonLines) do
        ReturnPooledLine(line)
    end
    ReturnPooledHighlight(esp.Cham)
    PlayerESP[player] = nil
end

local function UpdatePlayerESP(player)
    local esp = PlayerESP[player]
    if not esp then return end

    local char = player.Character
    if not char or not Settings.Visuals.General.Enabled then
        esp.Name.Visible = false
        esp.Distance.Visible = false
        esp.Tracer.Visible = false
        esp.HealthBar[1].Visible = false
        esp.HealthBar[2].Visible = false
        esp.Cham.Enabled = false
        for i = 1, esp.ActiveLines do
            esp.SkeletonLines[i].Visible = false
        end
        esp.ActiveLines = 0
        return
    end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then
        -- Hide all
        esp.Name.Visible = false
        esp.Distance.Visible = false
        esp.Tracer.Visible = false
        esp.HealthBar[1].Visible = false
        esp.HealthBar[2].Visible = false
        esp.Cham.Enabled = false
        for i = 1, esp.ActiveLines do
            esp.SkeletonLines[i].Visible = false
        end
        esp.ActiveLines = 0
        return
    end

    local dist = (root.Position - Camera.CFrame.Position).Magnitude
    if dist > Settings.Visuals.General.MaxDistance then
        -- Hide all
        esp.Name.Visible = false
        esp.Distance.Visible = false
        esp.Tracer.Visible = false
        esp.HealthBar[1].Visible = false
        esp.HealthBar[2].Visible = false
        esp.Cham.Enabled = false
        for i = 1, esp.ActiveLines do
            esp.SkeletonLines[i].Visible = false
        end
        esp.ActiveLines = 0
        return
    end

    local minX, minY, maxX, maxY = GetBoundingBox(char)
    if minX == math.huge then
        -- Not visible
        esp.Name.Visible = false
        esp.Distance.Visible = false
        esp.Tracer.Visible = false
        esp.HealthBar[1].Visible = false
        esp.HealthBar[2].Visible = false
        esp.Cham.Enabled = false
        for i = 1, esp.ActiveLines do
            esp.SkeletonLines[i].Visible = false
        end
        esp.ActiveLines = 0
        return
    end

    local boxPos = Vector2.new(minX, minY)
    local boxSize = Vector2.new(maxX - minX, maxY - minY)
    local centerX = (minX + maxX) / 2
    local centerY = (minY + maxY) / 2
    local screenCenter = Vector2.new(centerX, centerY)

    local isEnemy = IsEnemy(player)
    local health = GetRealHealth(player)
    local healthPercent = health / 100

    local boxColor = HSVToColor(Settings.Visuals.Box.Color)
    local nameColor = HSVToColor(Settings.Visuals.Name.Color)
    local distanceColor = HSVToColor(Settings.Visuals.Distance.Color)
    local skeletonColor = HSVToColor(Settings.Visuals.Skeleton.Color)

    -- Dynamic Thickness
    local thickness = math.max(1, Settings.Visuals.Dynamic.ThicknessBase / (dist / Settings.Visuals.Dynamic.ThicknessScale))

    -- Box (Full or Corner)
    esp.ActiveLines = 0
    if Settings.Visuals.Box.Enabled then
        local lines = esp.SkeletonLines  -- Reuse pool for box lines
        if Settings.Visuals.Box.Mode == "Corner" then
            local cornerLenX = boxSize.X * Settings.Visuals.Box.CornerLength
            local cornerLenY = boxSize.Y * Settings.Visuals.Box.CornerLength
            -- Top-left corners
            lines[1].From = Vector2.new(minX, minY)
            lines[1].To = Vector2.new(minX + cornerLenX, minY)
            lines[2].From = Vector2.new(minX, minY)
            lines[2].To = Vector2.new(minX, minY + cornerLenY)
            -- Top-right
            lines[3].From = Vector2.new(maxX - cornerLenX, minY)
            lines[3].To = Vector2.new(maxX, minY)
            lines[4].From = Vector2.new(maxX, minY)
            lines[4].To = Vector2.new(maxX, minY + cornerLenY)
            -- Bottom-left
            lines[5].From = Vector2.new(minX, maxY - cornerLenY)
            lines[5].To = Vector2.new(minX, maxY)
            lines[6].From = Vector2.new(minX, maxY)
            lines[6].To = Vector2.new(minX + cornerLenX, maxY)
            -- Bottom-right
            lines[7].From = Vector2.new(maxX, maxY - cornerLenY)
            lines[7].To = Vector2.new(maxX, maxY)
            lines[8].From = Vector2.new(maxX - cornerLenX, maxY)
            lines[8].To = Vector2.new(maxX, maxY)
            esp.ActiveLines = 8
        else  -- Full Box
            lines[1].From = Vector2.new(minX, minY)
            lines[1].To = Vector2.new(maxX, minY)
            lines[2].From = Vector2.new(maxX, minY)
            lines[2].To = Vector2.new(maxX, maxY)
            lines[3].From = Vector2.new(maxX, maxY)
            lines[3].To = Vector2.new(minX, maxY)
            lines[4].From = Vector2.new(minX, maxY)
            lines[4].To = Vector2.new(minX, minY)
            esp.ActiveLines = 4
        end
        for i = 1, esp.ActiveLines do
            lines[i].Color = boxColor
            lines[i].Thickness = thickness
            lines[i].Visible = true
        end
    end

    -- Name
    if Settings.Visuals.Name.Enabled then
        esp.Name.Visible = true
        esp.Name.Text = player.Name
        esp.Name.Color = nameColor
        esp.Name.Position = Vector2.new(centerX, minY - 16)  -- Above box
    else
        esp.Name.Visible = false
    end

    -- Distance
    if Settings.Visuals.Distance.Enabled then
        esp.Distance.Visible = true
        local unit = Settings.Visuals.Distance.Mode == "Meters" and "m" or "studs"
        esp.Distance.Text = string.format("%.0f %s", dist, unit)
        esp.Distance.Color = distanceColor
        esp.Distance.Position = Vector2.new(centerX, maxY + 4)  -- Below box
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
        esp.Tracer.From = fromPos
        esp.Tracer.To = screenCenter
        esp.Tracer.Color = boxColor
        esp.Tracer.Thickness = thickness
        esp.Tracer.Visible = true
    else
        esp.Tracer.Visible = false
    end

    -- Health Bar (Non-jumping, attached to left of box)
    if Settings.Visuals.Health.Bar then
        local barHeight = boxSize.Y
        local barX = minX - 5
        local barY = minY
        esp.HealthBar[1].From = Vector2.new(barX, barY)
        esp.HealthBar[1].To = Vector2.new(barX, barY + barHeight)
        esp.HealthBar[1].Color = Color3.new(0,0,0)  -- Background
        esp.HealthBar[1].Thickness = 3
        esp.HealthBar[1].Visible = true

        local fillHeight = barHeight * healthPercent
        esp.HealthBar[2].From = Vector2.new(barX, barY + barHeight)
        esp.HealthBar[2].To = Vector2.new(barX, barY + barHeight - fillHeight)
        if Settings.Visuals.Health.ColorMode == "Green" then
            esp.HealthBar[2].Color = Color3.new(0,1,0)
        elseif Settings.Visuals.Health.ColorMode == "Red" then
            esp.HealthBar[2].Color = Color3.new(1,0,0)
        else  -- Gradient
            esp.HealthBar[2].Color = Color3.new(1 - healthPercent, healthPercent, 0)
        end
        esp.HealthBar[2].Thickness = 3
        esp.HealthBar[2].Visible = true
    else
        esp.HealthBar[1].Visible = false
        esp.HealthBar[2].Visible = false
    end

    -- Skeleton
    if Settings.Visuals.Skeleton.Enabled then
        local parts = {
            Head = char:FindFirstChild("Head"),
            Torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"),
            RightUpperArm = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm"),
            LeftUpperArm = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm"),
            RightUpperLeg = char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg"),
            LeftUpperLeg = char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg"),
            RightHand = char:FindFirstChild("RightHand"),
            LeftHand = char:FindFirstChild("LeftHand"),
            RightFoot = char:FindFirstChild("RightFoot"),
            LeftFoot = char:FindFirstChild("LeftFoot"),
        }

        local function getScreenPos(part)
            if not part then return nil end
            local vec, on = Camera:WorldToViewportPoint(part.Position)
            if on then return Vector2.new(vec.X, vec.Y) end
            return nil
        end

        local connections = {
            {parts.Head, parts.Torso},  -- Neck to Torso
            {parts.Torso, parts.RightUpperArm},
            {parts.Torso, parts.LeftUpperArm},
            {parts.RightUpperArm, parts.RightHand},
            {parts.LeftUpperArm, parts.LeftHand},
            {parts.Torso, parts.RightUpperLeg},
            {parts.Torso, parts.LeftUpperLeg},
            {parts.RightUpperLeg, parts.RightFoot},
            {parts.LeftUpperLeg, parts.LeftFoot},
        }

        local skeletonIdx = esp.ActiveLines + 1
        for _, conn in ipairs(connections) do
            local pos1 = getScreenPos(conn[1])
            local pos2 = getScreenPos(conn[2])
            if pos1 and pos2 then
                esp.SkeletonLines[skeletonIdx].From = pos1
                esp.SkeletonLines[skeletonIdx].To = pos2
                esp.SkeletonLines[skeletonIdx].Color = skeletonColor
                esp.SkeletonLines[skeletonIdx].Thickness = thickness
                esp.SkeletonLines[skeletonIdx].Visible = true
                skeletonIdx = skeletonIdx + 1
            end
        end
        esp.ActiveLines = skeletonIdx - 1

        -- Hide remaining lines
        for i = skeletonIdx, #esp.SkeletonLines do
            esp.SkeletonLines[i].Visible = false
        end
    end

    -- Chams
    if Settings.Visuals.Chams.Enabled and isEnemy then
        esp.Cham.Adornee = char
        esp.Cham.FillColor = Settings.Visuals.Chams.Color
        esp.Cham.FillTransparency = Settings.Visuals.Chams.Transparency
        esp.Cham.OutlineColor = Color3.new(1,1,1)  -- White outline
        esp.Cham.OutlineTransparency = Settings.Visuals.Chams.Outline and 0 or 1
        esp.Cham.Enabled = true
    else
        esp.Cham.Enabled = false
    end
end

-- ███████████████████████████████████████████████████████
-- OBJECT ESP (Items, Quests, Vehicles)
-- ███████████████████████████████████████████████████████

local ObjectESP = {
    Items = {},
    Quests = {},
    Vehicles = {},
}

local function CreateObjectESP(list, obj, posPartName, name, flag)
    local text = GetPooledText()
    text.Size = 12
    table.insert(list, {obj = obj, text = text, posPartName = posPartName, name = name, flag = flag})
end

local function UpdateObjectESP(list, flag)
    if not Settings.Visuals[flag].Enabled then
        for _, entry in ipairs(list) do
            entry.text.Visible = false
        end
        return
    end

    local color = HSVToColor(Settings.Visuals[flag].Color)
    local maxDist = Settings.Visuals.General.MaxDistance

    for _, entry in ipairs(list) do
        if entry.obj and entry.obj.Parent then
            local posPart = entry.obj:FindFirstChild(entry.posPartName) or entry.obj
            local position = posPart.Position
            local screenPos, onScreen = Camera:WorldToViewportPoint(position)
            if onScreen then
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
            -- Optional: Remove from list if destroyed
        end
    end
end

-- Initialize Objects
if Workspace:FindFirstChild("Containers") then
    for _, container in ipairs(Workspace.Containers:GetChildren()) do
        CreateObjectESP(ObjectESP.Items, container, "Part", container.Name, "ItemText")
    end
    Workspace.Containers.ChildAdded:Connect(function(item)
        CreateObjectESP(ObjectESP.Items, item, "Part", item.Name, "ItemText")
    end)
end

if Workspace:FindFirstChild("QuestItems") then
    for _, quest in ipairs(Workspace.QuestItems:GetChildren()) do
        CreateObjectESP(ObjectESP.Quests, quest, "Part", quest.Name, "QuestItems")
    end
    Workspace.QuestItems.ChildAdded:Connect(function(quest)
        CreateObjectESP(ObjectESP.Quests, quest, "Part", quest.Name, "QuestItems")
    end)
end

if Workspace:FindFirstChild("Vehicles") then
    for _, veh in ipairs(Workspace.Vehicles:GetChildren()) do
        CreateObjectESP(ObjectESP.Vehicles, veh, "PrimaryPart", veh.Name, "Vehicles")
    end
    Workspace.Vehicles.ChildAdded:Connect(function(veh)
        CreateObjectESP(ObjectESP.Vehicles, veh, "PrimaryPart", veh.Name, "Vehicles")
    end)
end

-- ███████████████████████████████████████████████████████
-- DEATH HISTORY
-- ███████████████████████████████████████████████████████

local DeathESP = {}
local DeathCounter = 0

local function OnPlayerDied(player)
    if not Settings.Visuals.DeathHistory.Enabled then return end
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    DeathCounter = DeathCounter + 1
    local text = GetPooledText()
    table.insert(DeathESP, {pos = root.Position, text = text, count = DeathCounter})
end

local function UpdateDeathESP()
    if not Settings.Visuals.DeathHistory.Enabled then
        for _, entry in ipairs(DeathESP) do
            entry.text.Visible = false
        end
        return
    end

    local color = HSVToColor(Settings.Visuals.DeathHistory.Color)
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

-- Connect Death Events
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function(char)
            local hum = char:WaitForChild("Humanoid", 5)
            if hum then
                hum.Died:Connect(function()
                    OnPlayerDied(player)
                end)
            end
        end)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function(char)
            local hum = char:WaitForChild("Humanoid", 5)
            if hum then
                hum.Died:Connect(function()
                    OnPlayerDied(player)
                end)
            end
        end)
    end
    CreatePlayerESP(player)
end)

Players.PlayerRemoving:Connect(RemovePlayerESP)

-- ███████████████████████████████████████████████████████
-- MAIN RENDER LOOP (Optimized)
-- ███████████████████████████████████████████████████████

RunService.RenderStepped:Connect(function()
    if not Settings.Visuals.General.Enabled then
        -- Global hide
        for _, esp in pairs(PlayerESP) do
            esp.Name.Visible = false
            esp.Distance.Visible = false
            esp.Tracer.Visible = false
            esp.HealthBar[1].Visible = false
            esp.HealthBar[2].Visible = false
            esp.Cham.Enabled = false
            for i = 1, esp.ActiveLines do
                esp.SkeletonLines[i].Visible = false
            end
            esp.ActiveLines = 0
        end
        for _, list in pairs(ObjectESP) do
            for _, entry in ipairs(list) do
                entry.text.Visible = false
            end
        end
        for _, entry in ipairs(DeathESP) do
            entry.text.Visible = false
        end
        return
    end

    -- Update Players
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer or Settings.Visuals.General.IncludeNPC then
            if not PlayerESP[player] then
                CreatePlayerESP(player)
            end
            UpdatePlayerESP(player)
        end
    end

    -- Update Objects
    UpdateObjectESP(ObjectESP.Items, "ItemText")
    UpdateObjectESP(ObjectESP.Quests, "QuestItems")
    UpdateObjectESP(ObjectESP.Vehicles, "Vehicles")

    -- Update Deaths
    UpdateDeathESP()
end)

-- Zoom Feature
RunService.RenderStepped:Connect(function()
    if Settings.Visuals.Zoom.Enabled then
        Camera.FieldOfView = 70 - Settings.Visuals.Zoom.Level
    else
        Camera.FieldOfView = 70
    end
end)

print("Professional ESP System for Project Delta loaded!")
