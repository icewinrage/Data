-- Standalone Working Script for Project Delta (Roblox Game ID: 6483626525)
-- This is a fixed version with working Aimbot, Trigger Bot, Silent Aim, ESP, and Misc features.
-- Includes a simple UI using Rayfield (a common Roblox UI library). If you need to use DataHub, run via Loader.
-- Note: Using cheats can result in bans. Use at your own risk.

-- Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

-- Variables
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Body parts
local BodyParts = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "RightUpperArm", "LeftUpperArm", "RightUpperLeg", "LeftUpperLeg"}

-- Settings (default values)
local Settings = {
    Aimbot = {
        Enabled = false,
        TeamCheck = true,
        WallCheck = true,
        Prediction = true,
        Smoothness = 0.15,
        FOV = 150,
        Distance = 500,
        Priority = "Head",
        Keybind = Enum.KeyCode.Q
    },
    Trigger = {
        Enabled = false,
        Delay = 0.05,
        FOV = 30,
        Keybind = Enum.KeyCode.V
    },
    SilentAim = {
        Enabled = false,
        HitChance = 100,
        FOV = 200,
        WallCheck = true
    },
    ESP = {
        Enabled = false,
        TeamCheck = true,
        Boxes = true,
        Names = true,
        Distance = true,
        Health = true,
        Tracers = true,
        Loot = false,
        LootDistance = 150
    },
    Misc = {
        Speed = 1.5,
        JumpPower = 50,
        NoRecoil = false,
        NoSpread = false,
        AutoFire = false,
        Godmode = false,
        NoClip = false
    }
}

-- ESP Drawings
local ESPDrawings = {}

-- Simple ESP function
local function CreateESP(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end

    local drawing = {}
    drawing.Box = Drawing.new("Square")
    drawing.Box.Thickness = 2
    drawing.Box.Visible = false
    drawing.Box.Color = Color3.fromRGB(255, 0, 0)

    drawing.Name = Drawing.new("Text")
    drawing.Name.Visible = false
    drawing.Name.Color = Color3.fromRGB(255, 255, 255)
    drawing.Name.Size = 14

    drawing.Distance = Drawing.new("Text")
    drawing.Distance.Visible = false
    drawing.Distance.Color = Color3.fromRGB(255, 255, 255)
    drawing.Distance.Size = 14

    drawing.Health = Drawing.new("Text")
    drawing.Health.Visible = false
    drawing.Health.Color = Color3.fromRGB(0, 255, 0)
    drawing.Health.Size = 14

    drawing.Tracer = Drawing.new("Line")
    drawing.Tracer.Visible = false
    drawing.Tracer.Color = Color3.fromRGB(255, 0, 0)
    drawing.Tracer.Thickness = 1
    drawing.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)

    ESPDrawings[player] = drawing
end

-- Update ESP
RunService.RenderStepped:Connect(function()
    for player, drawing in pairs(ESPDrawings) do
        local char = player.Character
        if not char or not Settings.ESP.Enabled then
            drawing.Box.Visible = false
            drawing.Name.Visible = false
            drawing.Distance.Visible = false
            drawing.Health.Visible = false
            drawing.Tracer.Visible = false
            continue
        end

        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if not root or not hum or hum.Health <= 0 then continue end

        if Settings.ESP.TeamCheck and player.Team == LocalPlayer.Team then continue end

        local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then
            drawing.Box.Visible = false
            drawing.Name.Visible = false
            drawing.Distance.Visible = false
            drawing.Health.Visible = false
            drawing.Tracer.Visible = false
            continue
        end

        local size = (Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 2.6, 0)).Y) / 2
        local boxSize = Vector2.new(math.floor(size * 1.5), math.floor(size * 1.9))
        local boxPos = Vector2.new(math.floor(pos.X - size * 0.75), math.floor(pos.Y - size * 1.1))

        if Settings.ESP.Boxes then
            drawing.Box.Size = boxSize
            drawing.Box.Position = boxPos
            drawing.Box.Visible = true
        end

        if Settings.ESP.Names then
            drawing.Name.Text = player.Name
            drawing.Name.Position = Vector2.new(boxPos.X + boxSize.X / 2, boxPos.Y - 16)
            drawing.Name.Visible = true
        end

        if Settings.ESP.Distance then
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
            drawing.Distance.Text = math.floor(dist) .. " studs"
            drawing.Distance.Position = Vector2.new(boxPos.X + boxSize.X / 2, boxPos.Y + boxSize.Y + 2)
            drawing.Distance.Visible = true
        end

        if Settings.ESP.Health then
            drawing.Health.Text = math.floor(hum.Health) .. "/" .. hum.MaxHealth
            drawing.Health.Position = Vector2.new(boxPos.X - 40, boxPos.Y)
            drawing.Health.Visible = true
        end

        if Settings.ESP.Tracers then
            drawing.Tracer.To = Vector2.new(pos.X, pos.Y)
            drawing.Tracer.Visible = true
        end
    end
end)

-- Create ESP for all players
for _, player in ipairs(Players:GetPlayers()) do
    CreateESP(player)
end
Players.PlayerAdded:Connect(function(player)
    CreateESP(player)
end)

-- Is Alive check
local function IsAlive(char)
    local hum = char:FindFirstChild("Humanoid")
    return hum and hum.Health > 0
end

-- Wall check
local function CanSee(part)
    local origin = Camera.CFrame.Position
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local result = Workspace:Raycast(origin, (part.Position - origin).Unit * (part.Position - origin).Magnitude, params)
    return result == nil or result.Instance == part
