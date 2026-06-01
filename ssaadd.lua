-- 战争大亨全能脚本 - WindUI 最终稳定版
-- 功能：战斗辅助、ESP、自动农场、移动、杂项
-- UI 优先构建，所有功能代码安全隔离

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WindUI then return end

-- 创建窗口
local Window = WindUI:CreateWindow({
    Title = "战争大亨全能脚本",
    Folder = "WarTycoonHub",
    Theme = "Dark",
    Size = UDim2.fromOffset(850, 580),
    Resizable = true,
    ToggleKey = Enum.KeyCode.RightControl,
})

if Window.AddButton then
    Window:AddButton({ Text = "官网", Callback = function() setclipboard("https://example.com") end })
end

-- 创建标签页
local CombatTab = Window:Tab({ Title = "战斗辅助", Icon = "sword" })
local ESPTab = Window:Tab({ Title = "视觉ESP", Icon = "eye" })
local FarmTab = Window:Tab({ Title = "自动农场", Icon = "tractor" })
local MoveTab = Window:Tab({ Title = "移动功能", Icon = "plane" })
local MiscTab = Window:Tab({ Title = "综合功能", Icon = "settings" })

-- 添加 UI 控件（与之前测试版相同，但回调留空，稍后动态绑定）
CombatTab:Section({ Title = "瞄准辅助", Side = "left" })
local silentToggle = CombatTab:Toggle({ Title = "静默自瞄", Default = false, Callback = function(v) end })
local fovSlider = CombatTab:Slider({ Title = "自瞄FOV", Min = 50, Max = 500, Step = 1, Default = 200, Callback = function(v) end })
local wallToggle = CombatTab:Toggle({ Title = "穿墙模式", Default = false, Callback = function(v) end })
local auraToggle = CombatTab:Toggle({ Title = "杀戮光环", Default = false, Callback = function(v) end })
local rangeSlider = CombatTab:Slider({ Title = "光环范围", Min = 100, Max = 1000, Step = 1, Default = 500, Callback = function(v) end })

CombatTab:Section({ Title = "枪械改装", Side = "right" })
local ammoToggle = CombatTab:Toggle({ Title = "无限弹药", Default = false, Callback = function(v) end })
local recoilToggle = CombatTab:Toggle({ Title = "无后坐力", Default = false, Callback = function(v) end })
local rapidToggle = CombatTab:Toggle({ Title = "极速射速", Default = false, Callback = function(v) end })
local rocketToggle = CombatTab:Toggle({ Title = "火箭弹幕", Default = false, Callback = function(v) end })

ESPTab:Section({ Title = "视觉效果", Side = "left" })
local espToggle = ESPTab:Toggle({ Title = "启用ESP", Default = false, Callback = function(v) end })
local boxToggle = ESPTab:Toggle({ Title = "方框ESP", Default = true, Callback = function(v) end })
local nameToggle = ESPTab:Toggle({ Title = "名称ESP", Default = true, Callback = function(v) end })
local healthToggle = ESPTab:Toggle({ Title = "血量ESP", Default = true, Callback = function(v) end })

FarmTab:Section({ Title = "自动收集", Side = "left" })
local farmMasterToggle = FarmTab:Toggle({ Title = "自动农场总开关", Default = false, Callback = function(v) end })
local oilToggle = FarmTab:Toggle({ Title = "自动油桶", Default = false, Callback = function(v) end })
local stealToggle = FarmTab:Toggle({ Title = "自动掠夺板条箱", Default = false, Callback = function(v) end })
local sellToggle = FarmTab:Toggle({ Title = "自动出售板条箱", Default = false, Callback = function(v) end })
local rebirthToggle = FarmTab:Toggle({ Title = "自动转生", Default = false, Callback = function(v) end })
local dailyToggle = FarmTab:Toggle({ Title = "自动每日奖励", Default = false, Callback = function(v) end })
local sessionToggle = FarmTab:Toggle({ Title = "自动会话奖励", Default = false, Callback = function(v) end })
local wheelToggle = FarmTab:Toggle({ Title = "自动轮盘抽奖", Default = false, Callback = function(v) end })

