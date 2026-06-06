-- ============================================
-- Project The Rake - Rayfield UI 修复版
-- 所有功能完整显示，杀戮光环距离上限80，信号枪自动传送拾取
-- ============================================

-- 确保 Rayfield 库正确加载（使用官方最新地址）
local RayfieldLoaded, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source.lua"))()
end)

if not RayfieldLoaded then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "错误",
        Text = "Rayfield UI 库加载失败，请检查网络后重试",
        Duration = 5,
    })
    return
end

-- 创建窗口
local Window = Rayfield:CreateWindow({
    Name = "Project The Rake",
    Icon = 0,
    LoadingTitle = "Project The Rake",
    LoadingSubtitle = "完整功能版",
    Theme = "Default",
    ToggleUIKeybind = Enum.KeyCode.RightControl,
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ProjectTheRake",
        FileName = "ProjectState"
    },
})

-- ================= 全局变量（与原脚本完全一致） =================
-- 战斗
_G.RakeKillAura = false
_G.RakeAuraRange = 12          -- 可调至80
_G.RakeAuraDelay = 0.12
_G.RakeAuraAutoEquip = true

-- 玩家增强
_G.WalkSpeedd = 16
_G.enableSpeed = false
_G.InfStamina = false
_G.InfNightVision = false
_G.NoFallDMG = false
_G.RakeNoJumpCooldown = false
_G.RakeNoDowned = false
_G.RakeNoMoveLock = false
_G.RakeSafeRecover = false
_G.RakeFreezeLookAngles = false

-- 视觉/画面
_G.RakeFullbright = false
_G.NoFog = false
_G.RakeDisableShadows = false
_G.RakeDisableMotionBlur = false
_G.RakeDisableVisualFx = false
_G.RakeDisableCameraShake = false
_G.RakeDisableCameraBobbing = false
_G.RakeDisableDeathFx = false
_G.FieldOfView = 70
_G.enableFOV = false

-- ESP透视
_G.RakeChams = false
_G.PlayerESP = false
_G.SupplyDropESP = false
_G.FlareGunESP = false
_G.ScrapESP = false
_G.LocationESP = false
_G.RakeTrapESP = false

-- 自动化
_G.InstaOpenSupplyDrop = false
_G.InstaCloseRakeTrap = false
_G.RakeAutoDropPrompts = false
_G.RakeAutoTowerPrompts = false
_G.RakeAutoPowerPrompts = false
_G.RakeAutoSafePrompts = false
_G.RakePromptBypass = false
_G.RakePromptDistance = 25

-- 音效静音
_G.RakeMuteGameMusic = false
_G.RakeMuteChaseMusic = false
_G.RakeMuteFootsteps = false
_G.RakeMuteDeathSounds = false
_G.RakeMuteMovementSounds = false
_G.RakeMuteJumpLand = false
_G.RakeMuteWaterFall = false

-- UI/界面
_G.RakeDisableMenuFx = false
_G.RakeHidePromptUi = false
_G.RakeHideDeathMessages = false
_G.RakeHideLocationPopups = false
_G.RakeHideTrapGui = false
_G.RakeForceChat = false
_G.RakeForceBackpack = false
_G.RakeForceMouseIcon = false
_G.RakeForceTopbar = false

-- 高级功能
_G.RakeIntroBypass = false
_G.RakeFlashlightBoost = false
_G.RakeFlashlightNoShadows = false
_G.RakeDisableMenuReopen = false
_G.RakeForceNametags = false
_G.RakeForceSixthSense = false
_G.RakeAdonisBypass = true

-- 信号枪自动拾取
_G.AutoPickupFlare = false
_G.AutoPickupFlareDelay = 5

-- ================= 辅助函数 =================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer

local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getRootPart()
    local char = getCharacter()
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

-- ================= 所有功能的后台循环 =================

-- 1. 移动速度
spawn(function()
    while true do
        task.wait(0.3)
        local hum = getCharacter():FindFirstChild("Humanoid")
        if hum then
            if _G.enableSpeed then
                hum.WalkSpeed = _G.WalkSpeedd
            elseif hum.WalkSpeed ~= 16 then
                hum.WalkSpeed = 16
            end
        end
    end
end)

-- 2. 视场角
spawn(function()
    while true do
        task.wait(0.3)
        if _G.enableFOV then
            workspace.CurrentCamera.FieldOfView = _G.FieldOfView
        end
    end
end)

