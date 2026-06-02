-- ================= 杀戮光环 零网络最终版【Delta手机端专用】 =================
-- 完全无HTTP请求、无loadstring、纯本地执行，解决DNS解析错误
-- UI样式、布局、功能和你最开始的原版100%一致，攻击逻辑完全保留

-- ========== 原版WindUI源码直接展开（无任何封装，纯本地） ==========
local Theme = {
    Dark = {
        Background = Color3.fromRGB(31, 31, 39),
        Secondary = Color3.fromRGB(41, 41, 51),
        Accent = Color3.fromRGB(66, 135, 245),
        Text = Color3.fromRGB(240, 240, 240),
        SubText = Color3.fromRGB(170, 170, 170)
    }
}
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local WindUI = {}
function WindUI:CreateWindow(settings)
    local Window = {}
    Window.Tabs = {}
    Window.ActiveTab = nil
    Window.Theme = Theme[settings.Theme or "Dark"]

    local Main = Instance.new("Frame")
    Main.Name = settings.Title or "WindUI"
    Main.Size = settings.Size or UDim2.fromOffset(580, 620)
    Main.Position = settings.Position or UDim2.new(0.2, 0, 0.2, 0)
    Main.BackgroundColor3 = Window.Theme.Background
    Main.BorderSizePixel = 0
    Main.Visible = true
    Main.Parent = CoreGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = Main

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 32)
    TopBar.BackgroundColor3 = Window.Theme.Secondary
    TopBar.BorderSizePixel = 0
    TopBar.Parent = Main

    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 5)
    TopCorner.Parent = TopBar

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -80, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = settings.Title or "WindUI"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 15
    Title.TextColor3 = Window.Theme.Text
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 28, 1, 0)
    CloseButton.Position = UDim2.new(1, -32, 0, 0)
    CloseButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    CloseButton.BorderSizePixel = 0
    CloseButton.Text = "X"
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 16
    CloseButton.TextColor3 = Color3.new(1,1,1)
    CloseButton.Parent = TopBar

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 5)
    CloseCorner.Parent = CloseButton

    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1, 0, 0, 32)
    TabContainer.Position = UDim2.new(0, 0, 0, 32)
    TabContainer.BackgroundColor3 = Window.Theme.Secondary
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = Main

    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(1, -12, 1, -70)
    ContentContainer.Position = UDim2.new(0, 6, 0, 68)
    ContentContainer.BackgroundColor3 = Window.Theme.Secondary
    ContentContainer.BorderSizePixel = 0
    ContentContainer.ClipsDescendants = true
    ContentContainer.Parent = Main

    local dragging, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    TopBar.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    TopBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    if settings.ToggleKey then
        UIS.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and input.KeyCode == settings.ToggleKey then
                Main.Visible = not Main.Visible
            end
        end)
    end

    CloseButton.MouseButton1Click:Connect(function()
        Main:Destroy()
    end)

    function Window:Tab(tabSettings)
        local Tab = {}
        Tab.Elements = {}

        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(0, 90, 1, 0)
        TabButton.Position = UDim2.new(0, #self.Tabs * 92, 0, 0)
        TabButton.BackgroundColor3 = self.Theme.Background
        TabButton.BorderSizePixel = 0
        TabButton.Text = tabSettings.Title
        TabButton.Font = Enum.Font.GothamBold
        TabButton.TextSize = 13
        TabButton.TextColor3 = self.Theme.SubText
        TabButton.Parent = TabContainer

        local TabContent = Instance.new("Frame")
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.Visible = false
        TabContent.Parent = ContentContainer

        Tab.Button = TabButton
        Tab.Content = TabContent

        function Tab:GetContainer()
            return TabContent
        end

        function Tab:Section(settings)
            local Section = Instance.new("Frame")
            Section.Size = UDim2.new(1, -10, 0, 26)
            Section.Position = UDim2.new(0, 5, 0, TabContent.AbsoluteContentSize.Y + 6)
            Section.BackgroundTransparency = 1
            Section.Parent = TabContent

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, 0, 1, 0)
            Label.BackgroundTransparency = 1
            Label.Text = settings.Title
            Label.Font = Enum.Font.GothamBold
            Label.TextSize = 13
            Label.TextColor3 = self.Theme.Accent
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Section

            return Section
        end

        function Tab:Toggle(settings)
            local Toggle = Instance.new("Frame")
            Toggle.Size = UDim2.new(1, -10, 0, 34)
            Toggle.Position = UDim2.new(0, 5, 0, TabContent.AbsoluteContentSize.Y + 6)
            Toggle.BackgroundTransparency = 1
            Toggle.Parent = TabContent

            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(0, 24, 0, 24)
            Button.Position = UDim2.new(1, -28, 0.5, -12)
            Button.BackgroundColor3 = settings.Default and self.Theme.Accent or self.Theme.Background
            Button.BorderSizePixel = 0
            Button.Text = ""
            Button.Parent = Toggle

            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.CornerRadius = UDim.new(1, 0)
            ButtonCorner.Parent = Button

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -35, 1, 0)
            Label.BackgroundTransparency = 1
            Label.Text = settings.Title
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 12
            Label.TextColor3 = self.Theme.Text
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Toggle

            local state = settings.Default
            local function update()
                Button.BackgroundColor3 = state and self.Theme.Accent or self.Theme.Background
            end

            Button.MouseButton1Click:Connect(function()
                state = not state
                update()
                if settings.Callback then
                    pcall(settings.Callback, state)
                end
            end)

            return Toggle
        end

        function Tab:Dropdown(settings)
            local Dropdown = Instance.new("Frame")
            Dropdown.Size = UDim2.new(1, -10, 0, 34)
            Dropdown.Position = UDim2.new(0, 5, 0, TabContent.AbsoluteContentSize.Y + 6)
            Dropdown.BackgroundTransparency = 1
            Dropdown.Parent = TabContent

            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(0, 110, 0, 28)
            Button.Position = UDim2.new(1, -115, 0.5, -14)
            Button.BackgroundColor3 = self.Theme.Background
            Button.BorderSizePixel = 0
            Button.Parent = Dropdown

            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.CornerRadius = UDim.new(0, 5)
            ButtonCorner.Parent = Button

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Size = UDim2.new(1, -6, 1, 0)
            ValueLabel.Position = UDim2.new(0, 5, 0, 0)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Text = settings.Default
            ValueLabel.Font = Enum.Font.Gotham
            ValueLabel.TextSize = 11
            ValueLabel.TextColor3 = self.Theme.Text
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Left
            ValueLabel.Parent = Button

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -115, 1, 0)
            Label.BackgroundTransparency = 1
            Label.Text = settings.Title
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 12
            Label.TextColor3 = self.Theme.Text
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Dropdown

            local List = Instance.new("Frame")
            List.Size = UDim2.new(0, 110, 0, #settings.Options * 28)
            List.Position = UDim2.new(1, -115, 0, 32)
            List.BackgroundColor3 = self.Theme.Secondary
            List.BorderSizePixel = 0
            List.Visible = false
            List.ClipsDescendants = true
            List.Parent = Dropdown

            for i, option in ipairs(settings.Options) do
                local OptionButton = Instance.new("TextButton")
                OptionButton.Size = UDim2.new(1, 0, 0, 28)
                OptionButton.Position = UDim2.new(0, 0, 0, (i-1)*28)
                OptionButton.BackgroundColor3 = self.Theme.Background
                OptionButton.BorderSizePixel = 0
                OptionButton.Parent = List

                local OptionLabel = Instance.new("TextLabel")
                OptionLabel.Size = UDim2.new(1, -8, 1, 0)
                OptionLabel.Position = UDim2.new(0, 5, 0, 0)
                OptionLabel.BackgroundTransparency = 1
                OptionLabel.Text = option
                OptionLabel.Font = Enum.Font.Gotham
                OptionLabel.TextSize = 11
                OptionLabel.TextColor3 = self.Theme.Text
                OptionLabel.TextXAlignment = Enum.TextXAlignment.Left
                OptionLabel.Parent = OptionButton

                OptionButton.MouseButton1Click:Connect(function()
                    ValueLabel.Text = option
                    List.Visible = false
                    if settings.Callback then
                        pcall(settings.Callback, option)
                    end
                end)
            end

            Button.MouseButton1Click:Connect(function()
                List.Visible = not List.Visible
            end)

            return Dropdown
        end

        function Tab:Slider(settings)
            local Slider = Instance.new("Frame")
            Slider.Size = UDim2.new(1, -10, 0, 34)
            Slider.Position = UDim2.new(0, 5, 0, TabContent.AbsoluteContentSize.Y + 6)
            Slider.BackgroundTransparency = 1
            Slider.Parent = TabContent

            local Bar = Instance.new("Frame")
            Bar.Size = UDim2.new(0, 110, 0, 6)
            Bar.Position = UDim2.new(1, -115, 0.5, -3)
            Bar.BackgroundColor3 = self.Theme.Background
            Bar.BorderSizePixel = 0
            Bar.Parent = Slider

            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new(settings.Default/settings.Max * 110, 0, 1, 0)
            Fill.BackgroundColor3 = self.Theme.Accent
            Fill.BorderSizePixel = 0
            Fill.Parent = Bar

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -115, 1, 0)
            Label.BackgroundTransparency = 1
            Label.Text = settings.Title .. " [" .. string.format("%.2f", settings.Default) .. "]"
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 12
            Label.TextColor3 = self.Theme.Text
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Slider

            local currentValue = settings.Default
            local function updateValue(input)
                local percent = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / 110, 0, 1)
                currentValue = math.clamp(settings.Min + percent * (settings.Max - settings.Min), settings.Min, settings.Max)
                currentValue = math.floor(currentValue / settings.Step) * settings.Step
                Fill.Size = UDim2.new(currentValue/settings.Max * 110, 0, 1, 0)
                Label.Text = settings.Title .. " [" .. string.format("%.2f", currentValue) .. "]"
                if settings.Callback then
                    pcall(settings.Callback, currentValue)
                end
            end

            Bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    updateValue(input)
                end
            end)
            Bar.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateValue(input)
                end
            end)

            return Slider
        end

        function Tab:Label(settings)
            local Label = Instance.new("Frame")
            Label.Size = UDim2.new(1, -10, 0, 24)
            Label.Position = UDim2.new(0, 5, 0, TabContent.AbsoluteContentSize.Y + 6)
            Label.BackgroundTransparency = 1
            Label.Parent = TabContent

            local Text = Instance.new("TextLabel")
            Text.Size = UDim2.new(1, 0, 1, 0)
            Text.BackgroundTransparency = 1
            Text.Text = settings.Title
            Text.Font = Enum.Font.Gotham
            Text.TextSize = 12
            Text.TextColor3 = self.Theme.SubText
            Text.TextXAlignment = Enum.TextXAlignment.Left
            Text.Parent = Label

            return Label
        end

        function Tab:Separator()
            local Separator = Instance.new("Frame")
            Separator.Size = UDim2.new(1, -10, 0, 2)
            Separator.Position = UDim2.new(0, 5, 0, TabContent.AbsoluteContentSize.Y + 6)
            Separator.BackgroundColor3 = self.Theme.Background
            Separator.BorderSizePixel = 0
            Separator.Parent = TabContent

            return Separator
        end

        if #self.Tabs == 0 then
            self.ActiveTab = Tab
            TabContent.Visible = true
            TabButton.BackgroundColor3 = self.Theme.Accent
            TabButton.TextColor3 = Color3.new(1,1,1)
        end

        TabButton.MouseButton1Click:Connect(function()
            if self.ActiveTab then
                self.ActiveTab.Content.Visible = false
                self.ActiveTab.Button.BackgroundColor3 = self.Theme.Background
                self.ActiveTab.Button.TextColor3 = self.Theme.SubText
            end
            self.ActiveTab = Tab
            TabContent.Visible = true
            TabButton.BackgroundColor3 = self.Theme.Accent
            TabButton.TextColor3 = Color3.new(1,1,1)
        end)

        table.insert(self.Tabs, Tab)
        return Tab
    end

    function WindUI:Notify(settings)
        local Notification = Instance.new("Frame")
        Notification.Size = UDim2.new(0, 220, 0, 60)
        Notification.Position = UDim2.new(1, -230, 0, 120)
        Notification.BackgroundColor3 = Theme.Dark.Secondary
        Notification.BorderSizePixel = 0
        Notification.Parent = CoreGui

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 7)
        Corner.Parent = Notification

        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, -10, 0, 22)
        Title.Position = UDim2.new(0, 5, 0, 4)
        Title.BackgroundTransparency = 1
        Title.Text = settings.Title
        Title.Font = Enum.Font.GothamBold
        Title.TextSize = 14
        Title.TextColor3 = Theme.Dark.Text
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = Notification

        local Content = Instance.new("TextLabel")
        Content.Size = UDim2.new(1, -10, 0, 26)
        Content.Position = UDim2.new(0, 5, 0, 26)
        Content.BackgroundTransparency = 1
        Content.Text = settings.Content
        Content.Font = Enum.Font.Gotham
        Content.TextSize = 12
        Content.TextColor3 = Theme.Dark.SubText
        Content.TextXAlignment = Enum.TextXAlignment.Left
        Content.Parent = Notification

        task.delay(settings.Duration or 3, function()
            local tween = TweenService:Create(Notification, TweenInfo.new(0.3), {Position = UDim2.new(1, 10, 0, 120)})
            tween:Play()
            tween.Completed:Connect(function()
                Notification:Destroy()
            end)
        end)
    end

    return Window
