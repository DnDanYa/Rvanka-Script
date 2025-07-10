local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")

-- settings
local SpinSpeed = 1000000
local LaunchPower = 500
local ButtonSize = UDim2.new(0.15, 0, 0.1, 0)

local HUDColor = Color3.fromRGB(80, 80, 80)
local TextColor = Color3.fromRGB(255, 255, 255)
local HUDTransparency = 0.3
local OutlineColor = Color3.fromRGB(255, 0, 0)

local Running = false
local CurrentTarget = nil
local SpinTorque = nil
local RainbowHighlight = nil
local CurrentMode = "Default" -- "Default" или "Ultra"
local Dragging = false
local DragStartPos = nil
local TextStartPos = nil

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "SpinAttackUI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local TargetHUD = Instance.new("Frame")
TargetHUD.Parent = ScreenGui
TargetHUD.Size = UDim2.new(0.35, 0, 0.07, 0)
TargetHUD.Position = UDim2.new(0.325, 0, 0.04, 0)
TargetHUD.BackgroundColor3 = HUDColor
TargetHUD.BackgroundTransparency = HUDTransparency
TargetHUD.BorderSizePixel = 0
TargetHUD.Active = true
TargetHUD.Draggable = true

local UICorner = Instance.new("UICorner")
UICorner.Parent = TargetHUD
UICorner.CornerRadius = UDim.new(0.2, 0)

local UIStroke = Instance.new("UIStroke")
UIStroke.Parent = TargetHUD
UIStroke.Color = Color3.fromRGB(120, 120, 120)
UIStroke.Thickness = 2
UIStroke.Transparency = 0.5
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local HudText = Instance.new("TextLabel")
HudText.Parent = TargetHUD
HudText.Size = UDim2.new(0.7, 0, 0.8, 0)
HudText.Position = UDim2.new(0.05, 0, 0.1, 0)
HudText.BackgroundTransparency = 1
HudText.Text = "SpinLorius Beta | OFF | Target: None | Mode: Default"
HudText.TextColor3 = TextColor
HudText.Font = Enum.Font.GothamBold
HudText.TextSize = 16
HudText.TextXAlignment = Enum.TextXAlignment.Left

local MenuButton = Instance.new("TextButton")
MenuButton.Parent = TargetHUD
MenuButton.Size = UDim2.new(0.2, 0, 0.8, 0)
MenuButton.Position = UDim2.new(0.75, 0, 0.1, 0)
MenuButton.Text = "Меню"
MenuButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MenuButton.BackgroundTransparency = 0.3
MenuButton.TextColor3 = TextColor
MenuButton.Font = Enum.Font.GothamBold
MenuButton.TextSize = 14
MenuButton.AutoButtonColor = false

local MenuButtonCorner = Instance.new("UICorner")
MenuButtonCorner.Parent = MenuButton
MenuButtonCorner.CornerRadius = UDim.new(0.2, 0)

local SettingsFrame = Instance.new("Frame")
SettingsFrame.Parent = ScreenGui
SettingsFrame.Size = UDim2.new(0.25, 0, 0.3, 0)
SettingsFrame.Position = UDim2.new(0.375, 0, 0.3, 0)
SettingsFrame.BackgroundColor3 = HUDColor
SettingsFrame.BackgroundTransparency = HUDTransparency
SettingsFrame.BorderSizePixel = 0
SettingsFrame.Visible = false
SettingsFrame.Active = true
SettingsFrame.Draggable = true

local SettingsCorner = Instance.new("UICorner")
SettingsCorner.Parent = SettingsFrame
SettingsCorner.CornerRadius = UDim.new(0.05, 0)

local SettingsStroke = Instance.new("UIStroke")
SettingsStroke.Parent = SettingsFrame
SettingsStroke.Color = Color3.fromRGB(100, 100, 100)
SettingsStroke.Thickness = 2
SettingsStroke.Transparency = 0.3

local SettingsTitle = Instance.new("TextLabel")
SettingsTitle.Parent = SettingsFrame
SettingsTitle.Size = UDim2.new(0.9, 0, 0.15, 0)
SettingsTitle.Position = UDim2.new(0.05, 0, 0.02, 0)
SettingsTitle.BackgroundTransparency = 1
SettingsTitle.Text = "Настройки SpinLorius"
SettingsTitle.TextColor3 = TextColor
SettingsTitle.Font = Enum.Font.GothamBold
SettingsTitle.TextSize = 18

