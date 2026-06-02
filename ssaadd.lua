-- ================= 杀戮光环 最终修复版（无 lastFire 冲突） =================
local WindUI = (function()
    local Theme = {
        Bg1 = Color3.new(0.12,0.12,0.15),
        Bg2 = Color3.new(0.18,0.18,0.22),
        Accent = Color3.new(0.22,0.55,0.98),
        Text = Color3.new(0.95,0.95,0.95),
        TextDim = Color3.new(0.55,0.55,0.62)
    }
    local CoreGui = game:GetService("CoreGui")
    local UIS = game:GetService("UserInputService")
    local Tween = game:GetService("TweenService")

    local function new(class, props)
        local obj = Instance.new(class)
        for k,v in pairs(props) do obj[k]=v end
        return obj
    end

    local Notify
    local function CreateWindow(data)
        local main = new("Frame", {
            Name="WindWin",
            Size=data.Size or UDim2.fromOffset(580,620),
            Position=UDim2.new(0.2,0,0.2,0),
            BackgroundColor3=Theme.Bg1,
            BorderSizePixel=0,
            Visible=true,
            Parent=CoreGui
        })
        new("UICorner", {CornerRadius=UDim.new(0,6), Parent=main})

        local drag = new("Frame", {
            Size=UDim2.new(1,0,0,32),
            Position=UDim2.new(0,0,0,0),
            BackgroundColor3=Theme.Bg2,
            BorderSizePixel=0,
            Parent=main
        })
        new("UICorner", {CornerRadius=UDim.new(0,5), Parent=drag})
        new("TextLabel", {
            Size=UDim2.new(1,-80,1,0),
            Position=UDim2.new(0,10,0,0),
            BackgroundTransparency=1,
            Text=data.Title,
            Font=Enum.Font.GothamBold,
            TextSize=15,
            TextXAlignment=Enum.TextXAlignment.Left,
            TextColor3=Theme.Text,
            Parent=drag
        })
        local close = new("TextButton", {
            Size=UDim2.new(0,28,1,0),
            Position=UDim2.new(1,-32,0,0),
            BackgroundColor3=Color3.new(0.8,0.22,0.22),
            BorderSizePixel=0,
            Text="X",
            Font=Enum.Font.GothamBold,
            TextSize=16,
            TextColor3=Color3.new(1,1,1),
            Parent=drag
        })
        new("UICorner", {CornerRadius=UDim.new(0,5), Parent=close})

        local tabContainer = new("Frame", {
            Size=UDim2.new(1,0,0,32),
            Position=UDim2.new(0,0,0,32),
            BackgroundColor3=Theme.Bg2,
            BorderSizePixel=0,
            Parent=main
        })
        local content = new("Frame", {
            Size=UDim2.new(1,-12,1,-70),
            Position=UDim2.new(0,6,0,68),
            BackgroundColor3=Theme.Bg2,
            BorderSizePixel=0,
            ClipsDescendants=true,
            Parent=main
        })

        local dragStart, dragPos
        drag.InputBegan:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1 then
                dragStart=input.Position
                dragPos=main.Position
            end
        end)
        drag.InputChanged:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.MouseMovement then
                local delta=input.Position-dragStart
                main.Position=UDim2.new(dragPos.X.Scale, dragPos.X.Offset+delta.X, dragPos.Y.Scale, dragPos.Y.Offset+delta.Y)
            end
        end)

        if data.ToggleKey then
            UIS.InputBegan:Connect(function(input, gpe)
                if not gpe and input.KeyCode==data.ToggleKey then
                    main.Visible=not main.Visible
                end
            end)
        end
        close.MouseButton1Click:Connect(function() main:Destroy() end)

        local tabs = {}
        local activeTab = nil
        local winApi = {}

        function winApi:Tab(tabData)
            local btn = new("TextButton", {
                Size=UDim2.new(0,90,1,0),
                Position=UDim2.new(0,#tabs*92,0,0),
                BackgroundColor3=Theme.Bg1,
                BorderSizePixel=0,
                Text=tabData.Title,
                Font=Enum.Font.GothamBold,
                TextSize=13,
                TextColor3=Theme.TextDim,
                Parent=tabContainer
            })
            local tabContent = new("Frame", {
                Size=UDim2.new(1,0,1,0),
                Position=UDim2.new(0,0,0,0),
                BackgroundTransparency=1,
                Visible=false,
                Parent=content
            })
            local tab = {
                Button=btn,
                Content=tabContent,
                GetContainer=function() return tabContent end
            }
            table.insert(tabs, tab)
            if #tabs==1 then
                activeTab=tab
                tabContent.Visible=true
                btn.BackgroundColor3=Theme.Accent
                btn.TextColor3=Color3.new(1,1,1)
            end
            btn.MouseButton1Click:Connect(function()
                if activeTab then
                    activeTab.Content.Visible=false
                    activeTab.Button.BackgroundColor3=Theme.Bg1
                    activeTab.Button.TextColor3=Theme.TextDim
                end
                activeTab=tab
                tabContent.Visible=true
                btn.BackgroundColor3=Theme.Accent
                btn.TextColor3=Color3.new(1,1,1)
            end)
            return tab
        end

        local function Section(parent, data)
            local frame = new("Frame", {
                Size=UDim2.new(1,-10,0,26),
                Position=UDim2.new(0,5,0,parent.AbsoluteContentSize.Y+6),
                BackgroundTransparency=1,
                Parent=parent
            })
            new("TextLabel", {
                Size=UDim2.new(1,0,1,0),
                Position=UDim2.new(0,0,0,0),
                BackgroundTransparency=1,
                Text=data.Title,
                Font=Enum.Font.GothamBold,
                TextSize=13,
                TextXAlignment=Enum.TextXAlignment.Left,
                TextColor3=Theme.Accent,
                Parent=frame
            })
            return frame
        end
        local function Toggle(parent, data)
            local frame = new("Frame", {
                Size=UDim2.new(1,-10,0,34),
                Position=UDim2.new(0,5,0,parent.AbsoluteContentSize.Y+6),
                BackgroundTransparency=1,
                Parent=parent
            })
            local btn = new("TextButton", {
                Size=UDim2.new(0,24,0,24),
                Position=UDim2.new(1,-28,0.5,-12),
                BackgroundColor3=data.Default and Theme.Accent or Theme.Bg1,
                BorderSizePixel=0,
                Text="",
                Parent=frame
            })
            new("UICorner", {CornerRadius=UDim.new(1,0), Parent=btn})
            new("TextLabel", {
                Size=UDim2.new(1,-35,1,0),
                Position=UDim2.new(0,0,0,0),
                BackgroundTransparency=1,
                Text=data.Title,
                Font=Enum.Font.Gotham,
                TextSize=12,
                TextXAlignment=Enum.TextXAlignment.Left,
                TextColor3=Theme.Text,
                Parent=frame
            })
            local state = data.Default
            local function refresh() btn.BackgroundColor3=state and Theme.Accent or Theme.Bg1 end
            btn.MouseButton1Click:Connect(function()
                state=not state refresh()
                if data.Callback then pcall(data.Callback,state) end
            end)
            return frame
        end
        local function Dropdown(parent, data)
            local frame = new("Frame", {
                Size=UDim2.new(1,-10,0,34),
                Position=UDim2.new(0,5,0,parent.AbsoluteContentSize.Y+6),
                BackgroundTransparency=1,
                Parent=parent
            })
            local btn = new("TextButton", {
                Size=UDim2.new(0,110,0,28),
                Position=UDim2.new(1,-115,0.5,-14),
                BackgroundColor3=Theme.Bg1,
                BorderSizePixel=0,
                Parent=frame
            })
            new("UICorner", {CornerRadius=UDim.new(0,5), Parent=btn})
            local lab = new("TextLabel", {
                Size=UDim2.new(1,-6,1,0),
                Position=UDim2.new(0,5,0,0),
                BackgroundTransparency=1,
                Text=data.Default,
                Font=Enum.Font.Gotham,
                TextSize=11,
                TextXAlignment=Enum.TextXAlignment.Left,
                TextColor3=Theme.Text,
                Parent=btn
            })
            new("TextLabel", {
                Size=UDim2.new(1,-115,1,0),
                Position=UDim2.new(0,0,0,0),
                BackgroundTransparency=1,
                Text=data.Title,
                Font=Enum.Font.Gotham,
                TextSize=12,
                TextXAlignment=Enum.TextXAlignment.Left,
                TextColor3=Theme.Text,
                Parent=frame
            })
            local list = new("Frame", {
                Size=UDim2.new(0,110,0,#data.Options*28),
                Position=UDim2.new(1,-115,0,32),
                BackgroundColor3=Theme.Bg2,
                BorderSizePixel=0,Visible=false,ClipsDescendants=true,Parent=frame
            })
            for i,opt in ipairs(data.Options) do
                local optBtn = new("TextButton", {Size=UDim2.new(1,0,0,28),Position=UDim2.new(0,0,0,(i-1)*28),BackgroundColor3=Theme.Bg1,BorderSizePixel=0,Parent=list})
                new("TextLabel", {Size=UDim2.new(1,-8,1,0),Position=UDim2.new(0,5,0,0),BackgroundTransparency=1,Text=opt,Font=Enum.Font.Gotham,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=Theme.Text,Parent=optBtn})
                optBtn.MouseButton1Click:Connect(function() lab.Text=opt list.Visible=false if data.Callback then pcall(data.Callback,opt) end end)
            end
            btn.MouseButton1Click:Connect(function() list.Visible=not list.Visible end)
            return frame
        end
        local function Slider(parent, data)
            local frame = new("Frame", {Size=UDim2.new(1,-10,0,34),Position=UDim2.new(0,5,0,parent.AbsoluteContentSize.Y+6),BackgroundTransparency=1,Parent=parent})
            local bar = new("Frame", {Size=UDim2.new(0,110,0,6),Position=UDim2.new(1,-115,0.5,-3),BackgroundColor3=Theme.Bg1,BorderSizePixel=0,Parent=frame})
            local fill = new("Frame", {Size=UDim2.new(data.Default/data.Max*110,0,1,0),Position=UDim2.new(0,0,0,0),BackgroundColor3=Theme.Accent,BorderSizePixel=0,Parent=bar})
            local lab = new("TextLabel", {Size=UDim2.new(1,-115,1,0),Position=UDim2.new(0,0,0,0),BackgroundTransparency=1,Text=data.Title.." ["..string.format("%.2f",data.Default).."]",Font=Enum.Font.Gotham,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=Theme.Text,Parent=frame})
            local curVal = data.Default
            local function update(x)
                local val = math.clamp(data.Min+(x/110)*(data.Max-data.Min), data.Min, data.Max)
                val = math.floor(val/data.Step)*data.Step
                fill.Size=UDim2.new(val/data.Max,0,1,0)
                curVal=val lab.Text=data.Title.." ["..string.format("%.2f",val).."]"
                if data.Callback then pcall(data.Callback,val) end
            end
            bar.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 then update(i.Position.X-bar.AbsolutePosition.X)end end)
            bar.InputChanged:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseMovement then update(i.Position.X-bar.AbsolutePosition.X)end end)
            return frame
        end
        local function Label(parent, data)
            local frame = new("Frame", {Size=UDim2.new(1,-10,0,24),Position=UDim2.new(0,5,0,parent.AbsoluteContentSize.Y+6),BackgroundTransparency=1,Parent=parent})
            new("TextLabel", {Size=UDim2.new(1,0,1,0),Position=UDim2.new(0,0,0,0),BackgroundTransparency=1,Text=data.Title,Font=Enum.Font.Gotham,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=Theme.TextDim,Parent=frame})
            return frame
        end
        local function Separator(parent)
            return new("Frame", {Size=UDim2.new(1,-10,0,2),Position=UDim2.new(0,5,0,parent.AbsoluteContentSize.Y+6),BackgroundColor3=Theme.Bg1,BorderSizePixel=0,Parent=parent})
        end

        winApi.Section=Section winApi.Toggle=Toggle winApi.Dropdown=Dropdown
        winApi.Slider=Slider winApi.Label=Label winApi.Separator=Separator
        return winApi
    end

    Notify=function(title,content,dur)
        local frame = new("Frame", {Size=UDim2.new(0,220,0,60),Position=UDim2.new(1,-230,0,120),BackgroundColor3=Theme.Bg2,BorderSizePixel=0,Parent=CoreGui})
        new("UICorner", {CornerRadius=UDim.new(0,7), Parent=frame})
        new("TextLabel", {Size=UDim2.new(1,-10,0,22),Position=UDim2.new(0,5,0,4),BackgroundTransparency=1,Text=title,Font=Enum.Font.GothamBold,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=Theme.Text,Parent=frame})
        new("TextLabel", {Size=UDim2.new(1,-10,0,26),Position=UDim2.new(0,5,0,26),BackgroundTransparency=1,Text=content,Font=Enum.Font.Gotham,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=Theme.TextDim,Parent=frame})
        task.delay(dur or 3,function()local t=Tween:Create(frame,TweenInfo.new(0.3),{Position=UDim2.new(1,10,0,120)})t:Play()t.Completed:Connect(function()frame:Destroy()end)end)
    end

    return {CreateWindow=CreateWindow,Notify=Notify}
