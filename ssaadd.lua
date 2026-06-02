-- ================= 加载 WindUI 库 =================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- ================= 配置参数（可调）=================
local PLAYER_ATTACK_INTERVAL = 0.5      -- 玩家攻击间隔（秒/轮）
local SHIELD_ATTACK_INTERVAL = 0.5      -- 护盾攻击间隔（秒/轮）
local TARGET_PARTS = {"HumanoidRootPart", "Head"}  -- 攻击玩家的优先部位

-- ================= 创建主窗口（密码系统）=================
local Window = WindUI:CreateWindow({
    Title = "⚡ 全能杀戮光环",
    Icon = "sword",
    IconThemed = true,
    Author = "私人服务器",
    Folder = "AuraTools",
    Size = UDim2.fromOffset(560, 480),
    Transparent = true,
    Theme = "Dark",
    User = { Enabled = false },
    SideBarWidth = 200,
    ScrollBarEnabled = true,
    KeySystem = {
        Key = { "NB666" },               -- 密码改为 NB666
        Note = "请输入密码以使用本工具",
        SaveKey = true,
    },
})

-- 可选：隐藏悬浮按钮（保持干净）
Window:EditOpenButton({ Enabled = false })

-- ================= 创建两个标签页 =================
local PlayerTab = Window:Tab({ Title = "玩家追杀", Icon = "skull" })
local ShieldTab = Window:Tab({ Title = "护盾攻击", Icon = "shield" })

-- ================= 公共变量与核心功能 =================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RocketHitEvent = ReplicatedStorage:WaitForChild("RocketSystem"):WaitForChild("Events"):WaitForChild("RocketHit")

-- 辅助函数：获取本地 RPG 工具
local function getLocalRPG()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("RPG")
end

-- 辅助函数：获取本地角色根部位置
local function getLocalOrigin()
    local char = LocalPlayer.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    return root and root.Position or nil
end

-- ================= 1. 玩家追杀功能（杀戮光环）=================
local playerActive = false
local playerTask = nil
local playerInterval = PLAYER_ATTACK_INTERVAL

-- 获取目标玩家的可命中部件和位置
local function getTargetHitPart(targetPlayer)
    local character = targetPlayer.Character
    if not character then return nil, nil end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return nil, nil end
    for _, partName in ipairs(TARGET_PARTS) do
        local part = character:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            return part, part.Position
        end
    end
    return nil, nil
end

-- 攻击单个玩家
local function attackPlayer(targetPlayer)
    if not playerActive then return end
    if targetPlayer == LocalPlayer then return end
    local hitPart, hitPos = getTargetHitPart(targetPlayer)
    if not hitPart then return end
    local rpg = getLocalRPG()
    if not rpg then return end
    local origin = getLocalOrigin()
    if not origin then return end
    local normal = Vector3.new(0, 1, 0)
    local args = {{
        Normal = normal,
        Player = targetPlayer,
        HitPart = hitPart,
        Origin = origin,
        Label = "PlayerAura_" .. tostring(os.clock()) .. "_" .. math.random(10000),
        Vehicle = rpg,
        Position = hitPos,
        Weapon = rpg
    }}
    pcall(function() RocketHitEvent:FireServer(unpack(args)) end)
end

-- 玩家攻击主循环
local function playerAttackLoop()
    while playerActive do
        local players = Players:GetPlayers()
        local count = #players - 1
        for _, plr in ipairs(players) do
            if not playerActive then break end
            if plr ~= LocalPlayer then
                attackPlayer(plr)
                task.wait(playerInterval / math.max(1, count))
            end
        end
        task.wait(0.1)
    end
end

local function startPlayerAura()
    if playerTask then task.cancel(playerTask) end
    playerActive = true
    playerTask = task.spawn(playerAttackLoop)
    WindUI:Notify({ Title = "玩家追杀", Content = "已开启", Duration = 2, Icon = "skull" })
end

local function stopPlayerAura()
    playerActive = false
    if playerTask then task.cancel(playerTask); playerTask = nil end
    WindUI:Notify({ Title = "玩家追杀", Content = "已关闭", Duration = 2, Icon = "shield-off" })
end

-- ================= 2. 护盾攻击功能 =================
local shieldActive = false
local shieldTask = nil
local shieldInterval = SHIELD_ATTACK_INTERVAL
local SHIELD_PARTS = {"Shield1"}   -- 可根据需要添加 "Shield2" 等

-- 获取指定玩家的基地护盾部件
local function getPlayerShield(player)
    if player == LocalPlayer then return nil end
    local tycoon = workspace:FindFirstChild("Tycoon")
    if not tycoon then return nil end
    local tycoons = tycoon:FindFirstChild("Tycoons")
    if not tycoons then return nil end
    local playerTycoon = tycoons:FindFirstChild(player.Name)
    if not playerTycoon then return nil end
    local purchased = playerTycoon:FindFirstChild("PurchasedObjects")
    if not purchased then return nil end
    local baseShield = purchased:FindFirstChild("Base Shield")
    if not baseShield then return nil end
    local shield = baseShield:FindFirstChild("Shield")
    if not shield then return nil end
    for _, partName in ipairs(SHIELD_PARTS) do
        local part = shield:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            return part
        end
    end
    return nil
end

-- 获取所有在线玩家的护盾列表
local function getAllShields()
    local shields = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local shieldPart = getPlayerShield(player)
            if shieldPart then
                table.insert(shields, {player = player, part = shieldPart})
            end
        end
    end
    return shields
