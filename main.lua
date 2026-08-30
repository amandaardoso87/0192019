-- https://raw.githubusercontent.com/SEU_USER/UniversalHax/main/main.lua
-- ============================================
-- UNIVERSAL HAX - MODULAR LOADER
-- ============================================

-- Base URL do seu repositório (troque SEU_USER pelo seu nome de usuário do GitHub)
local BASE_URL = "https://raw.githubusercontent.com/amandaardoso87/0192019/main"

-- Função para carregar módulo remoto
local function LoadModule(path)
    local success, content = pcall(function()
        return game:HttpGet(BASE_URL .. "/" .. path)
    end)
    if not success then
        warn("❌ Falha ao carregar: " .. path)
        return nil
    end
    local fn, err = loadstring(content)
    if not fn then
        warn("❌ Erro ao compilar: " .. path .. " | " .. tostring(err))
        return nil
    end
    return fn()
end

-- Carregar biblioteca de UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Neospeed1kk/RochaFace/refs/heads/main/gui.lua"))()

-- Carregar Config
local Config = LoadModule("config.lua")
if not Config then
    warn("❌ Não foi possível carregar o config. Script abortado.")
    return
end
Config.Load()
Config.ForceOff()

-- Carregar Módulos
local CameraZoom = LoadModule("modules/camerazoom.lua")
local FullBright = LoadModule("modules/fullbright.lua")
local AimAssist = LoadModule("modules/aimassist.lua")
local ESP = LoadModule("modules/esp.lua")
local Fly = LoadModule("modules/fly.lua")
local Noclip = LoadModule("modules/noclip.lua")
local Speed = LoadModule("modules/speed.lua")
local AirJump = LoadModule("modules/airjump.lua")

-- Círculo do FOV
local circle = Drawing.new("Circle")
circle.Radius = Config.Data.Settings.FOV
circle.Visible = false
circle.Thickness = 2
circle.Color = Color3.new(1, 1, 1)

-- Instanciar módulos
local aim = AimAssist and AimAssist.new(Config, circle) or nil
local esp = ESP and ESP.new(Config) or nil
local fly = Fly and Fly.new(Config) or nil
local noclip = Noclip and Noclip.new(Config) or nil
local speed = Speed and Speed.new(Config) or nil
local airjump = AirJump and AirJump.new(Config) or nil

-- Iniciar módulos
if aim then aim:Start() end
if esp then esp:Start() end
if fly then fly:Start() end
if noclip then noclip:Start() end
if speed then speed:Start() end

-- Tabela de todas as connections do loader
local loaderConnections = {}
local scriptAtivo = true

-- ============================================
-- CRIAR GUI
-- ============================================
local Combat = Library:CreateCategory("Combate", UDim2.new(0, 50, 0, 100))
local Movement = Library:CreateCategory("Movimento", UDim2.new(0, 250, 0, 100))
local Visual = Library:CreateCategory("Visuais", UDim2.new(0, 450, 0, 100))
local Utils = Library:CreateCategory("Utilitários", UDim2.new(0, 650, 0, 100))

-- --- COMBATE ---
if aim then
    local AimModule = Combat:AddModule("Aim Assist", function(estado)
        aim.Enabled = estado
        Config.Data.Settings.AimAssist = estado
        circle.Visible = estado and Config.Data.Settings.FOVMode
        Config.Save()
    end, false)
    AimModule.Enabled = aim.Enabled

    Combat:AddModule("FOV Mode", function(estado)
        Config.Data.Settings.FOVMode = estado
        circle.Visible = aim.Enabled and estado
        Config.Save()
    end, false).Enabled = Config.Data.Settings.FOVMode

    Combat:AddModule("Team Check", function(estado)
        Config.Data.Settings.TeamCheck = estado
        Config.Save()
    end, false).Enabled = Config.Data.Settings.TeamCheck

    Combat:AddModule("Wall Check", function(estado)
        Config.Data.Settings.WallCheck = estado
        Config.Save()
    end, false).Enabled = Config.Data.Settings.WallCheck

    local FOVSlider = Combat:AddModule("FOV Size", function() end, false)
    FOVSlider:AddSlider("Tamanho", 50, 500, Config.Data.Settings.FOV, function(valor)
        Config.Data.Settings.FOV = valor
        circle.Radius = valor
        Config.Save()
    end)

    local BodyPartSlider = Combat:AddModule("Parte do Corpo", function() end, false)
    BodyPartSlider:AddSlider("0=Cabeça  1=Tronco  2=Pernas", 0, 2, Config.Data.Settings.BodyPart, function(valor)
        Config.Data.Settings.BodyPart = math.floor(valor)
        Config.Save()
    end)
end

-- --- MOVIMENTO ---
if airjump then
    local AJModule = Movement:AddModule("Air Jump", function(estado)
        airjump.Enabled = estado
        Config.Data.Settings.AirJump = estado
        Config.Save()
    end, false)
    AJModule.Enabled = airjump.Enabled

    AJModule:AddSlider("Força", 20, 100, airjump.Power, function(valor)
        airjump:SetPower(valor)
    end)