end)()

-- 原版攻击逻辑，移除 lastFire 冲突
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local RocketHitEvent = ReplicatedStorage:FindFirstChild("RocketSystem")
if RocketHitEvent then RocketHitEvent = RocketHitEvent:FindFirstChild("Events") end
if RocketHitEvent then RocketHitEvent = RocketHitEvent:FindFirstChild("RocketHit") end
if not RocketHitEvent then warn("未找到RocketHit") end

local Settings = {Enabled=false,AttackType="Player",AttackDelay=0.2,SelectedPlayers={}}
local attackThread = nil

local function getPlayerHitPart(target)
    local char=target.Character if not char then return end
    for _,n in ipairs({"HumanoidRootPart","Head"})do local p=char:FindFirstChild(n)if p and p:IsA("BasePart")then return p,p.Position end end
end
local function getEnemyShieldPart(ply)
    if ply==LocalPlayer then return end
    local ty=Workspace:FindFirstChild("Tycoon")if not ty then return end
    local tyc=ty:FindFirstChild("Tycoons")if not tyc then return end
    local pty=tyc:FindFirstChild(ply.Name)if not pty then return end
    local pur=pty:FindFirstChild("PurchasedObjects")if not pur then return end
    local bs=pur:FindFirstChild("Base Shield")if not bs then return end
    local sh=bs:FindFirstChild("Shield")if not sh then return end
    for _,n in ipairs({"Shield1","Shield2","Shield3","Shield4"})do local p=sh:FindFirstChild(n)if p then return p end end
