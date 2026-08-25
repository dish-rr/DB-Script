-- 集合 · 天休制作 (Slaughter 97463774278378)
-- DB 风格 UI: 箱子 Chams / 人物 ESP / 秒交互
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer

if not game:IsLoaded() then game.Loaded:Wait() end

local S = {
    crateChams = true,
    playerEsp = true,
    instantInteract = false,
    closed = false,
}

------------------------------------------------------------
-- DB 风格 UI 基础
------------------------------------------------------------
local RAINBOW_FLOW = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 82, 126)),
    ColorSequenceKeypoint.new(0.14, Color3.fromRGB(255, 146, 82)),
    ColorSequenceKeypoint.new(0.28, Color3.fromRGB(255, 218, 82)),
    ColorSequenceKeypoint.new(0.42, Color3.fromRGB(142, 255, 82)),
    ColorSequenceKeypoint.new(0.56, Color3.fromRGB(82, 224, 255)),
    ColorSequenceKeypoint.new(0.70, Color3.fromRGB(98, 130, 255)),
    ColorSequenceKeypoint.new(0.86, Color3.fromRGB(236, 92, 255)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 82, 126)),
})

local function AddCorner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = obj
end

local function StartRainbowFlow(parent, duration, transparency)
    local grad = Instance.new("UIGradient")
    grad.Name = "RainbowFlow"
    grad.Color = RAINBOW_FLOW
    grad.Transparency = transparency or NumberSequence.new(0)
    grad.Rotation = -180
    grad.Parent = parent
    local tw = TweenService:Create(grad, TweenInfo.new(duration or 2.0, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false, 0), { Rotation = 180 })
    tw:Play()
    return grad, tw
end

local function AddRainbowBorder(obj, thickness, transparency, speed)
    local stroke = Instance.new("UIStroke")
    stroke.Name = "DB_RainbowMain"
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Thickness = thickness or 0.9
    stroke.Color = Color3.new(1, 1, 1)
    stroke.Transparency = transparency or 0.01
    stroke.LineJoinMode = Enum.LineJoinMode.Round
    stroke.Parent = obj
    local grad = StartRainbowFlow(stroke, speed or 1.95)
    return stroke, grad
end

local function AddBorder(obj, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Thickness = thickness or 0.85
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = transparency or 0.52
    stroke.LineJoinMode = Enum.LineJoinMode.Round
    stroke.Parent = obj
    return stroke
end

local function CreateToggleRow(parent, title, getValue, onChange)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -12, 0, 36)
    row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    row.BackgroundTransparency = 0.88
    row.BorderSizePixel = 0
    row.Parent = parent
    AddCorner(row, 8)
    AddBorder(row, 0.7, 0.6)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -66, 1, 0)
    label.Position = UDim2.fromOffset(12, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 12
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.Parent = row
    local enabled = getValue and getValue() or false
    local switch = Instance.new("TextButton")
    switch.AnchorPoint = Vector2.new(1, 0.5)
    switch.Position = UDim2.new(1, -12, 0.5, 0)
    switch.Size = UDim2.fromOffset(44, 22)
    switch.BackgroundColor3 = enabled and Color3.fromRGB(205, 210, 220) or Color3.fromRGB(62, 65, 72)
    switch.BackgroundTransparency = 0.12
    switch.BorderSizePixel = 0
    switch.Text = ""
    switch.AutoButtonColor = false
    switch.Parent = row
    AddCorner(switch, 999)
    local knob = Instance.new("Frame")
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = enabled and UDim2.new(1, -11, 0.5, 0) or UDim2.new(0, 11, 0.5, 0)
    knob.Size = UDim2.fromOffset(17, 17)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BackgroundTransparency = 0
    knob.BorderSizePixel = 0
    knob.Parent = switch
    AddCorner(knob, 999)
    switch.Activated:Connect(function()
        enabled = not enabled
        if onChange then pcall(onChange, enabled) end
        TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = enabled and UDim2.new(1, -11, 0.5, 0) or UDim2.new(0, 11, 0.5, 0) }):Play()
        TweenService:Create(switch, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = enabled and Color3.fromRGB(205, 210, 220) or Color3.fromRGB(62, 65, 72) }):Play()
    end)
    return row
end

