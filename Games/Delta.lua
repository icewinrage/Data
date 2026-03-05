-- Data Hub - Project Delta (Viking Studios)
-- ID игры: 6483626525 (проверьте актуальный ID в игре)

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Camera = Workspace.CurrentCamera
local LocalPlayer = PlayerService.LocalPlayer

-- Переменные состояний
local AimbotActive = false
local TriggerActive = false

-- Основные части тела для прицеливания
local BodyParts = {
    "Head", "HumanoidRootPart", "Torso", "Right Arm", "Left Arm"
}

-- Создаём главное окно
local Window = DataHub.Utilities.UI:Window({
    Name = "Data Hub " .. utf8.char(8212) .. " Project Delta",
    Position = UDim2.new(0.5, -300, 0.5, -250),
    Size = UDim2.new(0, 600, 0, 500)
}) do

    ----- ВКЛАДКА "БОЙ" -----
    local CombatTab = Window:Tab({Name = "Бой"}) do

        -- Секция Aimbot
        local AimbotSection = CombatTab:Section({Name = "Aimbot", Side = "Left"}) do
            AimbotSection:Toggle({
                Name = "Включить Aimbot",
                Flag = "Delta/Aimbot/Enabled",
                Value = false,
                Callback = function(val) Settings.Aimbot.Enabled = val end
            }):Keybind({
                Flag = "Delta/Aimbot/Keybind",
                Value = "MouseButton2",
                Mouse = true,
                Callback = function(key, state) AimbotActive = state end
            })

            AimbotSection:Toggle({Name = "Чек команды", Flag = "Delta/Aimbot/TeamCheck", Value = true})
            AimbotSection:Toggle({Name = "Предсказание", Flag = "Delta/Aimbot/Prediction", Value = false})
            AimbotSection:Slider({Name = "Чувствительность", Flag = "Delta/Aimbot/Sensitivity", Min = 1, Max = 100, Value = 30, Unit = "%"})
            AimbotSection:Slider({Name = "Дистанция", Flag = "Delta/Aimbot/Distance", Min = 10, Max = 1000, Value = 300, Unit = "studs"})
            AimbotSection:Slider({Name = "FOV", Flag = "Delta/Aimbot/FOV/Radius", Min = 10, Max = 360, Value = 120})

            -- Выбор приоритетной части тела
            local PartsList = {}
            for _, part in ipairs(BodyParts) do
                table.insert(PartsList, {Name = part, Mode = "Button", Value = part == "Head"})
            end
            AimbotSection:Dropdown({Name = "Приоритет", Flag = "Delta/Aimbot/Priority", List = PartsList})
        end

        -- Секция Silent Aim
        local SilentSection = CombatTab:Section({Name = "Silent Aim", Side = "Right"}) do
            SilentSection:Toggle({
                Name = "Включить Silent Aim",
                Flag = "Delta/SilentAim/Enabled",
                Value = false
            }):Keybind({Flag = "Delta/SilentAim/Keybind", Mouse = true})

            SilentSection:Slider({Name = "Шанс попадания", Flag = "Delta/SilentAim/HitChance", Min = 0, Max = 100, Value = 100})
            SilentSection:Slider({Name = "FOV", Flag = "Delta/SilentAim/FOV/Radius", Min = 10, Max = 360, Value = 120})
        end

        -- Секция Trigger Bot
        local TriggerSection = CombatTab:Section({Name = "Trigger Bot", Side = "Right"}) do
            TriggerSection:Toggle({
                Name = "Включить Trigger",
                Flag = "Delta/Trigger/Enabled",
                Value = false,
                Callback = function(val) TriggerActive = val end
            }):Keybind({Flag = "Delta/Trigger/Keybind", Mouse = true})

            TriggerSection:Slider({Name = "Задержка (сек)", Flag = "Delta/Trigger/Delay", Min = 0, Max = 0.5, Precise = 2, Value = 0.1})
            TriggerSection:Slider({Name = "FOV", Flag = "Delta/Trigger/FOV/Radius", Min = 10, Max = 360, Value = 30})
        end

        -- Визуализация FOV кругов
        DataHub.Utilities.Drawing.SetupFOV("Aimbot", Window.Flags)
        DataHub.Utilities.Drawing.SetupFOV("SilentAim", Window.Flags)
        DataHub.Utilities.Drawing.SetupFOV("Trigger", Window.Flags)
    end

    ----- ВКЛАДКА "ВИЗУАЛ" (ESP) -----
    local VisualsTab = Window:Tab({Name = "Визуал"}) do
        -- ESP для игроков (используем готовую секцию из утилит)
        local ESPSection = DataHub.Utilities:ESPSection(Window, "ESP Игроков", "Delta/ESP", true, false, true, true, true, false) do
            ESPSection:Colorpicker({Name = "Цвет союзников", Flag = "Delta/ESP/Ally", Value = {0.33, 0.66, 1, 0, false}})
            ESPSection:Colorpicker({Name = "Цвет врагов", Flag = "Delta/ESP/Enemy", Value = {1, 0.33, 0.33, 0, false}})
            ESPSection:Toggle({Name = "Чек команды", Flag = "Delta/ESP/TeamCheck", Value = true})
        end

        -- ESP для лута (кастомная секция)
        local LootSection = VisualsTab:Section({Name = "ESP Лута", Side = "Right"}) do
            LootSection:Toggle({Name = "Включить", Flag = "Delta/ESP/Loot/Enabled", Value = false})
            LootSection:Colorpicker({Name = "Цвет", Flag = "Delta/ESP/Loot/Color", Value = {0.5, 1, 0.5, 0, false}})
            LootSection:Slider({Name = "Дистанция", Flag = "Delta/ESP/Loot/Distance", Min = 10, Max = 500, Value = 100})
        end
    end

    ----- ВКЛАДКА "РАЗНОЕ" (Misc) -----
    local MiscTab = Window:Tab({Name = "Разное"}) do
        local CharSection = MiscTab:Section({Name = "Персонаж", Side = "Left"}) do
            CharSection:Toggle({Name = "Ускорение бега", Flag = "Delta/Speed/Enabled", Value = false}):Keybind()
            CharSection:Slider({Name = "Множитель скорости", Flag = "Delta/Speed/Mult", Min = 1, Max = 3, Value = 1.5})

            CharSection:Toggle({Name = "Супер-прыжок", Flag = "Delta/Jump/Enabled", Value = false}):Keybind()
            CharSection:Slider({Name = "Высота прыжка", Flag = "Delta/Jump/Power", Min = 10, Max = 100, Value = 50})
        end

        local WeaponSection = MiscTab:Section({Name = "Оружие", Side = "Right"}) do
            WeaponSection:Toggle({Name = "Нет отдачи", Flag = "Delta/NoRecoil", Value = false})
            WeaponSection:Toggle({Name = "Нет разброса", Flag = "Delta/NoSpread", Value = false})
            WeaponSection:Toggle({Name = "Автоматическая стрельба", Flag = "Delta/AutoFire", Value = false})
        end

        local WorldSection = MiscTab:Section({Name = "Мир", Side = "Right"}) do
            WeaponSection:Toggle({Name = "Иммортал (бессмертие)", Flag = "Delta/Godmode", Value = false})
            WeaponSection:Toggle({Name = "NoClip (проход сквозь стены)", Flag = "Delta/NoClip", Value = false})
        end
    end

    -- Секция настроек (из утилит)
    DataHub.Utilities:SettingsSection(Window, "RightShift", false)
