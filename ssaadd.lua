-- ================= 加载 WindUI =================
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)
if not success then
    warn("WindUI 加载失败: " .. tostring(WindUI))
    return
end

-- ================= 配置 =================
local PLAYER_INTERVAL = 0.5
local SHIELD_INTERVAL = 0.5
local TARGET_PARTS = {"HumanoidRootPart", "Head"}

-- 创建主窗口
local Window = WindUI:CreateWindow({
    Title = "全能杀戮光环",
    Icon = "sword",
    IconThemed = true,
    Size = UDim2.fromOffset(620, 560),
    Theme = "Dark",
    KeySystem = { Key = {"NB666"}, Note = "请输入密码", SaveKey = true }
})
Window:EditOpenButton({ Enabled = true, Title = "打开菜单", Draggable = true })

-- ================= 通用 =================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RocketHitEvent = ReplicatedStorage:WaitForChild("RocketSystem"):WaitForChild("Events"):WaitForChild("RocketHit")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local function getRPG()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("RPG")
end

local function getOrigin()
    local char = LocalPlayer.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    return root and root.Position or nil
end

-- ================= 玩家追杀（全图/固定目标）=================
local playerActive = false
local playerTask = nil
local playerInterval = PLAYER_INTERVAL
local fixedTargetName = nil   -- 固定目标玩家名
local isFixedMode = false     -- 是否固定目标模式

local function getTargetPart(target)
    local char = target.Character
    if not char then return nil, nil end
    local hum = char:FindFirstChild("Humanoid")
    if not hum or hum.Health <= 0 then return nil, nil end
    for _, name in ipairs(TARGET_PARTS) do
        local part = char:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            return part, part.Position
        end
    end
    return nil, nil
end

local function attackPlayer(target)
    if not playerActive then return false end
    if target == LocalPlayer then return false end
    local hitPart, hitPos = getTargetPart(target)
    if not hitPart then return false end
    local rpg = getRPG()
    if not rpg then return false end
    local origin = getOrigin()
    if not origin then return false end
    local args = {{
        Normal = Vector3.new(0,1,0),
        Player = target,
        HitPart = hitPart,
        Origin = origin,
        Label = "Aura_" .. tostring(os.clock()) .. "_" .. math.random(99999),
        Vehicle = rpg,
        Position = hitPos,
        Weapon = rpg
    }}
    pcall(function() RocketHitEvent:FireServer(unpack(args)) end)
    return true
end

local function playerLoop()
    while true do
        while not playerActive do task.wait(0.5) end
        local targets = {}
        if isFixedMode and fixedTargetName then
            local fixed = Players:FindFirstChild(fixedTargetName)
            if fixed and fixed ~= LocalPlayer then
                targets = {fixed}
            else
                task.wait(0.5)
                goto continue
            end
        else
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then table.insert(targets, p) end
            end
        end
        local count = #targets
        if count == 0 then
            task.wait(0.3)
        else
            local interval = playerInterval
            local start = tick()
            for _, p in ipairs(targets) do
                if not playerActive then break end
                local ok = attackPlayer(p)
                if not ok then
                    task.wait(0.1)
                else
                    local elapsed = tick() - start
                    local waitTime = (interval / count) - elapsed
                    if waitTime > 0 then task.wait(waitTime) end
                end
            end
        end
        ::continue::
        task.wait(0.05)
    end
end

local function startPlayer()
    if playerTask then task.cancel(playerTask) end
    playerActive = true
    playerTask = task.spawn(playerLoop)
    WindUI:Notify({Title = "玩家追杀", Content = "已开启", Duration = 2})
end

local function stopPlayer()
    playerActive = false
    WindUI:Notify({Title = "玩家追杀", Content = "已关闭", Duration = 2})
end

-- ================= 护盾攻击（不变）=================
local shieldActive = false
local shieldTask = nil
local shieldInterval = SHIELD_INTERVAL
local SHIELD_PARTS = {"Shield1"}