end

if speed then
    local SpdModule = Movement:AddModule("Velocidade", function(estado)
        speed:Toggle()
    end, false)
    SpdModule.Enabled = speed.Enabled

    SpdModule:AddSlider("Valor", 16, 200, speed.Value, function(valor)
        speed:SetValue(valor)
    end)
end

if fly then
    local FlyModule = Movement:AddModule("Fly", function(estado)
        fly:Toggle()
    end, false)
    FlyModule.Enabled = fly.Enabled

    FlyModule:AddSlider("Velocidade", 10, 300, fly.Speed, function(valor)
        fly:SetSpeed(valor)
    end)
end

if noclip then
    local NoclipModule = Movement:AddModule("NoClip", function(estado)
        noclip:Toggle()
    end, false)
    NoclipModule.Enabled = noclip.Enabled
end

-- --- VISUAIS ---
if esp then
    local ESPModule = Visual:AddModule("ESP", function(estado)
        esp:Toggle()
    end, false)
    ESPModule.Enabled = esp.Enabled
end

-- --- UTILITÁRIOS ---
Utils:AddModule("Salvar Config", function()
    Config.Save()
    print("💾 Salvo!")
end, true)

Utils:AddModule("Remover Script", function()
    -- Destroi todos os módulos
    if aim then aim:Destroy() end
    if esp then esp:Destroy() end
    if fly then fly:Destroy() end
    if noclip then noclip:Destroy() end
    if speed then speed:Destroy() end
    if airjump then airjump:Destroy() end
    
    -- Limpa o loader
    scriptAtivo = false
    pcall(function() circle:Remove() end)
    for _, conn in pairs(loaderConnections) do
        pcall(function() conn:Disconnect() end)
    end
    pcall(function()
        local gui = game:GetService("CoreGui"):FindFirstChild("ManusGuiLib")
        if gui then gui:Destroy() end
    end)
    print("🗑️ Script removido por completo!")
end, true)

-- ============================================
-- INPUT (Mouse + Teclado K + Air Jump)
-- ============================================
local UserInputService = game:GetService("UserInputService")

table.insert(loaderConnections, UserInputService.InputBegan:Connect(function(input, gp)
    if gp and input.UserInputType == Enum.UserInputType.Keyboard then return end
    
    -- K = remove tudo
    if input.KeyCode == Enum.KeyCode.K then
        if aim then aim:Destroy() end
        if esp then esp:Destroy() end
        if fly then fly:Destroy() end
        if noclip then noclip:Destroy() end
        if speed then speed:Destroy() end
        if airjump then airjump:Destroy() end
        scriptAtivo = false
        pcall(function() circle:Remove() end)
        for _, conn in pairs(loaderConnections) do
            pcall(function() conn:Disconnect() end)
        end
        pcall(function()
            local gui = game:GetService("CoreGui"):FindFirstChild("ManusGuiLib")
            if gui then gui:Destroy() end
        end)
        return
    end

    -- Botão direito = aiming
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if aim then aim:SetAiming(true) end
    end

    -- Space = air jump (só se fly NÃO estiver ativo)
    if input.KeyCode == Enum.KeyCode.Space then
        if airjump and fly and not fly.Enabled then
            airjump:TryJump()
        elseif airjump and not fly then
            airjump:TryJump()
        end
    end
end))

table.insert(loaderConnections, UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if aim then aim:SetAiming(false) end
    end
end))

-- ============================================
-- KEYBINDS
-- ============================================
local function getKeyCode(keyName)
    if keyName == "None" then return nil end
    return Enum.KeyCode[keyName]
end

Library:AddKeybind("Aim Assist", getKeyCode(Config.Data.Keybinds.AimAssist), function(key, pressed)
    if pressed then
        if aim then
            local newState = aim:Toggle()
            -- Atualiza visual do botão (simplificado)
            Config.Save()
        end
    else
        Config.Data.Keybinds.AimAssist = key.Name
        Config.Save()
    end
end)

Library:AddKeybind("ESP", getKeyCode(Config.Data.Keybinds.ESP), function(key, pressed)
    if pressed then
        if esp then esp:Toggle() end
    else
        Config.Data.Keybinds.ESP = key.Name
        Config.Save()
    end
end)

Library:AddKeybind("Air Jump", getKeyCode(Config.Data.Keybinds.AirJump), function(key, pressed)
    if pressed then
        if airjump then airjump:Toggle() end
    else
        Config.Data.Keybinds.AirJump = key.Name
        Config.Save()
    end
end)

-- Auto-save a cada 10s
task.spawn(function()
    while scriptAtivo do
        task.wait(10)
        if scriptAtivo then Config.Save() end
    end
end)

print("✅ Universal Hax (MODULAR) carregado!")
print("🔹 Cada módulo é carregado separadamente do GitHub.")
print("🔹 Para adicionar algo novo, só crie um novo arquivo em modules/")