end
local function sendRocketHit(tar,part,pos)
    if not RocketHitEvent or not tar or not part then return end
    local lc=LocalPlayer.Character if not lc then return end
    local rpg=lc:FindFirstChild("RPG")if not rpg then return end
    local root=lc:FindFirstChild("HumanoidRootPart")if not root then return end
    local args={{Normal=Vector3.new(0,1,0),Player=tar,HitPart=part,Origin=root.Position,Label="KillA_"..os.clock(),Vehicle=rpg,Position=pos or part.Position,Weapon=rpg}}
    pcall(function()RocketHitEvent:FireServer(unpack(args))end)
end
local function attackLoop()
    while Settings.Enabled do
        local tarList={}
        for name in pairs(Settings.SelectedPlayers)do
            local p=Players:FindFirstChild(name)
            if p and p~=LocalPlayer and p.Team~=LocalPlayer.Team and p.Character then table.insert(tarList,p)end
        end
        if #tarList==0 then task.wait(0.5)goto continue end
        for _,v in ipairs(tarList)do
            if not Settings.Enabled then break end
            if Settings.AttackType=="Player"then
                local p,pos=getPlayerHitPart(v)
                if p then sendRocketHit(v,p,pos)end
            else
                local sp=getEnemyShieldPart(v)
                if sp then sendRocketHit(v,sp,sp.Position)end
            end
            task.wait(Settings.AttackDelay)
        end
        ::continue::
    end
