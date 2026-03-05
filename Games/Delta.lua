-- Data Hub : Project Delta Module

local DataHub = getgenv().DataHub
if not DataHub then return end

local UI = DataHub.Utilities.UI
local Physics = DataHub.Utilities.Physics
local Drawing = DataHub.Utilities.Drawing

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-------------------------------------------------
-- STATE
-------------------------------------------------

local Delta = {
    Toggles = {},
    Connections = {},
    ESP = {}
}

local currentWalkSpeed = 16
local currentJumpPower = 50

-------------------------------------------------
-- UI
-------------------------------------------------

local Window = UI:Window({
    Name = "Data Hub - Project Delta",
    Size = UDim2.new(0,520,0,360)
})

local PlayerTab = Window:Tab({Name = "Player"})
local VisualTab = Window:Tab({Name = "Visuals"})
local MiscTab = Window:Tab({Name = "Misc"})

-------------------------------------------------
-- PLAYER FUNCTIONS
-------------------------------------------------

PlayerTab:Slider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 100,
    Value = 16,

    Callback = function(value)
        currentWalkSpeed = value
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = value
        end
    end
})

PlayerTab:Slider({
    Name = "JumpPower",
    Min = 50,
    Max = 150,
    Value = 50,

    Callback = function(value)
        currentJumpPower = value
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = value
        end
    end
})

-- Persist speed and jump on respawn
table.insert(
    Delta.Connections,
    LocalPlayer.CharacterAdded:Connect(function(char)
        local humanoid = char:WaitForChild("Humanoid")
        humanoid.WalkSpeed = currentWalkSpeed
        humanoid.JumpPower = currentJumpPower
    end)
)

-- Initial set if character exists
local char = LocalPlayer.Character
if char then
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = currentWalkSpeed
        humanoid.JumpPower = currentJumpPower
    end
end

-------------------------------------------------
-- INFINITE JUMP
-------------------------------------------------

PlayerTab:Toggle({
    Name = "Infinite Jump",

    Callback = function(state)
        Delta.Toggles.InfJump = state
    end
})

table.insert(
    Delta.Connections,
    UserInputService.JumpRequest:Connect(function()
        if not Delta.Toggles.InfJump then
            return
        end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        if not hum then return end
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end)
)

-------------------------------------------------
-- ESP using custom Drawing utility
-------------------------------------------------

local Flags = {
    ["ESP/Player/Enabled"] = false,
    ["ESP/Player/Box/Enabled"] = true,
    ["ESP/Player/Box/Color"] = Color3.fromRGB(255, 0, 0),
    ["ESP/Player/Box/Outline"] = true,
    ["ESP/Player/Name/Enabled"] = true,
    ["ESP/Player/Name/Color"] = Color3.fromRGB(255, 255, 255),
    ["ESP/Player/Distance/Enabled"] = true,
    ["ESP/Player/Distance/Color"] = Color3.fromRGB(255, 255, 255),
    ["ESP/Player/Health/Enabled"] = true,
    ["ESP/Player/Health/Color"] = Color3.fromRGB(0, 255, 0),
    ["ESP/Player/Tracer/Enabled"] = true,
    ["ESP/Player/Tracer/Color"] = Color3.fromRGB(255, 0, 0),
    ["ESP/Player/Tracer/Outline"] = true,
    ["ESP/Player/HeadDot/Enabled"] = false,
    ["ESP/Player/TeamCheck"] = true,
    ["ESP/Player/DistanceCheck"] = false,
    ["ESP/Player/Distance"] = 1000,
    ["ESP/Player/TeamColor"] = false
}

local function AddESP(player)
    if player == LocalPlayer then return end
    Delta.ESP[player] = Drawing.AddESP(player, "Player", "ESP/Player", Flags)
end

local function RemoveESP(player)
    local esp = Delta.ESP[player]
    if esp then
        esp:Remove()
        Delta.ESP[player] = nil
    end
end

VisualTab:Toggle({
    Name = "Player ESP",

    Callback = function(state)
        Flags["ESP/Player/Enabled"] = state

        if state then
            for _, plr in pairs(Players:GetPlayers()) do
                AddESP(plr)
            end
        else
            for plr, esp in pairs(Delta.ESP) do
                RemoveESP(plr)
            end
            Delta.ESP = {}
        end
    end
})

-------------------------------------------------
-- ESP UPDATE LOOP
-------------------------------------------------

table.insert(
    Delta.Connections,
    RunService.RenderStepped:Connect(function()
        for player, esp in pairs(Delta.ESP) do
            Drawing.Update(esp, player)
        end
    end)
)

-------------------------------------------------
-- PLAYER JOIN/LEAVE
-------------------------------------------------

table.insert(
    Delta.Connections,
    Players.PlayerAdded:Connect(function(player)
        if Flags["ESP/Player/Enabled"] then
            AddESP(player)
        end
    end)
)

table.insert(
    Delta.Connections,
    Players.PlayerRemoving:Connect(function(player)
        RemoveESP(player)
    end)
)

-------------------------------------------------
-- MISC
-------------------------------------------------

MiscTab:Button({
    Name = "Rejoin Server",

    Callback = function()
        game:GetService("TeleportService"):Teleport(
            game.PlaceId,
            LocalPlayer
        )
    end
})

-------------------------------------------------
-- CLEANUP
-------------------------------------------------

function Delta:Unload()
    for _, con in pairs(self.Connections) do
        pcall(function()
            con:Disconnect()
        end)
    end
    for _, esp in pairs(self.ESP) do
        pcall(function()
            esp:Remove()
        end)
    end
    self.ESP = {}
end

-------------------------------------------------
-- NOTIFICATION
-------------------------------------------------

UI:Push({
    Title = "Data Hub",
    Description = "Project Delta module loaded successfully",
    Duration = 10
})