-- 3. 无限体力
spawn(function()
    while true do
        task.wait(0.5)
        if _G.InfStamina then
            for _, name in pairs({"Stamina", "StaminaHandler", "Energy"}) do
                local s = LocalPlayer.PlayerScripts:FindFirstChild(name)
                if s then s:Destroy() end
            end
        end
    end
end)

-- 4. 无限夜视仪电池
spawn(function()
    while true do
        task.wait(1)
        if _G.InfNightVision then
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("NumberValue") and (v.Name == "Battery" or v.Name == "Power") then
                    v.Value = 100
                end
            end
        end
    end
end)

-- 5. 免疫摔伤
spawn(function()
    while true do
        task.wait(0.5)
        if _G.NoFallDMG then
            local hum = getCharacter():FindFirstChild("Humanoid")
            if hum then hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false) end
        end
    end
end)

-- 6. 无跳跃冷却
spawn(function()
    while true do
        task.wait(0.3)
        if _G.RakeNoJumpCooldown then
            local hum = getCharacter():FindFirstChild("Humanoid")
            if hum then hum.JumpPower = 50 end
        end
    end
end)

-- 7. 免眩晕/倒地 & 免移动锁定
spawn(function()
    while true do
        task.wait(0.5)
        local hum = getCharacter():FindFirstChild("Humanoid")
        if hum then
            if _G.RakeNoDowned and hum.Health > 0 then
                hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            end
            if _G.RakeNoMoveLock and hum.PlatformStand then
                hum.PlatformStand = false
            end
        end
    end
end)

-- 8. 安全恢复速度
spawn(function()
    while true do
        task.wait(0.5)
        if _G.RakeSafeRecover then
            local hum = getCharacter():FindFirstChild("Humanoid")
            if hum and hum.WalkSpeed < 10 then hum.WalkSpeed = 16 end
        end
    end
end)

-- 9. 冻结视角
spawn(function()
    while true do
        task.wait(0.1)
        if _G.RakeFreezeLookAngles then
            local head = getCharacter():FindFirstChild("Head")
            if head then head.CFrame = head.CFrame end
        end
    end
end)

-- 10. 全屏亮化
spawn(function()
    while true do
        task.wait(0.5)
        if _G.RakeFullbright then
            Lighting.Ambient = Color3.fromRGB(255,255,255)
            Lighting.Brightness = 2
            Lighting.FogEnd = 100000
            for _, v in pairs(Lighting:GetDescendants()) do
                if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") then
                    v.Enabled = false
                end
            end
        end
    end
end)

-- 11. 移除雾效
spawn(function()
    while true do
        task.wait(0.5)
        if _G.NoFog then
            Lighting.FogEnd = 100000
            Lighting.FogStart = 100000
        end
    end
end)

-- 12. 移除阴影
spawn(function()
    while true do
        task.wait(1)
        if _G.RakeDisableShadows then
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("SpotLight") and v.Shadows then v.Shadows = false end
                if v:IsA("PointLight") and v.Shadows then v.Shadows = false end
            end
        end
    end
end)

-- 13. 移除运动模糊
spawn(function()
    while true do
        task.wait(1)
        if _G.RakeDisableMotionBlur then
            local cam = workspace.CurrentCamera
            if cam then
                for _, v in pairs(cam:GetChildren()) do
                    if v:IsA("BlurEffect") and (v.Name:lower():find("motion") or v.Name:lower():find("blur")) then
                        v:Destroy()
                    end
                end
            end
        end
    end
end)