end
local function start()if attackThread then task.cancel(attackThread)end attackThread=task.spawn(attackLoop)end
local function stop()Settings.Enabled=false if attackThread then task.cancel(attackThread)attackThread=nil end end

-- UI创建（无任何改动）
local Window=WindUI:CreateWindow({Title="杀戮光环-全能",Size=UDim2.fromOffset(580,620),ToggleKey=Enum.KeyCode.RightControl})
local MainTab=Window:Tab({Title="控制"})
local PlayerTab=Window:Tab({Title="玩家列表"})
local MainCon=MainTab:GetContainer()
local PlyCon=PlayerTab:GetContainer()

Window:Section(MainCon,{Title="攻击开关"})
Window:Toggle(MainCon,{Title="总开关",Default=false,Callback=function(v)Settings.Enabled=v if v then start()else stop()end end})
Window:Separator(MainCon)
Window:Section(MainCon,{Title="攻击设置"})
Window:Dropdown(MainCon,{Title="攻击类型",Options={"玩家本体","基地护盾"},Default="玩家本体",Callback=function(s)Settings.AttackType=s=="玩家本体"and"Player"or"Shield"end})
Window:Slider(MainCon,{Title="攻击间隔(秒)",Min=0.05,Max=1,Step=0.01,Default=0.2,Callback=function(v)Settings.AttackDelay=v end})
Window:Label(MainCon,{Title="提示：手持RPG，勾选玩家后开总开关"})

