local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

-- Настройки
local SpinSpeed = 1000000
local TeleportInterval = 0.01
local LaunchPower = 500
local ButtonSize = UDim2.new(0.15, 0, 0.1, 0)

-- Состояние
local Running = false
local Mode = "one" -- "one" или "all"
local CurrentTarget = nil
local VisualParts = {}
local SpinTorque = nil

-- Создаем основной GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "SpinAttackMobileUI"

-- Создаем HUD
local TargetHUD = Instance.new("TextLabel")
TargetHUD.Parent = ScreenGui
TargetHUD.Size = UDim2.new(0.3, 0, 0.05, 0)
TargetHUD.Position = UDim2.new(0.35, 0, 0.05, 0)
TargetHUD.BackgroundColor3 = Color3.new(1, 0, 0)
TargetHUD.BorderSizePixel = 2
TargetHUD.BorderColor3 = Color3.new(0, 0, 0)
TargetHUD.Text = "OFF | Mode: one | Target: None"
TargetHUD.TextColor3 = Color3.new(1, 1, 1)
TargetHUD.Font = Enum.Font.SourceSansBold
TargetHUD.TextSize = 18

-- Обновляем HUD
local function UpdateHUD()
    TargetHUD.Text = string.format("%s | Mode: %s | Target: %s", 
        Running and "ON" or "OFF", 
        Mode, 
        CurrentTarget and CurrentTarget.Name or (Mode == "all" and "ALL" or "None"))
end

-- Создаем 3D Box
local function CreateBox(target)
    ClearBox()
    
    if not target or not target.Character then return end
    
    local root = target.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local size = Vector3.new(4, 6, 4)
    local cf = root.CFrame
    
    local edges = {
        {Vector3.new(1,1,1), Vector3.new(-1,1,1)},
        {Vector3.new(-1,1,1), Vector3.new(-1,-1,1)},
        {Vector3.new(-1,-1,1), Vector3.new(1,-1,1)},
        {Vector3.new(1,-1,1), Vector3.new(1,1,1)},
        {Vector3.new(1,1,-1), Vector3.new(-1,1,-1)},
        {Vector3.new(-1,1,-1), Vector3.new(-1,-1,-1)},
        {Vector3.new(-1,-1,-1), Vector3.new(1,-1,-1)},
        {Vector3.new(1,-1,-1), Vector3.new(1,1,-1)},
        {Vector3.new(1,1,1), Vector3.new(1,1,-1)},
        {Vector3.new(-1,1,1), Vector3.new(-1,1,-1)},
        {Vector3.new(-1,-1,1), Vector3.new(-1,-1,-1)},
        {Vector3.new(1,-1,1), Vector3.new(1,-1,-1)}
    }
    
    for _, edge in pairs(edges) do
        local start = cf * CFrame.new(edge[1] * size/2)
        local finish = cf * CFrame.new(edge[2] * size/2)
        local distance = (start.p - finish.p).Magnitude
        
        local part = Instance.new("Part")
        part.Anchored = true
        part.CanCollide = false
        part.Transparency = 0.7
        part.Color = Color3.new(0, 1, 1)
        part.Size = Vector3.new(0.2, 0.2, distance)
        part.CFrame = CFrame.new(start.p:Lerp(finish.p, 0.5), finish.p)
        part.Parent = workspace
        
        table.insert(VisualParts, part)
    end
end

-- Очищаем Box
local function ClearBox()
    for _, part in pairs(VisualParts) do
        part:Destroy()
    end
    VisualParts = {}
end

-- Вращение
local function ToggleSpin(enable)
    local char = LocalPlayer.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    if enable then
        SpinTorque = Instance.new("Torque")
        SpinTorque.Torque = Vector3.new(0, SpinSpeed, 0)
        SpinTorque.Attachment0 = Instance.new("Attachment")
        SpinTorque.Attachment0.Parent = root
        SpinTorque.Parent = root
    else
        if SpinTorque then SpinTorque:Destroy() end
        for _, v in pairs(root:GetChildren()) do
            if v:IsA("Attachment") then v:Destroy() end
        end
    end
end

-- Телепорт и отбрасывание
local function TeleportAndLaunch(target)
    if not target or not target.Character then return end
    
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot or not myRoot then return end
    
    -- Телепорт
    myRoot.CFrame = targetRoot.CFrame
    
    -- Отбрасывание
    local humanoid = target.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.PlatformStand = true
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = Vector3.new(0, LaunchPower, 0)
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Parent = targetRoot
        game:GetService("Debris"):AddItem(bv, 0.1)
    end
