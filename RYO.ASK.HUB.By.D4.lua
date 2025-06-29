local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Configs
local sizeLevels = {
    [1] = {size = Vector3.new(6, 6, 6), label = "Padrão"},
    [2] = {size = Vector3.new(10, 10, 10), label = "Média"},
    [3] = {size = Vector3.new(16, 16, 16), label = "Grande"}
}
local transparencyLevels = {
    [1] = {transparency = 1, label = "Invisível"},
    [2] = {transparency = 0.7, label = "Média"},
    [3] = {transparency = 0.4, label = "Baixa"}
}
local currentSize = 1
local currentTransparency = 3
local isActive = false
local hitboxParts = {}

-- Função para criar/atualizar hitbox
local function updateHitbox()
    for _, part in pairs(hitboxParts) do
        if part and part.Parent then part:Destroy() end
    end
    hitboxParts = {}

    if not isActive then return end

    local char = LocalPlayer.Character
    if not char then return end

    local parts = {
        char:FindFirstChild("LowerTorso"),
        char:FindFirstChild("UpperTorso"),
        char:FindFirstChild("HumanoidRootPart"),
        char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftHand"),
        char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand"),
        char:FindFirstChild("Left Leg") or char:FindFirstChild("LeftFoot"),
        char:FindFirstChild("Right Leg") or char:FindFirstChild("RightFoot"),
    }

    for i, orig in ipairs(parts) do
        if orig then
            local clone = Instance.new("Part")
            clone.Size = sizeLevels[currentSize].size
            clone.CanCollide = false
            clone.Transparency = transparencyLevels[currentTransparency].transparency
            clone.Name = orig.Name .. "_Expanded"
            clone.Position = orig.Position
            clone.Anchored = false
            clone.Parent = orig.Parent
            clone.Color = Color3.fromRGB(60, 180, 180)
            clone.Material = Enum.Material.SmoothPlastic

            -- Attachments para seguir a parte original
            local att0 = Instance.new("Attachment", orig)
            att0.Name = "OriginalAttachment"
            local att1 = Instance.new("Attachment", clone)
            att1.Name = "CloneAttachment"
            local alignPos = Instance.new("AlignPosition", clone)
            alignPos.Attachment0 = att1
            alignPos.Attachment1 = att0
            alignPos.RigidityEnabled = true
            local alignOri = Instance.new("AlignOrientation", clone)
            alignOri.Attachment0 = att1
            alignOri.Attachment1 = att0
            alignOri.RigidityEnabled = true

            table.insert(hitboxParts, clone)
        end
    end
end

local function removeHitbox()
    for _, part in pairs(hitboxParts) do
        if part and part.Parent then part:Destroy() end
    end
    hitboxParts = {}
end

-- UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ReachOpGui"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 340, 0, 260)
frame.Position = UDim2.new(0.5, -170, 0.5, -130)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.35
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 36)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Reach Op - Ask"
title.TextColor3 = Color3.fromRGB(0, 255, 200)
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.Parent = frame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
closeBtn.BackgroundTransparency = 0.3
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 20
closeBtn.Parent = frame
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    removeHitbox()
end)

local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -20, 0, 2)
divider.Position = UDim2.new(0, 10, 0, 36)
divider.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
divider.BackgroundTransparency = 0.5
divider.BorderSizePixel = 0
divider.Parent = frame

-- Slider de tamanho
local sliderLabel = Instance.new("TextLabel")
sliderLabel.Size = UDim2.new(0, 140, 0, 24)
sliderLabel.Position = UDim2.new(0, 10, 0, 48)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Text = "Tamanho: " .. sizeLevels[currentSize].label
sliderLabel.TextColor3 = Color3.fromRGB(200, 255, 255)
sliderLabel.Font = Enum.Font.Gotham
sliderLabel.TextSize = 16
sliderLabel.Parent = frame

local sliderBar = Instance.new("Frame")
sliderBar.Size = UDim2.new(0, 180, 0, 8)
sliderBar.Position = UDim2.new(0, 10, 0, 78)
sliderBar.BackgroundColor3 = Color3.fromRGB(60, 180, 180)
sliderBar.BackgroundTransparency = 0.2
sliderBar.BorderSizePixel = 0
sliderBar.Parent = frame

local sliderBtn = Instance.new("TextButton")
sliderBtn.AutoButtonColor = false
sliderBtn.Text = ""
sliderBtn.Size = UDim2.new(0, 18, 0, 18)
sliderBtn.Position = UDim2.new(0, 10 + (currentSize-1)*80, 0, 74)
sliderBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
sliderBtn.BackgroundTransparency = 0
sliderBtn.BorderSizePixel = 0
sliderBtn.Parent = frame

sliderBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local conn
        conn = UserInputService.InputChanged:Connect(function(moveInput)
            if moveInput.UserInputType == Enum.UserInputType.MouseMovement then
                local mouseX = moveInput.Position.X
                local barAbs = sliderBar.AbsolutePosition.X
                local rel = math.clamp(mouseX - barAbs, 0, sliderBar.AbsoluteSize.X)
                local percent = rel / sliderBar.AbsoluteSize.X
                local level = 1
                if percent > 0.66 then
                    level = 3
                elseif percent > 0.33 then
                    level = 2
                end
                if currentSize ~= level then
                    currentSize = level
                    sliderBtn.Position = UDim2.new(0, 10 + (currentSize-1)*80, 0, 74)
                    sliderLabel.Text = "Tamanho: " .. sizeLevels[currentSize].label
                    if isActive then updateHitbox() end
                end
            end
        end)
        UserInputService.InputEnded:Connect(function(endInput)
            if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
                if conn then conn:Disconnect() end
            end
        end)
    end