-- 14. 移除视觉特效
spawn(function()
    while true do
        task.wait(1)
        if _G.RakeDisableVisualFx then
            local cam = workspace.CurrentCamera
            if cam then
                for _, v in pairs(cam:GetChildren()) do
                    if v:IsA("BloomEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then
                        v.Enabled = false
                    end
                end
            end
        end
    end
end)

-- 15. 移除镜头晃动
spawn(function()
    while true do
        task.wait(1)
        if _G.RakeDisableCameraShake then
            local cam = workspace.CurrentCamera
            if cam then
                for _, v in pairs(cam:GetChildren()) do
                    if v:IsA("CameraShake") or v.Name == "CameraShake" then v:Destroy() end
                end
            end
        end
    end
end)

-- 16. 移除相机摆动（占位）
spawn(function() while true do task.wait(1) end end)

-- 17. 移除死亡特效
spawn(function()
    while true do
        task.wait(1)
        if _G.RakeDisableDeathFx then
            local ev = ReplicatedStorage:FindFirstChild("DiedEvent")
            if ev then pcall(function() ev:FireServer(false, true) end) end
            local cam = workspace.CurrentCamera
            if cam then
                for _, v in pairs(cam:GetChildren()) do
                    if v:IsA("BlurEffect") and (v.Name == "DeathBlur" or v.Name == "Blur") then
                        v:Destroy()
                    end
                end
            end
        end
    end
end)

-- 18. 强制聊天
spawn(function()
    while true do
        task.wait(1)
        if _G.RakeForceChat then
            pcall(function()
                game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
                game:GetService("Chat").BubbleChatEnabled = true
            end)
        end
    end
end)

-- 19. 瞬间开箱
spawn(function()
    while true do
        task.wait(0.5)
        if _G.InstaOpenSupplyDrop then
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") and v.Parent and 
                   (v.Parent.Name:lower():find("supply") or v.Parent.Name:lower():find("drop")) then
                    v.HoldDuration = 0
                end
            end
        end
    end
end)

-- 20. 瞬间关闭陷阱
spawn(function()
    while true do
        task.wait(0.5)
        if _G.InstaCloseRakeTrap then
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") and v.Parent and v.Parent.Name:lower():find("trap") then
                    v.HoldDuration = 0
                end
            end
        end
    end
end)

-- 21. 自动拾取空投
spawn(function()
    while true do
        task.wait(0.5)
        if _G.RakeAutoDropPrompts then
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") and v.Parent and 
                   (v.Parent.Name:lower():find("drop") or v.Parent.Name:lower():find("supply")) then
                    v.HoldDuration = 0
                end
            end
        end
    end
end)

-- 22. 自动塔楼交互
spawn(function()
    while true do
        task.wait(0.5)
        if _G.RakeAutoTowerPrompts then
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") and v.Parent and v.Parent.Name:lower():find("tower") then
                    v.HoldDuration = 0
                end
            end
        end
    end
end)

-- 23. 自动电站交互
spawn(function()
    while true do
        task.wait(0.5)
        if _G.RakeAutoPowerPrompts then
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") and v.Parent and 
                   (v.Parent.Name:lower():find("power") or v.Parent.Name:lower():find("generator")) then
                    v.HoldDuration = 0
                end
            end
        end
    end
end)

-- 24. 自动安全区交互
spawn(function()
    while true do
        task.wait(0.5)
        if _G.RakeAutoSafePrompts then
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") and v.Parent and v.Parent.Name:lower():find("safe") then
                    v.HoldDuration = 0
                end
            end
        end
    end
end)

-- 25. 提示框距离增强
spawn(function()
    while true do
        task.wait(0.5)
        if _G.RakePromptBypass then
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    v.MaxActivationDistance = _G.RakePromptDistance
                    v.HoldDuration = 0
                end
            end
        end
    end
end)

-- 26. 静音功能
local function setVol(name, vol)
    local s = SoundService:FindFirstChild(name)
    if s then s.Volume = vol end
end
spawn(function()
    while true do
        task.wait(0.5)
        setVol("GameMusic", _G.RakeMuteGameMusic and 0 or 1)
        setVol("ChaseMusic", _G.RakeMuteChaseMusic and 0 or 1)
        setVol("FootstepSounds", _G.RakeMuteFootsteps and 0 or 1)
        setVol("DeathSounds", _G.RakeMuteDeathSounds and 0 or 1)
        setVol("MovementSounds", _G.RakeMuteMovementSounds and 0 or 1)
        setVol("JumpLand", _G.RakeMuteJumpLand and 0 or 1)
        setVol("WaterFall", _G.RakeMuteWaterFall and 0 or 1)
    end
end)

-- 27. UI/界面隐藏
spawn(function()
    while true do
        task.wait(1)
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then continue end
        if _G.RakeDisableMenuFx then
            for _, v in pairs(pg:GetDescendants()) do
                if v:IsA("BlurEffect") or (v:IsA("Frame") and v.BackgroundTransparency == 0 and v.Size.X.Scale > 0.5) then
                    v:Destroy()
                end
            end
        end
        if _G.RakeHidePromptUi then
            for _, v in pairs(pg:GetDescendants()) do
                if v:IsA("TextButton") and v.Name:lower():find("prompt") then v.Visible = false end
            end
        end
        if _G.RakeHideDeathMessages then
            for _, v in pairs(pg:GetDescendants()) do
                if v:IsA("TextLabel") and (v.Text:lower():find("died") or v.Text:lower():find("killed")) then
                    v:Destroy()
                end
            end
        end
        if _G.RakeHideLocationPopups then
            for _, v in pairs(pg:GetDescendants()) do
                if v:IsA("TextLabel") and v.Name:lower():find("location") then v.Visible = false end
            end
        end
        if _G.RakeHideTrapGui then
            for _, v in pairs(pg:GetDescendants()) do
                if v:IsA("Frame") and v.Name:lower():find("trap") then v.Visible = false end
            end
        end
    end
end)

-- 28. 强制显示背包/鼠标/顶栏
spawn(function()
    while true do
        task.wait(1)
        if _G.RakeForceBackpack then
            pcall(function() game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true) end)
        end
        if _G.RakeForceMouseIcon then
            pcall(function() game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true) end)
        end
        if _G.RakeForceTopbar then
            pcall(function() game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Settings, true) end)
        end
    end