MoveTab:Section({ Title = "移动增强", Side = "left" })
local flyToggle = MoveTab:Toggle({ Title = "飞行模式", Default = false, Callback = function(v) end })
local flySpeedSlider = MoveTab:Slider({ Title = "飞行速度", Min = 20, Max = 300, Step = 1, Default = 80, Callback = function(v) end })
local noclipToggle = MoveTab:Toggle({ Title = "穿墙模式", Default = false, Callback = function(v) end })
local noFallToggle = MoveTab:Toggle({ Title = "免疫摔伤", Default = false, Callback = function(v) end })
local speedBoostToggle = MoveTab:Toggle({ Title = "加速行走", Default = false, Callback = function(v) end })
local walkSpeedSlider = MoveTab:Slider({ Title = "行走速度", Min = 16, Max = 200, Step = 1, Default = 32, Callback = function(v) end })
local jumpBoostToggle = MoveTab:Toggle({ Title = "超级跳跃", Default = false, Callback = function(v) end })
local jumpPowerSlider = MoveTab:Slider({ Title = "跳跃力度", Min = 50, Max = 300, Step = 1, Default = 50, Callback = function(v) end })
local infJumpToggle = MoveTab:Toggle({ Title = "无限跳跃", Default = false, Callback = function(v) end })

MiscTab:Section({ Title = "实用工具", Side = "left" })
local afkToggle = MiscTab:Toggle({ Title = "反AFK", Default = false, Callback = function(v) end })
local daynightToggle = MiscTab:Toggle({ Title = "昼夜切换", Default = false, Callback = function(v) end })
MiscTab:Button({ Title = "清除所有板条箱", Callback = function() end })
MiscTab:Button({ Title = "重新加入服务器", Callback = function() end })

WindUI:Notify({ Title = "UI 已加载", Content = "正在加载功能模块...", Duration = 2 })

