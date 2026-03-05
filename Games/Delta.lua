-- Data Hub - Project Delta (Visuals Only, Minimal)
-- Game ID: 2862098693
-- Features: ESP for players, containers, quest items, vehicles, death history

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

if not DataHub or not DataHub.Utilities or not DataHub.Utilities.UI then
    warn("DataHub UI not loaded")
    return
end

local DrawingLib = DataHub.Utilities.Drawing
if not DrawingLib then
    warn("Drawing library not loaded")
    return
end

-- Простое окно с одной вкладкой
local Window = DataHub.Utilities.UI:Window({
    Name = "Data Hub Visuals",
    Position = UDim2.new(0.5, -200, 0.5, -150),
    Size = UDim2.new(0, 400, 0, 300)
})

local VisualsTab = Window:Tab({Name = "Visuals"})

-- Общие настройки
local GeneralSection = VisualsTab:Section({Name = "General", Side = "Left"})
GeneralSection:Toggle({Name = "ESP Enabled", Flag = "Delta/Visuals/Enabled", Value = false})
GeneralSection:Slider({Name = "Max Distance", Flag = "Delta/Visuals/MaxDistance", Min = 100, Max = 5000, Value = 1000})

-- Player ESP (используем встроенную секцию)
DataHub.Utilities:ESPSection(Window, "Players", "Delta/ESP", true, false, true, true, true, false)

-- Лут
local LootSection = VisualsTab:Section({Name = "Loot", Side = "Right"})
LootSection:Toggle({Name = "Show Containers", Flag = "Delta/Visuals/Loot", Value = false})
LootSection:Colorpicker({Name = "Color", Flag = "Delta/Visuals/LootColor", Value = {1,1,1,0,false}})

-- Квесты
local QuestSection = VisualsTab:Section({Name = "Quest Items", Side = "Right"})
QuestSection:Toggle({Name = "Show Quest Items", Flag = "Delta/Visuals/Quests", Value = false})
QuestSection:Colorpicker({Name = "Color", Flag = "Delta/Visuals/QuestColor", Value = {0,1,0,0,false}})

-- Машины
local VehicleSection = VisualsTab:Section({Name = "Vehicles", Side = "Right"})
VehicleSection:Toggle({Name = "Show Vehicles", Flag = "Delta/Visuals/Vehicles", Value = false})
VehicleSection:Colorpicker({Name = "Color", Flag = "Delta/Visuals/VehicleColor", Value = {0,0,1,0,false}})

-- История смертей
local DeathSection = VisualsTab:Section({Name = "Death History", Side = "Right"})
DeathSection:Toggle({Name = "Show Deaths", Flag = "Delta/Visuals/Deaths", Value = false})
DeathSection:Colorpicker({Name = "Color", Flag = "Delta/Visuals/DeathColor", Value = {1,0,0,0,false}})

DataHub.Utilities.InitAutoLoad(Window)

-- ESP для игроков (через библиотеку)
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        DrawingLib.AddESP(player, "Player", "Delta/ESP", Window.Flags)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        DrawingLib.AddESP(player, "Player", "Delta/ESP", Window.Flags)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    DrawingLib.RemoveESP(player)
end)

-- Кастомные объекты
local function CreateObjectESP(list, obj, name, position)
    if not obj or not position then return end
    local text = DrawingLib.AddDrawing("Text", { Size = 12, Center = true, Outline = true })
    table.insert(list, { obj = obj, text = text, position = position })
end

local function UpdateObjectESP(list, flag, colorFlag)
    if not Window.Flags[flag] then
        for _, entry in ipairs(list) do
            entry.text.Visible = false
        end
        return
    end
    local color = Color3.fromHSV(
        Window.Flags[colorFlag][1] or 0,
        Window.Flags[colorFlag][2] or 1,
        Window.Flags[colorFlag][3] or 1
    )
    local maxDist = Window.Flags["Delta/Visuals/MaxDistance"]
    for _, entry in ipairs(list) do
        local obj = entry.obj
        if obj and obj.Parent then
            local pos = entry.position.Value or entry.position.Position
            local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
            if onScreen then
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