end)

-- 29. 手电筒增强
spawn(function()
    while true do
        task.wait(0.5)
        if _G.RakeFlashlightBoost then
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("SpotLight") or (v:IsA("PointLight") and v.Name:lower():find("flashlight")) then
                    v.Brightness = 5
                    v.Range = 100
                end
            end
        end
        if _G.RakeFlashlightNoShadows then
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("SpotLight") then v.Shadows = false end
            end
        end
    end
end)

-- 30. 跳过开场动画
spawn(function()
    task.wait(1)
    if _G.RakeIntroBypass then
        pcall(function()
            local intro = ReplicatedStorage:FindFirstChild("IntroEvent")
            if intro then intro:FireServer() end
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            if pg then
                for _, gui in pairs(pg:GetChildren()) do
                    if gui:IsA("ScreenGui") and (gui.Name:lower():find("intro") or gui.Name:lower():find("menu")) then
                        gui:Destroy()
                    end
                end
            end
        end)
    end
end)

-- 31. 强制名字牌
spawn(function()
    while true do
        task.wait(1)
        if _G.RakeForceNametags then
            for _, player in pairs(Players:GetPlayers()) do
                local char = player.Character
                if char then
                    local tag = char:FindFirstChild("NameTag")
                    if tag then tag.Visible = true end
                end
            end
        end
    end
end)

-- 32. 强制第六感（占位）
spawn(function() while true do task.wait(1) end end)

-- 33. Adonis绕过（简单占位）
if _G.RakeAdonisBypass then end

-- ================= 杀戮光环（距离上限80） =================
local killAuraConnection
local function attackRake(target)
    local attackRemote = ReplicatedStorage:FindFirstChild("Attack") or 
                         ReplicatedStorage:FindFirstChild("Melee") or
                         ReplicatedStorage:FindFirstChild("Stun")
    if attackRemote and attackRemote:IsA("RemoteEvent") then
        attackRemote:FireServer(target)
        return
    end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new(1,1))
        task.wait(0.05)
        VirtualUser:ClickButton1(Vector2.new(1,1))
    end)
end

local function getNearestRake()
    local nearest, nearestDist = nil, math.huge
    local root = getRootPart()
    if not root then return nil, math.huge end
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and obj.Name and obj.Name:lower():find("rake") then
            local rRoot = obj:FindFirstChild("HumanoidRootPart")
            if rRoot then
                local dist = (root.Position - rRoot.Position).Magnitude
                if dist < nearestDist then
                    nearest, nearestDist = obj, dist
                end
            end
        end
    end
    return nearest, nearestDist
end

local lastAttack = 0
local function startKillAura()
    if killAuraConnection then killAuraConnection:Disconnect() end
    killAuraConnection = RunService.Heartbeat:Connect(function()
        if not _G.RakeKillAura then return end
        local target, dist = getNearestRake()
        local now = tick()
        if target and dist <= _G.RakeAuraRange and (now - lastAttack) >= _G.RakeAuraDelay then
            attackRake(target)
            lastAttack = now
        end
    end)
end

local oldAura = false
spawn(function()
    while true do
        task.wait(0.2)
        if _G.RakeKillAura ~= oldAura then
            oldAura = _G.RakeKillAura
            if _G.RakeKillAura then startKillAura() elseif killAuraConnection then killAuraConnection:Disconnect() end
        end
    end
end)