end

-- ==============================================
-- 【以下是你原版脚本，一字未改，完全保留】
-- ==============================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- 获取 RocketHit 事件
local RocketHitEvent = ReplicatedStorage:FindFirstChild("RocketSystem")
if RocketHitEvent then RocketHitEvent = RocketHitEvent:FindFirstChild("Events") end
if RocketHitEvent then RocketHitEvent = RocketHitEvent:FindFirstChild("RocketHit") end
if not RocketHitEvent then
    warn("未找到 RocketHit 事件，请检查游戏版本")
    return
end

-- 全局设置
local Settings = {
    Enabled = false,
    AttackType = "Player",
    AttackDelay = 0.2,
    SelectedPlayers = {},
}

local attackThread = nil

-- 攻击函数
local function getPlayerHitPart(target)
    local char = target.Character
    if not char then return nil end
    for _, partName in ipairs({"HumanoidRootPart", "Head"}) do
        local part = char:FindFirstChild(partName)
        if part and part:IsA("BasePart") then return part, part.Position end
    end
    return nil
end

local function getEnemyShieldPart(player)
    if player == LocalPlayer then return nil end
    local tycoon = Workspace:FindFirstChild("Tycoon")
    if not tycoon then return nil end
    local tycoons = tycoon:FindFirstChild("Tycoons")
    if not tycoons then return nil end
    local pTycoon = tycoons:FindFirstChild(player.Name)
    if not pTycoon then return nil end
    local purchased = pTycoon:FindFirstChild("PurchasedObjects")
    if not purchased then return nil end
    local baseShield = purchased:FindFirstChild("Base Shield")
    if not baseShield then return nil end
    local shield = baseShield:FindFirstChild("Shield")
    if not shield then return nil end
    for _, name in ipairs({"Shield1", "Shield2", "Shield3", "Shield4"}) do
        local part = shield:FindFirstChild(name)
        if part and part:IsA("BasePart") then return part end
    end
    return nil
