local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local FullBright = {}
FullBright.__index = FullBright

function FullBright.new(config)
    local self = setmetatable({}, FullBright)
    self.Config = config
    self.Enabled = false
    self.Active = true
    self.Intensity = config.Data.Settings.FullBrightIntensity or 3
    self.Connections = {}
    
    -- Salva originals
    self.Originals = {
        Brightness = Lighting.Brightness,
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        ClockTime = Lighting.ClockTime,
        FogEnd = Lighting.FogEnd,
        FogStart = Lighting.FogStart,
        GlobalShadows = Lighting.GlobalShadows,
        AtmosphereDensity = 0
    }
    
    -- Salva atmosphere se existir
    self.Atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
    if self.Atmosphere then
        self.Originals.AtmosphereDensity = self.Atmosphere.Density
        self.Originals.AtmosphereOffset = self.Atmosphere.Offset
    end
    
    return self
end

function FullBright:Apply()
    local i = self.Intensity
    Lighting.Brightness = i
    Lighting.Ambient = Color3.new(i/3, i/3, i/3)
    Lighting.OutdoorAmbient = Color3.new(i/3, i/3, i/3)
    Lighting.ClockTime = 14.5
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
    
    if self.Atmosphere and self.Atmosphere.Parent then
        self.Atmosphere.Density = 0
        self.Atmosphere.Offset = 0
    end
end

function FullBright:Restore()
    Lighting.Brightness = self.Originals.Brightness
    Lighting.Ambient = self.Originals.Ambient
    Lighting.OutdoorAmbient = self.Originals.OutdoorAmbient
    Lighting.ClockTime = self.Originals.ClockTime
    Lighting.FogEnd = self.Originals.FogEnd
    Lighting.GlobalShadows = self.Originals.GlobalShadows
    
    if self.Atmosphere and self.Atmosphere.Parent then
        self.Atmosphere.Density = self.Originals.AtmosphereDensity
        self.Atmosphere.Offset = self.Originals.AtmosphereOffset
    end
end

function FullBright:Start()
    -- Monitora pra caso o jogo resetar a iluminação
    table.insert(self.Connections, RunService.RenderStepped:Connect(function()
        if not self.Active or not self.Enabled then return end
        if Lighting.Brightness ~= self.Intensity then
            self:Apply()
        end
    end))
end

function FullBright:Toggle()
    self.Enabled = not self.Enabled
    self.Config.Data.Settings.FullBright = self.Enabled
    if self.Enabled then
        self:Apply()
    else
        self:Restore()
    end
    self.Config.Save()
    return self.Enabled
end

function FullBright:SetIntensity(value)
    self.Intensity = value
    self.Config.Data.Settings.FullBrightIntensity = value
    if self.Enabled then
        self:Apply()
    end
    self.Config.Save()
end

function FullBright:Destroy()
    self.Active = false
    self.Enabled = false
    self:Restore()
    for _, conn in pairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    self.Connections = {}
end

return FullBright
print("Carregando fullbright.lua")
