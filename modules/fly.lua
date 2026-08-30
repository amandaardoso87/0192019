-- https://raw.githubusercontent.com/SEU_USER/UniversalHax/main/modules/fly.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

print("[modules/fly.lua] loaded")

local Fly = {}
Fly.__index = Fly

function Fly.new(config)
    local self = setmetatable({}, Fly)
    
    self.Config = config
    self.Enabled = false
    self.Active = true
    self.Speed = (config and config.Data and config.Data.Settings.FlySpeed) or 50
    self.BodyVel = nil
    self.BodyGyro = nil
    self.Connections = {}
    print("[Fly] new() - Speed:", tostring(self.Speed))
    
    return self
end

function Fly:StopPhysics()
    if self.BodyVel then
        pcall(function() self.BodyVel:Destroy() end)
        self.BodyVel = nil
    end
    if self.BodyGyro then
        pcall(function() self.BodyGyro:Destroy() end)
        self.BodyGyro = nil
    end
end

function Fly:EnsureParts()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    if self.BodyVel and self.BodyVel.Parent == hrp and self.BodyGyro and self.BodyGyro.Parent == hrp then
        return hrp
    end
    
    self:StopPhysics()
    
    self.BodyVel = Instance.new("BodyVelocity")
    self.BodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    self.BodyVel.Velocity = Vector3.zero
    self.BodyVel.Parent = hrp

    self.BodyGyro = Instance.new("BodyGyro")
    self.BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    self.BodyGyro.P = 9000
    self.BodyGyro.D = 500
    self.BodyGyro.Parent = hrp
    
    return hrp
end

function Fly:Start()
    print("[Fly] Start()")
    table.insert(self.Connections, RunService.RenderStepped:Connect(function()
        if not self.Active or not self.Enabled then return end
        
        local hrp = self:EnsureParts()
        if not hrp then return end
        
        local moveDir = Vector3.zero
        local camCF = Camera.CFrame

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then 
            moveDir += camCF.LookVector 
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then 
            moveDir -= camCF.LookVector 
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then 
            moveDir -= camCF.RightVector 
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then 
            moveDir += camCF.RightVector 
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then 
            moveDir += Vector3.new(0, 1, 0) 
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then 
            moveDir -= Vector3.new(0, 1, 0) 
        end

        if moveDir.Magnitude > 0 then
            self.BodyVel.Velocity = moveDir.Unit * self.Speed
        else
            self.BodyVel.Velocity = Vector3.zero
        end

        self.BodyGyro.CFrame = camCF
    end))
end

function Fly:Toggle()
    self.Enabled = not self.Enabled
    self.Config.Data.Settings.Fly = self.Enabled
    print("[Fly] Toggle() ->", tostring(self.Enabled))
    if not self.Enabled then
        self:StopPhysics()
    end
    self.Config.Save()
    return self.Enabled
end

function Fly:SetSpeed(value)
    self.Speed = value
    self.Config.Data.Settings.FlySpeed = value
    print("[Fly] SetSpeed ->", tostring(value))
    self.Config.Save()
end

function Fly:Destroy()
    print("[Fly] Destroy()")
    self.Active = false
    self.Enabled = false
    self:StopPhysics()
    for _, conn in pairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    self.Connections = {}
end

return Fly
