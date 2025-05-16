repeat wait() until game:IsLoaded()

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local gui = Instance.new("ScreenGui")
gui.Name = "SpeedHub"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 320)
frame.Position = UDim2.new(0, 100, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
frame.Parent = gui

local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

local function updatePosition(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        -- Só começar o drag se o mouse NÃO estiver em cima dos sliders (exclui os sliders)
        local mousePos = input.Position
        local relativePos = Vector2.new(mousePos.X - frame.AbsolutePosition.X, mousePos.Y - frame.AbsolutePosition.Y)
        
        -- Áreas dos sliders: 
        -- Slider 1 (velocidade walk): y entre 65 e 85 (sliderBg posY 65, height 20)
        -- Slider 2 (velocidade voo): y entre 220 e 240 (posY 220, height 20)
        
        local overSlider1 = relativePos.Y >= 65 and relativePos.Y <= 85 and relativePos.X >= (frame.AbsoluteSize.X*0.1) and relativePos.X <= (frame.AbsoluteSize.X*0.9)
        local overSlider2 = relativePos.Y >= 220 and relativePos.Y <= 240 and relativePos.X >= (frame.AbsoluteSize.X*0.1) and relativePos.X <= (frame.AbsoluteSize.X*0.9)

        if not (overSlider1 or overSlider2) then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updatePosition(input)
    end
end)

-- Função para criar sliders bonitos
local function criarSlider(parent, posY, textoInicial, corFill, minVal, maxVal, valorInicial)
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 0, 25)
    textLabel.Position = UDim2.new(0, 0, 0, posY)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = textoInicial
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.Font = Enum.Font.SourceSans
    textLabel.TextSize = 20
    textLabel.Parent = parent

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(0.8, 0, 0, 20)
    sliderBg.Position = UDim2.new(0.1, 0, 0, posY + 30)
    sliderBg.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    sliderBg.Parent = parent

    local sliderBgCorner = Instance.new("UICorner")
    sliderBgCorner.CornerRadius = UDim.new(0, 8)
    sliderBgCorner.Parent = sliderBg

    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((valorInicial - minVal) / (maxVal - minVal), 0, 1, 0)
    sliderFill.BackgroundColor3 = corFill
    sliderFill.Parent = sliderBg

    local sliderFillCorner = Instance.new("UICorner")
    sliderFillCorner.CornerRadius = UDim.new(0, 8)
    sliderFillCorner.Parent = sliderFill

    return textLabel, sliderBg, sliderFill, minVal, maxVal
end

-- Função para criar botões padronizados
local function criarBotao(texto, posXScale, posY, corFundo)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.45, 0, 0, 30)
    btn.Position = UDim2.new(posXScale, 0, 0, posY)
    btn.Text = texto
    btn.BackgroundColor3 = corFundo
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.Parent = frame
    return btn
end

-- Variáveis da velocidade walk
local velocidadeSelecionada = 16
local velocidadeMin, velocidadeMax = 16, 300

-- Criar slider walk
local velocidadeText, velocidadeSliderBg, velocidadeSliderFill, vMin, vMax = criarSlider(frame, 35, "Velocidade Walk: 16", Color3.fromRGB(0, 170, 255), velocidadeMin, velocidadeMax, velocidadeSelecionada)

local mouseDown = false
local bloqueiaDrag = false

local function atualizarSlider(posX)
    local largura = velocidadeSliderBg.AbsoluteSize.X
    local cliqueX = math.clamp(posX, 0, largura)
    local percent = cliqueX / largura
    velocidadeSelecionada = math.floor(velocidadeMin + percent * (velocidadeMax - velocidadeMin))
    velocidadeSliderFill.Size = UDim2.new(percent, 0, 1, 0)
    velocidadeText.Text = "Velocidade Walk: " .. velocidadeSelecionada
end

velocidadeSliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        mouseDown = true
        bloqueiaDrag = true
        atualizarSlider(input.Position.X - velocidadeSliderBg.AbsolutePosition.X)
    end
end)

velocidadeSliderBg.InputChanged:Connect(function(input)
    if mouseDown and input.UserInputType == Enum.UserInputType.MouseMovement then
        atualizarSlider(input.Position.X - velocidadeSliderBg.AbsolutePosition.X)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        mouseDown = false
        bloqueiaDrag = false
    end
end)

-- Botões walk
local aplicarBtn = criarBotao("Aplicar Velocidade", 0.05, 120, Color3.fromRGB(0, 170, 255))
local resetBtn = criarBotao("Resetar para 16", 0.5, 120, Color3.fromRGB(170, 0, 0))