local function Notify(title, text)
    pcall(function()
        local pg = lp:WaitForChild("PlayerGui")
        local old = pg:FindFirstChild("TX_CollectionNotify")
        if old then old:Destroy() end
        local frame = Instance.new("Frame")
        frame.Name = "TX_CollectionNotify"
        frame.AnchorPoint = Vector2.new(1, 1)
        frame.Position = UDim2.new(1, -16, 1, -16)
        frame.Size = UDim2.fromOffset(280, 54)
        frame.BackgroundColor3 = Color3.fromRGB(10, 12, 16)
        frame.BackgroundTransparency = 0.25
        frame.BorderSizePixel = 0
        frame.ZIndex = 5000
        frame.Parent = pg
        AddCorner(frame, 12)
        AddBorder(frame, 1, 0.35)
        local t1 = Instance.new("TextLabel")
        t1.Size = UDim2.new(1, -20, 0, 18)
        t1.Position = UDim2.fromOffset(10, 5)
        t1.BackgroundTransparency = 1
        t1.Text = title
        t1.TextColor3 = Color3.fromRGB(255, 255, 255)
        t1.TextSize = 12
        t1.Font = Enum.Font.GothamBlack
        t1.TextXAlignment = Enum.TextXAlignment.Left
        t1.Parent = frame
        local t2 = Instance.new("TextLabel")
        t2.Size = UDim2.new(1, -20, 0, 22)
        t2.Position = UDim2.fromOffset(10, 25)
        t2.BackgroundTransparency = 1
        t2.Text = text
        t2.TextColor3 = Color3.fromRGB(200, 210, 230)
        t2.TextSize = 10
        t2.Font = Enum.Font.GothamMedium
        t2.TextXAlignment = Enum.TextXAlignment.Left
        t2.Parent = frame
        task.delay(3, function()
            if frame and frame.Parent then
                TweenService:Create(frame, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
                task.delay(0.35, function() if frame and frame.Parent then frame:Destroy() end end)
            end
        end)
    end)
end

------------------------------------------------------------
-- ① 箱子 Chams
------------------------------------------------------------
local function getCrateSpawns()
    local Map1 = workspace:FindFirstChild("Map1")
    return Map1 and Map1:FindFirstChild("CrateSpawns") or nil
end

local function applyCrateChams(crate)
    if crate:FindFirstChild("VoughtCrateChams") then
        return
    end
    pcall(function()
        local h = Instance.new("Highlight")
        h.Name = "VoughtCrateChams"
        h.FillColor = Color3.fromRGB(80, 255, 140)
        h.FillTransparency = 0.45
        h.OutlineColor = Color3.fromRGB(20, 200, 90)
        h.OutlineTransparency = 0
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent = crate
    end)
end

local function scanCrates()
    local CrateSpawns = getCrateSpawns()
    if not CrateSpawns then
        return 0
    end
    local n = 0
    for _, child in ipairs(CrateSpawns:GetChildren()) do
        if child:IsA("Model") and child.Name == "VoughtCrate" then
            applyCrateChams(child)
            n = n + 1
        end
    end
    return n
end

task.spawn(function()
    while true do
        if S.closed then break end
        pcall(function()
            if S.crateChams then
                scanCrates()
            end
        end)
        task.wait(1.5)
    end
end)

------------------------------------------------------------
-- ② 人物 ESP
------------------------------------------------------------
local function charTeam(char)
    if not char then
        return "None"
    end
    local player = Players:GetPlayerFromCharacter(char)
    if player then
        return player.Team and player.Team.Name or "Lobby"
    end
    return "None"
end

local function isVillain(char)
    return charTeam(char) == "Villain" or char:FindFirstChild("VillainCostume") ~= nil
end

local COLORS = {
    Villain = { fill = Color3.fromRGB(255, 64, 64), outline = Color3.fromRGB(200, 20, 20) },
    Survivor = { fill = Color3.fromRGB(80, 255, 140), outline = Color3.fromRGB(20, 200, 90) },
    Lobby = { fill = Color3.fromRGB(150, 150, 150), outline = Color3.fromRGB(100, 100, 100) },
}

local tracked = {}
local function applyPlayerChams(char)
    local hl = char:FindFirstChild("PlyEspChams")
    if not hl then
        hl = Instance.new("Highlight")
        hl.Name = "PlyEspChams"
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char
    end
    local c = isVillain(char) and COLORS.Villain or (charTeam(char) == "Survivors" and COLORS.Survivor or COLORS.Lobby)
    hl.FillColor = c.fill
    hl.FillTransparency = 0.45
    hl.OutlineColor = c.outline
    hl.OutlineTransparency = 0
end

local function rescanPlayers()
    for _, p in ipairs(Players:GetPlayers()) do
        local char = p.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            tracked[char] = true
        end
    end
end

local function onPlayerChar(char)
    tracked[char] = true
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(onPlayerChar)
end)
for _, p in ipairs(Players:GetPlayers()) do
    p.CharacterAdded:Connect(onPlayerChar)
end