local function CreateColorPicker(parent, name, positionY, defaultColor, callback)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.Size = UDim2.new(0.9, 0, 0.1, 0)
    frame.Position = UDim2.new(0.05, 0, positionY, 0)
    frame.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = TextColor
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local colorButton = Instance.new("TextButton")
    colorButton.Parent = frame
    colorButton.Size = UDim2.new(0.3, 0, 0.8, 0)
    colorButton.Position = UDim2.new(0.7, 0, 0.1, 0)
    colorButton.BackgroundColor3 = defaultColor
    colorButton.Text = ""
    colorButton.AutoButtonColor = false
    
    local corner = Instance.new("UICorner")
    corner.Parent = colorButton
    corner.CornerRadius = UDim.new(0.2, 0)
    
    colorButton.MouseButton1Click:Connect(function()
        local newColor = Color3.fromRGB(
            math.random(0, 255),
            math.random(0, 255),
            math.random(0, 255)
        )
        colorButton.BackgroundColor3 = newColor
        callback(newColor)
    end)
    
    return frame
end

CreateColorPicker(SettingsFrame, "Цвет интерфейса", 0.15, HUDColor, function(color)
    HUDColor = color
    TargetHUD.BackgroundColor3 = color
    SettingsFrame.BackgroundColor3 = color
    MenuButton.BackgroundColor3 = Color3.fromRGB(
        math.floor(color.R * 60),
        math.floor(color.G * 60),
        math.floor(color.B * 60)
    )
    CoordText.TextColor3 = color
end)

CreateColorPicker(SettingsFrame, "Цвет текста", 0.3, TextColor, function(color)
    TextColor = color
    HudText.TextColor3 = color
    SettingsTitle.TextColor3 = color
    MenuButton.TextColor3 = color
    CoordText.TextColor3 = color
end)

CreateColorPicker(SettingsFrame, "Цвет обводки", 0.45, OutlineColor, function(color)
    OutlineColor = color
    if RainbowHighlight then
        RainbowHighlight.OutlineColor = color
    end
end)

local ModeButton = Instance.new("TextButton")
ModeButton.Parent = SettingsFrame
ModeButton.Size = UDim2.new(0.9, 0, 0.1, 0)
ModeButton.Position = UDim2.new(0.05, 0, 0.6, 0)
ModeButton.Text = "Режим: Default"
ModeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
ModeButton.TextColor3 = TextColor
ModeButton.Font = Enum.Font.GothamBold
ModeButton.TextSize = 14

local ModeCorner = Instance.new("UICorner")
ModeCorner.Parent = ModeButton
ModeCorner.CornerRadius = UDim.new(0.2, 0)

local ControlsText = Instance.new("TextLabel")
ControlsText.Parent = SettingsFrame
ControlsText.Size = UDim2.new(0.9, 0, 0.2, 0)
ControlsText.Position = UDim2.new(0.05, 0, 0.75, 0)
ControlsText.BackgroundTransparency = 1
ControlsText.Text = "R - Вкл/Выкл\nN - Сменить цель\nInsert - Открыть меню"
ControlsText.TextColor3 = TextColor
ControlsText.Font = Enum.Font.Gotham
ControlsText.TextSize = 14
ControlsText.TextXAlignment = Enum.TextXAlignment.Left
ControlsText.TextYAlignment = Enum.TextYAlignment.Top

-- Текст с координатами и ником
local CoordText = Instance.new("TextLabel")
CoordText.Parent = ScreenGui
CoordText.Size = UDim2.new(0.2, 0, 0.05, 0)
CoordText.Position = UDim2.new(0.75, 0, 0.9, 0)
CoordText.BackgroundTransparency = 1
CoordText.Text = "Player: "..LocalPlayer.Name.." | Pos: [0, 0, 0]"
CoordText.TextColor3 = TextColor
CoordText.Font = Enum.Font.GothamBold
CoordText.TextSize = 14
CoordText.TextXAlignment = Enum.TextXAlignment.Left
CoordText.Active = true
CoordText.Selectable = true

CoordText.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = true
        DragStartPos = Vector2.new(input.Position.X, input.Position.Y)
        TextStartPos = CoordText.Position
    end
end)

CoordText.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = Vector2.new(input.Position.X, input.Position.Y) - DragStartPos
        CoordText.Position = UDim2.new(
            TextStartPos.X.Scale, 
            TextStartPos.X.Offset + delta.X,
            TextStartPos.Y.Scale, 
            TextStartPos.Y.Offset + delta.Y
        )
    end
end)

