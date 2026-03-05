-- Data Hub - Deadline (RECOIL Studio)
-- ID игры: 1793802713 (или уточните актуальный)

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Camera = Workspace.CurrentCamera
local LocalPlayer = PlayerService.LocalPlayer

-- Переменные состояний
local AimbotActive = false
local TriggerActive = false

-- Настройки (можно будет менять через UI)
local Settings = {
    Aimbot = { Enabled = false, Key = "MouseButton2", Prediction = false, TeamCheck = true, FOV = 120, Smoothness = 20 },
    Trigger = { Enabled = false, Key = "MouseButton2", Delay = 0.1, FOV = 30 },
    ESP = { Enabled = false, TeamCheck = true, Boxes = true, Names = true, Distance = true },
    Misc = { NoRecoil = false, Speed = 1, JumpPower = 50, NoBreath = false }
}

-- Создаём главное окно
local Window = DataHub.Utilities.UI:Window({
    Name = "Data Hub " .. utf8.char(8212) .. " Deadline",
    Position = UDim2.new(0.5, -300, 0.5, -250),
    Size = UDim2.new(0, 600, 0, 500)
}) do

    ----- ВКЛАДКА "БОЙ" -----
    local CombatTab = Window:Tab({Name = "Бой"}) do

        -- Секция Aimbot
        local AimbotSection = CombatTab:Section({Name = "Aimbot", Side = "Left"}) do
            AimbotSection:Toggle({
                Name = "Включить",
                Flag = "Deadline/Aimbot/Enabled",
                Value = false,
                Callback = function(val) Settings.Aimbot.Enabled = val end
            }):Keybind({
                Flag = "Deadline/Aimbot/Keybind",
                Value = "MouseButton2",
                Mouse = true,
                Callback = function(key, state) AimbotActive = state end
            })

            AimbotSection:Toggle({Name = "Чек команды", Flag = "Deadline/Aimbot/TeamCheck", Value = true,
                Callback = function(val) Settings.Aimbot.TeamCheck = val end})
            AimbotSection:Toggle({Name = "Предсказание", Flag = "Deadline/Aimbot/Prediction", Value = false,
                Callback = function(val) Settings.Aimbot.Prediction = val end})
            AimbotSection:Slider({Name = "Угол обзора (FOV)", Flag = "Deadline/Aimbot/FOV/Radius", Min = 10, Max = 360, Value = 120,
                Callback = function(val) Settings.Aimbot.FOV = val end})
            AimbotSection:Slider({Name = "Плавность", Flag = "Deadline/Aimbot/Smoothness", Min = 1, Max = 100, Value = 20, Unit = "%",
                Callback = function(val) Settings.Aimbot.Smoothness = val end})

            -- Выбор приоритетной части тела
            local PartsList = {{Name = "Голова", Mode = "Button", Value = true}, {Name = "Туловище", Mode = "Button"}}
            AimbotSection:Dropdown({Name = "Приоритет", Flag = "Deadline/Aimbot/Priority", List = PartsList})
        end

        -- Секция Trigger Bot
        local TriggerSection = CombatTab:Section({Name = "Trigger Bot", Side = "Right"}) do
            TriggerSection:Toggle({
                Name = "Включить",
                Flag = "Deadline/Trigger/Enabled",
                Value = false,
                Callback = function(val) Settings.Trigger.Enabled = val end
            }):Keybind({
                Flag = "Deadline/Trigger/Keybind",
                Mouse = true,
                Callback = function(key, state) TriggerActive = state end
            })

            TriggerSection:Slider({Name = "Задержка (сек)", Flag = "Deadline/Trigger/Delay", Min = 0, Max = 0.5, Precise = 2, Value = 0.1,
                Callback = function(val) Settings.Trigger.Delay = val end})
            TriggerSection:Slider({Name = "FOV", Flag = "Deadline/Trigger/FOV/Radius", Min = 10, Max = 360, Value = 30,
                Callback = function(val) Settings.Trigger.FOV = val end})
        end

        -- Визуализация FOV кругов
        DataHub.Utilities.Drawing.SetupFOV("Aimbot", Window.Flags)
        DataHub.Utilities.Drawing.SetupFOV("Trigger", Window.Flags)
    end

    ----- ВКЛАДКА "ВИЗУАЛ" (ESP) -----
    local VisualsTab = Window:Tab({Name = "Визуал"}) do
        -- Используем готовый шаблон ESP из утилит
        local ESPSection = DataHub.Utilities:ESPSection(Window, "ESP Игроков", "Deadline/ESP", true, false, true, true, true, false) do
            ESPSection:Colorpicker({Name = "Цвет союзников", Flag = "Deadline/ESP/Ally", Value = {0.33, 0.66, 1, 0, false}})
            ESPSection:Colorpicker({Name = "Цвет врагов", Flag = "Deadline/ESP/Enemy", Value = {1, 0.33, 0.33, 0, false}})
            ESPSection:Toggle({Name = "Чек команды", Flag = "Deadline/ESP/TeamCheck", Value = true,
                Callback = function(val) Settings.ESP.TeamCheck = val end})
        end
    end

    ----- ВКЛАДКА "РАЗНОЕ" (Misc) -----
    local MiscTab = Window:Tab({Name = "Разное"}) do
        local CharSection = MiscTab:Section({Name = "Персонаж", Side = "Left"}) do
            CharSection:Toggle({Name = "Ускорение бега", Flag = "Deadline/Speed/Enabled", Value = false,
                Callback = function(val) Settings.Misc.Speed = val and 2 or 1 end}):Keybind()
            CharSection:Slider({Name = "Множитель", Flag = "Deadline/Speed/Mult", Min = 1, Max = 5, Value = 2,
                Callback = function(val) if Window.Flags["Deadline/Speed/Enabled"] then Settings.Misc.Speed = val end end})

            CharSection:Toggle({Name = "Супер-прыжок", Flag = "Deadline/Jump/Enabled", Value = false,
                Callback = function(val) Settings.Misc.JumpPower = val and 100 or 50 end}):Keybind()
        end

        local WeaponSection = MiscTab:Section({Name = "Оружие", Side = "Right"}) do
            WeaponSection:Toggle({Name = "Нет отдачи", Flag = "Deadline/NoRecoil", Value = false,
                Callback = function(val) Settings.Misc.NoRecoil = val end})
            WeaponSection:Toggle({Name = "Нет разброса", Flag = "Deadline/NoSpread", Value = false})
            WeaponSection:Toggle({Name = "Нет дрожи прицела", Flag = "Deadline/NoBreath", Value = false,
                Callback = function(val) Settings.Misc.NoBreath = val end})
        end
    end

    ----- ВКЛАДКА "VIP СЕРВЕР" (Команды для админов) -----
    local VIPTab = Window:Tab({Name = "VIP Сервер"}) do
        local CmdSection = VIPTab:Section({Name = "Консольные команды", Side = "Left"}) do
            CmdSection:Label({Text = "Работают только на VIP серверах"})
            CmdSection:Button({Name = "Отключить ограничения тюнинга", Callback = function()
                print("Выполните в консоли: ($dl.globals.disable_attachment_checks true)")
            end})
            CmdSection:Button({Name = "Сменить карту (Стрельбище)", Callback = function()
                print("Выполните в консоли: (dl.util.set_map \"dl_shooting_range\")")
            end})
            CmdSection:Button({Name = "Включить темный мир", Callback = function()
                print("Выполните сложную команду (см. консоль)")
            end})
        end
        local GravSection = VIPTab:Section({Name = "Гравитация / Скорость", Side = "Right"}) do
            GravSection:Slider({Name = "Гравитация", Flag = "Deadline/VIP/Gravity", Min = 10, Max = 200, Value = 196,
                Callback = function(val) print(string.format("Установите в консоли: ($dl.globals.gravity %d)", val)) end})
            GravSection:Slider({Name = "Скорость игрока", Flag = "Deadline/VIP/PlayerSpeed", Min = 5, Max = 50, Value = 16,
                Callback = function(val) print(string.format("Установите в консоли: ($dl.globals.debug_player_speed %d)", val)) end})
        end
    end

    -- Стандартная секция настроек (из утилит)
    DataHub.Utilities:SettingsSection(Window, "RightShift", false)