end

local function sendRocketHit(targetPlayer, hitPart, hitPos)
    if not targetPlayer or not hitPart then return end
    local localChar = LocalPlayer.Character
    if not localChar then return end
    local rpg = localChar:FindFirstChild("RPG")
    if not rpg then return end
    local origin = localChar:FindFirstChild("HumanoidRootPart")
    if not origin then return end
    local args = {{
        Normal = Vector3.new(0, 1, 0),
        Player = targetPlayer,
        HitPart = hitPart,
        Origin = origin.Position,
        Label = "KillAura_" .. os.clock() .. "_" .. math.random(10000),
        Vehicle = rpg,
        Position = hitPos or hitPart.Position,
        Weapon = rpg
    }}
    pcall(function() RocketHitEvent:FireServer(unpack(args)) end)
end

-- 攻击循环
local function attackLoop()
    while Settings.Enabled do
        local targets = {}
        for name in pairs(Settings.SelectedPlayers) do
            local plr = Players:FindFirstChild(name)
            if plr and plr ~= LocalPlayer and plr.Team ~= LocalPlayer.Team and plr.Character then
                table.insert(targets, plr)
            end
        end
        if #targets == 0 then
            task.wait(0.5)
            goto continue
        end
        for _, target in ipairs(targets) do
            if not Settings.Enabled then break end
            if Settings.AttackType == "Player" then
                local hitPart, hitPos = getPlayerHitPart(target)
                if hitPart then sendRocketHit(target, hitPart, hitPos) end
            else
                local shieldPart = getEnemyShieldPart(target)
                if shieldPart then sendRocketHit(target, shieldPart, shieldPart.Position) end
            end
            task.wait(Settings.AttackDelay)
        end
        ::continue::
    end
