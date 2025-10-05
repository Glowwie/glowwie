--// Speed Control Script by Glowwie x GPT-5
--// Put this inside StarterPlayer > StarterPlayerScripts

--// CONFIG
local SPEED_VALUE = 200 -- 🔥 Change this to any number you want

--// SCRIPT
local player = game.Players.LocalPlayer
local humanoid = nil

-- wait for character to load
player.CharacterAdded:Connect(function(char)
	humanoid = char:WaitForChild("Humanoid")

	-- keep updating WalkSpeed so nothing slows you down
	while humanoid and humanoid.Parent do
		humanoid.WalkSpeed = SPEED_VALUE
		task.wait(0.1)
	end
end)

-- if character already exists
if player.Character then
	local char = player.Character
	humanoid = char:WaitForChild("Humanoid")

	while humanoid and humanoid.Parent do
		humanoid.WalkSpeed = SPEED_VALUE
		task.wait(0.1)
	end
end
