-- https://raw.githubusercontent.com/SEU_USER/UniversalHax/main/config.lua
local HttpService = game:GetService("HttpService")
local SAVE_FILE = "UniversalHax_Config.json"

local ConfigModule = {}

-- Configurações padrão
ConfigModule.Defaults = {
    Keybinds = {
        AimAssist = "None",
        ESP = "None",
        AirJump = "None"
    },
    Settings = {
        AimAssist = false,
        FOVMode = true,
        TeamCheck = true,
        WallCheck = false,
        ESPEnabled = false,
        FOV = 100,
        AirJump = false,
        AirJumpPower = 50,
        BodyPart = 0,
        SpeedEnabled = false,
        SpeedValue = 16,
        Fly = false,
        FlySpeed = 50,
        Noclip = false,
        CameraZoom = false,
        CameraZoomDistance = 500,
        FullBright = false,
        FullBrightIntensity = 3
    }
}

-- Copia defaults para a config ativa
ConfigModule.Data = {}
for k, v in pairs(ConfigModule.Defaults) do
    if type(v) == "table" then
        ConfigModule.Data[k] = {}
        for k2, v2 in pairs(v) do
            ConfigModule.Data[k][k2] = v2
        end
    else
        ConfigModule.Data[k] = v
    end
end

function ConfigModule.Save()
    local success, json = pcall(function()
        return HttpService:JSONEncode(ConfigModule.Data)
    end)
    if success then
        pcall(function() writefile(SAVE_FILE, json) end)
    end
end

function ConfigModule.Load()
    if isfile(SAVE_FILE) then
        local success, content = pcall(function()
            return readfile(SAVE_FILE)
        end)
        if success then
            local success2, decoded = pcall(function()
                return HttpService:JSONDecode(content)
            end)
            if success2 then
                for k, v in pairs(decoded.Keybinds or {}) do
                    ConfigModule.Data.Keybinds[k] = v
                end
                for k, v in pairs(decoded.Settings or {}) do
                    ConfigModule.Data.Settings[k] = v
                end
            end
        end
    end
end

-- FORÇAR tudo desligado ao iniciar (segurança)
function ConfigModule.ForceOff()
    ConfigModule.Data.Settings.AimAssist = false
    ConfigModule.Data.Settings.ESPEnabled = false
    ConfigModule.Data.Settings.AirJump = false
    ConfigModule.Data.Settings.SpeedEnabled = false
    ConfigModule.Data.Settings.Fly = false
    ConfigModule.Data.Settings.Noclip = false
    ConfigModule.Data.Settings.CameraZoom = false
    ConfigModule.Data.Settings.FullBright = false
end

return ConfigModule