local function getShieldPart(player)
    if player == LocalPlayer then return nil end
    local tycoon = workspace:FindFirstChild("Tycoon")
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
    for _, name in ipairs(SHIELD_PARTS) do
        local part = shield:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            return part
        end
    end
    return nil
end

local function attackShield(target, part)
    if not shieldActive then return false end
    local rpg = getRPG()
    if not rpg then return false end
    local origin = getOrigin()
    if not origin then return false end
    local args = {{
        Normal = Vector3.new(0,1,0),
        Player = target,
        HitPart = part,
        Origin = origin,
        Label = target.Name .. "_Shield_" .. tostring(os.clock()) .. "_" .. math.random(99999),
        Vehicle = rpg,
        Position = part.Position,
        Weapon = rpg
    }}
    pcall(function() RocketHitEvent:FireServer(unpack(args)) end)
    return true
end

local function shieldLoop()
    while true do
        while not shieldActive do task.wait(0.5) end
        local targets = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local part = getShieldPart(p)
                if part then
                    table.insert(targets, {player = p, part = part})
                end
            end
        end
        local count = #targets
        if count == 0 then
            task.wait(0.3)
        else
            local interval = shieldInterval
            local start = tick()
            for _, t in ipairs(targets) do
                if not shieldActive then break end
                local ok = attackShield(t.player, t.part)
                if not ok then
                    task.wait(0.1)
                else
                    local elapsed = tick() - start
                    local waitTime = (interval / count) - elapsed
                    if waitTime > 0 then task.wait(waitTime) end
                end
            end
        end
        task.wait(0.05)
    end
end

local function startShield()
    if shieldTask then task.cancel(shieldTask) end
    shieldActive = true
    shieldTask = task.spawn(shieldLoop)
    WindUI:Notify({Title = "护盾攻击", Content = "已开启", Duration = 2})
end

local function stopShield()
    shieldActive = false
    WindUI:Notify({Title = "护盾攻击", Content = "已关闭", Duration = 2})
end

-- ================= 穿墙（彻底不掉地）=================
local noclipActive = false
local noclipSpeed = 16
local originalSpeed = nil

local function applyNoclip()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    if originalSpeed == nil then
        originalSpeed = humanoid.WalkSpeed
    end
    humanoid.WalkSpeed = noclipSpeed
    humanoid.PlatformStand = true
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

local function revertNoclip()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.PlatformStand = false
        if originalSpeed then
            humanoid.WalkSpeed = originalSpeed
        end
    end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
end

local function noclipKeepAboveGround()
    local char = LocalPlayer.Character
    if not noclipActive or not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local ray = Ray.new(root.Position, Vector3.new(0, -10, 0))
    local hit, pos = workspace:FindPartOnRay(ray, char, false, true)
    if hit then
        local newY = pos.Y + 2   -- 脚离地面2单位
        if root.Position.Y < newY then
            root.Position = Vector3.new(root.Position.X, newY, root.Position.Z)
        end
    end
end

local function startNoclip()
    if noclipActive then return end
    noclipActive = true
    originalSpeed = nil
    applyNoclip()
    WindUI:Notify({Title = "穿墙", Content = "已开启（不会掉地）", Duration = 2})
end

local function stopNoclip()
    noclipActive = false
    revertNoclip()
    WindUI:Notify({Title = "穿墙", Content = "已关闭", Duration = 2})
end

-- 每帧修正高度
RunService.Heartbeat:Connect(function()
    if noclipActive then
        noclipKeepAboveGround()
    end
end)

-- 重生自动重新应用
LocalPlayer.CharacterAdded:Connect(function()
    if noclipActive then
        task.wait(0.2)
        applyNoclip()
    end
end)

-- ================= 摇杆飞行（手机圆盘）=================
local flying = false
local flySpeed = 40
local flyBodyVelocity = nil
local joystickGui = nil
local joystickThumb = nil
local joystickBg = nil
local joystickActive = false
local joystickDirection = Vector2.new(0,0)
local cancelFlyBtn = nil

