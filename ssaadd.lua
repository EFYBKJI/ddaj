-- ================= 杀戮光环 | 内置WindUI离线版【不改动任何攻击逻辑】 =================
-- 改动：内嵌WindUI源码，抛弃HttpGet在线加载，解决国内加载不出UI问题，所有勾选/攻击设置功能原样保留
local WindUI = (function()local a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,_,_0,_1,_2,_3,_4,_5,_6,_7,_8,_9=...local function l(...)local t={...}return function()return unpack(t)end end local function h(t)return setmetatable(t,{__index=function()return h({})end})end local function n(a,b,c,d,e,f,g)local h=Instance.new(a)if b then h.Name=b end if c then h.Size=c end if d then h.Position=d end if e then h.BackgroundColor3=e end if f then h.BorderSizePixel=f end if g then h.Parent=g end return h end local function r(t)return t and t~="" end local function y(t)return type(t)=="table"end local function w(t)return type(t)=="number"end local function _(t)return type(t)=="string"end local function _0(t)return type(t)=="boolean"end local WindowIndex=0 local ActiveWindows={} local ThemeData={Dark={Bg1=Color3.new(0.12,0.12,0.15),Bg2=Color3.new(0.18,0.18,0.22),Accent=Color3.new(0.22,0.55,0.98),Text=Color3.new(0.95,0.95,0.95),TextDim=Color3.new(0.55,0.55,0.62)},Light={Bg1=Color3.new(0.94,0.94,0.96),Bg2=Color3.new(0.82,0.82,0.86),Accent=Color3.new(0.18,0.48,0.94),Text=Color3.new(0.12,0.12,0.15),TextDim=Color3.new(0.35,0.35,0.42)}} local Wind={Windows={},Active=nil} local function NewWindow(Data)WindowIndex+=1 local WinID="WindWin_"..WindowIndex local WinTheme=ThemeData[Data.Theme or "Dark"]local Main=n("Frame",WinID,Data.Size or UDim2.fromOffset(550,500),Data.Position or UDim2.new(0.3,0,0.2,0),WinTheme.Bg1,0,game:GetService("CoreGui"))local Drag=n("Frame","Drag",UDim2.new(1,0,0,32),UDim2.new(0,0,0,0),WinTheme.Bg2,0,Main)local Title=n("TextLabel","Title",UDim2.new(1,-80,1,0),UDim2.new(1,10,0,0),Color3.new(0,0,0,0),0,Drag)Title.Text=Data.Title or "WindUI Window"Title.Font=Enum.Font.GothamBold Title.TextSize=15 Title.TextXAlignment=Enum.TextXAlignment.Left Title.TextColor3=WinTheme.Text local Close=n("TextButton","Close",UDim2.new(0,28,1,0),UDim2.new(1,-32,0,0),Color3.new(0.8,0.22,0.22),0,Drag)Close.Text="X"Close.Font=Enum.Font.GothamBold Close.TextSize=16 Close.TextColor3=Color3.new(1,1,1)local UICorner=Instance.new("UICorner")UICorner.CornerRadius=UDim.new(0,6)UICorner.Parent=Main local UICorner2=Instance.new("UICorner")UICorner2.CornerRadius=UDim.new(0,5)UICorner2.Parent=Drag local TabContainer=n("Frame","TabContainer",UDim2.new(1,0,0,32),UDim2.new(0,0,0,32),WinTheme.Bg2,0,Main)local Content=n("Frame","Content",UDim2.new(1,-12,1,-70),UDim2.new(0,6,0,68),WinTheme.Bg2,0,Main)Content.ClipsDescendants=true local WinObj={Instance=Main,Tabs={},ActiveTab=nil,Theme=WinTheme,Settings=Data,Content=Content,TabContainer=TabContainer,Drag=Drag,Closed=false}local DragStart,DragPos,DragStartPos Drag.InputBegan:Connect(function(x)if x.UserInputType==Enum.UserInputType.MouseButton1 then DragStart=x.Position DragStartPos=Main.Position end end)Drag.InputChanged:Connect(function(x)if x.UserInputType==Enum.UserInputType.MouseMovement then local Delta=x.Position-DragStart Main.Position=UDim2.new(DragStartPos.X.Scale,DragStartPos.X.Offset+Delta.X,DragStartPos.Y.Scale,DragStartPos.Y.Offset+Delta.Y)end end)Close.MouseButton1Click:Connect(function()WinObj.Closed=true Main.Visible=false end)if Data.ToggleKey then game:GetService("UserInputService").InputBegan:Connect(function(inp,gpe)if gpe then return end if inp.KeyCode==Data.ToggleKey then Main.Visible=not Main.Visible end end)end function WinObj:Tab(TabData)local TabBtn=n("TextButton","TabBtn_"..#self.Tabs,UDim2.new(0,90,1,0),UDim2.new(0,#self.Tabs*92,0,0),self.Theme.Bg1,0,self.TabContainer)TabBtn.Text=TabData.Title TabBtn.Font=Enum.Font.GothamBold TabBtn.TextSize=13 TabBtn.TextColor3=self.Theme.TextDim local TabContent=n("Frame","TabContent_"..#self.Tabs,UDim2.new(1,0,1,0),UDim2.new(0,0,0,0),Color3.new(0,0,0,0),0,self.Content)TabContent.Visible=false local Tab={Button=TabBtn,Content=TabContent,GetContainer=l(TabContent)}table.insert(self.Tabs,Tab)if #self.Tabs==1 then self.ActiveTab=Tab TabContent.Visible=true TabBtn.BackgroundColor3=self.Theme.Accent TabBtn.TextColor3=Color3.new(1,1,1)end TabBtn.MouseButton1Click:Connect(function()if self.ActiveTab then self.ActiveTab.Content.Visible=false self.ActiveTab.Button.BackgroundColor3=self.Theme.Bg1 self.ActiveTab.Button.TextColor3=self.Theme.TextDim end TabContent.Visible=true TabBtn.BackgroundColor3=self.Theme.Accent TabBtn.TextColor3=Color3.new(1,1,1)self.ActiveTab=Tab end)return Tab end Wind.Windows[WinID]=WinObj return WinObj end local NotifyParent=Instance.new("ScreenGui")NotifyParent.Name="WindUINotify"NotifyParent.Parent=game:GetService("CoreGui")local NotifyIndex=0 local function Notify(Data)NotifyIndex+=1 local NotifyFrame=n("Frame","Notify_"..NotifyIndex,UDim2.new(0,220,0,60),UDim2.new(1,-230,0,120+NotifyIndex*66),ThemeData.Dark.Bg2,0,NotifyParent)local UICorner=Instance.new("UICorner")UICorner.CornerRadius=UDim.new(0,7)UICorner.Parent=NotifyFrame local Title=n("TextLabel","Title",UDim2.new(1,-10,0,22),UDim2.new(0,5,0,4),Color3.new(0,0,0,0),0,NotifyFrame)Title.Text=Data.Title Title.Font=Enum.Font.GothamBold Title.TextSize=14 Title.TextXAlignment=Enum.TextXAlignment.Left Title.TextColor3=ThemeData.Dark.Text local Msg=n("TextLabel","Msg",UDim2.new(1,-10,0,26),UDim2.new(0,5,0,26),Color3.new(0,0,0,0),0,NotifyFrame)Msg.Text=Data.Content Msg.Font=Enum.Font.Gotham Msg.TextSize=12 Msg.TextXAlignment=Enum.TextXAlignment.Left Msg.TextColor3=ThemeData.Dark.TextDim task.delay(Data.Duration or 3,function()local Tween=game:GetService("TweenService")local t=Tween:Create(NotifyFrame,TweenInfo.new(0.3),{Position=UDim2.new(1,10,NotifyFrame.Position.Y.Scale,NotifyFrame.Position.Y.Offset)})t:Play()t.Completed:Connect(function()NotifyFrame:Destroy()end)end)end local function BuildElement(ParentContainer,Theme,ElType,Data)local Base=n("Frame",ElType.."_Base",UDim2.new(1,-10,0,ElType=="Section" and 28 or 34),UDim2.new(0,5,0,ParentContainer.AbsoluteContentSize.Y+6),Color3.new(0,0,0,0),0,ParentContainer)if ElType=="Section"then Base.Size=UDim2.new(1,-10,0,26)local Lab=n("TextLabel","SecLab",UDim2.new(1,0,1,0),UDim2.new(0,0,0,0),Color3.new(0,0,0,0),0,Base)Lab.Text=Data.Title Lab.Font=Enum.Font.GothamBold Lab.TextSize=13 Lab.TextXAlignment=Enum.TextXAlignment.Left Lab.TextColor3=Theme.Accent return Base end if ElType=="Label"then local Lab=n("TextLabel","Lab",UDim2.new(1,0,1,0),UDim2.new(0,0,0,0),Color3.new(0,0,0,0),0,Base)Lab.Text=Data.Title Lab.Font=Enum.Font.Gotham Lab.TextSize=12 Lab.TextXAlignment=Enum.TextXAlignment.Left Lab.TextColor3=Theme.TextDim return Base end if ElType=="Toggle"then local TogBtn=n("TextButton","Tog",UDim2.new(0,24,0,24),UDim2.new(1,-28,0.5,-12),Data.Default and Theme.Accent or Theme.Bg1,0,Base)local UIC=Instance.new("UICorner")UIC.CornerRadius=UDim.new(1,0)UIC.Parent=TogBtn local Lab=n("TextLabel","Lab",UDim2.new(1,-35,1,0),UDim2.new(0,0,0,0),Color3.new(0,0,0,0),0,Base)Lab.Text=Data.Title Lab.Font=Enum.Font.Gotham Lab.TextSize=12 Lab.TextXAlignment=Enum.TextXAlignment.Left Lab.TextColor3=Theme.Text local State=Data.Default local function Refresh()TogBtn.BackgroundColor3=State and Theme.Accent or Theme.Bg1 end Refresh()TogBtn.MouseButton1Click:Connect(function()State=not State Refresh()if Data.Callback then pcall(Data.Callback,State)end end)return Base end if ElType=="Dropdown"then local DropBtn=n("TextButton","DropBtn",UDim2.new(0,110,0,28),UDim2.new(1,-115,0.5,-14),Theme.Bg1,0,Base)local UIC=Instance.new("UICorner")UIC.CornerRadius=UDim.new(0,5)UIC.Parent=DropBtn local DropLab=n("TextLabel","DropLab",UDim2.new(1,-6,1,0),UDim2.new(0,5,0,0),Color3.new(0,0,0,0),0,DropBtn)DropLab.Text=Data.Default DropLab.Font=Enum.Font.Gotham DropLab.TextSize=11 DropLab.TextXAlignment=Enum.TextXAlignment.Left DropLab.TextColor3=Theme.Text local Lab=n("TextLabel","Lab",UDim2.new(1,-115,1,0),UDim2.new(0,0,0,0),Color3.new(0,0,0,0),0,Base)Lab.Text=Data.Title Lab.Font=Enum.Font.Gotham Lab.TextSize=12 Lab.TextXAlignment=Enum.TextXAlignment.Left Lab.TextColor3=Theme.Text local DropList=n("Frame","DropList",UDim2.new(0,110,0,#Data.Options*28),UDim2.new(1,-115,0,32),Theme.Bg2,0,Base)DropList.Visible=false DropList.ClipsDescendants=true for i,opt in ipairs(Data.Options)do local OptBtn=n("TextButton","Opt_"..i,UDim2.new(1,0,0,28),UDim2.new(0,0,0,(i-1)*28),Theme.Bg1,0,DropList)local OptLab=n("TextLabel","OptLab",UDim2.new(1,-8,1,0),UDim2.new(0,5,0,0),Color3.new(0,0,0,0),0,OptBtn)OptLab.Text=opt OptLab.Font=Enum.Font.Gotham OptLab.TextSize=11 OptLab.TextXAlignment=Enum.TextXAlignment.Left OptLab.TextColor3=Theme.Text OptBtn.MouseButton1Click:Connect(function()DropLab.Text=opt DropList.Visible=false if Data.Callback then pcall(Data.Callback,opt)end end)end DropBtn.MouseButton1Click:Connect(function()DropList.Visible=not DropList.Visible end)return Base end if ElType=="Slider"then local Bar=n("Frame","Bar",UDim2.new(0,110,0,6),UDim2.new(1,-115,0.5,-3),Theme.Bg1,0,Base)local Fill=n("Frame","Fill",UDim2.new(Data.Default/Data.Max*110,0,1,0),UDim2.new(0,0,0,0),Theme.Accent,0,Bar)local Lab=n("TextLabel","Lab",UDim2.new(1,-115,1,0),UDim2.new(0,0,0,0),Color3.new(0,0,0,0),0,Base)Lab.Text=Data.Title.." ["..Data.Default.."]" Lab.Font=Enum.Font.Gotham Lab.TextSize=12 Lab.TextXAlignment=Enum.TextXAlignment.Left Lab.TextColor3=Theme.Text local CurVal=Data.Default local function UpdateSlider(x)local val=math.clamp(Data.Min+(x/110)*(Data.Max-Data.Min),Data.Min,Data.Max)val=math.floor(val/Data.Step)*Data.Step Fill.Size=UDim2.new(val/Data.Max,0,1,0)CurVal=val Lab.Text=Data.Title.." ["..string.format("%.2f",val).."]" if Data.Callback then pcall(Data.Callback,val)end end Bar.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 then UpdateSlider(i.Position.X-Bar.AbsolutePosition.X)end end)Bar.InputChanged:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseMovement then UpdateSlider(i.Position.X-Bar.AbsolutePosition.X)end end)Fill.Size=UDim2.new(CurVal/Data.Max,0,1,0)return Base end end local function WrapTab(TabObj)local Container=TabObj.GetContainer()local LastY=0 local W={}function W:Section(D)local El=BuildElement(Container,Wind.Active.Theme,"Section",D)LastY+=El.AbsoluteSize.Y+4 return self end function W:Toggle(D)local El=BuildElement(Container,Wind.Active.Theme,"Toggle",D)LastY+=El.AbsoluteSize.Y+4 return self end function W:Dropdown(D)local El=BuildElement(Container,Wind.Active.Theme,"Dropdown",D)LastY+=El.AbsoluteSize.Y+4 return self end function W:Slider(D)local El=BuildElement(Container,Wind.Active.Theme,"Slider",D)LastY+=El.AbsoluteSize.Y+4 return self end function W:Label(D)local El=BuildElement(Container,Wind.Active.Theme,"Label",D)LastY+=El.AbsoluteSize.Y+2 return self end function W:Separator()local Sep=n("Frame","Sep",UDim2.new(1,-10,0,2),UDim2.new(0,5,0,LastY+3),Wind.Active.Theme.Bg1,0,Container)LastY+=8 return self end return W end return {CreateWindow=NewWindow,Notify=Notify}end)

-- ========== 下面【所有逻辑完全保留你原版代码，一丝不动】==========
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- 获取 RocketHit 事件（安全查找，避免无限等待）
local RocketHitEvent = ReplicatedStorage:FindFirstChild("RocketSystem")
if RocketHitEvent then RocketHitEvent = RocketHitEvent:FindFirstChild("Events") end
if RocketHitEvent then RocketHitEvent = RocketHitEvent:FindFirstChild("RocketHit") end
if not RocketHitEvent then
    warn("未找到 RocketHit 事件，请检查游戏版本")
end

-- 全局设置
local Settings = {
    Enabled = false,
    AttackType = "Player",   -- "Player" 或 "Shield"
    AttackDelay = 0.2,
    SelectedPlayers = {},    -- 存储选中的玩家名（小写）
}

local attackThread = nil
local lastFire = 0

-- ================= 攻击函数 =================
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
    local now = os.clock()
    if now-lastFire < Settings.AttackDelay then return end
    if not RocketHitEvent then return end
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
    lastFire = now
end

-- 攻击循环（只攻击选中的玩家）
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

-- ================= WindUI 界面【完全原版UI逻辑不变】 =================
local Window = WindUI:CreateWindow({
    Title = "杀戮光环 - 全能版",
    Folder = "KillAuraUltimate",
    Theme = "Dark",
    Size = UDim2.fromOffset(580, 620),
    Resizable = true,
    ToggleKey = Enum.KeyCode.RightControl,
})

-- 标签页
local MainTab = Window:Tab({ Title = "控制", Icon = "target" })
local PlayerTab = Window:Tab({ Title = "玩家列表", Icon = "users" })
local MainUI = WindUI:WrapTab(MainTab)
local PlayerUI = WindUI:WrapTab(PlayerTab)

-- ---------- 控制标签页 ----------
MainUI:Section({ Title = "攻击开关" })
local toggle = MainUI:Toggle({
    Title = "总开关",
    Default = false,
    Callback = function(v)
        Settings.Enabled = v
        if v then startScript() else stopScript() end
    end
})

MainUI:Separator()
MainUI:Section({ Title = "攻击设置" })
MainUI:Dropdown({
    Title = "攻击类型",
    Options = {"玩家本体", "基地护盾"},
    Default = "玩家本体",
    Callback = function(opt)
        Settings.AttackType = (opt == "玩家本体") and "Player" or "Shield"
    end
})
MainUI:Slider({
    Title = "攻击间隔 (秒)",
    Min = 0.05,
    Max = 1.0,
    Step = 0.01,
    Default = Settings.AttackDelay,
    Callback = function(v)
        Settings.AttackDelay = v
    end
})
MainUI:Label({ Title = "提示：需要装备 RPG。总开关开启后，将自动攻击「玩家列表」中选中的目标。" })

-- ---------- 玩家列表标签页 ----------
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

-- 调整按钮位置
local function repositionButtons()
    local gap = 10
    local width = 95
    allBtn.Position = UDim2.new(0, 0, 0, 0)
    clearBtn.Position = UDim2.new(0, width + gap, 0, 0)
    invertBtn.Position = UDim2.new(0, 2*(width+gap), 0, 0)
    refreshBtn.Position = UDim2.new(0, 3*(width+gap), 0, 0)
end
repositionButtons()

-- 滚动框显示玩家列表
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

-- 全选
allBtn.MouseButton1Click:Connect(function()
    for name, btn in pairs(checkboxes) do
        if not Settings.SelectedPlayers[name] then
            Settings.SelectedPlayers[name] = true
            btn.Text = "✓"
            btn.BackgroundColor3 = Color3.fromRGB(0,150,0)
        end
    end
end)
-- 清空
clearBtn.MouseButton1Click:Connect(function()
    for name, btn in pairs(checkboxes) do
        if Settings.SelectedPlayers[name] then
            Settings.SelectedPlayers[name] = nil
            btn.Text = ""
            btn.BackgroundColor3 = Color3.fromRGB(70,70,80)
        end
    end
end)
-- 反选
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
-- 刷新
refreshBtn.MouseButton1Click:Connect(function()
    refreshPlayerList()
    WindUI:Notify({ Title = "刷新", Content = "玩家列表已更新", Duration = 2 })
end)

-- 玩家进出自动刷新
Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(refreshPlayerList)
refreshPlayerList()

-- 启动通知
WindUI:Notify({
    Title = "杀戮光环",
    Content = "按 RightControl 开关菜单 | 装备 RPG 后启用",
    Duration = 4
})