end)

-- Slider de transparência
local transpLabel = Instance.new("TextLabel")
transpLabel.Size = UDim2.new(0, 140, 0, 24)
transpLabel.Position = UDim2.new(0, 10, 0, 108)
transpLabel.BackgroundTransparency = 1
transpLabel.Text = "Transparência: " .. transparencyLevels[currentTransparency].label
transpLabel.TextColor3 = Color3.fromRGB(200, 255, 255)
transpLabel.Font = Enum.Font.Gotham
transpLabel.TextSize = 16
transpLabel.Parent = frame

local transpBar = Instance.new("Frame")
transpBar.Size = UDim2.new(0, 180, 0, 8)
transpBar.Position = UDim2.new(0, 10, 0, 138)
transpBar.BackgroundColor3 = Color3.fromRGB(60, 180, 180)
transpBar.BackgroundTransparency = 0.2
transpBar.BorderSizePixel = 0
transpBar.Parent = frame

local transpBtn = Instance.new("TextButton")
transpBtn.AutoButtonColor = false
transpBtn.Text = ""
transpBtn.Size = UDim2.new(0, 18, 0, 18)
transpBtn.Position = UDim2.new(0, 10 + (currentTransparency-1)*80, 0, 134)
transpBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
transpBtn.BackgroundTransparency = 0
transpBtn.BorderSizePixel = 0
transpBtn.Parent = frame

transpBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local conn
        conn = UserInputService.InputChanged:Connect(function(moveInput)
            if moveInput.UserInputType == Enum.UserInputType.MouseMovement then
                local mouseX = moveInput.Position.X
                local barAbs = transpBar.AbsolutePosition.X
                local rel = math.clamp(mouseX - barAbs, 0, transpBar.AbsoluteSize.X)
                local percent = rel / transpBar.AbsoluteSize.X
                local level = 1
                if percent > 0.66 then
                    level = 3
                elseif percent > 0.33 then
                    level = 2
                end
                if currentTransparency ~= level then
                    currentTransparency = level
                    transpBtn.Position = UDim2.new(0, 10 + (currentTransparency-1)*80, 0, 134)
                    transpLabel.Text = "Transparência: " .. transparencyLevels[currentTransparency].label
                    if isActive then updateHitbox() end
                end
            end
        end)
        UserInputService.InputEnded:Connect(function(endInput)
            if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
                if conn then conn:Disconnect() end
            end
        end)
    end
end)

-- Botão ativar/desativar
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 140, 0, 36)
toggleBtn.Position = UDim2.new(0, 170, 0, 170)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
toggleBtn.BackgroundTransparency = 0.15
toggleBtn.Text = "Ativar Hitbox"
toggleBtn.TextColor3 = Color3.fromRGB(20, 20, 20)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 18
toggleBtn.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 140, 0, 36)
statusLabel.Position = UDim2.new(0, 10, 0, 170)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Desativado"
statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 18
statusLabel.Parent = frame

local function setStatus(active)
    if active then
        statusLabel.Text = "Status: Ativado"
        statusLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
        toggleBtn.Text = "Desativar Hitbox"
    else
        statusLabel.Text = "Status: Desativado"
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        toggleBtn.Text = "Ativar Hitbox"
    end
end

toggleBtn.MouseButton1Click:Connect(function()
    isActive = not isActive
    setStatus(isActive)
    if isActive then
        updateHitbox()
    else
        removeHitbox()
    end
end)

-- Atalho para ativar/desativar (J)
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.J then
        isActive = not isActive
        setStatus(isActive)
        if isActive then
            updateHitbox()
        else
            removeHitbox()
        end
    end
end)

-- Remove hitbox ao morrer
LocalPlayer.CharacterAdded:Connect(function()
    removeHitbox()
    if isActive then
        wait(1)
        updateHitbox()
    end
end)

-- TAKE BALL (pega a bola mais próxima)
local function takeBall()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("ball") then
            if (obj.Position - hrp.Position).Magnitude < 20 then
                hrp.CFrame = CFrame.new(obj.Position + Vector3.new(0,2,0))
                break
            end
        end
    end
end

-- Botão Take Ball
local takeBallBtn = Instance.new("TextButton")
takeBallBtn.Size = UDim2.new(0, 140, 0, 36)
takeBallBtn.Position = UDim2.new(0, 170, 0, 210)
takeBallBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
takeBallBtn.BackgroundTransparency = 0.15
takeBallBtn.Text = "Take Ball"
takeBallBtn.TextColor3 = Color3.fromRGB(20, 20, 20)
takeBallBtn.Font = Enum.Font.GothamBold
takeBallBtn.TextSize = 18
takeBallBtn.Parent = frame
takeBallBtn.MouseButton1Click:Connect(takeBall)

-- Atalho para Take Ball (K)
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.K then
        takeBall()
    end
end)

-- STAMINA INFINITA (ajuste o nome do valor se necessário)
game:GetService("RunService").RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if char then
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("NumberValue") and v.Name:lower():find("stam") then
                v.Value = v.MaxValue or 100
             end
        end
    end
end)