end

-- 攻击单个护盾
local function attackShield(targetPlayer, hitPart)
    if not shieldActive then return end
    local rpg = getLocalRPG()
    if not rpg then return end
    local origin = getLocalOrigin()
    if not origin then return end
    local hitPos = hitPart.Position
    local normal = Vector3.new(0, 1, 0)
    local args = {{
        Normal = normal,
        Player = targetPlayer,
        HitPart = hitPart,
        Origin = origin,
        Label = targetPlayer.Name .. "Shield_" .. tostring(os.clock()) .. "_" .. math.random(10000),
        Vehicle = rpg,
        Position = hitPos,
        Weapon = rpg
    }}
    pcall(function() RocketHitEvent:FireServer(unpack(args)) end)
end

-- 护盾攻击主循环
local function shieldAttackLoop()
    while shieldActive do
        local shields = getAllShields()
        local count = #shields
        for _, info in ipairs(shields) do
            if not shieldActive then break end
            attackShield(info.player, info.part)
            task.wait(shieldInterval / math.max(1, count))
        end
        task.wait(0.1)
    end
end

local function startShieldAura()
    if shieldTask then task.cancel(shieldTask) end
    shieldActive = true
    shieldTask = task.spawn(shieldAttackLoop)
    WindUI:Notify({ Title = "护盾攻击", Content = "已开启", Duration = 2, Icon = "shield" })
end

local function stopShieldAura()
    shieldActive = false
    if shieldTask then task.cancel(shieldTask); shieldTask = nil end
    WindUI:Notify({ Title = "护盾攻击", Content = "已关闭", Duration = 2, Icon = "shield-off" })
end

-- ================= UI 构建：玩家追杀标签页 =================
local PlayerControlSection = PlayerTab:Section({ Title = "控制", Icon = "toggle-left" })
local PlayerStatusSection = PlayerTab:Section({ Title = "状态", Icon = "eye" })

-- 开关
PlayerControlSection:Toggle({
    Title = "开启玩家追杀",
    Desc = "自动攻击全图其他玩家的角色",
    Value = false,
    Callback = function(state)
        if state then startPlayerAura() else stopPlayerAura() end
    end
})

-- 攻击间隔滑块
PlayerControlSection:Slider({
    Title = "攻击间隔（秒）",
    Desc = "数值越小攻击越密集",
    Value = { Min = 0.1, Max = 2.0, Default = PLAYER_ATTACK_INTERVAL },
    Step = 0.05,
    Callback = function(value)
        playerInterval = value
    end
})

-- 状态显示
local playerStatusPara = PlayerStatusSection:Paragraph({
    Title = "当前状态",
    Desc = "● 未开启",
    Image = "circle-off",
    Color = "Grey",
})

local playerTargetCountPara = PlayerStatusSection:Paragraph({
    Title = "目标玩家数量",
    Desc = "0",
    Image = "users",
})

-- 实时更新玩家目标数量
task.spawn(function()
    while true do
        if playerActive then
            local count = #Players:GetPlayers() - 1
            playerTargetCountPara:SetDesc(tostring(count))
            playerStatusPara:SetDesc("● 攻击中")
            playerStatusPara:SetColor("Red")
        else
            playerTargetCountPara:SetDesc(tostring(#Players:GetPlayers() - 1))
            playerStatusPara:SetDesc("● 未开启")
            playerStatusPara:SetColor("Grey")
        end
        task.wait(1)
    end
end)

-- ================= UI 构建：护盾攻击标签页 =================
local ShieldControlSection = ShieldTab:Section({ Title = "控制", Icon = "toggle-left" })
local ShieldStatusSection = ShieldTab:Section({ Title = "状态", Icon = "eye" })

-- 开关
ShieldControlSection:Toggle({
    Title = "开启护盾攻击",
    Desc = "自动攻击全图其他玩家的基地护盾",
    Value = false,
    Callback = function(state)
        if state then startShieldAura() else stopShieldAura() end
    end
})

-- 攻击间隔滑块
ShieldControlSection:Slider({
    Title = "攻击间隔（秒）",
    Desc = "数值越小攻击越密集",
    Value = { Min = 0.1, Max = 2.0, Default = SHIELD_ATTACK_INTERVAL },
    Step = 0.05,
    Callback = function(value)
        shieldInterval = value
    end
})

-- 状态显示
local shieldStatusPara = ShieldStatusSection:Paragraph({
    Title = "当前状态",
    Desc = "● 未开启",
    Image = "circle-off",
    Color = "Grey",
})

local shieldTargetCountPara = ShieldStatusSection:Paragraph({
    Title = "目标护盾数量",
    Desc = "0",
    Image = "shield",
})

-- 实时更新护盾目标数量
task.spawn(function()
    while true do
        if shieldActive then
            local shields = getAllShields()
            shieldTargetCountPara:SetDesc(tostring(#shields))
            shieldStatusPara:SetDesc("● 攻击中")
            shieldStatusPara:SetColor("Red")
        else
            local shields = getAllShields()
            shieldTargetCountPara:SetDesc(tostring(#shields))
            shieldStatusPara:SetDesc("● 未开启")
            shieldStatusPara:SetColor("Grey")
        end
        task.wait(1)
    end
end)

-- ================= 窗口关闭时停止所有任务 =================
Window:OnClose(function()
    if playerActive then stopPlayerAura() end
    if shieldActive then stopShieldAura() end
end)

print("全能杀戮光环已加载，密码: NB666")
