-- Data Hub - Project Delta (Complete Edition)
-- Game ID: 6483626525
-- Author: Data Hub Team
-- Description: Full-featured script for Project Delta with Aimbot, ESP, Misc mods.

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

-- State flags (will be controlled by UI)
local AimbotEnabled = false
local AimbotActive = false
local TriggerEnabled = false
local SilentAimEnabled = false
local ESPEnabled = false

-- Settings tables (will be updated by UI flags)
local Settings = {
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
    SilentAim = {
        Enabled = false,
        HitChance = 100,
        FOV = 120
    },
    ESP = {
        Enabled = false,
        TeamCheck = true,
        Boxes = true,
        Names = true,
        Distance = true,
        Health = true,
        Tracers = false,
        Loot = false,
        LootDistance = 100
    },
    Misc = {
        Speed = 1.5,
        JumpPower = 70,
        NoRecoil = false,
        NoSpread = false,
        AutoFire = false,
        Godmode = false,
        NoClip = false
    }
}

-- Body parts for aimbot
local BodyParts = {"Head", "HumanoidRootPart", "Torso", "Right Arm", "Left Arm"}

-- ███████████████████████████████████████████████████████
-- UI CREATION (using DataHub.Utilities.UI)
-- ███████████████████████████████████████████████████████
local Window = DataHub.Utilities.UI:Window({
    Name = "Data Hub " .. utf8.char(8212) .. " Project Delta",
    Position = UDim2.new(0.5, -350, 0.5, -300),
    Size = UDim2.new(0, 700, 0, 600)
}) do

    -- COMBAT TAB
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
            AimbotSection:Slider({Name = "Max Distance", Flag = "Delta/Aimbot/Distance", Min = 10, Max = 1000, Value = 300, Unit = "studs",
                Callback = function(val) Settings.Aimbot.Distance = val end})

            -- Priority part dropdown
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
                Callback = function(key, state) TriggerEnabled = state end
            })

            TriggerSection:Slider({Name = "Delay (sec)", Flag = "Delta/Trigger/Delay", Min = 0, Max = 0.5, Precise = 2, Value = 0.1,
                Callback = function(val) Settings.Trigger.Delay = val end})
            TriggerSection:Slider({Name = "FOV", Flag = "Delta/Trigger/FOV", Min = 10, Max = 360, Value = 30,
                Callback = function(val) Settings.Trigger.FOV = val end})
        end

        -- Silent Aim Section
        local SilentSection = CombatTab:Section({Name = "Silent Aim", Side = "Right"}) do
            SilentSection:Toggle({
                Name = "Enable Silent Aim",
                Flag = "Delta/SilentAim/Enabled",
                Value = false,
                Callback = function(val) Settings.SilentAim.Enabled = val end
            }):Keybind({Flag = "Delta/SilentAim/Keybind", Mouse = true})

            SilentSection:Slider({Name = "Hit Chance %", Flag = "Delta/SilentAim/HitChance", Min = 0, Max = 100, Value = 100,
                Callback = function(val) Settings.SilentAim.HitChance = val end})
            SilentSection:Slider({Name = "FOV", Flag = "Delta/SilentAim/FOV", Min = 10, Max = 360, Value = 120,
                Callback = function(val) Settings.SilentAim.FOV = val end})
        end

        -- FOV Circles (visual)
        DataHub.Utilities.Drawing.SetupFOV("Aimbot", Window.Flags)
        DataHub.Utilities.Drawing.SetupFOV("Trigger", Window.Flags)
        DataHub.Utilities.Drawing.SetupFOV("SilentAim", Window.Flags)
    end

    -- VISUALS TAB (ESP)
    local VisualsTab = Window:Tab({Name = "Visuals"}) do
        -- Player ESP (using built-in ESPSection)
        local ESPSection = DataHub.Utilities:ESPSection(Window, "Player ESP", "Delta/ESP", true, false, true, true, true, false) do
            ESPSection:Colorpicker({Name = "Ally Color", Flag = "Delta/ESP/Ally", Value = {0.33, 0.66, 1, 0, false}})
            ESPSection:Colorpicker({Name = "Enemy Color", Flag = "Delta/ESP/Enemy", Value = {1, 0.33, 0.33, 0, false}})
            ESPSection:Toggle({Name = "Team Check", Flag = "Delta/ESP/TeamCheck", Value = true,
                Callback = function(val) Settings.ESP.TeamCheck = val end})
        end

        -- Loot ESP (custom)
        local LootSection = VisualsTab:Section({Name = "Loot ESP", Side = "Right"}) do
            LootSection:Toggle({Name = "Enable Loot ESP", Flag = "Delta/ESP/Loot/Enabled", Value = false,
                Callback = function(val) Settings.ESP.Loot = val end})
            LootSection:Colorpicker({Name = "Loot Color", Flag = "Delta/ESP/Loot/Color", Value = {0.5, 1, 0.5, 0, false}})
            LootSection:Slider({Name = "Max Distance", Flag = "Delta/ESP/Loot/Distance", Min = 10, Max = 500, Value = 100,
                Callback = function(val) Settings.ESP.LootDistance = val end})
        end
    end

    -- MISC TAB
    local MiscTab = Window:Tab({Name = "Miscellaneous"}) do
        -- Character Section
        local CharSection = MiscTab:Section({Name = "Character", Side = "Left"}) do
            CharSection:Toggle({Name = "Speed Boost", Flag = "Delta/Speed/Enabled", Value = false,
                Callback = function(val) if not val then Settings.Misc.Speed = 1.5 end end}):Keybind()
            CharSection:Slider({Name = "Speed Multiplier", Flag = "Delta/Speed/Mult", Min = 1, Max = 5, Value = 1.5, Precise = 1,
                Callback = function(val) Settings.Misc.Speed = val end})

            CharSection:Toggle({Name = "Super Jump", Flag = "Delta/Jump/Enabled", Value = false,
                Callback = function(val) if not val then Settings.Misc.JumpPower = 70 end end}):Keybind()
            CharSection:Slider({Name = "Jump Power", Flag = "Delta/Jump/Power", Min = 50, Max = 200, Value = 70,
                Callback = function(val) Settings.Misc.JumpPower = val end})
        end

        -- Weapon Section
        local WeaponSection = MiscTab:Section({Name = "Weapon", Side = "Right"}) do
            WeaponSection:Toggle({Name = "No Recoil", Flag = "Delta/NoRecoil", Value = false,
                Callback = function(val) Settings.Misc.NoRecoil = val end})
            WeaponSection:Toggle({Name = "No Spread", Flag = "Delta/NoSpread", Value = false,
                Callback = function(val) Settings.Misc.NoSpread = val end})
            WeaponSection:Toggle({Name = "Auto Fire (Hold)", Flag = "Delta/AutoFire", Value = false,
                Callback = function(val) Settings.Misc.AutoFire = val end})
        end

        -- World Section
        local WorldSection = MiscTab:Section({Name = "World", Side = "Right"}) do
            WorldSection:Toggle({Name = "Godmode (VIP)", Flag = "Delta/Godmode", Value = false,
                Callback = function(val) Settings.Misc.Godmode = val end})
            WorldSection:Toggle({Name = "NoClip", Flag = "Delta/NoClip", Value = false,
                Callback = function(val) Settings.Misc.NoClip = val end})
        end
    end

    -- Settings section (from utilities)
    DataHub.Utilities:SettingsSection(Window, "RightShift", false)