-- ================= 功能代码（全部放入保护中） =================
task.spawn(function()
    pcall(function()
        -- 服务引用
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local UserInputService = game:GetService("UserInputService")
        local VirtualInputManager = game:GetService("VirtualInputManager")
        local Workspace = game:GetService("Workspace")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local TweenService = game:GetService("TweenService")
        local Lighting = game:GetService("Lighting")
        local LocalPlayer = Players.LocalPlayer
        local Camera = Workspace.CurrentCamera
        local Mouse = LocalPlayer:GetMouse()

        -- 全局设置
        local Settings = {
            SilentAim = false, SilentAimFOV = 200, Wallbang = false,
            KillAura = false, KillAuraRange = 500,
            InfiniteAmmo = false, NoRecoil = false, RapidFire = false,
            RocketSpam = false,
            ESPEnabled = false, ESPBoxes = true, ESPNames = true, ESPHealth = true,
            Fly = false, FlySpeed = 80, Noclip = false, NoFallDamage = false,
            AntiAFK = false, SpeedBoost = false, SpeedBoostValue = 32,
            JumpBoost = false, JumpBoostValue = 50, InfiniteJump = false,
            DayNight = false,
            AutoFarmMaster = false, AutoOil = false, AutoStealCrate = false, AutoSellCrate = false,
            AutoRebirth = false, AutoClaimDaily = false, AutoClaimSession = false, AutoClaimWheel = false,
        }

        -- 辅助函数
        local function GetNearestEnemy(fov)
            local nearest, nearestDist = nil, fov or 200
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Team ~= LocalPlayer.Team then
                    local screenPos, onScreen = Camera:WorldToScreenPoint(plr.Character.HumanoidRootPart.Position)
                    if onScreen then
                        local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                        if dist < nearestDist then nearestDist, nearest = dist, plr end
                    end
                end
            end
            return nearest
        end

        local function GetAllEnemiesInRange(range)
            local enemies = {}
            local char = LocalPlayer.Character
            if not char then return enemies end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return enemies end
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Team ~= LocalPlayer.Team then
                    if (plr.Character.HumanoidRootPart.Position - root.Position).Magnitude <= range then
                        table.insert(enemies, plr)
                    end
                end
            end
            return enemies
        end

        local function GetCurrentWeapon()
            local char = LocalPlayer.Character
            if not char then return nil end
            for _, tool in ipairs(char:GetChildren()) do
                if tool:IsA("Tool") and tool.Parent == char then return tool end
            end
            return nil
        end

        -- 枪械改装
        local function ApplyGunMods()
            local weapon = GetCurrentWeapon()
            if not weapon then return end
            if Settings.InfiniteAmmo then
                for _, prop in ipairs({"Ammo","CurrentAmmo","AmmoCount","Magazine","StoredAmmo","Bullets","Clip"}) do
                    local p = weapon:FindFirstChild(prop)
                    if p then p.Value = 99999 end
                end
            end
            if Settings.NoRecoil then
                for _, prop in ipairs({"Recoil","CameraRecoil","Spread","ShotSpread","RecoilModifier","SpreadModifier","Kickback"}) do
                    local p = weapon:FindFirstChild(prop)
                    if p then p.Value = 0 end
                end
            end
            if Settings.RapidFire then
                for _, prop in ipairs({"FireRate","RateOfFire","Cooldown","ShotDelay","FireDelay","RecoveryTime"}) do
                    local p = weapon:FindFirstChild(prop)
                    if p then p.Value = 0.01 end
                end
            end
        end

        local gunModConnection
        gunModConnection = RunService.RenderStepped:Connect(function()
            if Settings.InfiniteAmmo or Settings.NoRecoil or Settings.RapidFire then
                ApplyGunMods()
            end
        end)

        -- 战斗连接
        local silentConn, killConn, rocketConn
        local function StartSilentAim()
            if silentConn then silentConn:Disconnect() end
            if not Settings.SilentAim then return end
            silentConn = RunService.RenderStepped:Connect(function()
                local target = GetNearestEnemy(Settings.SilentAimFOV)
                if target and target.Character then
                    local aimPart = target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
                    if aimPart and LocalPlayer.Character then
                        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            if not Settings.Wallbang then
                                local ray = Workspace:Raycast(Camera.CFrame.Position, (aimPart.Position - Camera.CFrame.Position).Unit * 1000)
                                if ray and not ray.Instance:IsDescendantOf(target.Character) then return end
                            end
                            hrp.CFrame = CFrame.new(hrp.Position, aimPart.Position)
                        end
                    end
                end
            end)
        end

        local function StartKillAura()
            if killConn then killConn:Disconnect() end
            if not Settings.KillAura then return end
            killConn = RunService.Heartbeat:Connect(function()
                for _, enemy in ipairs(GetAllEnemiesInRange(Settings.KillAuraRange)) do
                    local hum = enemy.Character and enemy.Character:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then hum.Health = 0 end
                end
            end)
        end

        local function StartRocketSpam()
            if rocketConn then rocketConn:Disconnect() end
            if not Settings.RocketSpam then return end
            rocketConn = RunService.Heartbeat:Connect(function()
                local remote = ReplicatedStorage:FindFirstChild("FireRocket")
                if remote then remote:FireServer() end
                task.wait(0.1)
            end)
        end

        -- ESP
        local espItems = {}
        local function UpdateESP()
            for _, item in ipairs(espItems) do if item and item.Destroy then item:Destroy() end end
            espItems = {}
            if not Settings.ESPEnabled then return end
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local root = plr.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        if Settings.ESPBoxes then
                            local box = Instance.new("BoxHandleAdornment")
                            box.Size = Vector3.new(4,5,2); box.Adornee = root; box.Color3 = Color3.fromRGB(255,0,0)
                            box.Transparency = 0.5; box.AlwaysOnTop = true; box.Parent = plr.Character
                            table.insert(espItems, box)
                        end
                        if Settings.ESPNames then
                            local bill = Instance.new("BillboardGui")
                            bill.Size = UDim2.new(0,200,0,40); bill.Adornee = root; bill.AlwaysOnTop = true
                            local label = Instance.new("TextLabel", bill)
                            label.Size = UDim2.new(1,0,1,0); label.BackgroundTransparency = 1
                            label.Text = plr.Name; label.TextColor3 = Color3.fromRGB(255,255,255)
                            bill.Parent = plr.Character; table.insert(espItems, bill)
                        end
                        if Settings.ESPHealth then
                            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                            if hum then
                                local healthBar = Instance.new("BillboardGui")
                                healthBar.Size = UDim2.new(0,100,0,10); healthBar.Adornee = root; healthBar.AlwaysOnTop = true
                                local bg = Instance.new("Frame", healthBar); bg.Size = UDim2.new(1,0,1,0); bg.BackgroundColor3 = Color3.fromRGB(0,0,0); bg.BackgroundTransparency = 0.5; bg.BorderSizePixel = 0
                                local bar = Instance.new("Frame", healthBar); bar.Size = UDim2.new(hum.Health/hum.MaxHealth,0,1,0); bar.BackgroundColor3 = Color3.fromRGB(0,255,0); bar.BorderSizePixel = 0
                                healthBar.Parent = plr.Character; table.insert(espItems, healthBar)
                                hum.HealthChanged:Connect(function()
                                    bar.Size = UDim2.new(hum.Health/hum.MaxHealth,0,1,0)
                                    local p = hum.Health/hum.MaxHealth
                                    bar.BackgroundColor3 = p>0.5 and Color3.fromRGB(0,255,0) or (p>0.25 and Color3.fromRGB(255,255,0) or Color3.fromRGB(255,0,0))
                                end)
                            end
                        end
                    end
                end
            end
        end
        local espConnection = RunService.RenderStepped:Connect(UpdateESP)

        -- 移动功能
        local flyBodyVel = nil
        local flyConn = nil
        local function StartFly()
            if flyConn then flyConn:Disconnect() end
            if not Settings.Fly then
                if flyBodyVel then flyBodyVel:Destroy() end
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand = false end
                return
            end
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = true end
            if flyBodyVel then flyBodyVel:Destroy() end
            flyBodyVel = Instance.new("BodyVelocity")
            flyBodyVel.MaxForce = Vector3.new(1,1,1)*1e5
            flyBodyVel.Parent = hrp
            flyConn = RunService.RenderStepped:Connect(function()
                if not Settings.Fly then return end
                local move = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end
                flyBodyVel.Velocity = move.Magnitude>0 and move.Unit*Settings.FlySpeed or Vector3.zero
            end)
        end

        local noclipConn = nil
        local function StartNoclip()
            if noclipConn then noclipConn:Disconnect() end
            if not Settings.Noclip then return end
            noclipConn = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if char then for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
            end)
        end

        local noFallConn = nil
        local function StartNoFallDamage()
            if noFallConn then noFallConn:Disconnect() end
            if not Settings.NoFallDamage then return end
            noFallConn = RunService.Stepped:Connect(function()
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.UseJumpPower = false end
            end)
        end

        local function StartInfiniteJump()
            local uis = game:GetService("UserInputService")
            uis.JumpRequest:Connect(function()
                if Settings.InfiniteJump and LocalPlayer.Character then
                    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum and hum.FloorMaterial ~= Enum.Material.Air then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
                end
            end)
        end

        local antiAFKConn = nil
        local function StartAntiAFK()
            if antiAFKConn then antiAFKConn:Disconnect() end
            if not Settings.AntiAFK then return end
            antiAFKConn = RunService.Heartbeat:Connect(function()
                local vu = game:GetService("VirtualUser")
                if vu then vu:Button2Down(Vector2.new(0,0), Camera.CFrame) end
            end)
        end

        local function ToggleDayNight()
            if Settings.DayNight then Lighting.TimeOfDay, Lighting.Brightness = "Night", 0.2 else Lighting.TimeOfDay, Lighting.Brightness = "Day", 1 end
        end

        local function ApplyMovementBoosts()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                if Settings.SpeedBoost then hum.WalkSpeed = Settings.SpeedBoostValue end
                if Settings.JumpBoost then hum.JumpPower = Settings.JumpBoostValue end
            end
        end
        local boostConn = RunService.RenderStepped:Connect(ApplyMovementBoosts)

        local function RemoveAllCrates()
            for _, obj in ipairs(Workspace:GetChildren()) do if obj.Name:lower():find("crate") then obj:Destroy() end end
            WindUI:Notify({ Title = "提示", Content = "已清除所有板条箱", Duration = 2 })
        end
        local function RejoinServer()
            game:GetService("TeleportService"):Teleport(game.PlaceId)
        end

        -- 自动农场（简化版，只使用远程事件）
        local farmConnection = nil
        local function startAutoFarm()
            if farmConnection then farmConnection:Disconnect() end
            if not Settings.AutoFarmMaster then return end
            farmConnection = RunService.Heartbeat:Connect(function()
                -- 自动收集现金
                if Settings.AutoSellCrate then  -- 复用为自动收集现金标志
                    local remote = ReplicatedStorage:FindFirstChild("CollectCash")
                    if remote then remote:FireServer() end
                end
                -- 自动油桶
                if Settings.AutoOil then
                    for _, obj in ipairs(Workspace:GetChildren()) do
                        if obj.Name:lower():find("oil") or obj.Name:lower():find("barrel") then
                            local remote = ReplicatedStorage:FindFirstChild("CollectOil")
                            if remote then remote:FireServer(obj) end
                        end
                    end
                end
                -- 自动空投/板条箱（简化）
                if Settings.AutoStealCrate then
                    for _, obj in ipairs(Workspace:GetChildren()) do
                        if obj.Name:lower():find("airdrop") or obj.Name:lower():find("crate") then
                            local remote = ReplicatedStorage:FindFirstChild("CollectAirdrop") or ReplicatedStorage:FindFirstChild("StealCrate")
                            if remote then remote:FireServer(obj) end
                        end
                    end
                end
                task.wait(1)
            end)
        end

        local rebirthLoop = nil
        local function startRebirthLoop()
            if rebirthLoop then return end
            rebirthLoop = task.spawn(function()
                while Settings.AutoRebirth do
                    local remote = ReplicatedStorage:FindFirstChild("Rebirth")
                    if remote then pcall(function() remote:FireServer() end) end
                    task.wait(60)
                end
            end)
        end

        local claimLoop = nil
        local function startClaimLoop()
            if claimLoop then return end
            claimLoop = task.spawn(function()
                while Settings.AutoClaimDaily or Settings.AutoClaimSession or Settings.AutoClaimWheel do
                    if Settings.AutoClaimDaily then
                        local r = ReplicatedStorage:FindFirstChild("ClaimDaily")
                        if r then pcall(function() r:FireServer() end) end
                    end
                    if Settings.AutoClaimSession then
                        local r = ReplicatedStorage:FindFirstChild("ClaimSession")
                        if r then pcall(function() r:FireServer() end) end
                    end
                    if Settings.AutoClaimWheel then
                        local r = ReplicatedStorage:FindFirstChild("SpinWheel")
                        if r then pcall(function() r:FireServer() end) end
                    end
                    task.wait(3600)
                end
            end)
        end

        -- 绑定 UI 回调到实际功能
        silentToggle:SetCallback(function(v) Settings.SilentAim = v; StartSilentAim() end)
        fovSlider:SetCallback(function(v) Settings.SilentAimFOV = v end)
        wallToggle:SetCallback(function(v) Settings.Wallbang = v end)
        auraToggle:SetCallback(function(v) Settings.KillAura = v; StartKillAura() end)
        rangeSlider:SetCallback(function(v) Settings.KillAuraRange = v end)
        ammoToggle:SetCallback(function(v) Settings.InfiniteAmmo = v end)
        recoilToggle:SetCallback(function(v) Settings.NoRecoil = v end)
        rapidToggle:SetCallback(function(v) Settings.RapidFire = v end)
        rocketToggle:SetCallback(function(v) Settings.RocketSpam = v; StartRocketSpam() end)
        espToggle:SetCallback(function(v) Settings.ESPEnabled = v end)
        boxToggle:SetCallback(function(v) Settings.ESPBoxes = v end)
        nameToggle:SetCallback(function(v) Settings.ESPNames = v end)
        healthToggle:SetCallback(function(v) Settings.ESPHealth = v end)
        flyToggle:SetCallback(function(v) Settings.Fly = v; StartFly() end)
        flySpeedSlider:SetCallback(function(v) Settings.FlySpeed = v end)
        noclipToggle:SetCallback(function(v) Settings.Noclip = v; StartNoclip() end)
        noFallToggle:SetCallback(function(v) Settings.NoFallDamage = v; StartNoFallDamage() end)
        speedBoostToggle:SetCallback(function(v) Settings.SpeedBoost = v end)
        walkSpeedSlider:SetCallback(function(v) Settings.SpeedBoostValue = v end)
        jumpBoostToggle:SetCallback(function(v) Settings.JumpBoost = v end)
        jumpPowerSlider:SetCallback(function(v) Settings.JumpBoostValue = v end)
        infJumpToggle:SetCallback(function(v) Settings.InfiniteJump = v; if v then StartInfiniteJump() end end)
        afkToggle:SetCallback(function(v) Settings.AntiAFK = v; StartAntiAFK() end)
        daynightToggle:SetCallback(function(v) Settings.DayNight = v; ToggleDayNight() end)
        -- 按钮
        local function setButtonCallback(container, title, callback)
            for _, btn in ipairs(container:GetChildren()) do
                if btn:IsA("Button") and btn.Title == title then
                    btn:SetCallback(callback)
                end
            end
        end
        -- 简单手动绑定（因为Button没有直接标识，改用最后的回调设置）
        -- 我们直接在原始 UI 创建处已经定义了清除和重新加入的按钮，现在重新获取并设置
        local clearBtn = MiscTab:Button({ Title = "清除所有板条箱", Callback = RemoveAllCrates })
        local rejoinBtn = MiscTab:Button({ Title = "重新加入服务器", Callback = RejoinServer })

        -- 农场绑定
        farmMasterToggle:SetCallback(function(v)
            Settings.AutoFarmMaster = v
            startAutoFarm()
        end)
        oilToggle:SetCallback(function(v) Settings.AutoOil = v; startAutoFarm() end)
        stealToggle:SetCallback(function(v) Settings.AutoStealCrate = v; startAutoFarm() end)
        sellToggle:SetCallback(function(v) Settings.AutoSellCrate = v; startAutoFarm() end)
        rebirthToggle:SetCallback(function(v) Settings.AutoRebirth = v; if v then startRebirthLoop() end end)
        dailyToggle:SetCallback(function(v) Settings.AutoClaimDaily = v; startClaimLoop() end)
        sessionToggle:SetCallback(function(v) Settings.AutoClaimSession = v; startClaimLoop() end)
        wheelToggle:SetCallback(function(v) Settings.AutoClaimWheel = v; startClaimLoop() end)

        -- 启动默认关闭的功能循环（避免自启动）
        StartSilentAim()
        StartKillAura()
        StartRocketSpam()
        StartFly()
        StartNoclip()
        StartNoFallDamage()
        StartAntiAFK()
        startAutoFarm()  -- 主开关关闭时不会实际执行

        WindUI:Notify({ Title = "脚本加载完成", Content = "所有功能已就绪 | 按 RightControl 开关菜单", Duration = 4 })
    end)