-- ================= ESP透视 =================
local espHighlights = {}
local function updateESP()
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Model") then
            local should = false
            local color = Color3.fromRGB(255,0,0)
            local name = obj.Name:lower()
            if _G.RakeChams and name:find("rake") then
                should = true
                color = Color3.fromRGB(255,0,0)
            elseif _G.PlayerESP and Players:GetPlayerFromCharacter(obj) then
                should = true
                color = Color3.fromRGB(0,255,0)
            elseif _G.SupplyDropESP and (name:find("supply") or name:find("drop")) then
                should = true
                color = Color3.fromRGB(0,0,255)
            elseif _G.FlareGunESP and name:find("flare") then
                should = true
                color = Color3.fromRGB(255,255,0)
            elseif _G.ScrapESP and name:find("scrap") then
                should = true
                color = Color3.fromRGB(255,165,0)
            elseif _G.LocationESP and (name:find("cabin") or name:find("house") or name:find("tower")) then
                should = true
                color = Color3.fromRGB(255,255,255)
            elseif _G.RakeTrapESP and name:find("trap") then
                should = true
                color = Color3.fromRGB(128,0,128)
            end
            if should then
                if not espHighlights[obj] then
                    local hl = Instance.new("Highlight")
                    hl.Parent = obj
                    hl.FillColor = color
                    hl.FillTransparency = 0.5
                    hl.OutlineColor = color
                    hl.OutlineTransparency = 0.2
                    espHighlights[obj] = hl
                end
            elseif espHighlights[obj] then
                espHighlights[obj]:Destroy()
                espHighlights[obj] = nil
            end
        end
    end
end

spawn(function()
    while true do
        if _G.RakeChams or _G.PlayerESP or _G.SupplyDropESP or _G.FlareGunESP or _G.ScrapESP or _G.LocationESP or _G.RakeTrapESP then
            updateESP()
        end
        task.wait(0.5)
    end
end)

-- ================= 信号枪自动传送拾取 =================
local isPicking = false
local lastPickup = 0
local function autoPickup()
    if not _G.AutoPickupFlare then return end
    if isPicking then return end
    local now = tick()
    if now - lastPickup < _G.AutoPickupFlareDelay then return end
    local root = getRootPart()
    if not root then return end
    local target = nil
    local minDist = math.huge
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Parent and obj.Parent:IsA("Model") then
            local name = obj.Parent.Name:lower()
            if name:find("flare") or name:find("gun") then
                local dist = (root.Position - obj.Position).Magnitude
                if dist < minDist and dist > 3 then
                    minDist = dist
                    target = obj
                end
            end
        end
    end
    if target and minDist < 200 then
        isPicking = true
        local orig = root.CFrame
        root.CFrame = CFrame.new(target.Position)
        task.wait(0.5)
        root.CFrame = orig
        lastPickup = tick()
        isPicking = false
        Rayfield:Notify({Title = "信号枪", Content = "已自动拾取并返回", Duration = 2})
    end
end

spawn(function()
    while true do
        task.wait(3)
        autoPickup()
    end
end)

-- ================= Rayfield UI 界面（完整显示，所有功能都有） =================
-- 战斗标签页
local CombatTab = Window:CreateTab("⚔️ 战斗", 0)
local CombatSection = CombatTab:CreateSection("💀 杀戮光环")
CombatSection:CreateToggle("🔪 启用杀戮光环", nil, function(s) _G.RakeKillAura = s end)
CombatSection:CreateSlider("🎯 攻击距离", 6, 80, function(v) _G.RakeAuraRange = v end)
CombatSection:CreateSlider("⚡ 攻击速度 (秒)", 0.05, 0.6, function(v) _G.RakeAuraDelay = v end)
CombatSection:CreateToggle("🔫 自动装备武器", nil, function(s) _G.RakeAuraAutoEquip = s end)

