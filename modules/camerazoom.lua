local Player = game.Players.LocalPlayer
local Camera = Workspace.CurrentCamera

function CameraZoom.new(config)
    local self = setmetatable({}, CameraZoom)
    self.Config = config
    self.Enabled = false
    self.Active = true
    self.MaxDistance = config.Data.Settings.CameraZoomDistance or 500
    self.Connections = {}
    self.OriginalMax = Player.CameraMaxZoomDistance
    self.OriginalMin = Player.CameraMinZoomDistance
    return self
end

function CameraZoom:Start()
    -- Não use RenderStepped
    if self.Enabled then
        Player.CameraMaxZoomDistance = self.MaxDistance
        Player.CameraMinZoomDistance = 0.5
    end
    -- Opcional: reagir a troca de câmera
    table.insert(self.Connections, Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        if self.Enabled then
            Player.CameraMaxZoomDistance = self.MaxDistance
            Player.CameraMinZoomDistance = 0.5
        end
    end))
end

function CameraZoom:Toggle()
    self.Enabled = not self.Enabled
    self.Config.Data.Settings.CameraZoom = self.Enabled
    if self.Enabled then
        Player.CameraMaxZoomDistance = self.MaxDistance
        Player.CameraMinZoomDistance = 0.5
    else
        Player.CameraMaxZoomDistance = self.OriginalMax
        Player.CameraMinZoomDistance = self.OriginalMin
    end
    self.Config.Save()
    return self.Enabled
end

-- SetDistance e Destroy adaptados igualmente