end

-- Поиск случайного игрока
local function GetRandomPlayer()
    local valid = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            table.insert(valid, player)
        end
    end
    return #valid > 0 and valid[math.random(#valid)] or nil
end

-- Получаем список всех игроков
local function GetAllPlayers()
    local valid = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            table.insert(valid, player)
        end
    end
    return valid
end

-- Смена цели
local function SwitchTarget()
    if Mode == "one" then
        CurrentTarget = GetRandomPlayer()
        CreateBox(CurrentTarget)
        UpdateHUD()
    end
end

-- Функции для кнопок
local function ToggleRunning()
    Running = not Running
    ToggleSpin(Running)
    if Running and Mode == "one" and not CurrentTarget then
        SwitchTarget()
    end
    UpdateHUD()
end

local function ToggleMode()
    Mode = Mode == "one" and "all" or "one"
    ClearBox()
    if Mode == "one" and Running then
        SwitchTarget()
    end
    UpdateHUD()
end

-- Создаем кнопки для мобильного управления
local function CreateMobileButtons()
    -- Кнопка включения/выключения (R)
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Parent = ScreenGui
    ToggleButton.Size = ButtonSize
    ToggleButton.Position = UDim2.new(0.05, 0, 0.8, 0)
    ToggleButton.Text = "R (Вкл/Выкл)"
    ToggleButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.8)
    ToggleButton.TextColor3 = Color3.new(1, 1, 1)
    ToggleButton.Font = Enum.Font.SourceSansBold
    ToggleButton.TextScaled = true
    
    -- Кнопка смены режима (G)
    local ModeButton = Instance.new("TextButton")
    ModeButton.Name = "ModeButton"
    ModeButton.Parent = ScreenGui
    ModeButton.Size = ButtonSize
    ModeButton.Position = UDim2.new(0.25, 0, 0.8, 0)
    ModeButton.Text = "G (Режим)"
    ModeButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    ModeButton.TextColor3 = Color3.new(1, 1, 1)
    ModeButton.Font = Enum.Font.SourceSansBold
    ModeButton.TextScaled = true
    
    -- Кнопка смены цели (N)
    local TargetButton = Instance.new("TextButton")
    TargetButton.Name = "TargetButton"
    TargetButton.Parent = ScreenGui
    TargetButton.Size = ButtonSize
    TargetButton.Position = UDim2.new(0.45, 0, 0.8, 0)
    TargetButton.Text = "N (Цель)"
    TargetButton.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
    TargetButton.TextColor3 = Color3.new(1, 1, 1)
    TargetButton.Font = Enum.Font.SourceSansBold
    TargetButton.TextScaled = true
    
    -- Обработчики нажатий
    ToggleButton.MouseButton1Click:Connect(function()
        ToggleRunning()
    end)
    
    ModeButton.MouseButton1Click:Connect(function()
        ToggleMode()
    end)
    
    TargetButton.MouseButton1Click:Connect(function()
        if Mode == "one" then
            SwitchTarget()
        end
    end)
end

-- Обработка клавиш
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.R then
        ToggleRunning()
    elseif input.KeyCode == Enum.KeyCode.G then
        ToggleMode()
    elseif input.KeyCode == Enum.KeyCode.N then
        if Mode == "one" then
            SwitchTarget()
        end
    end
end)

-- Главный цикл
RunService.Heartbeat:Connect(function()
    if not Running then return end
    
    if Mode == "one" then
        if CurrentTarget and CurrentTarget.Character then
            TeleportAndLaunch(CurrentTarget)
        else
            SwitchTarget()
            if not CurrentTarget then
                Running = false
                ToggleSpin(false)
                UpdateHUD()
            end
        end
    else
        -- Режим all - атакуем всех игроков
        for _, player in pairs(GetAllPlayers()) do
            if player.Character then
                TeleportAndLaunch(player)
            end
        end
    end
end)

-- Инициализация
CreateMobileButtons()
UpdateHUD()

-- Автоматически скрываем кнопки на ПК
if not GuiService:IsTenFootInterface() and not UIS.TouchEnabled then
    ScreenGui:FindFirstChild("ToggleButton").Visible = false
    ScreenGui:FindFirstChild("ModeButton").Visible = false
    ScreenGui:FindFirstChild("TargetButton").Visible = false
end