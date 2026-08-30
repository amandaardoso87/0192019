local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local CameraZoom = {}
CameraZoom.__index = CameraZoom

function CameraZoom.new(config)
    local self = setmetatable({}, CameraZoom)
    self.Config = config
    self.Enabled = false
    self.Active = true
    self.MaxDistance = config.Data.Settings.CameraZoomDistance or 500
    self.Connections = {}
    self.OriginalMax = Camera.CameraMaxZoomDistance
    self.OriginalMin = Camera.CameraMinZoomDistance
    return self
end

function CameraZoom:Start()
    table.insert(self.Connections, RunService.RenderStepped:Connect(function()
        if not self.Active then return end
        if not self.Enabled then return end
        -- Força toda frame porque alguns jogos resetam em loop
        if Camera.CameraMaxZoomDistance ~= self.MaxDistance then
            Camera.CameraMaxZoomDistance = self.MaxDistance
        end
        if Camera.CameraMinZoomDistance ~= 0.5 then
            Camera.CameraMinZoomDistance = 0.5
        end
    end))
end

function CameraZoom:Toggle()
    self.Enabled = not self.Enabled
    self.Config.Data.Settings.CameraZoom = self.Enabled
    if self.Enabled then
        Camera.CameraMaxZoomDistance = self.MaxDistance
        Camera.CameraMinZoomDistance = 0.5
    else
        Camera.CameraMaxZoomDistance = self.OriginalMax
        Camera.CameraMinZoomDistance = self.OriginalMin
    end
    self.Config.Save()
    return self.Enabled
end

function CameraZoom:SetDistance(value)
    self.MaxDistance = value
    self.Config.Data.Settings.CameraZoomDistance = value
    if self.Enabled then
        Camera.CameraMaxZoomDistance = value
    end
    self.Config.Save()
end

function CameraZoom:Destroy()
    self.Active = false
    self.Enabled = false
    Camera.CameraMaxZoomDistance = self.OriginalMax
    Camera.CameraMinZoomDistance = self.OriginalMin
    for _, conn in pairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    self.Connections = {}
end

return CameraZoom
