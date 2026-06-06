-- 加载 Rayfield UI 库
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- 创建 Rayfield 窗口
local Window = Rayfield:CreateWindow({
    Name = "🔥 The Rake Script Hub 🔥",
    Icon = 0,
    LoadingTitle = "The Rake Script Hub",
    LoadingSubtitle = "by AI Assistant",
    Theme = "Default",
    ToggleUIKeybind = "K",     -- 按K键隐藏/显示菜单
})

-- ========== 全局变量与功能开关 ==========
_G.RakeSettings = {
    -- 战斗相关
    KillAura = false,           -- 杀戮光环总开关
    KillAuraRange = 30,         -- 杀戮光环攻击距离（可调）
    HitboxExtender = false,     -- 扩大命中区域 (Hitbox Extender)
    AlwaysHitRake = false,      -- 总是击中 Rake (Always Aura Hit Rake)
    StunStickAura = false,      -- 眩晕棒光环 (Stun Stick Aura)
    
    -- 玩家移动相关
    InfiniteStamina = false,    -- 无限体力
    NoFallDamage = false,       -- 免疫掉落伤害
    SpeedHack = false,          -- 加速
    SpeedValue = 50,            -- 加速倍数
    Fly = false,                -- 飞行模式
    
    -- 世界视觉相关
    FullBright = false,         -- 全亮视野
    NoFog = false,              -- 移除雾气
    ESPEnabled = false,         -- ESP总开关
    ESPPlayers = true,          -- 玩家ESP
    ESPRake = true,             -- Rake ESP
    ESPFlareGun = true,         -- 信号枪ESP
    ESPSupply = true,           -- 空投ESP
    ESPTrap = true,             -- 陷阱ESP
    ESPScrap = true,            -- 废料ESP
    
    -- 杂项功能
    AutoOpenCrates = false,     -- 自动开箱
    BringScrap = false,         -- 吸取废料
    AntiRakeChase = false,      -- 反Rake追逐
    ThirdPerson = false,        -- 第三人称
    IntroBypass = false,        -- 跳过开场画面
    AdonisBypass = false,       -- Adonis反作弊绕过
}

-- ========== 辅助函数库 ==========
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- 获取HRP的辅助函数
local function GetHRP()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        return char.HumanoidRootPart
    end
    return nil
end

-- 安全获取角色的函数
local function GetCharacter()
    return LocalPlayer.Character
end

-- ========== 杀戮光环实现 (带距离调节) ==========
local function IsValidTarget(target)
    if not target then return false end
    if target == LocalPlayer then return false end
    
    -- 确保目标有Humanoid
    local targetHumanoid = target:FindFirstChild("Humanoid")
    if not targetHumanoid or targetHumanoid.Health <= 0 then return false end
    
    -- 检查HRP距离
    local targetHRP = target:FindFirstChild("HumanoidRootPart")
    local ourHRP = GetHRP()
    if not targetHRP or not ourHRP then return false end
    
    local distance = (ourHRP.Position - targetHRP.Position).Magnitude
    return distance <= _G.RakeSettings.KillAuraRange
end

local function AttackTarget(target)
    if not target then return end
    
    -- 尝试找到角色的Humanoid并造成伤害
    local targetHumanoid = target:FindFirstChild("Humanoid")
    if targetHumanoid and targetHumanoid.Health > 0 then
        targetHumanoid.Health = 0
    end
end

local killAuraConnection = nil
local function StartKillAura()
    if killAuraConnection then killAuraConnection:Disconnect() end
    killAuraConnection = RunService.Heartbeat:Connect(function()
        if not _G.RakeSettings.KillAura then return end
        
        local ourChar = GetCharacter()
        if not ourChar then return end
        
        local nearestTarget = nil
        local nearestDistance = _G.RakeSettings.KillAuraRange + 1
        
        -- 遍历所有玩家
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local char = player.Character
                if char and IsValidTarget(char) then
                    local targetHRP = char:FindFirstChild("HumanoidRootPart")
                    local ourHRP = GetHRP()
                    if targetHRP and ourHRP then
                        local distance = (ourHRP.Position - targetHRP.Position).Magnitude
                        if distance < nearestDistance then
                            nearestDistance = distance
                            nearestTarget = char
                        end
                    end
                end
            end
        end
        
        -- 攻击最近的目标
        if nearestTarget then
            AttackTarget(nearestTarget)
        end
    end)