task.spawn(function()
    while true do
        if S.closed then break end
        pcall(function()
            rescanPlayers()
            for char in pairs(tracked) do
                if not char.Parent then
                    tracked[char] = nil
                elseif S.playerEsp then
                    applyPlayerChams(char)
                end
            end
        end)
        task.wait(1)
    end
end)

RunService.RenderStepped:Connect(function()
    if S.closed then return end
    if not S.playerEsp then
        return
    end
    local cam = workspace.CurrentCamera
    if not cam then
        return
    end
    for char in pairs(tracked) do
        if not char.Parent then
            continue
        end
        local head = char:FindFirstChild("Head")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not (head and hrp and hum) then
            continue
        end
        local screenPos, onScreen = cam:WorldToViewportPoint(head.Position + Vector3.new(0, 3, 0))
        if not onScreen then
            continue
        end
        local dist = (hrp.Position - cam.CFrame.Position).Magnitude
        local player = Players:GetPlayerFromCharacter(char)
        local name = player and player.Name or "?"
        local team = charTeam(char)
        local label = name .. " | " .. tostring(math.floor(hum.Health)) .. "hp | " .. tostring(math.floor(dist)) .. "m"
        local col = isVillain(char) and COLORS.Villain.fill or (team == "Survivors" and COLORS.Survivor.fill or COLORS.Lobby.fill)
        if DrawingImmediate and DrawingImmediate.OutlinedText then
            DrawingImmediate.OutlinedText(
                Vector2.new(screenPos.X, screenPos.Y - 24),
                13,
                1,
                col,
                1,
                Color3.new(0, 0, 0),
                1,
                label,
                true
            )
        end
    end
end)

------------------------------------------------------------
-- ③ 秒交互: 交互进度条直接满 (HoldDuration=0 常驻)
------------------------------------------------------------
local scannedPrompts = {}
local function boostPrompt(prompt)
    if scannedPrompts[prompt] then
        return
    end
    scannedPrompts[prompt] = true
    pcall(function()
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = 1000
        prompt.RequiresLineOfSight = false
    end)
end

local function collectPrompts()
    for _, obj in ipairs({ workspace, game:GetService("ReplicatedStorage") }) do
        for _, d in ipairs(obj:GetDescendants()) do
            if d:IsA("ProximityPrompt") then
                boostPrompt(d)
            end
        end
    end
end

task.spawn(function()
    while true do
        if S.closed then break end
        if S.instantInteract then
            pcall(collectPrompts)
        end
        task.wait(0.4)
    end
end)

-- 秒交互 boost 循环在下方 task.spawn 常驻运行

------------------------------------------------------------
-- DB 风格主面板
------------------------------------------------------------
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "TX_Collection_Panel"
MainGui.ResetOnSpawn = false
MainGui.IgnoreGuiInset = true
MainGui.DisplayOrder = 999999
MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local pg = lp:WaitForChild("PlayerGui", 10)
MainGui.Parent = pg

local IntroGui = Instance.new("Frame")
IntroGui.Name = "TX_Intro"
IntroGui.Size = UDim2.fromScale(1, 1)
IntroGui.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
IntroGui.BackgroundTransparency = 1
IntroGui.BorderSizePixel = 0
IntroGui.ZIndex = 10000
IntroGui.Active = true
IntroGui.Parent = MainGui
local IntroTitle = Instance.new("TextLabel")
IntroTitle.AnchorPoint = Vector2.new(0.5, 0.5)
IntroTitle.Position = UDim2.fromScale(0.5, 0.42)
IntroTitle.Size = UDim2.new(0, 320, 0, 56)
IntroTitle.BackgroundTransparency = 1
IntroTitle.Text = "躲避恶人"
IntroTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
IntroTitle.TextTransparency = 1
IntroTitle.TextSize = 44
IntroTitle.Font = Enum.Font.GothamBlack
IntroTitle.ZIndex = 10002
IntroTitle.Parent = IntroGui
AddBorder(IntroTitle, 1.4, 0.15)
StartRainbowFlow(IntroTitle, 2.2, NumberSequence.new(0))
local IntroSub = Instance.new("TextLabel")
IntroSub.AnchorPoint = Vector2.new(0.5, 1)
IntroSub.Position = UDim2.new(0.5, 0, 0.72, 0)
IntroSub.Size = UDim2.new(0, 320, 0, 26)
IntroSub.BackgroundTransparency = 1
IntroSub.Text = "天休制作 · 欢迎, " .. lp.Name
IntroSub.TextColor3 = Color3.fromRGB(255, 255, 255)
IntroSub.TextTransparency = 1
IntroSub.TextSize = 14
IntroSub.Font = Enum.Font.GothamMedium
IntroSub.ZIndex = 10002
IntroSub.Parent = IntroGui
TweenService:Create(IntroGui, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0.25 }):Play()
task.wait(0.15)
TweenService:Create(IntroTitle, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
TweenService:Create(IntroSub, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
task.wait(1.4)
TweenService:Create(IntroGui, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), { BackgroundTransparency = 1 }):Play()
TweenService:Create(IntroTitle, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 1 }):Play()
TweenService:Create(IntroSub, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 1 }):Play()
task.wait(0.5)
if IntroGui.Parent then IntroGui:Destroy() end

