--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
- Place this inside a Script in ServerScriptService
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayAudioEvent = Instance.new("RemoteEvent", ReplicatedStorage)
PlayAudioEvent.Name = "PlayBoomboxAudio"

PlayAudioEvent.OnServerEvent:Connect(function(player, soundId)
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        -- Find or create the sound object
        local sound = character.HumanoidRootPart:FindFirstChild("BoomboxSound") or Instance.new("Sound")
        sound.Name = "BoomboxSound"
        sound.Parent = character.HumanoidRootPart
        
        -- Update and Play
        sound.SoundId = "rbxassetid://" .. soundId
        sound.RollOffMaxDistance = 50 -- So you don't annoy the whole map
        sound:Play()
    end
end)
