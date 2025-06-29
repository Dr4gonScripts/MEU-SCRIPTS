local SolarisLib = loadstring(game:HttpGet("https://solarishub.dev/SolarisLib.lua"))()

local win = SolarisLib:New({
    Name = "Ryo-Ask HubX",
    FolderToSave = "RyoAskHubStuff"
})

-- Cria a aba "Helpes"
local tab = win:Tab("Helpes")

-- Cria uma seção para os elementos
local sec = tab:Section("Recursos Úteis")

---
-- WalkSpeed Toggle
---
local isFastWalkActive = false
local defaultWalkSpeed = 16

sec:Toggle("Fast Walk", false, "FastWalkToggle", function(state)
    isFastWalkActive = state
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("Humanoid") then
        local humanoid = player.Character.Humanoid
        if state then
            humanoid.WalkSpeed = 100
        else
            humanoid.WalkSpeed = defaultWalkSpeed
        end
    end
end)

-- Garante que a velocidade seja restaurada após a morte
game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    if isFastWalkActive then
        character:WaitForChild("Humanoid").WalkSpeed = 100
    else
        character:WaitForChild("Humanoid").WalkSpeed = defaultWalkSpeed
    end
end)

---
-- Inf Jump Toggle
---
local isInfJumpActive = false

sec:Toggle("Inf Jump", false, "InfJumpToggle", function(state)
    isInfJumpActive = state
end)

game:GetService("RunService").Heartbeat:Connect(function()
    if isInfJumpActive then
        local player = game.Players.LocalPlayer
        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

---
-- God Mode Toggle (Sem Hitbox)
---
local isGodModeActive = false

sec:Toggle("God Mode", false, "GodModeToggle", function(state)
    isGodModeActive = state
end)

game:GetService("RunService").Heartbeat:Connect(function()
    local player = game.Players.LocalPlayer
    if player and player.Character then
        if isGodModeActive then
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        else
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    pcall(function()
                        part.CanCollide = true
                    end)
                end
            end
        end
    end
end)

---
-- ESP com Highlight e Nomes
---
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local highlights = {}
local nameTags = {}

local function createNameTag(player)
    local tag = Instance.new("BillboardGui")
    tag.Name = "ESP_NameTag"
    tag.AlwaysOnTop = true
    tag.Size = UDim2.new(4, 0, 1, 0)
    tag.StudsOffset = Vector3.new(0, 3, 0)
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextScaled = true
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Text = player.Name
    nameLabel.Parent = tag
    if player.Character and player.Character:FindFirstChild("Head") then
        tag.Parent = player.Character.Head
        nameTags[player] = tag
    end
end

local function createHighlight(player, color)
    local highlight = Instance.new("Highlight")
    highlight.FillColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = color
    highlight.OutlineTransparency = 0
    highlight.Adornee = player.Character
    highlight.Parent = player.Character
    highlights[player] = highlight
end

local function updatePlayerESP(player, color)
    local char = player.Character
    if char and player ~= LocalPlayer then
        if highlights[player] then
            highlights[player].FillColor = color
            highlights[player].OutlineColor = color
        else
            createHighlight(player, color)
        end
        if not nameTags[player] and char:FindFirstChild("Head") then
            createNameTag(player)
        end
    end
end

local function removePlayerESP(player)
    if highlights[player] then
        highlights[player]:Destroy()
        highlights[player] = nil
    end
    if nameTags[player] then
        nameTags[player]:Destroy()
        nameTags[player] = nil
    end
end

local function updateAllPlayersESP(color)
    for _, player in Players:GetPlayers() do
        if player.Character and player ~= LocalPlayer then
            updatePlayerESP(player, color)
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        updatePlayerESP(player, Color3.fromRGB(150, 200, 255))
    end)
end)

Players.PlayerRemoving:Connect(removePlayerESP)

-- Adiciona o Colorpicker na seção
sec:Colorpicker("ESP Color", Color3.fromRGB(150, 200, 255), "ESPColor", function(color)
    updateAllPlayersESP(color)
end)

RunService.Heartbeat:Connect(function()
    for _, player in Players:GetPlayers() do
        if player.Character and player.Character:FindFirstChild("Head") and not highlights[player] and player ~= LocalPlayer then
            updatePlayerESP(player, Color3.fromRGB(150, 200, 255))
        end
    end
end)

updateAllPlayersESP(Color3.fromRGB(150, 200, 255))