local PANEL_W, PANEL_H = 420, 300
local Panel = Instance.new("Frame")
Panel.Name = "Panel"
Panel.AnchorPoint = Vector2.new(0.5, 0.5)
Panel.Position = UDim2.fromScale(0.5, 0.5)
Panel.Size = UDim2.fromOffset(PANEL_W, PANEL_H)
Panel.BackgroundTransparency = 1
Panel.BorderSizePixel = 0
Panel.Active = true
Panel.Parent = MainGui

local Body = Instance.new("Frame")
Body.Name = "Body"
Body.Position = UDim2.fromOffset(2, 2)
Body.Size = UDim2.new(1, -4, 1, -4)
Body.BackgroundColor3 = Color3.fromRGB(6, 8, 12)
Body.BackgroundTransparency = 0.12
Body.BorderSizePixel = 0
Body.ClipsDescendants = true
Body.Parent = Panel
AddCorner(Body, 14)
AddRainbowBorder(Body, 1.5, 0.02, 2.6)

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundTransparency = 1
Header.Active = true
Header.Parent = Body

local DragArea = Instance.new("TextButton")
DragArea.Name = "DragArea"
DragArea.Size = UDim2.new(1, -58, 1, 0)
DragArea.BackgroundTransparency = 1
DragArea.BorderSizePixel = 0
DragArea.Text = ""
DragArea.AutoButtonColor = false
DragArea.Active = true
DragArea.Parent = Header

