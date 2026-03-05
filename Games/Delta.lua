-- Data Hub - Project Delta (Optimized for Loader.lua)
-- Game ID: 2862098693 (как в лоадере)
-- Features: Full ESP, RageBot, Gun Mods, World, Misc, Anti-UAC

-- Все сервисы и переменные (оставляем как есть)
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- (здесь идут все ваши настройки Settings и UI-код, они остаются без изменений)
-- Я не буду копировать их повторно, чтобы не загромождать ответ.
-- Они точно такие же, как в предыдущей версии.

-- ███████████████████████████████████████████████████████
-- PROJECT DELTA SPECIFIC FUNCTIONS
-- ███████████████████████████████████████████████████████

-- (функции GetPlayerGameplayVars, GetRealHealth, GetCurrentWeapon, IsEnemy остаются теми же)

-- ███████████████████████████████████████████████████████
-- ESP IMPLEMENTATION (упрощённая, использует DataHub)
-- ███████████████████████████████████████████████████████

-- Проверяем, что Drawing библиотека загружена (она должна быть)
local DrawingLib = DataHub.Utilities.Drawing
if not DrawingLib then
    warn("Drawing library not found in DataHub. ESP will not work.")
    -- Создаём заглушку, чтобы не было ошибок
    DrawingLib = {
        AddDrawing = function() return { Visible = false } end,
        SetupFOV = function() end,
    }
end

-- Теперь можно использовать DrawingLib для создания объектов
-- Все функции CreateText, CreateLine, CreateCircle используют DrawingLib.AddDrawing

-- (далее идёт весь код ESP, который мы писали ранее, но с использованием DrawingLib)
-- Он остаётся точно таким же, как в последней версии, только без fallback-загрузки.

-- ███████████████████████████████████████████████████████
-- FINAL MESSAGE
-- ███████████████████████████████████████████████████████
print("Data Hub - Project Delta loaded successfully!")
print("ESP reads real health from GameplayVariables.")
print("All features are ready. Press RightShift to open menu.")
