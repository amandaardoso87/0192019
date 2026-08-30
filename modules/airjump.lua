-- https://raw.githubusercontent.com/SEU_USER/UniversalHax/main/modules/airjump.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

print("[modules/airjump.lua] loaded")

local AirJump = {}
AirJump.__index = AirJump

function AirJump.new(config)
    local self = setmetatable({}, AirJump)
    self.Config = config
    self.Enabled = false
    self.Active = true
    self.Power = (config and config.Data and config.Data.Settings.AirJumpPower) or 50
    self.Connections = {}
    print("[AirJump] new() - Power:", tostring(self.Power))
    return self
end

function AirJump:TryJump()
    print("[AirJump] TryJump()")
    if not self.Active or not self.Enabled then
        print("[AirJump] not active or not enabled")
        return false
    end
    local char = LocalPlayer.Character
    if not char then
        print("[AirJump] no character")
        return false
    end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if humanoid and hrp then
        if not humanoid:IsDescendantOf(workspace) then
            print("[AirJump] humanoid not descendant of workspace")
            return false
        end
        local state = humanoid:GetState()
        if state ~= Enum.HumanoidStateType.Freefall and state ~= Enum.HumanoidStateType.Jumping then
            print("[AirJump] humanoid state not jump/freefall ->", tostring(state))
            return false
        end
        hrp.Velocity = Vector3.new(hrp.Velocity.X, self.Power, hrp.Velocity.Z)
        print("[AirJump] executed - velocity set")
        return true
    end
    print("[AirJump] missing humanoid or hrp")
    return false
end

function AirJump:Toggle()
    self.Enabled = not self.Enabled
    self.Config.Data.Settings.AirJump = self.Enabled
    print("[AirJump] Toggle() ->", tostring(self.Enabled))
    self.Config.Save()
    return self.Enabled
end

function AirJump:SetPower(value)
    self.Power = value
    self.Config.Data.Settings.AirJumpPower = value
    print("[AirJump] SetPower ->", tostring(value))
    self.Config.Save()
end

function AirJump:Destroy()
    print("[AirJump] Destroy()")
    self.Active = false
    self.Enabled = false
end

return AirJump