-- Собираем объекты
local LootObjects = {}
local QuestObjects = {}
local VehicleObjects = {}

if Workspace:FindFirstChild("Containers") then
    for _, item in ipairs(Workspace.Containers:GetChildren()) do
        CreateObjectESP(LootObjects, item, item.Name, item:FindFirstChild("Part") or item)
    end
    Workspace.Containers.ChildAdded:Connect(function(item)
        CreateObjectESP(LootObjects, item, item.Name, item:FindFirstChild("Part") or item)
    end)
end

if Workspace:FindFirstChild("QuestItems") then
    for _, q in ipairs(Workspace.QuestItems:GetChildren()) do
        CreateObjectESP(QuestObjects, q, q.Name, q:FindFirstChild("Part") or q)
    end
    Workspace.QuestItems.ChildAdded:Connect(function(q)
        CreateObjectESP(QuestObjects, q, q.Name, q:FindFirstChild("Part") or q)
    end)
end

if Workspace:FindFirstChild("Vehicles") then
    for _, v in ipairs(Workspace.Vehicles:GetChildren()) do
        CreateObjectESP(VehicleObjects, v, v.Name, v:FindFirstChild("PrimaryPart") or v)
    end
    Workspace.Vehicles.ChildAdded:Connect(function(v)
        CreateObjectESP(VehicleObjects, v, v.Name, v:FindFirstChild("PrimaryPart") or v)
    end)
end

-- История смертей (простая)
local Deaths = {}
local DeathCount = 0

local function OnDied(player)
    if not Window.Flags["Delta/Visuals/Deaths"] then return end
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    DeathCount = DeathCount + 1
    local text = DrawingLib.AddDrawing("Text", { Size = 14, Center = true, Outline = true })
    table.insert(Deaths, { pos = root.Position, text = text, count = DeathCount })
end

for _, p in ipairs(Players:GetPlayers()) do
    if p.Character then
        local hum = p.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Died:Connect(function() OnDied(p) end)
        end
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid")
        hum.Died:Connect(function() OnDied(p) end)
    end)
end)

-- Цикл обновления
RunService.Heartbeat:Connect(function()
    if not Window.Flags["Delta/Visuals/Enabled"] then
        for _, list in ipairs({LootObjects, QuestObjects, VehicleObjects}) do
            for _, e in ipairs(list) do
                e.text.Visible = false
            end
        end
        for _, d in ipairs(Deaths) do
            d.text.Visible = false
        end
        return
    end

    UpdateObjectESP(LootObjects, "Delta/Visuals/Loot", "Delta/Visuals/LootColor")
    UpdateObjectESP(QuestObjects, "Delta/Visuals/Quests", "Delta/Visuals/QuestColor")
    UpdateObjectESP(VehicleObjects, "Delta/Visuals/Vehicles", "Delta/Visuals/VehicleColor")

    -- Deaths
    if Window.Flags["Delta/Visuals/Deaths"] then
        local color = Color3.fromHSV(
            Window.Flags["Delta/Visuals/DeathColor"][1] or 0,
            Window.Flags["Delta/Visuals/DeathColor"][2] or 1,
            Window.Flags["Delta/Visuals/DeathColor"][3] or 1
        )
        local maxDist = Window.Flags["Delta/Visuals/MaxDistance"]
        for _, d in ipairs(Deaths) do
            local screenPos, onScreen = Camera:WorldToViewportPoint(d.pos)
            if onScreen then
                local dist = (d.pos - Camera.CFrame.Position).Magnitude
                if dist <= maxDist then
                    d.text.Visible = true
                    d.text.Text = "☠️ " .. d.count
                    d.text.Color = color
                    d.text.Position = Vector2.new(screenPos.X, screenPos.Y)
                else
                    d.text.Visible = false
                end
            else
                d.text.Visible = false
            end
        end
    else
        for _, d in ipairs(Deaths) do
            d.text.Visible = false
        end
    end
end)

print("Data Hub Visuals loaded")