local function createJoystick()
    if joystickGui then return end
    local gui = Instance.new("ScreenGui")
    gui.Name = "FlyJoystick"
    gui.Parent = game:GetService("CoreGui")
    local bg = Instance.new("ImageLabel")
    bg.Size = UDim2.new(0, 120, 0, 120)
    bg.Position = UDim2.new(0, 30, 1, -150)
    bg.BackgroundTransparency = 1
    bg.Image = "rbxassetid://129260712070622"  -- 圆形底图，可替换
    bg.ScaleType = Enum.ScaleType.Fit
    bg.Parent = gui
    local thumb = Instance.new("ImageLabel")
    thumb.Size = UDim2.new(0, 50, 0, 50)
    thumb.Position = UDim2.new(0.5, -25, 0.5, -25)
    thumb.BackgroundTransparency = 1
    thumb.Image = "rbxassetid://129260712070622"
    thumb.ScaleType = Enum.ScaleType.Fit
    thumb.Parent = bg
    joystickBg = bg
    joystickThumb = thumb
    joystickGui = gui

    -- 取消飞行按钮
    local cancel = Instance.new("TextButton")
    cancel.Size = UDim2.new(0, 80, 0, 40)
    cancel.Position = UDim2.new(0, 30, 1, -80)
    cancel.Text = "降落"
    cancel.TextColor3 = Color3.new(1,1,1)
    cancel.BackgroundColor3 = Color3.fromRGB(200,50,50)
    cancel.BorderSizePixel = 0
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = cancel
    cancel.Parent = gui
    cancel.MouseButton1Click:Connect(function()
        stopFly()
    end)
    cancelFlyBtn = cancel

    -- 摇杆拖动逻辑
    local function updateThumb(pos)
        local center = joystickBg.AbsolutePosition + Vector2.new(joystickBg.AbsoluteSize.X/2, joystickBg.AbsoluteSize.Y/2)
        local delta = pos - center
        local radius = 40
        local dist = math.min(delta.Magnitude, radius)
        local dir = delta.Magnitude > 0 and delta.Unit or Vector2.new(0,0)
        joystickThumb.Position = UDim2.new(0.5, dir.X * dist - 25, 0.5, dir.Y * dist - 25)
        joystickDirection = dir * (dist / radius)
    end

    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            local pos = input.Position
            if (pos - (joystickBg.AbsolutePosition + joystickBg.AbsoluteSize/2)).Magnitude <= 60 then
                joystickActive = true
                updateThumb(pos)
            end
        end
    end
    local function onInputChanged(input)
        if joystickActive and input.UserInputType == Enum.UserInputType.Touch then
            updateThumb(input.Position)
        end
    end
    local function onInputEnded(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            joystickActive = false
            joystickThumb.Position = UDim2.new(0.5, -25, 0.5, -25)
            joystickDirection = Vector2.new(0,0)
        end
    end
    UserInputService.TouchBegan:Connect(onInputBegan)
    UserInputService.TouchMoved:Connect(onInputChanged)
    UserInputService.TouchEnded:Connect(onInputEnded)
end

local function destroyJoystick()
    if joystickGui then joystickGui:Destroy() end
    joystickGui = nil
    joystickThumb = nil
    joystickBg = nil
end

local function startFly()
    if flying then return end
    flying = true
    createJoystick()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.PlatformStand = true
    end
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
    flyBodyVelocity.Parent = char:FindFirstChild("HumanoidRootPart")
    -- 飞行循环
    task.spawn(function()
        while flying do
            if not flyBodyVelocity or not flyBodyVelocity.Parent then break end
            local dir = Vector3.new(joystickDirection.X, 0, -joystickDirection.Y)
            if dir.Magnitude > 0 then
                local camCF = Camera.CFrame
                local right = camCF.RightVector
                local forward = camCF.LookVector
                local moveDir = (right * dir.X + forward * dir.Z).Unit
                flyBodyVelocity.Velocity = moveDir * flySpeed
            else
                flyBodyVelocity.Velocity = Vector3.new(0,0,0)
            end
            task.wait()
        end
    end)
    WindUI:Notify({Title = "飞行", Content = "使用摇杆移动，点击[降落]停止", Duration = 3})
end

local function stopFly()
    if not flying then return end
    flying = false
    if flyBodyVelocity then flyBodyVelocity:Destroy() end
    flyBodyVelocity = nil
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
    destroyJoystick()
    WindUI:Notify({Title = "飞行", Content = "已降落", Duration = 2})
end

-- 飞行开关（UI按钮触发）
local function toggleFly()
    if flying then stopFly() else startFly() end
end

-- ================= 超高跳跃 & 连跳 =================
local jumpActive = false
local jumpPower = 120
local autoJump = false   -- 连续跳跃（按住空格自动连跳）
local jumpConn = nil

local function applyJumpMods()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.JumpPower = jumpPower
        if autoJump then
            if not jumpConn then
                jumpConn = UserInputService.JumpRequest:Connect(function()
                    if humanoid and humanoid.Health > 0 then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end)
            end
        elseif jumpConn then
            jumpConn:Disconnect()
            jumpConn = nil
        end
    end
end

local function resetJumpMods()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.JumpPower = 50
    end
    if jumpConn then
        jumpConn:Disconnect()
        jumpConn = nil
    end
end

local function startJumpMods()
    jumpActive = true
    applyJumpMods()
    WindUI:Notify({Title = "跳跃增强", Content = "已启用 (超高+连跳)", Duration = 2})
end

local function stopJumpMods()
    jumpActive = false
    resetJumpMods()
    WindUI:Notify({Title = "跳跃增强", Content = "已关闭", Duration = 2})
end

-- 监听角色重生重新应用
LocalPlayer.CharacterAdded:Connect(function()
    if jumpActive then
        task.wait(0.2)
        applyJumpMods()
    end
    if noclipActive then
        task.wait(0.2)
        applyNoclip()
    end
end)

-- ================= ESP（方框+名字+血条+距离）=================
local espActive = false
local espObjects = {}  -- 存储每个玩家的绘制对象
local function rgbToHex(r,g,b) return string.format("%02x%02x%02x", r*255, g*255, b*255) end

local function createEspForPlayer(player)
    if player == LocalPlayer then return end
    if espObjects[player] then return end
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Color = Color3.fromRGB(0, 255, 0)
    box.Visible = false
    local nameText = Drawing.new("Text")
    nameText.Size = 14
    nameText.Center = true
    nameText.Outline = true
    nameText.Color = Color3.fromRGB(255,255,255)
    nameText.Visible = false
    local healthText = Drawing.new("Text")
    healthText.Size = 12
    healthText.Center = true
    healthText.Outline = true
    healthText.Color = Color3.fromRGB(255,100,100)
    healthText.Visible = false
    local distText = Drawing.new("Text")
    distText.Size = 12
    distText.Center = true
    distText.Outline = true
    distText.Color = Color3.fromRGB(200,200,200)
    distText.Visible = false
    espObjects[player] = {box=box, name=nameText, health=healthText, dist=distText}
end

local function updateEsp()
    if not espActive then
        for _, data in pairs(espObjects) do
            data.box.Visible = false
            data.name.Visible = false
            data.health.Visible = false
            data.dist.Visible = false
        end
        return
    end
    for player, data in pairs(espObjects) do
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToScreenPoint(root.Position)
            if onScreen and pos.Z > 0 then
                local size = 200 / pos.Z  -- 根据距离缩放方框大小
                local boxSize = Vector2.new(size*1.5, size*2)
                local boxPos = Vector2.new(pos.X - boxSize.X/2, pos.Y - boxSize.Y/2)
                data.box.Size = boxSize
                data.box.Position = boxPos
                data.box.Visible = true
                -- 名字
                data.name.Text = player.Name
                data.name.Position = Vector2.new(pos.X, pos.Y - boxSize.Y/2 - 10)
                data.name.Visible = true
                -- 血量
                local hum = player.Character:FindFirstChild("Humanoid")
                local hp = hum and hum.Health or 0
                data.health.Text = string.format("❤️ %.0f", hp)
                data.health.Position = Vector2.new(pos.X, pos.Y + boxSize.Y/2 + 5)
                data.health.Visible = true
                -- 距离
                local dist = (Camera.CFrame.Position - root.Position).Magnitude
                data.dist.Text = string.format("%.1fm", dist)
                data.dist.Position = Vector2.new(pos.X, pos.Y + boxSize.Y/2 + 20)
                data.dist.Visible = true
                -- 根据血量改变方框颜色
                if hp < 30 then
                    data.box.Color = Color3.fromRGB(255,0,0)
                elseif hp < 70 then
                    data.box.Color = Color3.fromRGB(255,165,0)
                else
                    data.box.Color = Color3.fromRGB(0,255,0)
                end
            else
                data.box.Visible = false
                data.name.Visible = false
                data.health.Visible = false
                data.dist.Visible = false
            end
        else
            data.box.Visible = false
            data.name.Visible = false
            data.health.Visible = false
            data.dist.Visible = false
        end
    end
end

local function startEsp()
    if espActive then return end
    espActive = true
    for _, plr in ipairs(Players:GetPlayers()) do
        createEspForPlayer(plr)
    end
    Players.PlayerAdded:Connect(createEspForPlayer)
    Players.PlayerRemoving:Connect(function(plr)
        if espObjects[plr] then
            espObjects[plr].box:Remove()
            espObjects[plr].name:Remove()
            espObjects[plr].health:Remove()
            espObjects[plr].dist:Remove()
            espObjects[plr] = nil
        end
    end)
    RunService.RenderStepped:Connect(updateEsp)
    WindUI:Notify({Title = "ESP", Content = "已开启透视", Duration = 2})
end

local function stopEsp()
    espActive = false
    for _, data in pairs(espObjects) do
        data.box.Visible = false
        data.name.Visible = false
        data.health.Visible = false
        data.dist.Visible = false
    end
    WindUI:Notify({Title = "ESP", Content = "已关闭", Duration = 2})
end

-- ================= UI 构建 =================
local tabs = {
    player = Window:Tab({Title = "玩家追杀", Icon = "skull"}),
    shield = Window:Tab({Title = "护盾攻击", Icon = "shield"}),
    movement = Window:Tab({Title = "移动增强", Icon = "square"}),
    espTab = Window:Tab({Title = "透视ESP", Icon = "eye"}),
    misc = Window:Tab({Title = "其他", Icon = "settings"})
}

-- 玩家追杀界面
local pCtrl = tabs.player:Section({Title = "控制"})
pCtrl:Toggle({Title = "开启玩家追杀", Value = false, Callback = function(s) if s then startPlayer() else stopPlayer() end end})
pCtrl:Slider({Title = "攻击间隔(秒)", Value = {Min=0.1, Max=2, Default=PLAYER_INTERVAL}, Step=0.05, Callback=function(v) playerInterval=v end})
-- 固定目标模式
local targetDropdown = nil
local function refreshPlayerList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(list, p.Name) end
    end
    if targetDropdown then
        targetDropdown:Refresh(list)
    end
end
pCtrl:Divider()
pCtrl:Paragraph({Title="固定目标模式", Desc="开启后只攻击选中的玩家"})
local fixedToggle = pCtrl:Toggle({Title="启用固定目标", Value=false, Callback=function(s) isFixedMode = s end})
targetDropdown = pCtrl:Dropdown({Title="选择玩家", Values={}, Multi=false, Callback=function(val) fixedTargetName = val end})
refreshPlayerList()
Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(refreshPlayerList)

local pStatus = tabs.player:Section({Title = "状态"})
local pState = pStatus:Paragraph({Title="当前状态", Desc="● 未开启", Image="circle-off", Color="Grey"})
local pCount = pStatus:Paragraph({Title="目标玩家数", Desc="0", Image="users"})
task.spawn(function()
    while true do
        if playerActive then
            local c = isFixedMode and (fixedTargetName and 1 or 0) or (#Players:GetPlayers()-1)
            pCount:SetDesc(tostring(c))
            pState:SetDesc("● 攻击中")
            pState:SetColor("Red")
        else
            pCount:SetDesc(tostring(#Players:GetPlayers()-1))
            pState:SetDesc("● 未开启")
            pState:SetColor("Grey")
        end
        task.wait(1)
    end
end)

-- 护盾攻击界面
local sCtrl = tabs.shield:Section({Title = "控制"})
sCtrl:Toggle({Title="开启护盾攻击", Value=false, Callback=function(s) if s then startShield() else stopShield() end end})
sCtrl:Slider({Title="攻击间隔(秒)", Value={Min=0.1,Max=2,Default=SHIELD_INTERVAL}, Step=0.05, Callback=function(v) shieldInterval=v end})
local sStatus = tabs.shield:Section({Title="状态"})
local sState = sStatus:Paragraph({Title="当前状态", Desc="● 未开启", Image="circle-off", Color="Grey"})
local sCount = sStatus:Paragraph({Title="目标护盾数", Desc="0", Image="shield"})
task.spawn(function()
    while true do
        if shieldActive then
            local c = 0
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and getShieldPart(p) then c=c+1 end
            end
            sCount:SetDesc(tostring(c))
            sState:SetDesc("● 攻击中")
            sState:SetColor("Red")
        else
            local c = 0
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and getShieldPart(p) then c=c+1 end
            end
            sCount:SetDesc(tostring(c))
            sState:SetDesc("● 未开启")
            sState:SetColor("Grey")
        end
        task.wait(1)
    end
end)

-- 移动增强（穿墙+飞行+跳跃）
local mSection = tabs.movement:Section({Title="穿墙"})
mSection:Toggle({Title="开启穿墙", Value=false, Callback=function(s) if s then startNoclip() else stopNoclip() end end})
mSection:Slider({Title="穿墙移动速度", Value={Min=8,Max=80,Default=16}, Step=1, Callback=function(v) noclipSpeed=v; if noclipActive then applyNoclip() end end})

local flySection = tabs.movement:Section({Title="飞行"})
flySection:Button({Title="起飞 (摇杆控制)", Callback=toggleFly})
flySection:Button({Title="降落", Callback=stopFly})
flySection:Slider({Title="飞行速度", Value={Min=20,Max=120,Default=40}, Step=2, Callback=function(v) flySpeed=v end})

local jumpSection = tabs.movement:Section({Title="跳跃增强"})
jumpSection:Toggle({Title="开启超高跳跃+连跳", Value=false, Callback=function(s) if s then startJumpMods() else stopJumpMods() end end})
jumpSection:Slider({Title="跳跃高度", Value={Min=80,Max=300,Default=120}, Step=10, Callback=function(v) jumpPower=v; if jumpActive then applyJumpMods() end end})

-- ESP 界面
local espSection = tabs.espTab:Section({Title="透视设置"})
espSection:Toggle({Title="开启ESP", Value=false, Callback=function(s) if s then startEsp() else stopEsp() end end})

-- 其他（备用）
local other = tabs.misc:Section({Title="说明"})
other:Paragraph({Title="版本", Desc="全能杀戮光环 v3.0\n密码: NB666\n功能: 玩家追杀/护盾/穿墙/飞行/超高跳/ESP/固定目标"})

Window:OnClose(function()
    playerActive = false; shieldActive = false
    if noclipActive then stopNoclip() end
    if flying then stopFly() end
    if jumpActive then stopJumpMods() end
    if espActive then stopEsp() end
    if playerTask then task.cancel(playerTask) end
    if shieldTask then task.cancel(shieldTask) end
end)

print("全能杀戮光环已加载 | 密码 NB666 | 摇杆飞行/ESP/固定目标已就绪")