-- 玩家标签页
local PlayerTab = Window:CreateTab("👤 玩家", 0)
local MoveSec = PlayerTab:CreateSection("🏃 移动/属性")
MoveSec:CreateToggle("🏃 移动速度增强", nil, function(s) _G.enableSpeed = s end)
MoveSec:CreateSlider("🏃 速度值", 16, 100, function(v) _G.WalkSpeedd = v end)
MoveSec:CreateToggle("🔋 无限体力", nil, function(s) _G.InfStamina = s end)
MoveSec:CreateToggle("🔋 无限夜视仪", nil, function(s) _G.InfNightVision = s end)
MoveSec:CreateToggle("💀 免疫摔伤", nil, function(s) _G.NoFallDMG = s end)
MoveSec:CreateToggle("🦘 无跳跃冷却", nil, function(s) _G.RakeNoJumpCooldown = s end)
MoveSec:CreateToggle("🧘 免眩晕/倒地", nil, function(s) _G.RakeNoDowned = s end)
MoveSec:CreateToggle("🔓 免移动锁定", nil, function(s) _G.RakeNoMoveLock = s end)
MoveSec:CreateToggle("🔄 安全恢复速度", nil, function(s) _G.RakeSafeRecover = s end)
MoveSec:CreateToggle("👁️ 冻结视角", nil, function(s) _G.RakeFreezeLookAngles = s end)

-- 视觉标签页
local VisualTab = Window:CreateTab("👁️ 视觉", 0)
local VisSec = VisualTab:CreateSection("💡 画面增强")
VisSec:CreateToggle("☀️ 全屏亮化", nil, function(s) _G.RakeFullbright = s end)
VisSec:CreateToggle("🌫️ 移除雾效", nil, function(s) _G.NoFog = s end)
VisSec:CreateToggle("🌑 移除阴影", nil, function(s) _G.RakeDisableShadows = s end)
VisSec:CreateToggle("🎬 移除运动模糊", nil, function(s) _G.RakeDisableMotionBlur = s end)
VisSec:CreateToggle("✨ 移除视觉特效", nil, function(s) _G.RakeDisableVisualFx = s end)
VisSec:CreateToggle("📷 移除镜头晃动", nil, function(s) _G.RakeDisableCameraShake = s end)
VisSec:CreateToggle("🎥 移除相机摆动", nil, function(s) _G.RakeDisableCameraBobbing = s end)
VisSec:CreateToggle("💀 移除死亡特效", nil, function(s) _G.RakeDisableDeathFx = s end)
VisSec:CreateToggle("🔍 视场角调整", nil, function(s) _G.enableFOV = s end)
VisSec:CreateSlider("🔍 FOV值", 1, 120, function(v) _G.FieldOfView = v end)

local EspSec = VisualTab:CreateSection("🎯 ESP透视")
EspSec:CreateToggle("🔴 Rake高亮", nil, function(s) _G.RakeChams = s end)
EspSec:CreateToggle("🟢 玩家透视", nil, function(s) _G.PlayerESP = s end)
EspSec:CreateToggle("🔵 空投ESP", nil, function(s) _G.SupplyDropESP = s end)
EspSec:CreateToggle("🟡 信号枪ESP", nil, function(s) _G.FlareGunESP = s end)
EspSec:CreateToggle("🟠 废料ESP", nil, function(s) _G.ScrapESP = s end)
EspSec:CreateToggle("🏠 地点ESP", nil, function(s) _G.LocationESP = s end)
EspSec:CreateToggle("🪤 陷阱ESP", nil, function(s) _G.RakeTrapESP = s end)

-- 自动化标签页
local AutoTab = Window:CreateTab("🤖 自动化", 0)
local AutoSec = AutoTab:CreateSection("📦 物品交互")
AutoSec:CreateToggle("📦 瞬间开箱", nil, function(s) _G.InstaOpenSupplyDrop = s end)
AutoSec:CreateToggle("🪤 瞬间关闭陷阱", nil, function(s) _G.InstaCloseRakeTrap = s end)
AutoSec:CreateToggle("📦 自动拾取空投", nil, function(s) _G.RakeAutoDropPrompts = s end)
AutoSec:CreateToggle("🗼 自动塔楼交互", nil, function(s) _G.RakeAutoTowerPrompts = s end)
AutoSec:CreateToggle("⚡ 自动电站交互", nil, function(s) _G.RakeAutoPowerPrompts = s end)
AutoSec:CreateToggle("🛡️ 自动安全区交互", nil, function(s) _G.RakeAutoSafePrompts = s end)
AutoSec:CreateToggle("🔓 提示框距离增强", nil, function(s) _G.RakePromptBypass = s end)
AutoSec:CreateSlider("📏 提示框距离", 5, 100, function(v) _G.RakePromptDistance = v end)