Window:Section(PlyCon,{Title="玩家选择"})
Window:Label(PlyCon,{Title="全选/清空/反选/刷新玩家"})

local btnFrame=Instance.new("Frame")
btnFrame.Size=UDim2.new(1,-20,0,35)
btnFrame.Position=UDim2.new(0,10,0,45)
btnFrame.BackgroundTransparency=1 btnFrame.Parent=PlyCon

local function mkBtn(text,col,call)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(0,95,0,30)b.Text=text b.BackgroundColor3=col b.TextColor3=Color3.new(1,1,1)b.BorderSizePixel=0
    local cor=Instance.new("UICorner")cor.CornerRadius=UDim.new(0,6)cor.Parent=b b.Parent=btnFrame
    b.MouseButton1Click:Connect(call)return b
end
local all=mkBtn("全选",Color3.fromRGB(60,60,70),nil)
local clr=mkBtn("清空",Color3.fromRGB(60,60,70),nil)
local inv=mkBtn("反选",Color3.fromRGB(60,60,70),nil)
local ref=mkBtn("刷新",Color3.fromRGB(60,60,70),nil)
local function posBtn()
    local g,w=10,95
    all.Position=UDim2.new(0,0,0,0)
    clr.Position=UDim2.new(0,w+g,0,0)
    inv.Position=UDim2.new(0,2*(w+g),0,0)
    ref.Position=UDim2.new(0,3*(w+g),0,0)
end posBtn()

