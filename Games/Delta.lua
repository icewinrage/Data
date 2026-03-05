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
    ESPObjects = {}
}

-------------------------------------------------
-- UI
-------------------------------------------------

local Window = UI:CreateWindow({
    Title = "Data Hub - Project Delta",
    Size = UDim2.new(0,520,0,360)
})

local PlayerTab = Window:CreateTab("Player")
local VisualTab = Window:CreateTab("Visuals")
local MiscTab = Window:CreateTab("Misc")

-------------------------------------------------
-- PLAYER FUNCTIONS
-------------------------------------------------

PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 100,
    Default = 16,

    Callback = function(value)

        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = value
        end

    end
})

PlayerTab:CreateSlider({
    Name = "JumpPower",
    Min = 50,
    Max = 150,
    Default = 50,

    Callback = function(value)

        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = value
        end

    end
})

-------------------------------------------------
-- INFINITE JUMP
-------------------------------------------------

PlayerTab:CreateToggle({
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
-- ESP
-------------------------------------------------

local function CreateESP(player)

    if player == LocalPlayer then return end

    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(255,0,0)
    box.Thickness = 2
    box.Filled = false

    Delta.ESPObjects[player] = box

end

local function RemoveESP(player)

    local obj = Delta.ESPObjects[player]
    if obj then
        obj:Remove()
        Delta.ESPObjects[player] = nil
    end

end

VisualTab:CreateToggle({
    Name = "Player ESP",

    Callback = function(state)

        Delta.Toggles.ESP = state

        if state then

            for _,plr in pairs(Players:GetPlayers()) do
                CreateESP(plr)
            end

        else

            for _,obj in pairs(Delta.ESPObjects) do
                obj:Remove()
            end

            Delta.ESPObjects = {}

        end

    end
})

-------------------------------------------------
-- ESP UPDATE LOOP
-------------------------------------------------

table.insert(
    Delta.Connections,
    RunService.RenderStepped:Connect(function()

        if not Delta.Toggles.ESP then
            return
        end

        for player,box in pairs(Delta.ESPObjects) do

            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if hrp then

                local pos, visible =
                    workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)

                box.Visible = visible

                box.Size = Vector2.new(40,60)
                box.Position = Vector2.new(pos.X-20,pos.Y-30)

            else

                box.Visible = false

            end

        end

    end)
)

-------------------------------------------------
-- PLAYER JOIN
-------------------------------------------------

table.insert(
    Delta.Connections,
    Players.PlayerAdded:Connect(function(player)

        if Delta.Toggles.ESP then
            CreateESP(player)
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

MiscTab:CreateButton({
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

    for _,con in pairs(self.Connections) do
        pcall(function()
            con:Disconnect()
        end)
    end

    for _,obj in pairs(self.ESPObjects) do
        pcall(function()
            obj:Remove()
        end)
    end

end

-------------------------------------------------
-- NOTIFICATION
-------------------------------------------------

UI:Push({
    Title = "Data Hub",
    Description = "Project Delta module loaded",
    Duration = 10
})
