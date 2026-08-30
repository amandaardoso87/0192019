local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local CameraZoom = {}
CameraZoom.__index = CameraZoom

local function safeSetCameraProperty(cam, prop, value)
    if not cam then return end
    local ok, err = pcall(function()
        cam[prop] = value
    end)
    if not ok then
        warn(string.format("Failed to set %s: %s", prop, err))
    end
end

function CameraZoom.new(config)
    local self = setmetatable({}, CameraZoom)
    self.Config = config
    self.Enabled = false
    self.Active = true
    self.MaxDistance = config.Data.Settings.CameraZoomDistance or 500
    self.Connections = {}
    self.OriginalMax = nil
    self.OriginalMin = nil
    return self
end

function CameraZoom:Start()
    -- Store originals only once, with safety
    local cam = Workspace.CurrentCamera
    if cam then
        self.OriginalMax = pcall(function() return cam.MaxZoomDistance end) and cam.MaxZoomDistance or nil
        self.OriginalMin = pcall(function() return cam.MinZoomDistance end) and cam.MinZoomDistance or nil
    end

    if self.Enabled then
        safeSetCameraProperty(cam, "MaxZoomDistance", self.MaxDistance)
        safeSetCameraProperty(cam, "MinZoomDistance", 0.5)
    end

    -- React to camera changes
    local function onCameraChanged()
        local newCam = Workspace.CurrentCamera
        if newCam and self.Enabled then
            safeSetCameraProperty(newCam, "MaxZoomDistance", self.MaxDistance)
            safeSetCameraProperty(newCam, "MinZoomDistance", 0.5)
        end
    end
    table.insert(self.Connections, Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(onCameraChanged))
end

function CameraZoom:Toggle()
    self.Enabled = not self.Enabled
    self.Config.Data.Settings.CameraZoom = self.Enabled
    local cam = Workspace.CurrentCamera
    if self.Enabled then
        safeSetCameraProperty(cam, "MaxZoomDistance", self.MaxDistance)
        safeSetCameraProperty(cam, "MinZoomDistance", 0.5)
    else
        safeSetCameraProperty(cam, "MaxZoomDistance", self.OriginalMax)
        safeSetCameraProperty(cam, "MinZoomDistance", self.OriginalMin)
    end
    self.Config.Save()
    return self.Enabled
end

function CameraZoom:SetDistance(value)
    self.MaxDistance = value
    self.Config.Data.Settings.CameraZoomDistance = value
    if self.Enabled then
        safeSetCameraProperty(Workspace.CurrentCamera, "MaxZoomDistance", value)
    end
    self.Config.Save()
end

function CameraZoom:Destroy()
    self.Active = false
    self.Enabled = false
    local cam = Workspace.CurrentCamera
    safeSetCameraProperty(cam, "MaxZoomDistance", self.OriginalMax)
    safeSetCameraProperty(cam, "MinZoomDistance", self.OriginalMin)
    for _, conn in pairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    self.Connections = {}
end

return CameraZoom
