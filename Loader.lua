print("=== НАЧАЛО ЗАГРУЗКИ ===")

print("1. Загрузка Utilities/Main...")
DataHub.Utilities = LoadScript("Utilities/Main")
print("✓ Utilities/Main загружен")

print("2. Загрузка Utilities/UI...")
DataHub.Utilities.UI = LoadScript("Utilities/UI")
print("✓ Utilities/UI загружен")

print("3. Загрузка Utilities/Physics...")
DataHub.Utilities.Physics = LoadScript("Utilities/Physics")
print("✓ Utilities/Physics загружен")

print("4. Загрузка Utilities/Drawing...")
DataHub.Utilities.Drawing = LoadScript("Utilities/Drawing")
print("✓ Utilities/Drawing загружен")

print("5. Загрузка основного скрипта игры...")
DataHub.Game = GetGameInfo()
LoadScript(DataHub.Game.Script)
print("✓ Основной скрипт загружен")