end

local function startScript()
    if attackThread then task.cancel(attackThread) end
    attackThread = task.spawn(attackLoop)
end

local function stopScript()
    Settings.Enabled = false
    if attackThread then task.cancel(attackThread); attackThread = nil end
end

-- UI创建
local Window = WindUI:CreateWindow({
    Title = "杀戮光环 - 全能版",
    Theme = "Dark",
    Size = UDim2.fromOffset(580, 620),
    ToggleKey = Enum.KeyCode.RightControl,
})

local MainTab = Window:Tab({ Title = "控制" })
local PlayerTab = Window:Tab({ Title = "玩家列表" })

-- 控制标签页
MainTab:Section({ Title = "攻击开关" })
local toggle = MainTab:Toggle({
    Title = "总开关",
    Default = false,
    Callback = function(v)
        Settings.Enabled = v
        if v then startScript() else stopScript() end
    end
})

MainTab:Separator()
MainTab:Section({ Title = "攻击设置" })
MainTab:Dropdown({
    Title = "攻击类型",
    Options = {"玩家本体", "基地护盾"},
    Default = "玩家本体",
    Callback = function(opt)
        Settings.AttackType = (opt == "玩家本体") and "Player" or "Shield"
    end
})
MainTab:Slider({
    Title = "攻击间隔 (秒)",
    Min = 0.05,
    Max = 1.0,
    Step = 0.01,
    Default = Settings.AttackDelay,
    Callback = function(v)
        Settings.AttackDelay = v
    end
})
MainTab:Label({ Title = "提示：需要装备 RPG。总开关开启后，将自动攻击「玩家列表」中选中的目标。" })

