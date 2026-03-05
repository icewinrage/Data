-- Data Hub - Project Delta (Ultimate Edition)
-- Game ID: 6483626525
-- Features: RageBot, Gun Mods, Visuals (Full ESP), PlayerList

-- Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

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

-- Settings tables (будут обновляться через UI)
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
        RapidFireDelay = 10
    },
    Visuals = {
        General = {
            Enabled = false,
            IncludeNPC = false,
            ScaleType = "Dynamic"
        },
        Box = {
            Enabled = false,
            Color = {1, 1, 1, 0, false}, -- white
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
            ColorMode = "Green" -- Red, Green, RGB
        },
        Chams = {
            Enabled = false,
            AllyColor = {0, 1, 0, 0, false}, -- green
            EnemyColor = {1, 0, 0, 0, false}, -- red
            Glow = false
        },
        OffscreenArrows = {
            Enabled = false,
            Filled = true,
            Outline = true,
            Width = 14,
            Height = 28,
            Radius = 150,
            Thickness = 1,
            Transparency = 0
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
        DeathHistory = false
    },
    Aimbot = {
        Enabled = false,
        TeamCheck = true,
        Prediction = false,
        Smoothness = 30,
        FOV = 120,
        Distance = 300,
        Priority = "Head"
    },
    Trigger = {
        Enabled = false,
        Delay = 0.1,
        FOV = 30
    }
}

-- Body parts for hitbox selection
local HitPartsList = {
    {Name = "Head", Mode = "Toggle", Value = true},
    {Name = "Torso", Mode = "Toggle", Value = true},
    {Name = "Legs", Mode = "Toggle", Value = true}
}

-- Body parts for aimbot priority
local BodyParts = {"Head", "HumanoidRootPart", "Torso", "Right Arm", "Left Arm"}

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
        Size = UDim2.new(0, 800, 0, 700)
    })
end)
if not Window then
    warn("Failed to create window.")
    return
end

-- ███████████████████████████████████████████████████████
-- ВКЛАДКА RAGEBOT (первая)
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
            Name = "Rapid Fire Delay (ms)",
            Flag = "Delta/Gun/RapidFireDelay",
            Min = 0,
            Max = 20,
            Value = 10,
            Callback = function(val) Settings.GunMods.RapidFireDelay = val end
        })
    end
end

-- ███████████████████████████████████████████████████████
-- ВКЛАДКА VISUALS (расширенная ESP)
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

    -- Offscreen Arrows Section
    local ArrowsSection = VisualsTab:Section({Name = "Offscreen Arrows", Side = "Right"}) do
        ArrowsSection:Toggle({Name = "Enabled", Flag = "Delta/Visuals/Arrows/Enabled", Value = false,
            Callback = function(val) Settings.Visuals.OffscreenArrows.Enabled = val end})
        ArrowsSection:Toggle({Name = "Filled", Flag = "Delta/Visuals/Arrows/Filled", Value = true,
            Callback = function(val) Settings.Visuals.OffscreenArrows.Filled = val end})
        ArrowsSection:Toggle({Name = "Outline", Flag = "Delta/Visuals/Arrows/Outline", Value = true,
            Callback = function(val) Settings.Visuals.OffscreenArrows.Outline = val end})
        ArrowsSection:Slider({Name = "Width", Flag = "Delta/Visuals/Arrows/Width", Min = 8, Max = 40, Value = 14,
            Callback = function(val) Settings.Visuals.OffscreenArrows.Width = val end})
        ArrowsSection:Slider({Name = "Height", Flag = "Delta/Visuals/Arrows/Height", Min = 8, Max = 40, Value = 28,
            Callback = function(val) Settings.Visuals.OffscreenArrows.Height = val end})
        ArrowsSection:Slider({Name = "Distance from Center", Flag = "Delta/Visuals/Arrows/Radius", Min = 50, Max = 300, Value = 150,
            Callback = function(val) Settings.Visuals.OffscreenArrows.Radius = val end})
        ArrowsSection:Slider({Name = "Thickness", Flag = "Delta/Visuals/Arrows/Thickness", Min = 1, Max = 10, Value = 1,
            Callback = function(val) Settings.Visuals.OffscreenArrows.Thickness = val end})
        ArrowsSection:Slider({Name = "Transparency", Flag = "Delta/Visuals/Arrows/Transparency", Min = 0, Max = 1, Precise = 2, Value = 0,
            Callback = function(val) Settings.Visuals.OffscreenArrows.Transparency = val end})
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

    -- Death History Section
    local DeathSection = VisualsTab:Section({Name = "Death History", Side = "Right"}) do
        DeathSection:Toggle({Name = "Death History ESP", Flag = "Delta/Visuals/DeathHistory", Value = false,
            Callback = function(val) Settings.Visuals.DeathHistory = val end})
    end
