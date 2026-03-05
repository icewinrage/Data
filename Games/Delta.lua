-- Data Hub - Project Delta (Rage Edition)
-- Game ID: 6483626525
-- Features: RageBot, Gun Mods, Aimbot, Trigger, ESP

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

-- Settings tables
local Settings = {
    Rage = {
        SilentAim = false,
        DeadCheck = true,
        VisibleCheck = true,
        InstantHit = false,
        HitParts = {"Head", "Torso", "Legs"}, -- по умолчанию все
        Distance = 300,
        FOV = 120,
        FOVCircle = true,
        FOVColor = {1, 0, 0, 0.5, false} -- красный полупрозрачный
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
        RapidFire = false
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
    },
    ESP = {
        Enabled = false,
        TeamCheck = true,
        Boxes = true,
        Names = true,
        Distance = true,
        Health = true,
        Tracers = false
    }
}

-- Body parts for hitbox selection (мультивыбор)
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
        Position = UDim2.new(0.5, -350, 0.5, -300),
        Size = UDim2.new(0, 700, 0, 600)
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
        }) -- без Keybind

        SilentSection:Toggle({Name = "Dead Check", Flag = "Delta/Rage/DeadCheck", Value = true,
            Callback = function(val) Settings.Rage.DeadCheck = val end})
        SilentSection:Toggle({Name = "Visible Check", Flag = "Delta/Rage/VisibleCheck", Value = true,
            Callback = function(val) Settings.Rage.VisibleCheck = val end})
        SilentSection:Toggle({Name = "Instant Hit", Flag = "Delta/Rage/InstantHit", Value = false,
            Callback = function(val) Settings.Rage.InstantHit = val end})

        -- Hitpart selection (мультивыбор)
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

    -- FOV Circle для Rage (рисуется, если включено)
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
        })
    end
end

-- ███████████████████████████████████████████████████████
-- ВКЛАДКА COMBAT (старый Aimbot/Trigger)
-- ███████████████████████████████████████████████████████
local CombatTab = Window:Tab({Name = "Combat"}) do
    -- Aimbot Section
    local AimbotSection = CombatTab:Section({Name = "Aimbot", Side = "Left"}) do
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
        AimbotSection:Slider({Name = "Smoothness", Flag = "Delta/Aimbot/Smoothness", Min = 1, Max = 100, Value = 30, Unit = "%",
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
    local TriggerSection = CombatTab:Section({Name = "Trigger Bot", Side = "Right"}) do
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
-- ВКЛАДКА VISUALS (ESP)
-- ███████████████████████████████████████████████████████
local VisualsTab = Window:Tab({Name = "Visuals"}) do
    local ESPSection = DataHub.Utilities:ESPSection(Window, "Player ESP", "Delta/ESP", true, false, true, true, true, false) do
        ESPSection:Colorpicker({Name = "Ally Color", Flag = "Delta/ESP/Ally", Value = {0.33, 0.66, 1, 0, false}})
        ESPSection:Colorpicker({Name = "Enemy Color", Flag = "Delta/ESP/Enemy", Value = {1, 0.33, 0.33, 0, false}})
        ESPSection:Toggle({Name = "Team Check", Flag = "Delta/ESP/TeamCheck", Value = true,
            Callback = function(val) Settings.ESP.TeamCheck = val end})
    end
end

-- ███████████████████████████████████████████████████████
-- ВКЛАДКА MISC (старая, без Speed/Jump)
-- ███████████████████████████████████████████████████████
local MiscTab = Window:Tab({Name = "Misc"}) do
    local WeaponSection = MiscTab:Section({Name = "Weapon", Side = "Left"}) do
        WeaponSection:Toggle({Name = "Auto Fire", Flag = "Delta/AutoFire", Value = false,
            Callback = function(val) Settings.Misc.AutoFire = val end})
    end
end

-- ███████████████████████████████████████████████████████
-- НАСТРОЙКИ (из утилит)
-- ███████████████████████████████████████████████████████
DataHub.Utilities:SettingsSection(Window, "RightShift", false)
DataHub.Utilities.InitAutoLoad(Window)

-- ███████████████████████████████████████████████████████
-- ЗАГЛУШКИ ДЛЯ ЛОГИКИ (нужно реализовать под игру)
-- ███████████████████████████████████████████████████████
-- TODO: добавить функции IsEnemy, GetClosestTarget, хуки для Silent Aim, модов оружия и т.д.
-- Вы можете скопировать их из предыдущей стабильной версии.

print("Data Hub - Rage Edition loaded")
