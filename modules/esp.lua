-- https://raw.githubusercontent.com/SEU_USER/UniversalHax/main/modules/esp.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ESP = {}
ESP.__index = ESP

function ESP.new(config)
    local self = setmetatable({}, ESP)
    self.Config = config
    self.Enabled = false
    self.Active = true
    self.Highlights = {}
    self.Drawings = {}
    self.Connections = {}
    return self
end

function ESP:CreateHighlight(char, plr)
    if not char or not plr or self.Highlights[plr] then return end
    local h = Instance.new("Highlight")
    h.FillTransparency = 1
    h.OutlineTransparency = 0
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = char
    self.Highlights[plr] = h
end

function ESP:RemovePlayer(plr)
    if self.Highlights[plr] then
        pcall(function() self.Highlights[plr]:Destroy() end)
        self.Highlights[plr] = nil
    end
    if self.Drawings[plr] then
        for _, d in pairs(self.Drawings[plr]) do
            pcall(function() d:Remove() end)
        end
        self.Drawings[plr] = nil
    end
end

function ESP:RemoveAll()
    for _, plr in pairs(Players:GetPlayers()) do
        self:RemovePlayer(plr)
    end
end

function ESP:CreateDrawings(plr)
    if self.Drawings[plr] then return end
    self.Drawings[plr] = {
        HeadToTorso = Drawing.new("Line"),
        LeftArm = Drawing.new("Line"),
        RightArm = Drawing.new("Line"),
        LeftLeg = Drawing.new("Line"),
        RightLeg = Drawing.new("Line")
    }
end

function ESP:ApplyToAll()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            self:CreateHighlight(plr.Character, plr)
        end
    end
end

function ESP:Start()
    -- Setup jogadores existentes
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local charConn = plr.CharacterAdded:Connect(function(char)
                if self.Enabled then
                    task.wait(0.5)
                    self:CreateHighlight(char, plr)
                end
            end)
            local remConn = plr.CharacterRemoving:Connect(function()
                self:RemovePlayer(plr)
            end)
            table.insert(self.Connections, charConn)
            table.insert(self.Connections, remConn)
            if plr.Character and self.Enabled then
                self:CreateHighlight(plr.Character, plr)
            end
        end
    end

    -- Novos jogadores
    table.insert(self.Connections, Players.PlayerAdded:Connect(function(plr)
        if plr == LocalPlayer then return end
        local charConn = plr.CharacterAdded:Connect(function(char)
            if self.Enabled then
                task.wait(0.5)
                self:CreateHighlight(char, plr)
            end
        end)
        local remConn = plr.CharacterRemoving:Connect(function()
            self:RemovePlayer(plr)
        end)
        table.insert(self.Connections, charConn)
        table.insert(self.Connections, remConn)
    end))

    -- Loop de renderização
    table.insert(self.Connections, RunService.RenderStepped:Connect(function()
        if not self.Active or not self.Enabled then return end

        for _, plr in pairs(Players:GetPlayers()) do
            if plr == LocalPlayer then continue end
            if self.Config.Data.Settings.TeamCheck and plr.Team == LocalPlayer.Team then
                if self.Drawings[plr] or self.Highlights[plr] then
                    self:RemovePlayer(plr)
                end
                continue
            end

            local char = plr.Character
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            if not char or not humanoid or humanoid.Health <= 0 then
                self:RemovePlayer(plr)
                continue
            end

            local head = char:FindFirstChild("Head")
            local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
            if not head or not torso then
                self:RemovePlayer(plr)
                continue
            end

            if not self.Highlights[plr] then
                self:CreateHighlight(char, plr)
            end

            self:CreateDrawings(plr)
            local d = self.Drawings[plr]
            local color = self.Config.Data.Settings.TeamCheck 
                and plr.TeamColor.Color 
                or Color3.new(1, 1, 1)

            local function line(fromPart, toPart, drawing)
                if fromPart and toPart then
                    local p1 = Camera:WorldToViewportPoint(fromPart.Position)
                    local p2 = Camera:WorldToViewportPoint(toPart.Position)
                    drawing.From = Vector2.new(p1.X, p1.Y)
                    drawing.To = Vector2.new(p2.X, p2.Y)
                    drawing.Color = color
                    drawing.Thickness = 2
                    drawing.Visible = true
                else
                    drawing.Visible = false
                end
            end

            line(head, torso, d.HeadToTorso)

            local larm = char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftUpperArm")
            local rarm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightUpperArm")
            local lleg = char:FindFirstChild("Left Leg") or char:FindFirstChild("LeftUpperLeg")
            local rleg = char:FindFirstChild("Right Leg") or char:FindFirstChild("RightUpperLeg")

            line(torso, larm, d.LeftArm)
            line(torso, rarm, d.RightArm)
            line(torso, lleg, d.LeftLeg)
            line(torso, rleg, d.RightLeg)
        end
    end))
end

function ESP:Toggle()
    self.Enabled = not self.Enabled
    self.Config.Data.Settings.ESPEnabled = self.Enabled
    if not self.Enabled then
        self:RemoveAll()
    else
        self:ApplyToAll()
    end
    self.Config.Save()
    return self.Enabled
end

function ESP:Destroy()
    self.Active = false
    self.Enabled = false
    self:RemoveAll()
    for _, conn in pairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    self.Connections = {}
end

return ESP
