-- Carrega a biblioteca
local Ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/drillygzzly/Roblox-UI-Libs/main/Abyss%20Lib/Abyss%20Lib%20Source.lua"))()
local Ui = Library

-- Mede o tempo de carregamento
local LoadTime = tick()

local Loader = Library.CreateLoader(
    "Ryo-Ask Hub Carregando",
    Vector2.new(300, 300)
)

local Window = Library.Window(
    "RYO-ASK HUB",
    Vector2.new(500, 620)
)

-- Notificação inicial
Window.SendNotification(
    "Normal",
    "Press RightShift to open menu and close menu!",
    10
)

-- Marca d'água
Window.Watermark("Ryo-ASK")

-- Cria a primeira aba
local Tab1 = Window:Tab("Home")

-- Seção de Ajudas
local Section1 = Tab1:Section("Ajudas - Helps", "Left")

-- WalkSpeed Slider
Section1:Slider({
    Title = "Walk Speed", 
    Flag = "WalkSpeed_Slider", 
    Symbol = " studs",
    Default = 16,
    Min = 16,
    Max = 80,
    Decimals = 0,
    Callback = function(value)
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        
        if character and character:FindFirstChildOfClass("Humanoid") then
            character.Humanoid.WalkSpeed = value
        end
        print("WalkSpeed definido para: "..value.." studs")
    end
})

-- GodMode Toggle
local godModeConnection = nil
Section1:Toggle({
    Title = "GodMode - Intangível", 
    Flag = "GodMode_Toggle",
    Callback = function(state)
        local player = game:GetService("Players").LocalPlayer
        
        local function setGodMode(character)
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                if state then
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                    humanoid.MaxHealth = math.huge
                    humanoid.Health = math.huge
                else
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
                    humanoid.MaxHealth = 100
                    humanoid.Health = 100
                end
            end
        end

        if state then
            if player.Character then
                setGodMode(player.Character)
            end
            
            godModeConnection = player.CharacterAdded:Connect(function(newCharacter)
                setGodMode(newCharacter)
            end)
            
            Window.SendNotification("Normal", "GodMode ATIVADO", 3)
            print("GodMode ativado - Personagem intangível")
        else
            if godModeConnection then
                godModeConnection:Disconnect()
                godModeConnection = nil
            end
            
            if player.Character then
                setGodMode(player.Character)
            end
            
            Window.SendNotification("Normal", "GodMode DESATIVADO", 3)
            print("GodMode desativado")
        end
    end
})

-- Seção Steal
local Section2 = Tab1:Section("Steal", "Right")

-- Infinite Jump Toggle
local infJumpConnection = nil
Section2:Toggle({
    Title = "Infinite Jump", 
    Flag = "Infinite_Jump_Toggle",
    Callback = function(state)
        if state then
            infJumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
                local player = game:GetService("Players").LocalPlayer
                local character = player.Character
                if character then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
            Window.SendNotification("Normal", "Infinite Jump ATIVADO", 3)
            print("Infinite Jump ativado")
        else
            if infJumpConnection then
                infJumpConnection:Disconnect()
                infJumpConnection = nil
            end
            Window.SendNotification("Normal", "Infinite Jump DESATIVADO", 3)
            print("Infinite Jump desativado")
        end
    end
})

-- Adiciona Keybind para o Infinite Jump
Section2:GetToggle("Infinite_Jump_Toggle"):Keybind({
    Title = "Atalho Infinite Jump",
    Flag = "Infinite_Jump_Keybind",
    Key = Enum.KeyCode.J,
    StateType = "Toggle"
})

-- Adiciona a aba de configurações
Window:AddSettingsTab()

-- Define a aba inicial
Window:SwitchTab(Tab1)

-- Desativa animações
Window.ToggleAnime(false)

-- Finaliza o carregamento
LoadTime = math.floor((tick() - LoadTime) * 1000
print(string.format("Ryo-Ask Hub carregado em %d ms", LoadTime))

-- Função para desconectar tudo quando o script for encerrado
local function cleanup()
    if godModeConnection then
        godModeConnection:Disconnect()
    end
    if infJumpConnection then
        infJumpConnection:Disconnect()
    end
end

-- Conecta o cleanup para quando o script for destruído
game:GetService("Players").LocalPlayer.CharacterRemoving:Connect(cleanup)
game:GetService("Players").LocalPlayer.PlayerGui.ChildRemoved:Connect(cleanup)

return {
    Cleanup = cleanup,
    Window = Window
}
