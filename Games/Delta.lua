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
-- UNNAMED ESP INTEGRATION
-- ███████████████████████████████████████████████████████

local UnnamedESP_Loaded = false

function LoadUnnamedESPWithDeltaSupport()
    if UnnamedESP_Loaded then return end

    local success, result = pcall(function()
        local code = game:HttpGet("https://raw.githubusercontent.com/ic3w0lf22/Unnamed-ESP/refs/heads/master/UnnamedESP.lua")

        -- Disable menu creation and input
        code = code:gsub("Menu:Create%(%)", "-- Menu:Create() -- disabled")
        code = code:gsub("UserInputService.InputBegan:.-end", "-- input disabled")

        -- Inject Project Delta module
        local deltaModule = [[
    [2862098693] = { -- Project Delta
        CustomESP = function()
            local containers = workspace:FindFirstChild("Containers")
            if containers then
                for _, obj in ipairs(containers:GetChildren()) do
                    if obj:IsA("Model") then
                        local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("Part")
                        if part and shared.UESP_Config.ItemText then
                            RenderList:AddOrUpdateInstance(obj, part, obj.Name .. " [" .. math.floor((part.Position - Camera.CFrame.Position).Magnitude) .. "]", shared.UESP_Config.ItemColor or Color3.new(0,1,0))
                        end
                    end
                end
            end

            local questItems = workspace:FindFirstChild("QuestItems")
            if questItems then
                for _, obj in ipairs(questItems:GetChildren()) do
                    if obj:IsA("Model") then
                        local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("Part")
                        if part and shared.UESP_Config.QuestItems then
                            RenderList:AddOrUpdateInstance(obj, part, obj.Name .. " [" .. math.floor((part.Position - Camera.CFrame.Position).Magnitude) .. "]", shared.UESP_Config.QuestColor or Color3.new(0,1,1))
                        end
                    end
                end
            end

            local vehicles = workspace:FindFirstChild("Vehicles")
            if vehicles then
                for _, obj in ipairs(vehicles:GetChildren()) do
                    if obj:IsA("Model") then
                        local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("Part")
                        if part and shared.UESP_Config.Vehicles then
                            RenderList:AddOrUpdateInstance(obj, part, obj.Name .. " [" .. math.floor((part.Position - Camera.CFrame.Position).Magnitude) .. "]", shared.UESP_Config.VehicleColor or Color3.new(1,0.5,0))
                        end
                    end
                end
            end
        end,
    },
]]

        -- Insert module into the Modules table
        code = code:gsub("local Modules = {.-}\n", function(fullMatch)
            return fullMatch:sub(1, -3) .. deltaModule .. "}\n"
        end)

        local fn = loadstring(code, "UnnamedESP")
        if fn then
            fn()
            UnnamedESP_Loaded = true
            print("UnnamedESP loaded with Project Delta support")
        end
    end)

    if not success then
        warn("Failed to load UnnamedESP:", result)
    end
end

-- Initialize UnnamedESP config table
shared.UESP_Config = shared.UESP_Config or {
    Enabled = false,
    Boxes = true,
    Names = true,
    Health = true,
    Weapons = true,
    Distance = true,
    Skeleton = false,
    Tracers = false,
    ItemText = false,
    QuestItems = false,
    Vehicles = false,
    AllyColor = Color3.new(0,1,0),
    EnemyColor = Color3.new(1,0,0),
    ItemColor = Color3.new(0,1,0),
    QuestColor = Color3.new(0,1,1),
    VehicleColor = Color3.new(1,0.5,0),
}

-- Zoom handling
RunService.RenderStepped:Connect(function()
    if Settings.Visuals.Zoom.Enabled then
        Camera.FieldOfView = 70 - Settings.Visuals.Zoom.Level
    else
        Camera.FieldOfView = 70
    end
end)

-- Final message
print("Data Hub - Project Delta (UnnamedESP Integrated) loaded")
print("Use the Visuals tab to control UnnamedESP settings.")
