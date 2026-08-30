-- modules/camerazoom.lua
-- Módulo para controle de zoom da câmera usando propriedades do Player

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local CameraZoom = {}
CameraZoom.__index = CameraZoom

-- Construtor
function CameraZoom.new(config)
    local self = setmetatable({}, CameraZoom)
    self.Config = config
    self.Enabled = false
    self.Active = true
    self.MaxDistance = config.Data.Settings.CameraZoomDistance or 500
    self.Connections = {}
    
    -- Obtém o jogador local
    self.Player = Players.LocalPlayer
    if not self.Player then
        error("LocalPlayer não encontrado")
    end
    
    -- Armazena os valores originais do jogador
    self.OriginalMax = self.Player.CameraMaxZoomDistance
    self.OriginalMin = self.Player.CameraMinZoomDistance
    
    return self
end

-- Inicializa o módulo (conecta eventos)
function CameraZoom:Start()
    -- Aplica o estado atual se estiver ativo
    if self.Enabled then
        self.Player.CameraMaxZoomDistance = self.MaxDistance
        self.Player.CameraMinZoomDistance = 0.5
    end
    
    -- Reage a mudanças de câmera (respawn, etc.)
    local function onCameraChanged()
        if self.Enabled and self.Active then
            self.Player.CameraMaxZoomDistance = self.MaxDistance
            self.Player.CameraMinZoomDistance = 0.5
        end
    end
    
    table.insert(self.Connections, Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(onCameraChanged))
end

-- Alterna o zoom customizado (ligar/desligar)
function CameraZoom:Toggle()
    self.Enabled = not self.Enabled
    self.Config.Data.Settings.CameraZoom = self.Enabled
    
    if self.Enabled then
        self.Player.CameraMaxZoomDistance = self.MaxDistance
        self.Player.CameraMinZoomDistance = 0.5
    else
        self.Player.CameraMaxZoomDistance = self.OriginalMax
        self.Player.CameraMinZoomDistance = self.OriginalMin
    end
    
    self.Config.Save()
    return self.Enabled
end

-- Define uma nova distância máxima
function CameraZoom:SetDistance(value)
    value = tonumber(value) or 500
    self.MaxDistance = value
    self.Config.Data.Settings.CameraZoomDistance = value
    
    if self.Enabled then
        self.Player.CameraMaxZoomDistance = value
    end
    
    self.Config.Save()
end

-- Define o zoom mínimo (opcional, pode ser usado separadamente)
function CameraZoom:SetMinDistance(value)
    value = tonumber(value) or 0.5
    if self.Enabled then
        self.Player.CameraMinZoomDistance = value
    end
    -- Se quiser salvar no config, adicione uma chave
end

-- Restaura valores originais e limpa conexões
function CameraZoom:Destroy()
    self.Active = false
    self.Enabled = false
    
    -- Restaura os valores originais
    if self.Player then
        self.Player.CameraMaxZoomDistance = self.OriginalMax
        self.Player.CameraMinZoomDistance = self.OriginalMin
    end
    
    -- Desconecta todos os eventos
    for _, conn in pairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    self.Connections = {}
end

return CameraZoom