end

DataHub.Utilities.InitAutoLoad(Window)

----- ОСНОВНАЯ ЛОГИКА СКРИПТА -----

-- Таблица для хранения настроек
local Settings = {
    Aimbot = { Enabled = false, TeamCheck = true, Prediction = false, Sensitivity = 30, Distance = 300, FOV = 120 },
    Trigger = { Enabled = false, Delay = 0.1, FOV = 30 },
    ESP = { Enabled = false, TeamCheck = true },
    Misc = { SpeedMult = 1.5, JumpPower = 50, NoRecoil = false, NoSpread = false, AutoFire = false, Godmode = false, NoClip = false }
}

-- Функция проверки команды (в Project Delta фракции: Wastelanders, Bandits, etc.)
local function IsEnemy(player)
    if player == LocalPlayer then return false end
    if not player.Character then return false end
    
    -- В Project Delta команды определяются через Team
    if player.Team == nil then return true end
    return LocalPlayer.Team ~= player.Team
end

-- Функция поиска ближайшей цели
local function GetClosestTarget(fovRadius, maxDist, checkTeam, prediction, priorityPart)
    local mousePos = UserInputService:GetMouseLocation()
    local cameraPos = Camera.CFrame.Position
    local closestDist = fovRadius
    local closestTarget = nil

    for _, player in ipairs(PlayerService:GetPlayers()) do
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

        -- Простое предсказание
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

