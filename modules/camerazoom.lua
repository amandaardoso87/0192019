-- modules/camerazoom.lua
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

print("[modules/camerazoom.lua] loaded")

local CameraZoom = {}
CameraZoom.__index = CameraZoom

function CameraZoom.new(config)
    local self = setmetatable({}, CameraZoom)
    self.Config = config
    self.Enabled = false
    self.Active = true
    self.MaxDistance = (config and config.Data and config.Data.Settings.CameraZoomDistance) or 500
    self.Connections = {}
    print("[CameraZoom] new() - MaxDistance:", tostring(self.MaxDistance))

    self.Player = Players.LocalPlayer
    if not self.Player then
        error("LocalPlayer não encontrado")
    end

    self.OriginalMax = self.Player.CameraMaxZoomDistance
    self.OriginalMin = self.Player.CameraMinZoomDistance

    return self
end

function CameraZoom:Start()
    print("[CameraZoom] Start()")
    if self.Enabled then
        self.Player.CameraMaxZoomDistance = self.MaxDistance
        self.Player.CameraMinZoomDistance = 0.5
    end

    local function onCameraChanged()
        if self.Enabled and self.Active then
            self.Player.CameraMaxZoomDistance = self.MaxDistance
            self.Player.CameraMinZoomDistance = 0.5
        end
    end

    table.insert(self.Connections, Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(onCameraChanged))
end

function CameraZoom:Toggle()
    self.Enabled = not self.Enabled
    self.Config.Data.Settings.CameraZoom = self.Enabled
    print("[CameraZoom] Toggle() ->", tostring(self.Enabled))

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

function CameraZoom:SetDistance(value)
    value = tonumber(value) or 500
    self.MaxDistance = value
    self.Config.Data.Settings.CameraZoomDistance = value
    print("[CameraZoom] SetDistance ->", tostring(value))

    if self.Enabled then
        self.Player.CameraMaxZoomDistance = value
    end

    self.Config.Save()
end

function CameraZoom:SetMinDistance(value)
    value = tonumber(value) or 0.5
    if self.Enabled then
        self.Player.CameraMinZoomDistance = value
    end
end

function CameraZoom:Destroy()
    print("[CameraZoom] Destroy()")
    self.Active = false
    self.Enabled = false

    if self.Player then
        self.Player.CameraMaxZoomDistance = self.OriginalMax
        self.Player.CameraMinZoomDistance = self.OriginalMin
    end

    for _, conn in pairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    self.Connections = {}
end

return CameraZoom