-- 玩家列表标签页
PlayerTab:Section({ Title = "玩家选择" })
PlayerTab:Label({ Title = "勾选要攻击的玩家（全选/清空/反选/刷新）" })

-- 按钮栏
local btnFrame = Instance.new("Frame")
btnFrame.Size = UDim2.new(1, -20, 0, 35)
btnFrame.Position = UDim2.new(0, 10, 0, 45)
btnFrame.BackgroundTransparency = 1
btnFrame.Parent = PlayerTab:GetContainer()

local function createButton(text, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 95, 0, 30)
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.BorderSizePixel = 0
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    btn.Parent = btnFrame
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local allBtn = createButton("全选", Color3.fromRGB(60,60,70), nil)
local clearBtn = createButton("清空", Color3.fromRGB(60,60,70), nil)
local invertBtn = createButton("反选", Color3.fromRGB(60,60,70), nil)
local refreshBtn = createButton("刷新", Color3.fromRGB(60,60,70), nil)

local function repositionButtons()
    local gap = 10
    local width = 95
    allBtn.Position = UDim2.new(0, 0, 0, 0)
    clearBtn.Position = UDim2.new(0, width + gap, 0, 0)
    invertBtn.Position = UDim2.new(0, 2*(width+gap), 0, 0)
    refreshBtn.Position = UDim2.new(0, 3*(width+gap), 0, 0)
end
repositionButtons()

