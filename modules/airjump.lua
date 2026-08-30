-- https://raw.githubusercontent.com/SEU_USER/UniversalHax/main/modules/airjump.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local AirJump = {}
AirJump.__index = AirJump

function AirJump.new(config)
    local self = setmetatable({}, AirJump)
    self.Config = config
    self.Enabled = false
    self.Active = true
    self.Power = config.Data.Settings.AirJumpPower or 50
    return self
end

-- Retorna true se executou o air jump (para o main saber)
function AirJump:TryJump()
    if not self.Active or not self.Enabled then return false end
    local char = LocalPlayer.Character
    if not char then return false end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if humanoid and hrp then
        -- Só ativa se NÃO estiver no chão
        if not humanoid:IsDescendantOf(workspace) then return false end
        local state = humanoid:GetState()
        if state ~= Enum.HumanoidStateType.Freefall 
           and state ~= Enum.HumanoidStateType.Jumping then
            return false
        end
        hrp.Velocity = Vector3.new(hrp.Velocity.X, self.Power, hrp.Velocity.Z)
        return true
    end
    return false
end

function AirJump:Toggle()
    self.Enabled = not self.Enabled
    self.Config.Data.Settings.AirJump = self.Enabled
    self.Config.Save()
    return self.Enabled
end

function AirJump:SetPower(value)
    self.Power = value
    self.Config.Data.Settings.AirJumpPower = value
    self.Config.Save()
end

function AirJump:Destroy()
    self.Active = false
    self.Enabled = false
end

return AirJump