end

DataHub.Utilities.InitAutoLoad(Window)

----- ОСНОВНАЯ ЛОГИКА СКРИПТА -----

-- Функция проверки команды (в Deadline команды: Security и Insurgent)
local function IsEnemy(player)
    if player == LocalPlayer then return false end
    if not player.Character then return false end
    if player.Team == nil then return true end -- нейтралы?
    return LocalPlayer.Team ~= player.Team
end

-- Функция поиска ближайшего врага в FOV
local function GetClosestTarget(fovRadius, checkTeam, prediction, priorityPart)
    local mousePos = UserInputService:GetMouseLocation()
    local cameraPos = Camera.CFrame.Position
    local closestDist = fovRadius
    local closestTarget = nil
    local targetPart = priorityPart or "Head"

    for _, player in ipairs(PlayerService:GetPlayers()) do
        if player == LocalPlayer then continue end
        if checkTeam and not IsEnemy(player) then continue end

        local character = player.Character
        if not character then continue end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end

        local part = character:FindFirstChild(targetPart) or character:FindFirstChild("HumanoidRootPart")
        if not part then continue end

        local partPos = part.Position
        local dist = (partPos - cameraPos).Magnitude

        -- Простое предсказание
        if prediction then
            partPos = partPos + part.AssemblyLinearVelocity * (dist / 2000) -- скорость пули примерная
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

-- Логика Aimbot (движение мыши)
RunService.RenderStepped:Connect(function()
    if not (Settings.Aimbot.Enabled and AimbotActive) then return end

    local target = GetClosestTarget(
        Settings.Aimbot.FOV,
        Settings.Aimbot.TeamCheck,
        Settings.Aimbot.Prediction,
        Window.Flags["Deadline/Aimbot/Priority"][1]
    )
    if target then
        local mousePos = UserInputService:GetMouseLocation()
        local sens = Settings.Aimbot.Smoothness / 100
        mousemoverel(
            (target[3].X - mousePos.X) * sens,
            (target[3].Y - mousePos.Y) * sens
        )
    end
end)

-- Логика Trigger Bot
RunService.RenderStepped:Connect(function()
    if not (Settings.Trigger.Enabled and TriggerActive) then return end

    local target = GetClosestTarget(
        Settings.Trigger.FOV,
        true, -- всегда чек команды
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

-- ESP для игроков
for _, player in ipairs(PlayerService:GetPlayers()) do
    if player ~= LocalPlayer then
        DataHub.Utilities.Drawing:AddESP(player, "Player", "Deadline/ESP", Window.Flags)
    end
end

PlayerService.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        DataHub.Utilities.Drawing:AddESP(player, "Player", "Deadline/ESP", Window.Flags)
    end
end)

PlayerService.PlayerRemoving:Connect(function(player)
    DataHub.Utilities.Drawing:RemoveESP(player)
end)

-- Обработка изменения камеры
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = Workspace.CurrentCamera
end)

-- Сообщение о загрузке
DataHub.Utilities.UI:Push({
    Title = "Data Hub - Deadline",
    Description = "Скрипт загружен!\nИспользуйте RightShift для меню.",
    Duration = 5
})
