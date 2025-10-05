-- esp.lua
-- Green-outline Highlight + NameTag ESP
-- Author: Glowwie (template)
-- Place this file in a public GitHub repo and use the raw URL with loadstring.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Settings (edit as you like)
local SETTINGS = {
    HighlightName = "GlowHighlight",
    BillboardName = "NameBillboard",
    FillColor = Color3.fromRGB(0, 255, 0),
    OutlineColor = Color3.fromRGB(0, 120, 0),
    FillTransparency = 0.6,
    OutlineTransparency = 0,
    BillboardOffset = Vector3.new(0, 2.6, 0),
    MaxDistance = 1000, -- set nil to always show
    ShowLocalPlayer = false,
    TextSize = 18,
}

local function makeHighlight(character)
    if not character then return end
    if character:FindFirstChild(SETTINGS.HighlightName) then return end
    local hl = Instance.new("Highlight")
    hl.Name = SETTINGS.HighlightName
    hl.FillColor = SETTINGS.FillColor
    hl.OutlineColor = SETTINGS.OutlineColor
    hl.FillTransparency = SETTINGS.FillTransparency
    hl.OutlineTransparency = SETTINGS.OutlineTransparency
    hl.Parent = character
end

local function makeBillboard(player)
    local char = player.Character
    if not char then return end
    if char:FindFirstChild(SETTINGS.BillboardName) then return end
    local head = char:FindFirstChild("Head")
    if not head then return end

    local b = Instance.new("BillboardGui")
    b.Name = SETTINGS.BillboardName
    b.Size = UDim2.new(0, 200, 0, 40)
    b.StudsOffset = SETTINGS.BillboardOffset
    b.AlwaysOnTop = true

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = player.Name
    lbl.TextScaled = false
    lbl.TextSize = SETTINGS.TextSize
    lbl.Font = Enum.Font.GothamBold
    lbl.TextColor3 = SETTINGS.FillColor
    lbl.TextStrokeTransparency = 0.2
    lbl.Parent = b

    b.Parent = head
end

local function removeESP(character)
    if not character then return end
    local hl = character:FindFirstChild(SETTINGS.HighlightName)
    if hl then hl:Destroy() end
    local head = character:FindFirstChild("Head")
    if head then
        local bb = head:FindFirstChild(SETTINGS.BillboardName)
        if bb then bb:Destroy() end
    end
end

local function shouldShow(player)
    if not player.Character or not player.Character.PrimaryPart then return false end
    if not SETTINGS.ShowLocalPlayer and player == LocalPlayer then return false end
    if SETTINGS.MaxDistance then
        local lpChar = LocalPlayer.Character
        if not lpChar or not lpChar.PrimaryPart then return true end
        local dist = (lpChar.PrimaryPart.Position - player.Character.PrimaryPart.Position).Magnitude
        return dist <= SETTINGS.MaxDistance
    end
    return true
end

local function onCharacterAdded(player, character)
    task.wait(0.8) -- give time to load parts
    if shouldShow(player) then
        makeHighlight(character)
        makeBillboard(player)
    end
    -- Clean removal when character dies
    character.AncestryChanged:Connect(function(_, parent)
        if not parent then removeESP(character) end
    end)
end

local function setupPlayer(player)
    player.CharacterAdded:Connect(function(char)
        onCharacterAdded(player, char)
    end)
    if player.Character then
        onCharacterAdded(player, player.Character)
    end
end

-- Connect players
for _, p in ipairs(Players:GetPlayers()) do
    setupPlayer(p)
end
Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(player)
    if player.Character then removeESP(player.Character) end
end)

-- Render-step guardian: re-create missing ESP for reliability
RunService.RenderStepped:Connect(function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and shouldShow(p) then
            if not p.Character:FindFirstChild(SETTINGS.HighlightName) then
                makeHighlight(p.Character)
            end
            local head = p.Character:FindFirstChild("Head")
            if head and not head:FindFirstChild(SETTINGS.BillboardName) then
                makeBillboard(p)
            end
        end
    end
end)