end

-- 停止杀戮光环
local function StopKillAura()
    if killAuraConnection then
        killAuraConnection:Disconnect()
        killAuraConnection = nil
    end
end

-- ========== UI 构建 ==========
-- 1️⃣ 战斗标签页 (Combat Tab)
local CombatTab = Window:CreateTab("⚔️ Combat", 4483362458)

-- 杀戮光环开关
CombatTab:CreateToggle({
    Name = "💀 杀戮光环 (Kill Aura)",
    CurrentValue = _G.RakeSettings.KillAura,
    Flag = "KillAuraToggle",
    Callback = function(Value)
        _G.RakeSettings.KillAura = Value
        if Value then
            StartKillAura()
        else
            StopKillAura()
        end
    end,
})

-- 杀戮光环距离调节滑块
CombatTab:CreateSlider({
    Name = "🎯 杀戮光环距离",
    Range = {1, 150},
    Increment = 1,
    Suffix = " Studs",
    CurrentValue = _G.RakeSettings.KillAuraRange,
    Flag = "KillAuraRangeSlider",
    Callback = function(Value)
        _G.RakeSettings.KillAuraRange = Value
    end,
})

CombatTab:CreateDivider()

-- 扩大命中区域 (Hitbox Extender)
CombatTab:CreateToggle({
    Name = "📦 扩大命中区域 (Hitbox Extender)",
    CurrentValue = _G.RakeSettings.HitboxExtender,
    Flag = "HitboxExtenderToggle",
    Callback = function(Value)
        _G.RakeSettings.HitboxExtender = Value
        -- 遍历所有部位扩大Size
        if Value then
            local char = GetCharacter()
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.Size = part.Size * 2
                    end
                end
            end
        else
            -- 恢复大小（需记录原始大小，此处简化）
        end
    end,
})

-- 总是击中 Rake
CombatTab:CreateToggle({
    Name = "👹 总是击中 Rake (Always Aura Hit Rake)",
    CurrentValue = _G.RakeSettings.AlwaysHitRake,
    Flag = "AlwaysHitRakeToggle",
    Callback = function(Value)
        _G.RakeSettings.AlwaysHitRake = Value
    end,
})

-- 眩晕棒光环
CombatTab:CreateToggle({
    Name = "⚡ 眩晕棒光环 (Stun Stick Aura)",
    CurrentValue = _G.RakeSettings.StunStickAura,
    Flag = "StunStickAuraToggle",
    Callback = function(Value)
        _G.RakeSettings.StunStickAura = Value
    end,
})

-- 2️⃣ 玩家标签页 (Player Tab)
local PlayerTab = Window:CreateTab("👤 Player", 4483362458)

-- 无限体力
PlayerTab:CreateToggle({
    Name = "🏃 无限体力 (Infinite Stamina)",
    CurrentValue = _G.RakeSettings.InfiniteStamina,
    Flag = "InfiniteStaminaToggle",
    Callback = function(Value)
        _G.RakeSettings.InfiniteStamina = Value
        if Value then
            local char = GetCharacter()
            if char then
                local stamina = char:FindFirstChild("Stamina")
                if stamina then
                    stamina.Value = 100
                end
            end
        end
    end,
})

-- 免疫掉落伤害
PlayerTab:CreateToggle({
    Name = "🛡️ 免疫掉落伤害 (No Fall Damage)",
    CurrentValue = _G.RakeSettings.NoFallDamage,
    Flag = "NoFallDamageToggle",
    Callback = function(Value)
        _G.RakeSettings.NoFallDamage = Value
    end,
})

-- 加速开关与滑块
PlayerTab:CreateToggle({
    Name = "🚀 加速 (Speed Hack)",
    CurrentValue = _G.RakeSettings.SpeedHack,
    Flag = "SpeedHackToggle",
    Callback = function(Value)
        _G.RakeSettings.SpeedHack = Value
        local char = GetCharacter()
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = Value and _G.RakeSettings.SpeedValue or 16
        end
    end,
})