local scroll=Instance.new("ScrollingFrame")
scroll.Size=UDim2.new(1,-20,0,420)
scroll.Position=UDim2.new(0,10,0,90)
scroll.BackgroundColor3=Color3.fromRGB(25,25,35)
scroll.BorderSizePixel=0 scroll.CanvasSize=UDim2.new(0,0,0,0)scroll.ScrollBarThickness=8
local scor=Instance.new("UICorner")scor.CornerRadius=UDim.new(0,8)scor.Parent=scroll scroll.Parent=PlyCon

local checkBox={}
local function refreshList()
    for _,c in ipairs(scroll:GetChildren())do if c:IsA("Frame")then c:Destroy()end end
    checkBox={}local y=5 local plist={}
    for _,p in ipairs(Players:GetPlayers())do if p~=LocalPlayer then table.insert(plist,p)end end
    table.sort(plist,function(a,b)return a.Name<b.Name end)
    for _,p in ipairs(plist)do
        local fr=Instance.new("Frame")fr.Size=UDim2.new(1,-10,0,36)fr.Position=UDim2.new(0,5,0,y)fr.BackgroundColor3=Color3.fromRGB(35,35,45)fr.BorderSizePixel=0
        local fcor=Instance.new("UICorner")fcor.CornerRadius=UDim.new(0,6)fcor.Parent=fr fr.Parent=scroll

        local ck=Instance.new("TextButton")ck.Size=UDim2.new(0,26,0,26)ck.Position=UDim2.new(0,8,0.5,-13)ck.BorderSizePixel=0
        local low=p.Name:lower()local sel=Settings.SelectedPlayers[low]==true
        ck.Text=sel and"✓"or"" ck.BackgroundColor3=sel and Color3.fromRGB(0,150,0)or Color3.fromRGB(70,70,80)
        ck.Font=Enum.Font.GothamBold ck.TextSize=18 local ckor=Instance.new("UICorner")ckor.CornerRadius=UDim.new(1,0)ckor.Parent=ck ck.Parent=fr

        local lab=Instance.new("TextLabel")lab.Size=UDim2.new(1,-45,1,0)lab.Position=UDim2.new(0,40,0,0)lab.Text=p.Name lab.BackgroundTransparency=1
        lab.TextColor3=Color3.fromRGB(220,220,220)lab.Font=Enum.Font.Gotham lab.TextSize=14 lab.TextXAlignment=Enum.TextXAlignment.Left lab.Parent=fr

        checkBox[low]=ck
        ck.MouseButton1Click:Connect(function()
            if Settings.SelectedPlayers[low]then Settings.SelectedPlayers[low]=nil ck.Text=""ck.BackgroundColor3=Color3.fromRGB(70,70,80)
            else Settings.SelectedPlayers[low]=true ck.Text="✓"ck.BackgroundColor3=Color3.fromRGB(0,150,0)end
        end)
        y=y+42
    end
    scroll.CanvasSize=UDim2.new(0,0,0,y+10)
end
all.MouseButton1Click:Connect(function()for n,b in pairs(checkBox)do Settings.SelectedPlayers[n]=true b.Text="✓"b.BackgroundColor3=Color3.fromRGB(0,150,0)end end)
clr.MouseButton1Click:Connect(function()for n,b in pairs(checkBox)do Settings.SelectedPlayers[n]=nil b.Text=""b.BackgroundColor3=Color3.fromRGB(70,70,80)end end)
inv.MouseButton1Click:Connect(function()for n,b in pairs(checkBox)do if Settings.SelectedPlayers[n]then Settings.SelectedPlayers[n]=nil b.Text=""b.BackgroundColor3=Color3.fromRGB(70,70,80)else Settings.SelectedPlayers[n]=true b.Text="✓"b.BackgroundColor3=Color3.fromRGB(0,150,0)end end end)
ref.MouseButton1Click:Connect(function()refreshList()WindUI:Notify("刷新","玩家列表已更新",2)end)

Players.PlayerAdded:Connect(refreshList)
Players.PlayerRemoving:Connect(refreshList)
refreshList()
WindUI:Notify("杀戮光环","右Ctrl呼出UI，装备RPG生效",4)
