local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local CameraZoom = {}
CameraZoom.__index = CameraZoom

function CameraZoom.new(config)
    local self = setmetatable({}, CameraZoom)
    self.Config = config
    self.Enabled = false
    self.Active = true
    self.MaxDistance = config.Data.Settings.CameraZoomDistance or 500
    self.Connections = {}
    self.OriginalMax = LocalPlayer.CameraMaxZoomDistance
    self.OriginalMin = LocalPlayer.CameraMinZoomDistance
    return self
end

function CameraZoom:Start()
    table.insert(self.Connections, RunService.RenderStepped:Connect(function()
        if not self.Active then return end
        if not self.Enabled then return end
        if LocalPlayer.CameraMaxZoomDistance ~= self.MaxDistance then
            LocalPlayer.CameraMaxZoomDistance = self.MaxDistance
        end
        if LocalPlayer.CameraMinZoomDistance ~= 0.5 then
            LocalPlayer.CameraMinZoomDistance = 0.5
        end
    end))
end

function CameraZoom:Toggle()
    self.Enabled = not self.Enabled
    self.Config.Data.Settings.CameraZoom = self.Enabled
    if self.Enabled then
        LocalPlayer.CameraMaxZoomDistance = self.MaxDistance
        LocalPlayer.CameraMinZoomDistance = 0.5
    else
        LocalPlayer.CameraMaxZoomDistance = self.OriginalMax
        LocalPlayer.CameraMinZoomDistance = self.OriginalMin
    end
    self.Config.Save()
    return self.Enabled
end

function CameraZoom:SetDistance(value)
    self.MaxDistance = value
    self.Config.Data.Settings.CameraZoomDistance = value
    if self.Enabled then
        LocalPlayer.CameraMaxZoomDistance = value
    end
    self.Config.Save()
end

function CameraZoom:Destroy()
    self.Active = false
    self.Enabled = false
    LocalPlayer.CameraMaxZoomDistance = self.OriginalMax
    LocalPlayer.CameraMinZoomDistance = self.OriginalMin
    for _, conn in pairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    self.Connections = {}
end

return CameraZoom