aplicarBtn.MouseButton1Click:Connect(function()
    local player = game.Players.LocalPlayer
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = velocidadeSelecionada
        end
    end
end)

resetBtn.MouseButton1Click:Connect(function()
    velocidadeSelecionada = 16
    velocidadeSliderFill.Size = UDim2.new(0, 0, 1, 0)
    velocidadeText.Text = "Velocidade Walk: 16"
    local player = game.Players.LocalPlayer
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
        end
    end
end)

-- Voo
local flySpeed = 50
local flySpeedMin, flySpeedMax = 16, 300
local flying = false
local control = {F=0, B=0, L=0, R=0}
local bv, bg

local function Fly()
    local player = game.Players.LocalPlayer
    local char = player.Character
    local humanoidRoot = char and char:FindFirstChild("HumanoidRootPart")
    if not humanoidRoot then return end

    bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.zero
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.P = 1250
    bv.Parent = humanoidRoot

    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bg.P = 1250
    bg.CFrame = humanoidRoot.CFrame
    bg.Parent = humanoidRoot

    RunService:BindToRenderStep("FlightUpdate", Enum.RenderPriority.Character.Value + 1, function()
        if flying then
            local camCF = workspace.CurrentCamera.CFrame
            local move = (camCF.LookVector * control.F + -camCF.LookVector * control.B + camCF.RightVector * control.R + -camCF.RightVector * control.L)
            bv.Velocity = move * flySpeed
            bg.CFrame = camCF
        end
    end)
end

UserInputService.InputBegan:Connect(function(input)
    local key = input.KeyCode
    if key == Enum.KeyCode.W then control.F = 1 end
    if key == Enum.KeyCode.S then control.B = 1 end
    if key == Enum.KeyCode.A then control.L = 1 end
    if key == Enum.KeyCode.D then control.R = 1 end
end)

UserInputService.InputEnded:Connect(function(input)
    local key = input.KeyCode
    if key == Enum.KeyCode.W then control.F = 0 end
    if key == Enum.KeyCode.S then control.B = 0 end
    if key == Enum.KeyCode.A then control.L = 0 end
    if key == Enum.KeyCode.D then control.R = 0 end
end)

-- Criar slider voo
local vooText, vooSliderBg, vooSliderFill, vFlyMin, vFlyMax = criarSlider(frame, 190, "Velocidade Voo: 50", Color3.fromRGB(255, 170, 0), flySpeedMin, flySpeedMax, flySpeed)

local function atualizarVooSlider(posX)
    local largura = vooSliderBg.AbsoluteSize.X
    local cliqueX = math.clamp(posX, 0, largura)
    local percent = cliqueX / largura
    flySpeed = math.floor(flySpeedMin + percent * (flySpeedMax - flySpeedMin))
    vooSliderFill.Size = UDim2.new(percent, 0, 1, 0)
    vooText.Text = "Velocidade Voo: " .. flySpeed
end

vooSliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        mouseDown = true
        bloqueiaDrag = true
        atualizarVooSlider(input.Position.X - vooSliderBg.AbsolutePosition.X)
    end
end)

vooSliderBg.InputChanged:Connect(function(input)
    if mouseDown and input.UserInputType == Enum.UserInputType.MouseMovement then
        atualizarVooSlider(input.Position.X - vooSliderBg.AbsolutePosition.X)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        mouseDown = false
        bloqueiaDrag = false
    end
end)

-- Botões voo
local flyBtn = criarBotao("✈️ Ativar Voo", 0.05, 255, Color3.fromRGB(0, 170, 0))
local unflyBtn = criarBotao("🛑 Desativar Voo", 0.5, 255, Color3.fromRGB(200, 0, 0))

flyBtn.MouseButton1Click:Connect(function()
    if not flying then
        flying = true
        Fly()
    end
end)

unflyBtn.MouseButton1Click:Connect(function()
    if flying then
        flying = false
        RunService:UnbindFromRenderStep("FlightUpdate")
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
    end
end)

-- Botão para esconder a interface
local fecharBtn = Instance.new("TextButton")
fecharBtn.Size = UDim2.new(0, 30, 0, 30)
fecharBtn.Position = UDim2.new(1, -35, 0, 5) -- no canto superior direito do frame
fecharBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
fecharBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
fecharBtn.Font = Enum.Font.SourceSansBold
fecharBtn.TextSize = 18
fecharBtn.Text = "X"
fecharBtn.Parent = frame

fecharBtn.MouseButton1Click:Connect(function()
    gui.Enabled = false
end)

-- Hotkey para mostrar/esconder a interface (tecla K)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.K then
        gui.Enabled = not gui.Enabled
    end
end)