local panelDrag = { active = false, start = nil, pos = nil }
local function StartPanelDrag(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
    panelDrag.active = true
    panelDrag.start = input.Position
    panelDrag.pos = Panel.Position
end
DragArea.InputBegan:Connect(StartPanelDrag)
Header.InputBegan:Connect(StartPanelDrag)
Panel.InputBegan:Connect(StartPanelDrag)
UserInputService.InputChanged:Connect(function(input)
    if not panelDrag.active then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
    local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
    local maxX = vp.X - PANEL_W / 2 - 30
    local maxY = vp.Y - PANEL_H / 2 - 30
    local minX = PANEL_W / 2 - vp.X + 30
    local minY = PANEL_H / 2 - vp.Y + 30
    local dx = math.clamp(panelDrag.pos.X.Offset + (input.Position.X - panelDrag.start.X), minX, maxX)
    local dy = math.clamp(panelDrag.pos.Y.Offset + (input.Position.Y - panelDrag.start.Y), minY, maxY)
    Panel.Position = UDim2.new(0.5, dx, 0.5, dy)
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
    panelDrag.active = false
end)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.fromOffset(12, 3)
TitleLabel.Size = UDim2.new(0, 110, 0, 24)
TitleLabel.Text = "躲避恶人"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 15
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header
StartRainbowFlow(TitleLabel, 2.4, NumberSequence.new(0))

local SubLabel = Instance.new("TextLabel")
SubLabel.BackgroundTransparency = 1
SubLabel.Position = UDim2.new(0, 12, 0, 0)
SubLabel.Size = UDim2.new(0, 200, 0, 22)
SubLabel.Text = "天休制作 · Slaughter"
SubLabel.TextColor3 = Color3.fromRGB(150, 160, 180)
SubLabel.TextSize = 11
SubLabel.Font = Enum.Font.GothamMedium
SubLabel.TextXAlignment = Enum.TextXAlignment.Left
SubLabel.Parent = Header

-- 最小化 / 关闭按钮
local function makeHeaderBtn(parent, text, tooltip, onClick)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(26, 22)
    btn.Position = UDim2.new(1, 0, 0.5, 0)
    btn.AnchorPoint = Vector2.new(1, 0.5)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = 0.85
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBlack
    btn.AutoButtonColor = false
    btn.ZIndex = 20
    btn.Parent = parent
    AddCorner(btn, 6)
    AddBorder(btn, 0.7, 0.55)
    btn.Activated:Connect(function()
        if onClick then pcall(onClick) end
    end)
    return btn
end

local MinimizeBtn = makeHeaderBtn(Header, "—", "最小化", function() end)
MinimizeBtn.Position = UDim2.new(1, -56, 0.5, 0)
local CloseBtn = makeHeaderBtn(Header, "✕", "关闭", function() end)
CloseBtn.Position = UDim2.new(1, -26, 0.5, 0)

local panelHidden = false
local FloatBtn = Instance.new("TextButton")
FloatBtn.Name = "TX_FloatBtn"
FloatBtn.Size = UDim2.fromOffset(120, 36)
FloatBtn.AnchorPoint = Vector2.new(0.5, 1)
FloatBtn.Position = UDim2.new(0.5, 0, 1, -24)
FloatBtn.BackgroundColor3 = Color3.fromRGB(6, 8, 12)
FloatBtn.BackgroundTransparency = 0.18
FloatBtn.BorderSizePixel = 0
FloatBtn.Text = "躲避恶人"
FloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatBtn.TextSize = 13
FloatBtn.Font = Enum.Font.GothamBlack
FloatBtn.AutoButtonColor = false
FloatBtn.Visible = false
FloatBtn.Parent = MainGui
AddCorner(FloatBtn, 10)
AddRainbowBorder(FloatBtn, 1.2, 0.02, 2.2)
FloatBtn.Activated:Connect(function()
    panelHidden = false
    FloatBtn.Visible = false
    Panel.Visible = true
end)

MinimizeBtn.Activated:Connect(function()
    panelHidden = true
    Panel.Visible = false
    FloatBtn.Visible = true
end)

local function shutdown()
    S.closed = true
    pcall(function()
        for _, conn in ipairs(getconnections(RunService.RenderStepped)) do
            local f = conn and conn.Function
            if f and isexecutorclosure(f) then
                conn:Disconnect()
            end
        end
        for _, conn in ipairs(getconnections(RunService.Heartbeat)) do
            local f = conn and conn.Function
            if f and isexecutorclosure(f) then
                conn:Disconnect()
            end
        end
    end)
    pcall(function()
        local CrateSpawns = getCrateSpawns()
        if CrateSpawns then
            for _, child in ipairs(CrateSpawns:GetChildren()) do
                local h = child:FindFirstChild("VoughtCrateChams")
                if h then h:Destroy() end
            end
        end
        for char in pairs(tracked) do
            local h = char:FindFirstChild("PlyEspChams")
            if h then h:Destroy() end
        end
    end)
    if MainGui then MainGui:Destroy() end
    Notify("躲避恶人", "已关闭卸载")
end

CloseBtn.Activated:Connect(shutdown)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Name = "Scroll"
Scroll.Position = UDim2.fromOffset(0, 34)
Scroll.Size = UDim2.new(1, 0, 1, -40)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageTransparency = 0.6
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.Parent = Body

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 6)
ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = Scroll

CreateToggleRow(Scroll, "箱子 Chams", function() return S.crateChams end, function(v)
    S.crateChams = v
    if not v then
        pcall(function()
            local CrateSpawns = getCrateSpawns()
            if CrateSpawns then
                for _, child in ipairs(CrateSpawns:GetChildren()) do
                    local h = child:FindFirstChild("VoughtCrateChams")
                    if h then h:Destroy() end
                end
            end
        end)
    else
        scanCrates()
    end
    Notify("箱子 Chams", v and "已开启" or "已关闭")
end)

CreateToggleRow(Scroll, "人物 ESP", function() return S.playerEsp end, function(v)
    S.playerEsp = v
    if not v then
        pcall(function()
            for char in pairs(tracked) do
                local h = char:FindFirstChild("PlyEspChams")
                if h then h:Destroy() end
            end
        end)
    end
    Notify("人物 ESP", v and "已开启" or "已关闭")
end)

CreateToggleRow(Scroll, "交互条秒满", function() return S.instantInteract end, function(v)
    S.instantInteract = v
    if v then
        pcall(collectPrompts)
    end
    Notify("交互条秒满", v and "已开启" or "已关闭")
end)

rescanPlayers()
scanCrates()
Notify("躲避恶人 · 天休制作", "加载完成 · 功能就绪")

_G.CollectionAPI = {
    set = function(key, v)
        if S[key] ~= nil then
            S[key] = v and true or false
            Notify(key, S[key] and "已开启" or "已关闭")
        end
    end,
    get = function(key)
        return S[key]
    end,
    state = function()
        return table.clone(S)
    end,
    close = shutdown,
}

print("COLLECTION|loaded|crateChams=" .. tostring(S.crateChams) .. "|playerEsp=" .. tostring(S.playerEsp) .. "|instantInteract=" .. tostring(S.instantInteract))
