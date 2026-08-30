-- https://raw.githubusercontent.com/SEU_USER/UniversalHax/main/modules/aimassist.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

print("[modules/aimassist.lua] loaded")

local AimAssist = {}
AimAssist.__index = AimAssist

function AimAssist.new(config, circle)
    local self = setmetatable({}, AimAssist)
    
    self.Config = config
    self.Circle = circle
    self.Enabled = false
    self.Aiming = false
    self.Active = true
    self.Connections = {}

    print("[AimAssist] new() - config:", tostring(config ~= nil), "circle:", tostring(circle ~= nil))
    
    return self
end

function AimAssist:GetTargetPart(character, partType)
    if not character then return nil end
    if partType == 0 then
        return character:FindFirstChild("Head")
    elseif partType == 1 then
        return character:FindFirstChild("Torso") 
            or character:FindFirstChild("UpperTorso") 
            or character:FindFirstChild("LowerTorso")
    elseif partType == 2 then
        local ll = character:FindFirstChild("Left Leg") 
            or character:FindFirstChild("LeftUpperLeg")
        local rl = character:FindFirstChild("Right Leg") 
            or character:FindFirstChild("RightUpperLeg")
        if ll and rl then return ll end
        if ll then return ll end
        if rl then return rl end
    end
    return nil
end

function AimAssist:IsVisible(part)
    local origin = Camera.CFrame.Position
    local direction = part.Position - origin
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    local result = Workspace:Raycast(origin, direction, params)
    return not result or result.Instance:IsDescendantOf(part.Parent)
end

function AimAssist:GetClosestTarget()
    local settings = self.Config.Data.Settings
    local closest = nil
    local shortest = settings.FOVMode and settings.FOV or math.huge
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if settings.TeamCheck and plr.Team == LocalPlayer.Team then continue end
        
        local char = plr.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if not char or not humanoid or humanoid.Health <= 0 then continue end

        local targetPart = self:GetTargetPart(char, settings.BodyPart)
        if not targetPart then continue end

        if not settings.WallCheck or self:IsVisible(targetPart) then
            if settings.FOVMode then
                local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist < shortest then
                        shortest = dist
                        closest = targetPart
                    end
                end
            else
                local realDist = (targetPart.Position - Camera.CFrame.Position).Magnitude
                if realDist < shortest then
                    shortest = realDist
                    closest = targetPart
                end
            end
        end
    end
    return closest
end

function AimAssist:Start()
    print("[AimAssist] Start()")
    RunService:BindToRenderStep("AimAssistSnap", Enum.RenderPriority.Camera.Value + 2, function()
        if not self.Active or not self.Enabled or not self.Aiming then return end
        local target = self:GetClosestTarget()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end)

    table.insert(self.Connections, RunService.RenderStepped:Connect(function()
        if not self.Active then return end
        if self.Circle then
            self.Circle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
            self.Circle.Visible = self.Enabled and self.Config.Data.Settings.FOVMode
        end
    end))
end

function AimAssist:SetAiming(state)
    self.Aiming = state
    print("[AimAssist] SetAiming ->", tostring(state))
end

function AimAssist:Toggle()
    self.Enabled = not self.Enabled
    self.Config.Data.Settings.AimAssist = self.Enabled
    if self.Circle then
        self.Circle.Visible = self.Enabled and self.Config.Data.Settings.FOVMode
    end
    self.Config.Save()
    print("[AimAssist] Toggle() ->", tostring(self.Enabled))
    return self.Enabled
end

function AimAssist:Destroy()
    print("[AimAssist] Destroy()")
    self.Active = false
    self.Enabled = false
    self.Aiming = false
    pcall(function() RunService:UnbindFromRenderStep("AimAssistSnap") end)
    for _, conn in pairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    self.Connections = {}
end

return AimAssist
