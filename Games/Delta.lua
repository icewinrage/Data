-- Data Hub - Project Delta (Ultimate Edition)
-- Game ID: 6483626525
-- Features: RageBot, Gun Mods, Visuals (Full ESP), World, Misc, Anti-UAC

-- Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RSPlayers = ReplicatedStorage:WaitForChild("Players")

-- Создаём GV при появлении player folder
RSPlayers.ChildAdded:Connect(function(playerFolder)
    if playerFolder.Name ~= LocalPlayer.Name then return end
    playerFolder.ChildAdded:Connect(function(status)
        if status.Name ~= "Status" then return end
        task.wait(0.5)  -- Ждём загрузки
        local gv = Instance.new("Folder")
        gv.Name = "GameplayVariables"
        gv.Parent = status
        
        -- Обязательные для игры (фикс крашей)
        local health = Instance.new("IntValue")
        health.Name = "Health"
        health.Value = 100
        health.Parent = gv
        
        local maxHealth = Instance.new("IntValue")
        maxHealth.Name = "MaxHealth"
        maxHealth.Value = 100
        maxHealth.Parent = gv
        
        local equipped = Instance.new("StringValue")
        equipped.Name = "EquippedTool"
        equipped.Value = ""
        equipped.Parent = gv
        
        -- Синхронизируем real HP (опционально)
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            health.Value = humanoid.Health
            maxHealth.Value = humanoid.MaxHealth
        end
        
        print("GameplayVariables создан для " .. LocalPlayer.Name)
    end)
end)

-- Если уже есть
local myFolder = RSPlayers:FindFirstChild(LocalPlayer.Name)
if myFolder and myFolder:FindFirstChild("Status") then
    -- Вызови создание вручную (скопируй код выше)
end

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

-- Death history storage
local DeathHistory = {} -- {position, time, count}
local DeathCounter = 0

-- Settings tables
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
            MaxDistance = 1000 -- общий слайдер дистанции
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
    warn("Data Hub UI library not loaded.")
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
    warn("Failed to create window.")
    return
end

-- ███████████████████████████████████████████████████████
-- ВКЛАДКА RAGEBOT
-- ███████████████████████████████████████████████████████
local RageTab = Window:Tab({Name = "RageBot"}) do
    -- Silent Aim Section
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

    -- AutoFire Section
    local AutoFireSection = RageTab:Section({Name = "Auto Fire", Side = "Right"}) do
        AutoFireSection:Toggle({Name = "Enable Auto Fire", Flag = "Delta/Rage/AutoFire", Value = false,
            Callback = function(val) Settings.Rage.AutoFire = val end})
    end

    -- PlayerList Section (заглушка)
    local PlayerListSection = RageTab:Section({Name = "Player List", Side = "Right"}) do
        PlayerListSection:Label({Text = "Player list will be displayed here."})
        PlayerListSection:Button({Name = "Refresh List", Callback = function()
            print("Refreshing player list...")
            -- TODO: actual player list logic
        end})
    end

    -- FOV Circle для Rage
    if Settings.Rage.FOVCircle then
        DataHub.Utilities.Drawing.SetupFOV("Rage", Window.Flags)
    end
end