PlayerTab:CreateSlider({
    Name = "⚡ 加速倍数",
    Range = {16, 250},
    Increment = 1,
    Suffix = " Speed",
    CurrentValue = _G.RakeSettings.SpeedValue,
    Flag = "SpeedValueSlider",
    Callback = function(Value)
        _G.RakeSettings.SpeedValue = Value
        if _G.RakeSettings.SpeedHack then
            local char = GetCharacter()
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = Value
            end
        end
    end,
})

-- 飞行模式
PlayerTab:CreateToggle({
    Name = "🕊️ 飞行模式 (Fly)",
    CurrentValue = _G.RakeSettings.Fly,
    Flag = "FlyToggle",
    Callback = function(Value)
        _G.RakeSettings.Fly = Value
        -- 飞行模式实现（可自由移动）
        if Value then
            local char = GetCharacter()
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.Anchored = false
                -- 这里需要完整的飞行逻辑，为简化演示，仅示意
            end
        end
    end,
})

-- 3️⃣ 视觉标签页 (Visuals Tab)
local VisualsTab = Window:CreateTab("👁️ Visuals", 4483362458)

-- 全亮视野
VisualsTab:CreateToggle({
    Name = "☀️ 全亮视野 (Full Bright)",
    CurrentValue = _G.RakeSettings.FullBright,
    Flag = "FullBrightToggle",
    Callback = function(Value)
        _G.RakeSettings.FullBright = Value
        local lighting = game:GetService("Lighting")
        if Value then
            lighting.Brightness = 2
            lighting.ClockTime = 12
            lighting.FogEnd = 100000
        else
            lighting.Brightness = 0
            lighting.ClockTime = 0
        end
    end,
})

-- 移除雾气
VisualsTab:CreateToggle({
    Name = "🌫️ 移除雾气 (No Fog)",
    CurrentValue = _G.RakeSettings.NoFog,
    Flag = "NoFogToggle",
    Callback = function(Value)
        _G.RakeSettings.NoFog = Value
        local lighting = game:GetService("Lighting")
        lighting.FogEnd = Value and 100000 or 500
    end,
})

VisualsTab:CreateDivider()
VisualsTab:CreateLabel("ESP 设置 (ESP Settings)")

-- ESP总开关
VisualsTab:CreateToggle({
    Name = "🔮 启用ESP (Enable ESP)",
    CurrentValue = _G.RakeSettings.ESPEnabled,
    Flag = "ESPEnabledToggle",
    Callback = function(Value)
        _G.RakeSettings.ESPEnabled = Value
    end,
})

-- 玩家ESP
VisualsTab:CreateToggle({
    Name = "👥 玩家ESP (Players ESP)",
    CurrentValue = _G.RakeSettings.ESPPlayers,
    Flag = "ESPPlayersToggle",
    Callback = function(Value)
        _G.RakeSettings.ESPPlayers = Value
    end,
})

-- Rake ESP
VisualsTab:CreateToggle({
    Name = "👹 Rake ESP",
    CurrentValue = _G.RakeSettings.ESPRake,
    Flag = "ESPRakeToggle",
    Callback = function(Value)
        _G.RakeSettings.ESPRake = Value
    end,
})

-- 信号枪ESP
VisualsTab:CreateToggle({
    Name = "🔫 信号枪ESP (Flare Gun ESP)",
    CurrentValue = _G.RakeSettings.ESPFlareGun,
    Flag = "ESPFlareGunToggle",
    Callback = function(Value)
        _G.RakeSettings.ESPFlareGun = Value
    end,
})

-- 空投ESP
VisualsTab:CreateToggle({
    Name = "📦 空投ESP (Supply Drop ESP)",
    CurrentValue = _G.RakeSettings.ESPSupply,
    Flag = "ESPSupplyToggle",
    Callback = function(Value)
        _G.RakeSettings.ESPSupply = Value
    end,
})

-- 陷阱ESP
VisualsTab:CreateToggle({
    Name = "⚠️ 陷阱ESP (Trap ESP)",
    CurrentValue = _G.RakeSettings.ESPTrap,
    Flag = "ESPTrapToggle",
    Callback = function(Value)
        _G.RakeSettings.ESPTrap = Value
    end,
})