end

-- ███████████████████████████████████████████████████████
-- ВКЛАДКА MISC (Aimbot, Trigger)
-- ███████████████████████████████████████████████████████
local MiscTab = Window:Tab({Name = "Misc"}) do
    -- Aimbot Section
    local AimbotSection = MiscTab:Section({Name = "Aimbot", Side = "Left"}) do
        AimbotSection:Toggle({
            Name = "Enable Aimbot",
            Flag = "Delta/Aimbot/Enabled",
            Value = false,
            Callback = function(val) Settings.Aimbot.Enabled = val end
        }):Keybind({
            Flag = "Delta/Aimbot/Keybind",
            Value = "MouseButton2",
            Mouse = true,
            Callback = function(key, state) AimbotActive = state end
        })

        AimbotSection:Toggle({Name = "Team Check", Flag = "Delta/Aimbot/TeamCheck", Value = true,
            Callback = function(val) Settings.Aimbot.TeamCheck = val end})
        AimbotSection:Toggle({Name = "Prediction", Flag = "Delta/Aimbot/Prediction", Value = false,
            Callback = function(val) Settings.Aimbot.Prediction = val end})
        AimbotSection:Slider({Name = "Smoothness", Flag = "Delta/Aimbot/Smoothness", Min = 1, Max = 100, Value = 30,
            Callback = function(val) Settings.Aimbot.Smoothness = val end})
        AimbotSection:Slider({Name = "FOV", Flag = "Delta/Aimbot/FOV", Min = 10, Max = 360, Value = 120,
            Callback = function(val) Settings.Aimbot.FOV = val end})
        AimbotSection:Slider({Name = "Max Distance", Flag = "Delta/Aimbot/Distance", Min = 10, Max = 1000, Value = 300,
            Callback = function(val) Settings.Aimbot.Distance = val end})

        local PartsList = {}
        for _, part in ipairs(BodyParts) do
            table.insert(PartsList, {Name = part, Mode = "Button", Value = (part == "Head")})
        end
        AimbotSection:Dropdown({
            Name = "Priority Part",
            Flag = "Delta/Aimbot/Priority",
            List = PartsList,
            Callback = function(val) Settings.Aimbot.Priority = val[1] end
        })
    end

    -- Trigger Bot Section
    local TriggerSection = MiscTab:Section({Name = "Trigger Bot", Side = "Right"}) do
        TriggerSection:Toggle({
            Name = "Enable Trigger",
            Flag = "Delta/Trigger/Enabled",
            Value = false,
            Callback = function(val) Settings.Trigger.Enabled = val end
        }):Keybind({
            Flag = "Delta/Trigger/Keybind",
            Mouse = true,
            Callback = function(key, state) TriggerActive = state end
        })

        TriggerSection:Slider({Name = "Delay (sec)", Flag = "Delta/Trigger/Delay", Min = 0, Max = 0.5, Precise = 2, Value = 0.1,
            Callback = function(val) Settings.Trigger.Delay = val end})
        TriggerSection:Slider({Name = "FOV", Flag = "Delta/Trigger/FOV", Min = 10, Max = 360, Value = 30,
            Callback = function(val) Settings.Trigger.FOV = val end})
    end

    -- FOV Circles for Aimbot and Trigger
    DataHub.Utilities.Drawing.SetupFOV("Aimbot", Window.Flags)
    DataHub.Utilities.Drawing.SetupFOV("Trigger", Window.Flags)
end

-- ███████████████████████████████████████████████████████
-- НАСТРОЙКИ (из утилит)
-- ███████████████████████████████████████████████████████
DataHub.Utilities:SettingsSection(Window, "RightShift", false)
DataHub.Utilities.InitAutoLoad(Window)

-- ███████████████████████████████████████████████████████
-- ЗАГЛУШКИ ДЛЯ ЛОГИКИ (TODO: реализовать под игру)
-- ███████████████████████████████████████████████████████
print("Data Hub - Ultimate Edition loaded")
print("Interface ready. Implement game-specific logic for features to work.")