-- Логика Aimbot
RunService.RenderStepped:Connect(function()
    if not (Window.Flags["Delta/Aimbot/Enabled"] and AimbotActive) then return end

    local target = GetClosestTarget(
        Window.Flags["Delta/Aimbot/FOV/Radius"],
        Window.Flags["Delta/Aimbot/Distance"],
        Window.Flags["Delta/Aimbot/TeamCheck"],
        Window.Flags["Delta/Aimbot/Prediction"],
        Window.Flags["Delta/Aimbot/Priority"][1]
    )
    if target then
        local mousePos = UserInputService:GetMouseLocation()
        local sens = Window.Flags["Delta/Aimbot/Sensitivity"] / 100
        mousemoverel(
            (target[3].X - mousePos.X) * sens,
            (target[3].Y - mousePos.Y) * sens
        )
    end
end)

-- Логика Trigger Bot
RunService.RenderStepped:Connect(function()
    if not (Window.Flags["Delta/Trigger/Enabled"] and TriggerActive) then return end

    local target = GetClosestTarget(
        Window.Flags["Delta/Trigger/FOV/Radius"],
        300, -- фиксированная дистанция для триггера
        true,
        false,
        "Head"
    )
    if target then
        task.wait(Window.Flags["Delta/Trigger/Delay"])
        mouse1press()
        task.wait(0.05)
        mouse1release()
    end
end)

-- ESP для игроков
for _, player in ipairs(PlayerService:GetPlayers()) do
    if player ~= LocalPlayer then
        DataHub.Utilities.Drawing:AddESP(player, "Player", "Delta/ESP", Window.Flags)
    end
end

PlayerService.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        DataHub.Utilities.Drawing:AddESP(player, "Player", "Delta/ESP", Window.Flags)
    end
end)

PlayerService.PlayerRemoving:Connect(function(player)
    DataHub.Utilities.Drawing:RemoveESP(player)
end)

-- ESP для лута (пример, нужно адаптировать под структуру игры)
if Window.Flags["Delta/ESP/Loot/Enabled"] then
    -- Здесь можно добавить поиск лута в Workspace
    -- Например: for _, item in ipairs(Workspace.Ignored.Items:GetChildren()) do ...
end

-- Модификаторы персонажа (скорость, прыжок)
RunService.Heartbeat:Connect(function()
    if not LocalPlayer.Character then return end
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    if Window.Flags["Delta/Speed/Enabled"] then
        humanoid.WalkSpeed = 16 * Window.Flags["Delta/Speed/Mult"]
    else
        humanoid.WalkSpeed = 16
    end

    if Window.Flags["Delta/Jump/Enabled"] then
        humanoid.JumpPower = Window.Flags["Delta/Jump/Power"]
    else
        humanoid.JumpPower = 50
    end
end)

-- Обработка изменения камеры
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = Workspace.CurrentCamera
end)

-- Сообщение о загрузке
DataHub.Utilities.UI:Push({
    Title = "Data Hub - Project Delta",
    Description = "Скрипт загружен!\nИспользуйте RightShift для меню.",
    Duration = 5
})