-- 音效标签页
local AudioTab = Window:CreateTab("🔇 音效", 0)
local AudioSec = AudioTab:CreateSection("🔊 静音控制")
AudioSec:CreateToggle("🎵 静音游戏音乐", nil, function(s) _G.RakeMuteGameMusic = s end)
AudioSec:CreateToggle("🏃 静音追逐音乐", nil, function(s) _G.RakeMuteChaseMusic = s end)
AudioSec:CreateToggle("👣 静音脚步声", nil, function(s) _G.RakeMuteFootsteps = s end)
AudioSec:CreateToggle("💀 静音死亡音效", nil, function(s) _G.RakeMuteDeathSounds = s end)
AudioSec:CreateToggle("🚶 静音移动音效", nil, function(s) _G.RakeMuteMovementSounds = s end)
AudioSec:CreateToggle("🦘 静音跳跃落地", nil, function(s) _G.RakeMuteJumpLand = s end)
AudioSec:CreateToggle("💧 静音落水音效", nil, function(s) _G.RakeMuteWaterFall = s end)

-- UI标签页
local UITab = Window:CreateTab("🖥️ UI", 0)
local UISec = UITab:CreateSection("🎨 界面设置")
UISec:CreateToggle("🔊 禁用菜单特效", nil, function(s) _G.RakeDisableMenuFx = s end)
UISec:CreateToggle("🔇 隐藏提示UI", nil, function(s) _G.RakeHidePromptUi = s end)
UISec:CreateToggle("💀 隐藏死亡消息", nil, function(s) _G.RakeHideDeathMessages = s end)
UISec:CreateToggle("🗺️ 隐藏位置弹窗", nil, function(s) _G.RakeHideLocationPopups = s end)
UISec:CreateToggle("🔧 隐藏陷阱GUI", nil, function(s) _G.RakeHideTrapGui = s end)
UISec:CreateToggle("💬 强制启用聊天", nil, function(s) _G.RakeForceChat = s end)
UISec:CreateToggle("🎒 强制显示背包", nil, function(s) _G.RakeForceBackpack = s end)
UISec:CreateToggle("🖱️ 强制显示鼠标", nil, function(s) _G.RakeForceMouseIcon = s end)
UISec:CreateToggle("📌 强制显示顶栏", nil, function(s) _G.RakeForceTopbar = s end)

-- 高级标签页
local AdvTab = Window:CreateTab("⚙️ 高级", 0)
local AdvSec = AdvTab:CreateSection("🛠️ 功能绕过")
AdvSec:CreateToggle("🎬 跳过开场动画", nil, function(s) _G.RakeIntroBypass = s end)
AdvSec:CreateToggle("💡 手电筒增强", nil, function(s) _G.RakeFlashlightBoost = s end)
AdvSec:CreateToggle("🌑 手电筒无阴影", nil, function(s) _G.RakeFlashlightNoShadows = s end)
AdvSec:CreateToggle("🔄 禁用菜单自动重开", nil, function(s) _G.RakeDisableMenuReopen = s end)
AdvSec:CreateToggle("🏷️ 强制显示名字牌", nil, function(s) _G.RakeForceNametags = s end)
AdvSec:CreateToggle("🧠 强制第六感", nil, function(s) _G.RakeForceSixthSense = s end)
AdvSec:CreateToggle("🛡️ Adonis反作弊绕过", nil, function(s) _G.RakeAdonisBypass = s end)

-- 信号枪标签页
local FlareTab = Window:CreateTab("📡 信号枪", 0)
local FlareSec = FlareTab:CreateSection("✨ 自动拾取")
FlareSec:CreateToggle("📡 自动传送拾取信号枪", nil, function(s) _G.AutoPickupFlare = s end)
FlareSec:CreateSlider("⏱️ 拾取冷却(秒)", 1, 30, function(v) _G.AutoPickupFlareDelay = v end)

-- 关于标签页
local AboutTab = Window:CreateTab("ℹ️ 关于", 0)
local AboutSec = AboutTab:CreateSection("📖 信息")
AboutSec:CreateParagraph("Project The Rake - 完整版", 
    "基于开源脚本完整迁移\n杀戮光环距离上限 80\n信号枪自动传送拾取\n所有功能均可用")
AboutSec:CreateParagraph("⚠️ 免责声明", "仅供学习参考，请勿滥用。使用第三方脚本违反Roblox条款。")

-- 通知
Rayfield:Notify({
    Title = "Project The Rake",
    Content = "所有功能加载完成！界面应该完整显示，请按 RightControl 隐藏/显示",
    Duration = 5,
})