local function UltraFling(TargetPlayer)
    if not TargetPlayer or not TargetPlayer.Character then return end
    
    local Character = LocalPlayer.Character
    if not Character then return end
    
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
    
    local TCharacter = TargetPlayer.Character
    local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    local TRootPart = THumanoid and THumanoid.RootPart
    local THead = TCharacter:FindFirstChild("Head")
    local Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    local Handle = Accessory and Accessory:FindFirstChild("Handle")
    
    if not Humanoid or not RootPart then return end
    
    if RootPart.Velocity.Magnitude < 50 then
        getgenv().OldPos = RootPart.CFrame
    end
    
    if THumanoid and THumanoid.Sit then return end
    
    if THead then
        workspace.CurrentCamera.CameraSubject = THead
    elseif Handle then
        workspace.CurrentCamera.CameraSubject = Handle
    else
        workspace.CurrentCamera.CameraSubject = THumanoid
    end
    
    if not TCharacter:FindFirstChildWhichIsA("BasePart") then
        return
    end

    local function FPos(BasePart, Pos, Ang)
        RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
        Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
        RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
        RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
    end

    local function SFBasePart(BasePart)
        local TimeToWait = 2
        local Time = tick()
        local Angle = 0

        repeat
            if RootPart and THumanoid then
                if BasePart.Velocity.Magnitude < 50 then
                    Angle = Angle + 100

                    FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                    task.wait()

                    FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()

                    FPos(BasePart, CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()

                    FPos(BasePart, CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()

                    FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()

                    FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()
                else
                    FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()

                    FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                    task.wait()

                    FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()

                    FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()

                    FPos(BasePart, CFrame.new(0, -1.5, -TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0))
                    task.wait()

                    FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()

                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()

                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                    task.wait()

                    FPos(BasePart, CFrame.new(0, -1.5 ,0), CFrame.Angles(math.rad(-90), 0, 0))
                    task.wait()

                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                    task.wait()
                end
            else
                break
            end
        until BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= TargetPlayer.Character or TargetPlayer.Parent ~= Players or not TargetPlayer.Character == TCharacter or THumanoid.Sit or Humanoid.Health <= 0 or tick() > Time + TimeToWait
    end

    workspace.FallenPartsDestroyHeight = 0/0

    local BV = Instance.new("BodyVelocity")
    BV.Name = "EpixVel"
    BV.Parent = RootPart
    BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
    BV.MaxForce = Vector3.new(1/0, 1/0, 1/0)

    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

    if TRootPart and THead then
        if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude > 5 then
            SFBasePart(THead)
        else
            SFBasePart(TRootPart)
        end
    elseif TRootPart and not THead then
        SFBasePart(TRootPart)
    elseif not TRootPart and THead then
        SFBasePart(THead)
    elseif not TRootPart and not THead and Accessory and Handle then
        SFBasePart(Handle)
    end

    BV:Destroy()
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    workspace.CurrentCamera.CameraSubject = Humanoid

    repeat
        RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
        Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
        Humanoid:ChangeState("GettingUp")
        for _, x in pairs(Character:GetChildren()) do
            if x:IsA("BasePart") then
                x.Velocity, x.RotVelocity = Vector3.new(), Vector3.new()
            end
        end
        task.wait()
    until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
    workspace.FallenPartsDestroyHeight = getgenv().FPDH
end

local function ToggleMode()
    if CurrentMode == "Default" then
        CurrentMode = "Ultra"
    else
        CurrentMode = "Default"
    end
    ModeButton.Text = "Режим: "..CurrentMode
    UpdateHUD()
end

ModeButton.MouseButton1Click:Connect(ToggleMode)

local function UpdateHUD()
    local statusText = Running and "ON" or "OFF"
    local targetText = CurrentTarget and CurrentTarget.Name or "None"
    
    HudText.Text = string.format("SpinLorius Beta | %s | Target: %s | Mode: %s", 
        statusText, 
        targetText,
        CurrentMode)
    
    if Running then
        UIStroke.Color = Color3.fromRGB(150, 150, 150)
    else
        UIStroke.Color = Color3.fromRGB(120, 120, 120)
    end
end

local function CreateRainbowOutline()
    if RainbowHighlight then RainbowHighlight:Destroy() end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    RainbowHighlight = Instance.new("Highlight")
    RainbowHighlight.Name = "RainbowOutline"
    RainbowHighlight.FillTransparency = 1
    RainbowHighlight.OutlineColor = OutlineColor
    RainbowHighlight.OutlineTransparency = 0
    RainbowHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    RainbowHighlight.Parent = character
    
    coroutine.wrap(function()
        while RainbowHighlight and RainbowHighlight.Parent do
            for hue = 0, 1, 0.01 do
                if not RainbowHighlight then break end
                RainbowHighlight.OutlineColor = Color3.fromHSV(hue, 1, 1)
                wait(0.05)
            end
        end
    end)()
end

local function RemoveRainbowOutline()
    if RainbowHighlight then
        RainbowHighlight:Destroy()
        RainbowHighlight = nil
    end
end

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
        
        CreateRainbowOutline()
    else
        if SpinTorque then SpinTorque:Destroy() end
        for _, v in pairs(root:GetChildren()) do
            if v:IsA("Attachment") then v:Destroy() end
        end
        RemoveRainbowOutline()
    end
end

local function TeleportAndLaunch(target)
    if not target or not target.Character then return end
    
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot or not myRoot then return end
    
    myRoot.CFrame = targetRoot.CFrame
    
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


local function GetRandomPlayer()
    local valid = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            table.insert(valid, player)
        end
    end
    return #valid > 0 and valid[math.random(#valid)] or nil
end


local function SwitchTarget()
    CurrentTarget = GetRandomPlayer()
    UpdateHUD()
end

local function ToggleRunning()
    Running = not Running
    
    if CurrentMode == "Default" then
        ToggleSpin(Running)
    else
        if Running then
            CreateRainbowOutline()
        else
            RemoveRainbowOutline()
        end
    end
    
    if Running and not CurrentTarget then
        SwitchTarget()
    end
    
    UpdateHUD()
end

local function CreateMobileButtons()
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Parent = ScreenGui
    ToggleButton.Size = ButtonSize
    ToggleButton.Position = UDim2.new(0.05, 0, 0.8, 0)
    ToggleButton.Text = "R (Вкл/Выкл)"
    ToggleButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.8)
    ToggleButton.TextColor3 = TextColor
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.TextScaled = true
    
    local TargetButton = Instance.new("TextButton")
    TargetButton.Name = "TargetButton"
    TargetButton.Parent = ScreenGui
    TargetButton.Size = ButtonSize
    TargetButton.Position = UDim2.new(0.25, 0, 0.8, 0)
    TargetButton.Text = "N (Цель)"
    TargetButton.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
    TargetButton.TextColor3 = TextColor
    TargetButton.Font = Enum.Font.GothamBold
    TargetButton.TextScaled = true
    
    ToggleButton.MouseButton1Click:Connect(function()
        ToggleRunning()
    end)
    
    TargetButton.MouseButton1Click:Connect(function()
        SwitchTarget()
    end)
end

local function ToggleMenu()
    SettingsFrame.Visible = not SettingsFrame.Visible
end

MenuButton.MouseButton1Click:Connect(ToggleMenu)

local function onInputBegan(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.R then
        ToggleRunning()
    elseif input.KeyCode == Enum.KeyCode.N then
        SwitchTarget()
    elseif input.KeyCode == Enum.KeyCode.Insert then
        ToggleMenu()
    end
end

UIS.InputBegan:Connect(onInputBegan)

RunService.Heartbeat:Connect(function()
    local character = LocalPlayer.Character
    if character then
        local root = character:FindFirstChild("HumanoidRootPart")
        if root then
            local pos = root.Position
            CoordText.Text = string.format("Player: %s | Pos: [%d, %d, %d]", 
                LocalPlayer.Name, 
                math.floor(pos.X), 
                math.floor(pos.Y), 
                math.floor(pos.Z))
        end
    end
    
    -- Обработка атаки
    if not Running then return end
    
    if CurrentTarget and CurrentTarget.Character then
        if CurrentMode == "Default" then
            TeleportAndLaunch(CurrentTarget)
        else
            UltraFling(CurrentTarget)
        end
    else
        SwitchTarget()
        if not CurrentTarget then
            Running = false
            if CurrentMode == "Default" then
                ToggleSpin(false)
            else
                RemoveRainbowOutline()
            end
            UpdateHUD()
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    if Running then
        wait(1) -- Даем время для полной загрузки персонажа
        if CurrentMode == "Default" then
            ToggleSpin(true)
        else
            CreateRainbowOutline()
        end
    end
end)

CreateMobileButtons()
UpdateHUD()

if not GuiService:IsTenFootInterface() and not UIS.TouchEnabled then
    for _, button in ipairs({"ToggleButton", "TargetButton"}) do
        local btn = ScreenGui:FindFirstChild(button)
        if btn then btn.Visible = false end
    end
end