-- ███████████████████████████████████████████████████████
-- ВКЛАДКА GUN MODS
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
-- ВКЛАДКА VISUALS (с Zoom)
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
        TracersSection:Toggle({Name = "Outline", Flag = "Delta/Visuals/Tracers/Outline", Value = false,
            Callback = function(val) Settings.Visuals.Tracers.Outline = val end})
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

    -- Chams Section
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

    -- Item Text Section (лут)
    local ItemTextSection = VisualsTab:Section({Name = "Item Text", Side = "Right"}) do
        ItemTextSection:Toggle({Name = "Enabled", Flag = "Delta/Visuals/ItemText/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.ItemText.Enabled = val end})
        ItemTextSection:Colorpicker({Name = "Color", Flag = "Delta/Visuals/ItemText/Color", Value = Settings.Visuals.ItemText.Color,
            Callback = function(val) Settings.Visuals.ItemText.Color = val end})
        ItemTextSection:Slider({Name = "Distance", Flag = "Delta/Visuals/ItemText/Distance", Min = 30, Max = 1000, Value = 100,
            Callback = function(val) Settings.Visuals.ItemText.Distance = val end})
    end

    -- Head Dots Section
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
        DeathSection:Toggle({Name = "Death History ESP", Flag = "Delta/Visuals/DeathHistory/Enabled", Value = false,
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
-- ВКЛАДКА WORLD
-- ███████████████████████████████████████████████████████
local WorldTab = Window:Tab({Name = "World"}) do
    -- Environment Section
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

    -- SkyBox Section
    local SkySection = WorldTab:Section({Name = "Sky Box", Side = "Left"}) do
        SkySection:Toggle({Name = "Moon", Flag = "Delta/World/SkyBox/Moon", Value = false,
            Callback = function(val) Settings.World.SkyBox.Moon = val end})
    end

    -- Inventory Checker Section
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
-- ВКЛАДКА MISC
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

-- ███████████████████████████████████████████████████████
-- НАСТРОЙКИ (из утилит)
-- ███████████████████████████████████████████████████████
DataHub.Utilities:SettingsSection(Window, "RightShift", false)
DataHub.Utilities.InitAutoLoad(Window)

-- ███████████████████████████████████████████████████████
-- РЕАЛИЗАЦИЯ VISUALS (ESP)
-- ███████████████████████████████████████████████████████

-- Вспомогательная функция для получения цвета из таблицы HSV
local function GetColorFromHSV(hsvTable)
    if not hsvTable then return Color3.new(1,1,1) end
    return Color3.fromHSV(hsvTable[1] or 0, hsvTable[2] or 1, hsvTable[3] or 1)
end

-- Функция определения врага/союзника (без команд, все кроме себя - враги)
local function IsEnemy(player)
    return player ~= LocalPlayer
end

-- Хранилище для Drawing объектов каждого игрока
local ESPObjects = {}

-- Хранилище для объектов лута, квестов, машин
local ItemESPObjects = {}
local QuestESPObjects = {}
local VehicleESPObjects = {}

-- Создание объектов для игрока
local function CreateESPForPlayer(player)
    if ESPObjects[player] then return end
    ESPObjects[player] = {
        Box = {
            Lines = {}, -- для бокса (будем создавать 4 или 8 линий)
            HealthBar = nil,
        },
        Name = DataHub.Utilities.Drawing.AddDrawing("Text", { Size = 14, Center = true, Outline = true, Font = 2 }),
        Distance = DataHub.Utilities.Drawing.AddDrawing("Text", { Size = 12, Center = true, Outline = true, Font = 2 }),
        Tracer = {
            Main = DataHub.Utilities.Drawing.AddDrawing("Line", {}),
            Outline = DataHub.Utilities.Drawing.AddDrawing("Line", {}),
        },
        HeadDot = {
            Main = DataHub.Utilities.Drawing.AddDrawing("Circle", {}),
            Outline = DataHub.Utilities.Drawing.AddDrawing("Circle", {}),
        },
        Highlight = nil -- будет создан позже
    }
    -- Создаём линии для бокса (4 линии для простого прямоугольника)
    for i = 1, 4 do
        ESPObjects[player].Box.Lines[i] = DataHub.Utilities.Drawing.AddDrawing("Line", {})
    end
end

-- Обновление ESP для игрока
local function UpdateESPForPlayer(player)
    local esp = ESPObjects[player]
    if not esp then return end

    local character = player.Character
    if not character then
        -- скрыть все объекты
        esp.Name.Visible = false
        esp.Distance.Visible = false
        esp.Tracer.Main.Visible = false
        esp.Tracer.Outline.Visible = false
        esp.HeadDot.Main.Visible = false
        esp.HeadDot.Outline.Visible = false
        for _, line in ipairs(esp.Box.Lines) do
            line.Visible = false
        end
        if esp.Highlight then
            esp.Highlight.Enabled = false
        end
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        -- скрыть
        esp.Name.Visible = false
        esp.Distance.Visible = false
        esp.Tracer.Main.Visible = false
        esp.Tracer.Outline.Visible = false
        esp.HeadDot.Main.Visible = false
        esp.HeadDot.Outline.Visible = false
        for _, line in ipairs(esp.Box.Lines) do
            line.Visible = false
        end
        return
    end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
    if not onScreen then
        -- можно скрыть или оставить стрелки (но пока скроем)
        esp.Name.Visible = false
        esp.Distance.Visible = false
        esp.Tracer.Main.Visible = false
        esp.Tracer.Outline.Visible = false
        esp.HeadDot.Main.Visible = false
        esp.HeadDot.Outline.Visible = false
        for _, line in ipairs(esp.Box.Lines) do
            line.Visible = false
        end
        return
    end

    local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
    if distance > Settings.Visuals.General.MaxDistance then
        -- скрываем за дистанцией
        esp.Name.Visible = false
        esp.Distance.Visible = false
        esp.Tracer.Main.Visible = false
        esp.Tracer.Outline.Visible = false
        esp.HeadDot.Main.Visible = false
        esp.HeadDot.Outline.Visible = false
        for _, line in ipairs(esp.Box.Lines) do
            line.Visible = false
        end
        return
    end

    local isEnemy = IsEnemy(player)

    -- Получаем настройки
    local vis = Settings.Visuals

    -- Определяем цвет в зависимости от врага/союзника (для бокса и трейсера используем цвет врага/союзника из настроек)
    local boxColor = GetColorFromHSV(vis.Box.Color)
    local nameColor = GetColorFromHSV(vis.Name.Color)
    local distanceColor = GetColorFromHSV(vis.Distance.Color)
    local healthColor = isEnemy and Color3.new(1,0,0) or Color3.new(0,1,0) -- для хп-бара

    -- Box (простой 2D прямоугольник вокруг персонажа)
    if vis.Box.Enabled then
        -- Приблизительный размер бокса (можно улучшить через GetExtentsSize)
        local size = Vector2.new(100, 150) * (1000 / math.max(distance, 1)) -- масштабирование
        local pos = Vector2.new(screenPos.X, screenPos.Y) - size/2
        local lines = esp.Box.Lines
        -- Верхняя горизонтальная
        lines[1].From = pos
        lines[1].To = pos + Vector2.new(size.X, 0)
        lines[1].Color = boxColor
        lines[1].Thickness = 2
        lines[1].Visible = true
        -- Правая вертикальная
        lines[2].From = pos + Vector2.new(size.X, 0)
        lines[2].To = pos + size
        lines[2].Color = boxColor
        lines[2].Thickness = 2
        lines[2].Visible = true
        -- Нижняя горизонтальная
        lines[3].From = pos + size
        lines[3].To = pos + Vector2.new(0, size.Y)
        lines[3].Color = boxColor
        lines[3].Thickness = 2
        lines[3].Visible = true
        -- Левая вертикальная
        lines[4].From = pos + Vector2.new(0, size.Y)
        lines[4].To = pos
        lines[4].Color = boxColor
        lines[4].Thickness = 2
        lines[4].Visible = true
    else
        for _, line in ipairs(esp.Box.Lines) do
            line.Visible = false
        end
    end

    -- Name
    if vis.Name.Enabled then
        esp.Name.Visible = true
        esp.Name.Text = player.Name
        esp.Name.Color = nameColor
        esp.Name.Position = Vector2.new(screenPos.X, screenPos.Y - 50)
    else
        esp.Name.Visible = false
    end

    -- Distance
    if vis.Distance.Enabled then
        esp.Distance.Visible = true
        local unit = vis.Distance.Mode == "Meters" and "m" or "studs"
        esp.Distance.Text = string.format("%.0f %s", distance, unit)
        esp.Distance.Color = distanceColor
        esp.Distance.Position = Vector2.new(screenPos.X, screenPos.Y + 30)
    else
        esp.Distance.Visible = false
    end

    -- Tracers
    if vis.Tracers.Enabled then
        local fromPos
        if vis.Tracers.Mode == "From Mouse" then
            fromPos = UserInputService:GetMouseLocation()
        else
            fromPos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
        end
        local toPos = Vector2.new(screenPos.X, screenPos.Y)
        esp.Tracer.Main.From = fromPos
        esp.Tracer.Main.To = toPos
        esp.Tracer.Main.Color = boxColor
        esp.Tracer.Main.Visible = true
        if vis.Tracers.Outline then
            esp.Tracer.Outline.From = fromPos
            esp.Tracer.Outline.To = toPos
            esp.Tracer.Outline.Color = Color3.new(0,0,0)
            esp.Tracer.Outline.Thickness = esp.Tracer.Main.Thickness + 2
            esp.Tracer.Outline.Visible = true
        else
            esp.Tracer.Outline.Visible = false
        end
    else
        esp.Tracer.Main.Visible = false
        esp.Tracer.Outline.Visible = false
    end

    -- Head Dots
    if vis.HeadDots.Enabled then
        local head = character:FindFirstChild("Head")
        if head then
            local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position)
            if headOnScreen then
                local radius = vis.HeadDots.Size
                if vis.HeadDots.Autoscale then
                    radius = radius * (1000 / math.max(distance, 1))
                end
                esp.HeadDot.Main.Radius = radius
                esp.HeadDot.Main.Position = Vector2.new(headPos.X, headPos.Y)
                esp.HeadDot.Main.Color = boxColor
                esp.HeadDot.Main.Filled = vis.HeadDots.Filled
                esp.HeadDot.Main.Visible = true
                if vis.HeadDots.Outline then
                    esp.HeadDot.Outline.Radius = radius + 1
                    esp.HeadDot.Outline.Position = esp.HeadDot.Main.Position
                    esp.HeadDot.Outline.Color = Color3.new(0,0,0)
                    esp.HeadDot.Outline.Thickness = 2
                    esp.HeadDot.Outline.Filled = false
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

    -- Chams через Highlight
    if vis.Chams.Enabled then
        if not esp.Highlight then
            esp.Highlight = Instance.new("Highlight")
            esp.Highlight.Adornee = character
            esp.Highlight.Parent = character
        end
        local chamColor = isEnemy and GetColorFromHSV(vis.Chams.EnemyColor) or GetColorFromHSV(vis.Chams.AllyColor)
        esp.Highlight.FillColor = chamColor
        esp.Highlight.OutlineColor = vis.Chams.Glow and Color3.new(1,1,1) or Color3.new(0,0,0)
        esp.Highlight.FillTransparency = 0.5
        esp.Highlight.OutlineTransparency = vis.Chams.Glow and 0 or 1
        esp.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    else
        if esp.Highlight then
            esp.Highlight:Destroy()
            esp.Highlight = nil
        end
    end
end

-- Функция для создания ESP для объектов (лут, квесты, машины)
local function CreateObjectESP(category, obj, name, position, colorFlag)
    if not obj or not position then return end
    local text = DataHub.Utilities.Drawing.AddDrawing("Text", { Size = 12, Center = true, Outline = true, Font = 2 })
    table.insert(category, { obj = obj, text = text, position = position, colorFlag = colorFlag })
end

-- Обновление ESP для объектов
local function UpdateObjectESP(list, settingsFlag)
    local enabled = Settings.Visuals[settingsFlag].Enabled
    local color = GetColorFromHSV(Settings.Visuals[settingsFlag].Color)
    local maxDist = Settings.Visuals.General.MaxDistance
    for _, entry in ipairs(list) do
        local obj = entry.obj
        if obj and obj.Parent then
            local pos = entry.position.Value or entry.position.Position
            local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
            if onScreen and enabled then
                local dist = (pos - Camera.CFrame.Position).Magnitude
                if dist <= maxDist then
                    entry.text.Visible = true
                    entry.text.Text = entry.obj.Name .. string.format(" [%.0f]", dist)
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

-- Создание ESP для существующих объектов при старте
for _, container in ipairs(Workspace:FindFirstChild("Containers"):GetChildren()) do
    CreateObjectESP(ItemESPObjects, container, container.Name, container:FindFirstChild("Part") or container, "ItemText")
end

Workspace.ChildAdded:Connect(function(child)
    if child.Name == "Containers" then
        child.ChildAdded:Connect(function(item)
            CreateObjectESP(ItemESPObjects, item, item.Name, item:FindFirstChild("Part") or item, "ItemText")
        end)
    end
end)

-- Quest Items
if Workspace:FindFirstChild("QuestItems") then
    for _, quest in ipairs(Workspace.QuestItems:GetChildren()) do
        CreateObjectESP(QuestESPObjects, quest, quest.Name, quest:FindFirstChild("Part") or quest, "QuestItems")
    end
    Workspace.QuestItems.ChildAdded:Connect(function(quest)
        CreateObjectESP(QuestESPObjects, quest, quest.Name, quest:FindFirstChild("Part") or quest, "QuestItems")
    end)
end

-- Vehicles
if Workspace:FindFirstChild("Vehicles") then
    for _, veh in ipairs(Workspace.Vehicles:GetChildren()) do
        CreateObjectESP(VehicleESPObjects, veh, veh.Name, veh:FindFirstChild("PrimaryPart") or veh, "Vehicles")
    end
    Workspace.Vehicles.ChildAdded:Connect(function(veh)
        CreateObjectESP(VehicleESPObjects, veh, veh.Name, veh:FindFirstChild("PrimaryPart") or veh, "Vehicles")
    end)
end

-- Death History
local function OnPlayerDied(player, humanoid)
    if not Settings.Visuals.DeathHistory.Enabled then return end
    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    DeathCounter = DeathCounter + 1
    local deathEntry = {
        position = rootPart.Position,
        time = tick(),
        count = DeathCounter,
        text = DataHub.Utilities.Drawing.AddDrawing("Text", { Size = 14, Center = true, Outline = true, Font = 2, Color = Color3.new(1,0,0) })
    }
    table.insert(DeathHistory, deathEntry)
    -- Удалять старые через время можно добавить позже
end

for _, player in ipairs(Players:GetPlayers()) do
    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Died:Connect(function()
                OnPlayerDied(player, humanoid)
            end)
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.Died:Connect(function()
            OnPlayerDied(player, humanoid)
        end)
    end)
end)

-- Обновление Death History
local function UpdateDeathHistory()
    if not Settings.Visuals.DeathHistory.Enabled then
        for _, entry in ipairs(DeathHistory) do
            entry.text.Visible = false
        end
        return
    end
    local color = GetColorFromHSV(Settings.Visuals.DeathHistory.Color)
    local maxDist = Settings.Visuals.General.MaxDistance
    for _, entry in ipairs(DeathHistory) do
        local screenPos, onScreen = Camera:WorldToViewportPoint(entry.position)
        if onScreen then
            local dist = (entry.position - Camera.CFrame.Position).Magnitude
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

-- Главный цикл обновления визуалов
RunService.RenderStepped:Connect(function()
    if not Settings.Visuals.General.Enabled then
        -- скрыть всё
        for _, player in pairs(ESPObjects) do
            if player.Name then player.Name.Visible = false end
            if player.Distance then player.Distance.Visible = false end
            if player.Tracer then
                player.Tracer.Main.Visible = false
                player.Tracer.Outline.Visible = false
            end
            if player.HeadDot then
                player.HeadDot.Main.Visible = false
                player.HeadDot.Outline.Visible = false
            end
            for _, line in ipairs(player.Box.Lines) do
                line.Visible = false
            end
        end
        for _, entry in ipairs(ItemESPObjects) do entry.text.Visible = false end
        for _, entry in ipairs(QuestESPObjects) do entry.text.Visible = false end
        for _, entry in ipairs(VehicleESPObjects) do entry.text.Visible = false end
        for _, entry in ipairs(DeathHistory) do entry.text.Visible = false end
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer or Settings.Visuals.General.IncludeNPC then
            if not ESPObjects[player] then
                CreateESPForPlayer(player)
            end
            UpdateESPForPlayer(player)
        end
    end

    UpdateObjectESP(ItemESPObjects, "ItemText")
    UpdateObjectESP(QuestESPObjects, "QuestItems")
    UpdateObjectESP(VehicleESPObjects, "Vehicles")
    UpdateDeathHistory()
end)

-- Обработка Zoom
RunService.RenderStepped:Connect(function()
    if Settings.Visuals.Zoom.Enabled then
        Camera.FieldOfView = 70 - Settings.Visuals.Zoom.Level
    else
        Camera.FieldOfView = 70
    end
end)

print("Data Hub - Ultimate Edition loaded")
print("All ESP features enabled.")