end)

-- 炫彩边框（安全隔离）
task.spawn(function()
    pcall(function()
        task.wait(0.5)
        local gui = game:GetService("CoreGui"):FindFirstChild("WarTycoonHub")
        if not gui then gui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("WarTycoonHub") end
        if not gui then return end
        local mainFrame = nil
        for _, child in ipairs(gui:GetDescendants()) do
            if child:IsA("Frame") and (child.Name == "Window" or child.Name:find("Main")) then
                mainFrame = child
                break
            end
        end
        if not mainFrame then return end
        local borderContainer = Instance.new("Frame")
        borderContainer.Size = UDim2.new(1, 20, 1, 20)
        borderContainer.Position = UDim2.new(0, -10, 0, -10)
        borderContainer.BackgroundTransparency = 1
        borderContainer.BorderSizePixel = 0
        borderContainer.ZIndex = 999
        borderContainer.Parent = mainFrame
        local colors = {Color3.fromRGB(255,50,50), Color3.fromRGB(50,255,50), Color3.fromRGB(50,50,255), Color3.fromRGB(255,255,50)}
        local sides = {
            {"top", UDim2.new(0,0,0,-3), UDim2.new(1,0,0,3)},
            {"right", UDim2.new(1,3,0,0), UDim2.new(0,3,1,0)},
            {"bottom", UDim2.new(0,0,1,3), UDim2.new(1,0,0,3)},
            {"left", UDim2.new(0,-3,0,0), UDim2.new(0,3,1,0)}
        }
        for i, side in ipairs(sides) do
            local bar = Instance.new("Frame")
            bar.Position = side[2]
            bar.Size = side[3]
            bar.BackgroundColor3 = colors[i]
            bar.BorderSizePixel = 0
            bar.ZIndex = 1000
            bar.Parent = borderContainer
            local grad = Instance.new("UIGradient", bar)
            local isHorizontal = (side[1] == "top" or side[1] == "bottom")
            grad.Rotation = isHorizontal and 0 or 90
            grad.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, colors[i]),
                ColorSequenceKeypoint.new(0.33, colors[(i % 4) + 1]),
                ColorSequenceKeypoint.new(0.66, colors[((i + 1) % 4) + 1]),
                ColorSequenceKeypoint.new(1, colors[i])
            }
            local offset = 0
            local direction = (side[1] == "bottom" or side[1] == "right") and -1 or 1
            task.spawn(function()
                while true do
                    offset = (offset + direction * 0.005) % 1
                    grad.Offset = Vector2.new(offset, 0)
                    task.wait(0.05)
                end
            end)
        end
    end)
end)