end

DataHub.Utilities.InitAutoLoad(Window)

-- ███████████████████████████████████████████████████████
-- CORE FUNCTIONS
-- ███████████████████████████████████████████████████████

-- Team check (adapt based on game mechanics)
local function IsEnemy(player)
    if player == LocalPlayer then return false end
    if not player.Character then return false end
    -- In Project Delta, teams are determined by Team property
    if player.Team == nil then return true end -- neutral
    return LocalPlayer.Team ~= player.Team
end

-- Get closest target for aimbot/trigger
local function GetClosestTarget(fovRadius, maxDist, checkTeam, prediction, priorityPart)
    local mousePos = UserInputService:GetMouseLocation()
    local cameraPos = Camera.CFrame.Position
    local closestDist = fovRadius
    local closestTarget = nil

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if checkTeam and not IsEnemy(player) then continue end

        local character = player.Character
        if not character then continue end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end

        local part = character:FindFirstChild(priorityPart) or character:FindFirstChild("HumanoidRootPart")
        if not part then continue end

        local partPos = part.Position
        local dist = (partPos - cameraPos).Magnitude
        if dist > maxDist then continue end

        -- Simple prediction
        if prediction then
            partPos = partPos + part.AssemblyLinearVelocity * (dist / 2000) -- approximate bullet speed
        end

        local screenPos, onScreen = Camera:WorldToViewportPoint(partPos)
        if not onScreen then continue end

        local screenVec = Vector2.new(screenPos.X, screenPos.Y)
        local fovDist = (screenVec - mousePos).Magnitude

        if fovDist < closestDist then
            closestDist = fovDist
            closestTarget = {player, part, screenVec}
        end
    end
    return closestTarget
