-- https://raw.githubusercontent.com/SEU_USER/UniversalHax/main/modules/noclip.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Noclip = {}
Noclip.__index = Noclip

function Noclip.new(config)
    local self = setmetatable({}, Noclip)
    self.Config = config
    self.Enabled = false
    self.Active = true
    self.Connections = {}
    return self
end

function Noclip:RestoreCollision()
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in pairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
end

function Noclip:Start()
    -- Stepped roda ANTES da física = mais confiável
    table.insert(self.Connections, RunService.Stepped:Connect(function()
        if not self.Active or not self.Enabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end))
end

function Noclip:Toggle()
    self.Enabled = not self.Enabled
    self.Config.Data.Settings.Noclip = self.Enabled
    if not self.Enabled then
        self:RestoreCollision()
    end
    self.Config.Save()
    return self.Enabled
end

function Noclip:Destroy()
    self.Active = false
    self.Enabled = false
    self:RestoreCollision()
    for _, conn in pairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    self.Connections = {}
end

return Noclip
