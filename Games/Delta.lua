-- Data Hub - Project Delta (Stable Edition)
-- Game ID: 6483626525
-- Focus: Aimbot, Trigger, ESP, Misc (без Speed/Jump)

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

-- Settings tables
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
    ESP = {
        Enabled = false,
        TeamCheck = true,
        Boxes = true,
        Names = true,
        Distance = true,
        Health = true,
        Tracers = false
    },
    Misc = {
        NoRecoil = false,
        NoSpread = false,
        AutoFire = false
    }
}

-- Body parts
local BodyParts = {"Head", "HumanoidRootPart", "Torso", "Right Arm", "Left Arm"}

-- Проверка на наличие UI-библиотеки
if not DataHub or not DataHub.Utilities or not DataHub.Utilities.UI then
    warn("Data Hub UI library not loaded. Cannot create window.")
    return
end

-- ███████████████████████████████████████████████████████
-- UI CREATION (with error handling)
-- ███████████████████████████████████████████████████████
local Window = nil
local success, err = pcall(function()
    Window = DataHub.Utilities.UI:Window({
        Name = "Data Hub " .. utf8.char(8212) .. " Project Delta",
        Position = UDim2.new(0.5, -350, 0.5, -300),
        Size = UDim2.new(0, 700, 0, 600)
    })
end)
if not success then
    warn("Failed to create window:", err)
    return
end

-- Define tabs inside pcall to catch errors
pcall(function()
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

        -- FOV Circles (visual)
        DataHub.Utilities.Drawing.SetupFOV("Aimbot", Window.Flags)
        DataHub.Utilities.Drawing.SetupFOV("Trigger", Window.Flags)
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
    end

    -- MISC TAB (without Speed/Jump)
    local MiscTab = Window:Tab({Name = "Misc"}) do
        -- Weapon Section
        local WeaponSection = MiscTab:Section({Name = "Weapon", Side = "Left"}) do
            WeaponSection:Toggle({Name = "No Recoil", Flag = "Delta/NoRecoil", Value = false,
                Callback = function(val) Settings.Misc.NoRecoil = val end})
            WeaponSection:Toggle({Name = "No Spread", Flag = "Delta/NoSpread", Value = false,
                Callback = function(val) Settings.Misc.NoSpread = val end})
            WeaponSection:Toggle({Name = "Auto Fire", Flag = "Delta/AutoFire", Value = false,
                Callback = function(val) Settings.Misc.AutoFire = val end})
        end
    end

    -- Settings section (from utilities)
    DataHub.Utilities:SettingsSection(Window, "RightShift", false)
end)

DataHub.Utilities.InitAutoLoad(Window)

-- ███████████████████████████████████████████████████████
-- CORE FUNCTIONS (with nil checks)
-- ███████████████████████████████████████████████████████

local function IsEnemy(player)
    if player == LocalPlayer then return false end
    if not player.Character then return false end
    -- In Project Delta, teams are determined by Team property
    if player.Team == nil then return true end -- neutral
    return LocalPlayer.Team ~= player.Team
end

local function GetClosestTarget(fovRadius, maxDist, checkTeam, prediction, priorityPart)
    if not Camera then return nil end
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

        -- Simple prediction (approximate bullet speed)
        if prediction then
            partPos = partPos + part.AssemblyLinearVelocity * (dist / 2000)
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
    if not Window then return end -- safety

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
    if not (Settings.Trigger.Enabled and TriggerActive) then return end
    if not Window then return end

    local target = GetClosestTarget(
        Settings.Trigger.FOV,
        300, -- fixed distance
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
-- ESP SETUP (players only)
-- ███████████████████████████████████████████████████████
if Window then
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            pcall(function()
                DataHub.Utilities.Drawing:AddESP(player, "Player", "Delta/ESP", Window.Flags)
            end)
        end
    end

    Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            pcall(function()
                DataHub.Utilities.Drawing:AddESP(player, "Player", "Delta/ESP", Window.Flags)
            end)
        end
    end)

    Players.PlayerRemoving:Connect(function(player)
        pcall(function()
            DataHub.Utilities.Drawing:RemoveESP(player)
        end)
    end)
end

-- Camera update
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = Workspace.CurrentCamera
end)

-- ███████████████████████████████████████████████████████
-- LOADING COMPLETE NOTIFICATION
-- ███████████████████████████████████████████████████████
pcall(function()
    DataHub.Utilities.UI:Push({
        Title = "Data Hub - Project Delta",
        Description = "Script loaded successfully!\nPress RightShift to open menu.",
        Duration = 5
    })
end)