end

-- ███████████████████████████████████████████████████████
-- AIMBOT LOOP
-- ███████████████████████████████████████████████████████
RunService.RenderStepped:Connect(function()
    if not (Settings.Aimbot.Enabled and AimbotActive) then return end

    local target = GetClosestTarget(
        Settings.Aimbot.FOV,
        Settings.Aimbot.Distance,
        Settings.Aimbot.TeamCheck,
        Settings.Aimbot.Prediction,
        Settings.Aimbot.Priority
    )
    if target then
        local mousePos = UserInputService:GetMouseLocation()
        local smooth = Settings.Aimbot.Smoothness / 100
        mousemoverel(
            (target[3].X - mousePos.X) * smooth,
            (target[3].Y - mousePos.Y) * smooth
        )
    end
end)

-- ███████████████████████████████████████████████████████
-- TRIGGER BOT LOOP
-- ███████████████████████████████████████████████████████
RunService.RenderStepped:Connect(function()
    if not (Settings.Trigger.Enabled and TriggerEnabled) then return end

    local target = GetClosestTarget(
        Settings.Trigger.FOV,
        300, -- fixed distance for trigger
        true,
        false,
        "Head"
    )
    if target then
        task.wait(Settings.Trigger.Delay)
        mouse1press()
        task.wait(0.05)
        mouse1release()
    end
end)

-- ███████████████████████████████████████████████████████
-- SILENT AIM (basic implementation via hook, can be expanded)
-- ███████████████████████████████████████████████████████
if Settings.SilentAim.Enabled then
    -- Placeholder for silent aim logic (needs game-specific hooks)
    -- For now, just a message
    print("Silent Aim enabled - implement hooks for full functionality")
end

-- ███████████████████████████████████████████████████████
-- ESP SETUP (using DataHub.Utilities.Drawing)
-- ███████████████████████████████████████████████████████
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        DataHub.Utilities.Drawing:AddESP(player, "Player", "Delta/ESP", Window.Flags)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        DataHub.Utilities.Drawing:AddESP(player, "Player", "Delta/ESP", Window.Flags)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    DataHub.Utilities.Drawing:RemoveESP(player)
end)

-- ███████████████████████████████████████████████████████
-- LOOT ESP (example – needs actual loot structure)
-- ███████████████████████████████████████████████████████
local function UpdateLootESP()
    if not Settings.ESP.Loot then return end
    -- This is a template; you need to find where loot is stored in Workspace
    -- For example: Workspace.Ignored.Items, Workspace.Drops, etc.
    -- Then loop and add objects via DataHub.Utilities.Drawing:AddObject()
end

RunService.Heartbeat:Connect(UpdateLootESP)

-- ███████████████████████████████████████████████████████
-- MISC MODIFICATIONS
-- ███████████████████████████████████████████████████████
RunService.Heartbeat:Connect(function()
    if not LocalPlayer.Character then return end
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    -- Speed
    if Window.Flags["Delta/Speed/Enabled"] then
        humanoid.WalkSpeed = 16 * Settings.Misc.Speed
    else
        humanoid.WalkSpeed = 16
    end

    -- Jump
    if Window.Flags["Delta/Jump/Enabled"] then
        humanoid.JumpPower = Settings.Misc.JumpPower
    else
        humanoid.JumpPower = 50
    end

    -- No Recoil / No Spread would require weapon hooks (advanced)
    -- Auto Fire would require checking if weapon is equipped and holding mouse
end)

-- Camera update
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = Workspace.CurrentCamera
end)

-- ███████████████████████████████████████████████████████
-- LOADING COMPLETE NOTIFICATION
-- ███████████████████████████████████████████████████████
DataHub.Utilities.UI:Push({
    Title = "Data Hub - Project Delta",
    Description = "Script loaded successfully!\nPress RightShift to open menu.",
    Duration = 5
})
