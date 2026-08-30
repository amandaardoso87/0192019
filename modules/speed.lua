-- https://raw.githubusercontent.com/SEU_USER/UniversalHax/main/modules/speed.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

print("[modules/speed.lua] loaded")

local Speed = {}
Speed.__index = Speed

function Speed.new(config)
    local self = setmetatable({}, Speed)
    self.Config = config
    self.Enabled = false
    self.Active = true
    self.Value = (config and config.Data and config.Data.Settings.SpeedValue) or 16
    self.Connections = {}
    print("[Speed] new() - Value:", tostring(self.Value))
    return self
end

function Speed:ApplySpeed()
    local char = LocalPlayer.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = self.Enabled and self.Value or 16
    end
end

function Speed:Start()
    print("[Speed] Start()")
    table.insert(self.Connections, RunService.RenderStepped:Connect(function()
        if not self.Active or not self.Enabled then return end
        local char = LocalPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.WalkSpeed ~= self.Value then
            humanoid.WalkSpeed = self.Value
        end
    end))
end

function Speed:Toggle()
    self.Enabled = not self.Enabled
    self.Config.Data.Settings.SpeedEnabled = self.Enabled
    print("[Speed] Toggle() ->", tostring(self.Enabled))
    self:ApplySpeed()
    self.Config.Save()
    return self.Enabled
end

function Speed:SetValue(value)
    self.Value = math.floor(value)
    self.Config.Data.Settings.SpeedValue = self.Value
    print("[Speed] SetValue ->", tostring(self.Value))
    if self.Enabled then self:ApplySpeed() end
    self.Config.Save()
end

function Speed:Destroy()
    print("[Speed] Destroy()")
    self.Active = false
    self.Enabled = false
    local char = LocalPlayer.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.WalkSpeed = 16 end
    for _, conn in pairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    self.Connections = {}
end

return Speed