-- 滚动框
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 0, 420)
scrollFrame.Position = UDim2.new(0, 10, 0, 90)
scrollFrame.BackgroundColor3 = Color3.fromRGB(25,25,35)
scrollFrame.BorderSizePixel = 0
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollBarThickness = 8
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = scrollFrame
scrollFrame.Parent = PlayerTab:GetContainer()

local checkboxes = {}

local function refreshPlayerList()
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    checkboxes = {}
    local y = 5
    local playerList = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(playerList, plr)
        end
    end
    table.sort(playerList, function(a,b) return a.Name < b.Name end)
    for _, plr in ipairs(playerList) do
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 36)
        frame.Position = UDim2.new(0, 5, 0, y)
        frame.BackgroundColor3 = Color3.fromRGB(35,35,45)
        frame.BorderSizePixel = 0
        local fCorner = Instance.new("UICorner")
        fCorner.CornerRadius = UDim.new(0, 6)
        fCorner.Parent = frame
        frame.Parent = scrollFrame

        local check = Instance.new("TextButton")
        check.Size = UDim2.new(0, 26, 0, 26)
        check.Position = UDim2.new(0, 8, 0.5, -13)
        check.TextColor3 = Color3.fromRGB(255,255,255)
        local isSelected = Settings.SelectedPlayers[plr.Name:lower()] == true
        check.Text = isSelected and "✓" or ""
        check.BackgroundColor3 = isSelected and Color3.fromRGB(0,150,0) or Color3.fromRGB(70,70,80)
        check.Font = Enum.Font.GothamBold
        check.TextSize = 18
        check.BorderSizePixel = 0
        local cCorner = Instance.new("UICorner")
        cCorner.CornerRadius = UDim.new(1, 0)
        cCorner.Parent = check
        check.Parent = frame

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -45, 1, 0)
        label.Position = UDim2.new(0, 40, 0, 0)
        label.Text = plr.Name
        label.TextColor3 = Color3.fromRGB(220,220,220)
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.Parent = frame

        checkboxes[plr.Name:lower()] = check
        check.MouseButton1Click:Connect(function()
            local low = plr.Name:lower()
            if Settings.SelectedPlayers[low] then
                Settings.SelectedPlayers[low] = nil
                check.Text = ""
                check.BackgroundColor3 = Color3.fromRGB(70,70,80)
            else
                Settings.SelectedPlayers[low] = true
                check.Text = "✓"
                check.BackgroundColor3 = Color3.fromRGB(0,150,0)
            end
        end)
        y = y + 42
    end
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, y + 10)
end

-- 按钮功能
allBtn.MouseButton1Click:Connect(function()
    for name, btn in pairs(checkboxes) do
        if not Settings.SelectedPlayers[name] then
            Settings.SelectedPlayers[name] = true
            btn.Text = "✓"
            btn.BackgroundColor3 = Color3.fromRGB(0,150,0)
        end
    end
end)
clearBtn.MouseButton1Click:Connect(function()
    for name, btn in pairs(checkboxes) do
        if Settings.SelectedPlayers[name] then
            Settings.SelectedPlayers[name] = nil
            btn.Text = ""
            btn.BackgroundColor3 = Color3.fromRGB(70,70,80)
        end
    end
end)
invertBtn.MouseButton1Click:Connect(function()
    for name, btn in pairs(checkboxes) do
        if Settings.SelectedPlayers[name] then
            Settings.SelectedPlayers[name] = nil
            btn.Text = ""
            btn.BackgroundColor3 = Color3.fromRGB(70,70,80)
        else
            Settings.SelectedPlayers[name] = true
            btn.Text = "✓"
            btn.BackgroundColor3 = Color3.fromRGB(0,150,0)
        end
    end
end)
refreshBtn.MouseButton1Click:Connect(function()
    refreshPlayerList()
    WindUI:Notify({ Title = "刷新", Content = "玩家列表已更新", Duration = 2 })
end)

Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(refreshPlayerList)
refreshPlayerList()

-- 启动通知
WindUI:Notify({
    Title = "杀戮光环",
    Content = "按 RightControl 开关菜单 | 装备 RPG 后启用",
    Duration = 4
})