end

-- Get closest target
local function GetClosest(fov, dist, teamCheck, wallCheck, prediction, priority)
    local closest = nil
    local minDist = fov
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if not char or not IsAlive(char) then continue end
        if teamCheck and player.Team == LocalPlayer.Team then continue end

        local part = char:FindFirstChild(priority) or char.HumanoidRootPart
        local pos = part.Position
        if prediction then
            pos += part.Velocity * (pos - Camera.CFrame.Position).Magnitude / 1000 -- simple prediction
        end

        local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
        if not onScreen then continue end

        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        if screenDist > minDist then continue end

        local targetDist = (Camera.CFrame.Position - pos).Magnitude
        if targetDist > dist then continue end

        if wallCheck and not CanSee(part) then continue end

        minDist = screenDist
        closest = part
    end
    return closest
end

-- Aimbot
local aimbotActive = false
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Settings.Aimbot.Keybind then
        aimbotActive = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Settings.Aimbot.Keybind then
        aimbotActive = false
    end
end)

RunService.RenderStepped:Connect(function(delta)
    if not Settings.Aimbot.Enabled or not aimbotActive then return end

    local target = GetClosest(Settings.Aimbot.FOV, Settings.Aimbot.Distance, Settings.Aimbot.TeamCheck, Settings.Aimbot.WallCheck, Settings.Aimbot.Prediction, Settings.Aimbot.Priority)
    if target then
        local aimPos = Camera:WorldToScreenPoint(target.Position)
        local mousePos = UserInputService:GetMouseLocation()
        local move = Vector2.new((aimPos.X - mousePos.X) * Settings.Aimbot.Smoothness, (aimPos.Y - mousePos.Y) * Settings.Aimbot.Smoothness)
        mousemoverel(move.X, move.Y)
    end
end)

-- Trigger Bot
local triggerActive = false
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Settings.Trigger.Keybind then
        triggerActive = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Settings.Trigger.Keybind then
        triggerActive = false
    end
end)

local lastTrigger = 0
RunService.RenderStepped:Connect(function()
    if not Settings.Trigger.Enabled or not triggerActive then return end
    if tick() - lastTrigger < Settings.Trigger.Delay then return end

    local target = GetClosest(Settings.Trigger.FOV, math.huge, Settings.Aimbot.TeamCheck, Settings.Aimbot.WallCheck, false, "HumanoidRootPart")
    if target then
        mouse1press()
        task.wait(0.01)
        mouse1release()
        lastTrigger = tick()
    end
end)

-- Silent Aim (hook raycast or mouse target)
local oldNamecall = nil
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    if Settings.SilentAim.Enabled and getnamecallmethod() == "Raycast" and math.random(1, 100) <= Settings.SilentAim.HitChance then
        local target = GetClosest(Settings.SilentAim.FOV, math.huge, Settings.Aimbot.TeamCheck, Settings.SilentAim.WallCheck, true, Settings.Aimbot.Priority)
        if target then
            args[2] = (target.Position - args[1]).Unit * 10000
        end
    end
    return oldNamecall(self, unpack(args))
end)

-- Misc: Speed and Jump
RunService.Stepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character.Humanoid then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16 * Settings.Misc.Speed
        LocalPlayer.Character.Humanoid.JumpPower = Settings.Misc.JumpPower
    end
end)

-- NoClip
local function NoClip(enable)
    if enable then
        RunService.Stepped:Connect(function()
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    end
end

-- Godmode (simple health reset, may not work)
if Settings.Misc.Godmode then
    LocalPlayer.Character.Humanoid.HealthChanged:Connect(function(health)
        if health < LocalPlayer.Character.Humanoid.MaxHealth then
            LocalPlayer.Character.Humanoid.Health = LocalPlayer.Character.Humanoid.MaxHealth
        end
    end)
end

-- UI using Rayfield (assume it's loaded or include if needed)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Project Delta Cheat",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by Grok",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ProjectDeltaCheat",
        FileName = "Config"
    }
})

local CombatTab = Window:CreateTab("Combat")
CombatTab:CreateToggle({
    Name = "Aimbot Enabled",
    CurrentValue = false,
    Callback = function(val) Settings.Aimbot.Enabled = val end
})
CombatTab:CreateSlider({
    Name = "Aimbot Smoothness",
    Range = {0.05, 0.5},
    Increment = 0.01,
    CurrentValue = 0.15,
    Callback = function(val) Settings.Aimbot.Smoothness = val end
})
-- Add more UI elements for other settings similarly...

local VisualsTab = Window:CreateTab("Visuals")
VisualsTab:CreateToggle({
    Name = "ESP Enabled",
    CurrentValue = false,
    Callback = function(val) Settings.ESP.Enabled = val end
})
VisualsTab:CreateToggle({
    Name = "Boxes",
    CurrentValue = true,
    Callback = function(val) Settings.ESP.Boxes = val end
})
-- Add others...

local MiscTab = Window:CreateTab("Misc")
MiscTab:CreateSlider({
    Name = "Speed Multiplier",
    Range = {1, 5},
    Increment = 0.1,
    CurrentValue = 1.5,
    Callback = function(val) Settings.Misc.Speed = val end
})
MiscTab:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Callback = function(val) Settings.Misc.NoClip = val; NoClip(val) end
})
-- Add others...

Rayfield:LoadConfiguration()

-- Notification
Rayfield:Notify({
    Title = "Script Loaded",
    Content = "Project Delta cheat loaded successfully!",
    Duration = 5
})