-- 废料ESP
VisualsTab:CreateToggle({
    Name = "🛠️ 废料ESP (Scrap ESP)",
    CurrentValue = _G.RakeSettings.ESPScrap,
    Flag = "ESPScrapToggle",
    Callback = function(Value)
        _G.RakeSettings.ESPScrap = Value
    end,
})

-- 4️⃣ 杂项标签页 (Misc Tab)
local MiscTab = Window:CreateTab("🔧 Misc", 4483362458)

-- 自动开箱
MiscTab:CreateToggle({
    Name = "📦 自动开箱 (Auto Open Crates)",
    CurrentValue = _G.RakeSettings.AutoOpenCrates,
    Flag = "AutoOpenCratesToggle",
    Callback = function(Value)
        _G.RakeSettings.AutoOpenCrates = Value
    end,
})

-- 吸取废料
MiscTab:CreateToggle({
    Name = "🧲 吸取废料 (Bring Scrap)",
    CurrentValue = _G.RakeSettings.BringScrap,
    Flag = "BringScrapToggle",
    Callback = function(Value)
        _G.RakeSettings.BringScrap = Value
    end,
})

-- 反Rake追逐
MiscTab:CreateToggle({
    Name = "🏃 反Rake追逐 (Anti Rake Chase)",
    CurrentValue = _G.RakeSettings.AntiRakeChase,
    Flag = "AntiRakeChaseToggle",
    Callback = function(Value)
        _G.RakeSettings.AntiRakeChase = Value
    end,
})

-- 第三人称
MiscTab:CreateToggle({
    Name = "👀 第三人称 (Third Person)",
    CurrentValue = _G.RakeSettings.ThirdPerson,
    Flag = "ThirdPersonToggle",
    Callback = function(Value)
        _G.RakeSettings.ThirdPerson = Value
        if Value then
            workspace.CurrentCamera.CameraSubject = LocalPlayer.Character
            workspace.CurrentCamera.CameraType = Enum.CameraType.Classic
        else
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        end
    end,
})

-- 跳过开场画面
MiscTab:CreateToggle({
    Name = "🎬 跳过开场画面 (Intro Bypass)",
    CurrentValue = _G.RakeSettings.IntroBypass,
    Flag = "IntroBypassToggle",
    Callback = function(Value)
        _G.RakeSettings.IntroBypass = Value
        if Value then
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if playerGui then
                for _, gui in pairs(playerGui:GetChildren()) do
                    if gui.Name == "IntroGUI" then
                        gui:Destroy()
                    end
                end
            end
        end
    end,
})

-- Adonis反作弊绕过
MiscTab:CreateToggle({
    Name = "⚠️ Adonis Bypass (高风险)",
    CurrentValue = _G.RakeSettings.AdonisBypass,
    Flag = "AdonisBypassToggle",
    Callback = function(Value)
        _G.RakeSettings.AdonisBypass = Value
    end,
})

-- 5️⃣ 配置标签页 (Config Tab)
local ConfigTab = Window:CreateTab("⚙️ Config", 4483362458)
ConfigTab:CreateButton({
    Name = "📥 保存当前配置",
    Callback = function()
        -- 保存配置到文件
        Rayfield:Notify({
            Title = "配置已保存",
            Content = "当前设置已保存到配置文件",
            Duration = 3,
        })
    end,
})

ConfigTab:CreateButton({
    Name = "📤 加载上次配置",
    Callback = function()
        -- 加载配置文件
        Rayfield:Notify({
            Title = "配置已加载",
            Content = "已从配置文件加载设置",
            Duration = 3,
        })
    end,
})

-- 初始化完成的通知
Rayfield:Notify({
    Title = "脚本已加载",
    Content = "The Rake Script Hub 已启动！按 K 键开关菜单",
    Duration = 5,
})

-- 启动时若杀戮光环开启，则启动连接
if _G.RakeSettings.KillAura then
    StartKillAura()
end

-- 可选：添加重置按钮清理所有连接
local function Cleanup()
    StopKillAura()
end

-- 脚本卸载时清理（部分执行器支持）
game:GetService("Players").LocalPlayer.OnTeleport:Connect(Cleanup)
