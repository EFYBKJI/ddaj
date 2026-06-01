-- 战争大亨全能脚本 - RPG全图追踪最终完整版
-- 功能：RPG无限弹药、全图追踪杀戮、白名单、ESP、移动、农场等
-- UI：Rayfield | 快捷键：RightControl

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
if not Rayfield then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- 抓包得到的 RPG 命中事件
local RocketHitEvent = ReplicatedStorage:WaitForChild("RocketSystem"):WaitForChild("Events"):WaitForChild("RocketHit")
if not RocketHitEvent then warn("RocketHit 事件未找到，请检查游戏更新") end

-- ================= 全局设置 =================
local Settings = {
    SilentAim = false, SilentAimFOV = 200, Wallbang = false,
    KillAura = false, KillAuraRange = 500,
    InfiniteAmmo = false, NoRecoil = false, RapidFire = false,
    RocketSpam = false, RocketSpamDelay = 0.03,
    RPGTrack = false, RPGTrackDelay = 0.1,
    ESPEnabled = false, ESPBoxes = true, ESPNames = true, ESPHealth = true,
    Fly = false, FlySpeed = 80, Noclip = false, NoFallDamage = false,
    AntiAFK = false,
    SpeedBoost = false, SpeedBoostValue = 32,
    JumpBoost = false, JumpBoostValue = 50, InfiniteJump = false,
    DayNight = false,
    AutoCash = false, AutoOil = false, AutoAirdrop = false, AutoStealCrate = false,
    AutoRebirth = false, AutoClaimDaily = false, AutoClaimSession = false, AutoClaimWheel = false,
    WhiteList = {},
}

-- ================= 辅助函数 =================
local function GetCurrentWeapon()
    local char = LocalPlayer.Character
    if not char then return nil end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and tool.Parent == char then return tool end
    end
    return nil
end

local function GetRPGWeapon()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("RPG")
end

local function IsWhiteListed(playerName)
    return Settings.WhiteList[playerName:lower()] == true
end

-- ================= RPG 弹药彻底锁定 =================
local function LockRPGAmmo()
    local rpg = GetRPGWeapon()
    if not rpg then return end
    local props = {"Ammo", "CurrentAmmo", "Magazine", "StoredAmmo", "Rockets", "AmmoCount", "Clip"}
    for _, name in ipairs(props) do
        local prop = rpg:FindFirstChild(name)
        if prop and prop:IsA("NumberValue") then prop.Value = 99999 end
    end
    local handler = rpg:FindFirstChild("WeaponHandler") or rpg:FindFirstChild("Handler")
    if handler then
        local ammo = handler:FindFirstChild("CurrentAmmo")
        if ammo and ammo:IsA("NumberValue") then ammo.Value = 99999 end
    end
    for _, obj in ipairs(rpg:GetDescendants()) do
        if obj:IsA("NumberValue") and (obj.Name:lower():find("ammo") or obj.Name:lower():find("rocket")) then
            obj.Value = 99999
        end
    end
end
RunService.RenderStepped:Connect(LockRPGAmmo)

-- ================= 发射火箭（精准命中目标玩家，排除自身和近距离） =================
local function FireRocketAtPlayer(targetPlayer)
    if not targetPlayer or targetPlayer == LocalPlayer then return end
    if not targetPlayer.Character then return end
    local rpg = GetRPGWeapon()
    if not rpg or not rpg:FindFirstChild("Handle") then return end
    
    local origin = rpg.Handle.Position
    local targetRoot = targetPlayer.Character:FindFirstChild("Head") or targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    local targetPos = targetRoot.Position
    local distance = (targetPos - origin).Magnitude
    if distance < 10 then return end  -- 避免自伤
    
    LockRPGAmmo()
    local direction = (targetPos - origin).Unit
    local hitPart = targetRoot
    local args = {{
        Normal = direction,
        Player = targetPlayer,
        HitPart = hitPart,
        Origin = origin,
        Label = LocalPlayer.Name .. "Rocket" .. tick(),
        Vehicle = rpg,
        Position = targetPos,
        Weapon = rpg
    }}
    pcall(function()
        if RocketHitEvent then
            RocketHitEvent:FireServer(unpack(args))
        end
    end)
    LockRPGAmmo()
end

-- ================= RPG 全图追踪（轮流攻击所有非白名单敌人） =================
local trackConn = nil
local function StartRPGTrack()
    if trackConn then trackConn:Disconnect() end
    if not Settings.RPGTrack then return end
    
    local function getTargetList()
        local targets = {}
        local myChar = LocalPlayer.Character
        if not myChar then return targets end
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return targets end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LocalPlayer then continue end
            if plr.Team == LocalPlayer.Team then continue end
            if IsWhiteListed(plr.Name) then continue end
            if not plr.Character then continue end
            local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character:FindFirstChild("Head")
            if targetRoot then
                local dist = (targetRoot.Position - myRoot.Position).Magnitude
                if dist > 10 then
                    table.insert(targets, plr)
                end
            end
        end
        return targets
    end
    
    local targetIndex = 1
    trackConn = RunService.Heartbeat:Connect(function()
        local targets = getTargetList()
        if #targets == 0 then return end
        if targetIndex > #targets then targetIndex = 1 end
        local currentTarget = targets[targetIndex]
        targetIndex = targetIndex + 1
        if currentTarget then
            FireRocketAtPlayer(currentTarget)
            task.wait(Settings.RPGTrackDelay)
        end
    end)
end

-- ================= 枪械改装 =================
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
RunService.RenderStepped:Connect(ApplyGunMods)

-- ================= 跟随准星连发 =================
local function GetMouseTarget()
    local unitRay = Camera:ScreenPointToRay(Mouse.X, Mouse.Y)
    local ray = Ray.new(unitRay.Origin, unitRay.Direction * 1000)
    local hit, pos = Workspace:FindPartOnRay(ray, LocalPlayer.Character)
    return hit and pos or (unitRay.Origin + unitRay.Direction * 500)
end
local function FireRocketAtMouse()
    local rpg = GetRPGWeapon()
    if not rpg or not rpg:FindFirstChild("Handle") then return end
    LockRPGAmmo()
    local targetPos = GetMouseTarget()
    local origin = rpg.Handle.Position
    local direction = (targetPos - origin).Unit
    local hitPart = Workspace.Terrain
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    local rayResult = Workspace:Raycast(origin, direction * 1000, raycastParams)
    if rayResult and rayResult.Instance then
        hitPart = rayResult.Instance
        targetPos = rayResult.Position
    end
    local args = {{
        Normal = direction,
        Player = nil,
        HitPart = hitPart,
        Origin = origin,
        Label = LocalPlayer.Name .. "Rocket" .. tick(),
        Vehicle = rpg,
        Position = targetPos,
        Weapon = rpg
    }}
    pcall(function() if RocketHitEvent then RocketHitEvent:FireServer(unpack(args)) end end)
    LockRPGAmmo()
end
local rocketSpamConn = nil
local function StartRocketSpam()
    if rocketSpamConn then rocketSpamConn:Disconnect() end
    if not Settings.RocketSpam then return end
    rocketSpamConn = RunService.Heartbeat:Connect(function()
        FireRocketAtMouse()
        task.wait(Settings.RocketSpamDelay)
    end)
end

-- ================= 战斗功能（静默自瞄、普通杀戮光环，均排除白名单） =================
local function GetNearestEnemy(fov)
    local nearest, nearestDist = nil, fov or 200
    local mx, my = Mouse.X, Mouse.Y
    if not mx or not my then return nil end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if plr.Team == LocalPlayer.Team then continue end
        if IsWhiteListed(plr.Name) then continue end
        if not plr.Character then continue end
        local root = plr.Character:FindFirstChild("HumanoidRootPart")
        if not root then continue end
        local screenPos, onScreen = Camera:WorldToScreenPoint(root.Position)
        if onScreen and screenPos then
            local dx = mx - screenPos.X
            local dy = my - screenPos.Y
            local dist = math.sqrt(dx*dx + dy*dy)
            if dist < nearestDist then
                nearestDist = dist
                nearest = plr
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
        if plr == LocalPlayer then continue end
        if plr.Team == LocalPlayer.Team then continue end
        if IsWhiteListed(plr.Name) then continue end
        if not plr.Character then continue end
        local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot and (targetRoot.Position - root.Position).Magnitude <= range then
            table.insert(enemies, plr)
        end
    end
    return enemies
end

local silentConn, killConn
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
                        local direction = (aimPart.Position - Camera.CFrame.Position).Unit
                        local ray = Workspace:Raycast(Camera.CFrame.Position, direction * 1000)
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

-- ================= ESP（优化版） =================
local espItems = {}
local function UpdateESP()
    for _, item in ipairs(espItems) do if item and item.Destroy then item:Destroy() end end
    espItems = {}
    if not Settings.ESPEnabled then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if not plr.Character then continue end
        local root = plr.Character:FindFirstChild("HumanoidRootPart")
        if root then
            if Settings.ESPBoxes then
                local box = Instance.new("BoxHandleAdornment")
                box.Size = Vector3.new(3, 4.5, 1.5)
                box.Adornee = root
                box.Color3 = plr.Team == LocalPlayer.Team and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,50,50)
                box.Transparency = 0.4
                box.AlwaysOnTop = true
                box.Parent = plr.Character
                table.insert(espItems, box)
            end
            if Settings.ESPNames then
                local bill = Instance.new("BillboardGui")
                bill.Size = UDim2.new(0, 200, 0, 40)
                bill.Adornee = root
                bill.StudsOffset = Vector3.new(0, 2.2, 0)
                bill.AlwaysOnTop = true
                local label = Instance.new("TextLabel", bill)
                label.Size = UDim2.new(1,0,1,0)
                label.BackgroundTransparency = 1
                label.Text = plr.Name
                label.TextColor3 = Color3.fromRGB(255,255,255)
                label.TextStrokeTransparency = 0.3
                label.TextScaled = true
                bill.Parent = plr.Character
                table.insert(espItems, bill)
            end
            if Settings.ESPHealth then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    local healthBar = Instance.new("BillboardGui")
                    healthBar.Size = UDim2.new(0, 80, 0, 6)
                    healthBar.Adornee = root
                    healthBar.StudsOffset = Vector3.new(0, 2.8, 0)
                    healthBar.AlwaysOnTop = true
                    local bg = Instance.new("Frame", healthBar)
                    bg.Size = UDim2.new(1,0,1,0)
                    bg.BackgroundColor3 = Color3.fromRGB(0,0,0)
                    bg.BackgroundTransparency = 0.5
                    local bar = Instance.new("Frame", healthBar)
                    bar.Size = UDim2.new(hum.Health/hum.MaxHealth,0,1,0)
                    bar.BackgroundColor3 = Color3.fromRGB(0,255,0)
                    bar.BorderSizePixel = 0
                    healthBar.Parent = plr.Character
                    table.insert(espItems, healthBar)
                    hum.HealthChanged:Connect(function()
                        if hum and hum.Health and hum.MaxHealth then
                            local percent = hum.Health / hum.MaxHealth
                            bar.Size = UDim2.new(percent,0,1,0)
                            if percent > 0.5 then bar.BackgroundColor3 = Color3.fromRGB(0,255,0)
                            elseif percent > 0.25 then bar.BackgroundColor3 = Color3.fromRGB(255,255,0)
                            else bar.BackgroundColor3 = Color3.fromRGB(255,0,0) end
                        end
                    end)
                end
            end
        end
    end
end
RunService.RenderStepped:Connect(UpdateESP)

-- ================= 移动功能 =================
local function ApplyMovementBoosts()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        if Settings.SpeedBoost then hum.WalkSpeed = Settings.SpeedBoostValue else hum.WalkSpeed = 16 end
        if Settings.JumpBoost then hum.JumpPower = Settings.JumpBoostValue else hum.JumpPower = 50 end
    end
end
RunService.RenderStepped:Connect(ApplyMovementBoosts)

local function StartInfiniteJump()
    UserInputService.JumpRequest:Connect(function()
        if Settings.InfiniteJump and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum and (hum.FloorMaterial ~= Enum.Material.Air or hum:GetState() ~= Enum.HumanoidStateType.Landed) then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

local function StartNoFallDamage()
    local function onStateChanged(old, new)
        if Settings.NoFallDamage and new == Enum.HumanoidStateType.FallingDown then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Running) end
        end
    end
    local connection
    local function connect()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                if connection then connection:Disconnect() end
                connection = hum.StateChanged:Connect(onStateChanged)
            end
        end
    end
    connect()
    LocalPlayer.CharacterAdded:Connect(connect)
end

local flyBodyVel, flyConn
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

local noclipConn
local function StartNoclip()
    if noclipConn then noclipConn:Disconnect() end
    if not Settings.Noclip then return end
    noclipConn = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end)
end

local antiAFKConn
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

local function RemoveAllCrates()
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj.Name and obj.Name:lower():find("crate") then obj:Destroy() end
    end
    Rayfield:Notify({Title = "提示", Content = "已清除所有板条箱", Duration = 2})
end

local function RejoinServer()
    game:GetService("TeleportService"):Teleport(game.PlaceId)
end

-- ================= 自动农场 =================
local farmConn
local function startAutoFarm()
    if farmConn then farmConn:Disconnect() end
    farmConn = RunService.Heartbeat:Connect(function()
        if Settings.AutoCash then
            local remote = ReplicatedStorage:FindFirstChild("CollectCash") or ReplicatedStorage:FindFirstChild("TakeCash")
            if remote then remote:FireServer() end
        end
        if Settings.AutoOil then
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj.Name and (obj.Name:lower():find("oil") or obj.Name:lower():find("barrel")) then
                    local remote = ReplicatedStorage:FindFirstChild("CollectOil") or ReplicatedStorage:FindFirstChild("OilCollect")
                    if remote then remote:FireServer(obj) end
                end
            end
        end
        if Settings.AutoStealCrate then
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj.Name and (obj.Name:lower():find("airdrop") or obj.Name:lower():find("crate")) then
                    local remote = ReplicatedStorage:FindFirstChild("CollectAirdrop") or ReplicatedStorage:FindFirstChild("StealCrate")
                    if remote then remote:FireServer(obj) end
                end
            end
        end
        task.wait(1)
    end)
end

local rebirthLoop
local function startRebirth()
    if rebirthLoop then return end
    rebirthLoop = task.spawn(function()
        while Settings.AutoRebirth do
            local r = ReplicatedStorage:FindFirstChild("Rebirth") or ReplicatedStorage:FindFirstChild("Prestige")
            if r then pcall(function() r:FireServer() end) end
            task.wait(60)
        end
    end)
end

local claimLoop
local function startClaim()
    if claimLoop then return end
    claimLoop = task.spawn(function()
        while Settings.AutoClaimDaily or Settings.AutoClaimSession or Settings.AutoClaimWheel do
            if Settings.AutoClaimDaily then
                local r = ReplicatedStorage:FindFirstChild("ClaimDaily") or ReplicatedStorage:FindFirstChild("DailyReward")
                if r then pcall(function() r:FireServer() end) end
            end
            if Settings.AutoClaimSession then
                local r = ReplicatedStorage:FindFirstChild("ClaimSession") or ReplicatedStorage:FindFirstChild("SessionReward")
                if r then pcall(function() r:FireServer() end) end
            end
            if Settings.AutoClaimWheel then
                local r = ReplicatedStorage:FindFirstChild("SpinWheel") or ReplicatedStorage:FindFirstChild("FortuneWheel")
                if r then pcall(function() r:FireServer() end) end
            end
            task.wait(3600)
        end
    end)
end

-- ================= UI 构建 =================
local Window = Rayfield:CreateWindow({
    Name = "战争大亨 - RPG全图追踪版",
    Icon = 0,
    LoadingTitle = "加载中",
    LoadingSubtitle = "RPG 无限弹药 | 全图锁定",
    Theme = "Default",
    ToggleUIKeybind = Enum.KeyCode.RightControl,
})

local CombatTab = Window:CreateTab("战斗辅助", 0)
local ESPTab = Window:CreateTab("视觉ESP", 0)
local FarmTab = Window:CreateTab("自动农场", 0)
local MoveTab = Window:CreateTab("移动功能", 0)
local MiscTab = Window:CreateTab("综合功能", 0)
local WhiteListTab = Window:CreateTab("白名单", 0)

-- 战斗标签页
CombatTab:CreateSection("瞄准辅助")
CombatTab:CreateToggle({ Name = "静默自瞄", CurrentValue = false, Callback = function(v) Settings.SilentAim = v; StartSilentAim() end })
CombatTab:CreateSlider({ Name = "自瞄FOV", Range = {50, 500}, Increment = 1, CurrentValue = 200, Callback = function(v) Settings.SilentAimFOV = v or 200 end })
CombatTab:CreateToggle({ Name = "穿墙模式", CurrentValue = false, Callback = function(v) Settings.Wallbang = v end })
CombatTab:CreateToggle({ Name = "普通杀戮光环（秒杀）", CurrentValue = false, Callback = function(v) Settings.KillAura = v; StartKillAura() end })
CombatTab:CreateSlider({ Name = "光环范围", Range = {100, 1000}, Increment = 1, CurrentValue = 500, Callback = function(v) Settings.KillAuraRange = v or 500 end })

CombatTab:CreateSection("枪械改装")
CombatTab:CreateToggle({ Name = "无限弹药（含RPG）", CurrentValue = false, Callback = function(v) Settings.InfiniteAmmo = v end })
CombatTab:CreateToggle({ Name = "无后坐力", CurrentValue = false, Callback = function(v) Settings.NoRecoil = v end })
CombatTab:CreateToggle({ Name = "极速射速", CurrentValue = false, Callback = function(v) Settings.RapidFire = v end })

CombatTab:CreateSection("RPG 模式")
CombatTab:CreateToggle({ Name = "跟随准星连发", CurrentValue = false, Callback = function(v) Settings.RocketSpam = v; StartRocketSpam() end })
CombatTab:CreateSlider({ Name = "连发间隔（秒）", Range = {0.01, 0.2}, Increment = 0.01, CurrentValue = 0.03, Callback = function(v) Settings.RocketSpamDelay = v or 0.03 end })
CombatTab:CreateToggle({ Name = "RPG 全图追踪杀戮", CurrentValue = false, Callback = function(v) Settings.RPGTrack = v; StartRPGTrack() end })
CombatTab:CreateSlider({ Name = "攻击间隔（秒）", Range = {0.05, 0.5}, Increment = 0.01, CurrentValue = 0.1, Callback = function(v) Settings.RPGTrackDelay = v or 0.1 end })
CombatTab:CreateLabel("说明：开启全图追踪后，自动轮流攻击所有非白名单敌人（距离>10米），无限弹药，不会误伤自己。")

-- ESP标签页
ESPTab:CreateSection("视觉效果")
ESPTab:CreateToggle({ Name = "启用ESP", CurrentValue = false, Callback = function(v) Settings.ESPEnabled = v end })
ESPTab:CreateToggle({ Name = "方框ESP", CurrentValue = true, Callback = function(v) Settings.ESPBoxes = v end })
ESPTab:CreateToggle({ Name = "名称ESP", CurrentValue = true, Callback = function(v) Settings.ESPNames = v end })
ESPTab:CreateToggle({ Name = "血量ESP", CurrentValue = true, Callback = function(v) Settings.ESPHealth = v end })

-- 自动农场标签页
FarmTab:CreateSection("自动收集")
FarmTab:CreateToggle({ Name = "自动收集现金", CurrentValue = false, Callback = function(v) Settings.AutoCash = v; startAutoFarm() end })
FarmTab:CreateToggle({ Name = "自动油桶", CurrentValue = false, Callback = function(v) Settings.AutoOil = v; startAutoFarm() end })
FarmTab:CreateToggle({ Name = "自动空投", CurrentValue = false, Callback = function(v) Settings.AutoAirdrop = v; startAutoFarm() end })
FarmTab:CreateToggle({ Name = "自动掠夺板条箱", CurrentValue = false, Callback = function(v) Settings.AutoStealCrate = v; startAutoFarm() end })
FarmTab:CreateToggle({ Name = "自动转生", CurrentValue = false, Callback = function(v) Settings.AutoRebirth = v; if v then startRebirth() end end })
FarmTab:CreateToggle({ Name = "自动每日奖励", CurrentValue = false, Callback = function(v) Settings.AutoClaimDaily = v; startClaim() end })
FarmTab:CreateToggle({ Name = "自动会话奖励", CurrentValue = false, Callback = function(v) Settings.AutoClaimSession = v; startClaim() end })
FarmTab:CreateToggle({ Name = "自动轮盘抽奖", CurrentValue = false, Callback = function(v) Settings.AutoClaimWheel = v; startClaim() end })

-- 移动标签页
MoveTab:CreateSection("移动增强")
MoveTab:CreateToggle({ Name = "飞行模式", CurrentValue = false, Callback = function(v) Settings.Fly = v; StartFly() end })
MoveTab:CreateSlider({ Name = "飞行速度", Range = {20, 300}, Increment = 1, CurrentValue = 80, Callback = function(v) Settings.FlySpeed = v or 80 end })
MoveTab:CreateToggle({ Name = "穿墙模式", CurrentValue = false, Callback = function(v) Settings.Noclip = v; StartNoclip() end })
MoveTab:CreateToggle({ Name = "免疫摔伤", CurrentValue = false, Callback = function(v) Settings.NoFallDamage = v; StartNoFallDamage() end })
MoveTab:CreateToggle({ Name = "加速行走", CurrentValue = false, Callback = function(v) Settings.SpeedBoost = v end })
MoveTab:CreateSlider({ Name = "行走速度", Range = {16, 200}, Increment = 1, CurrentValue = 32, Callback = function(v) Settings.SpeedBoostValue = v or 32 end })
MoveTab:CreateToggle({ Name = "超级跳跃", CurrentValue = false, Callback = function(v) Settings.JumpBoost = v end })
MoveTab:CreateSlider({ Name = "跳跃力度", Range = {50, 300}, Increment = 1, CurrentValue = 50, Callback = function(v) Settings.JumpBoostValue = v or 50 end })
MoveTab:CreateToggle({ Name = "无限跳跃", CurrentValue = false, Callback = function(v) Settings.InfiniteJump = v; if v then StartInfiniteJump() end end })

-- 综合标签页
MiscTab:CreateSection("实用工具")
MiscTab:CreateToggle({ Name = "反AFK", CurrentValue = false, Callback = function(v) Settings.AntiAFK = v; StartAntiAFK() end })
MiscTab:CreateToggle({ Name = "昼夜切换", CurrentValue = false, Callback = function(v) Settings.DayNight = v; ToggleDayNight() end })
MiscTab:CreateButton({ Name = "清除所有板条箱", Callback = RemoveAllCrates })
MiscTab:CreateButton({ Name = "重新加入服务器", Callback = RejoinServer })

-- ================= 白名单标签页（可点击的玩家列表） =================
WhiteListTab:CreateSection("白名单管理")
WhiteListTab:CreateLabel("点击下方玩家名称，即可添加/移除白名单（白名单玩家不会被攻击）")

local playerListFrame = Instance.new("ScrollingFrame")
playerListFrame.Size = UDim2.new(1, 0, 0, 300)
playerListFrame.Position = UDim2.new(0, 0, 0, 60)
playerListFrame.BackgroundTransparency = 1
playerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
playerListFrame.ScrollBarThickness = 8
playerListFrame.Parent = WhiteListTab.Container

local function UpdatePlayerList()
    for _, child in ipairs(playerListFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    local y = 5
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 32)
        btn.Position = UDim2.new(0, 5, 0, y)
        btn.Text = plr.Name
        btn.BackgroundColor3 = IsWhiteListed(plr.Name) and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(45, 45, 55)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.Parent = playerListFrame
        btn.MouseButton1Click:Connect(function()
            local nameLow = plr.Name:lower()
            if Settings.WhiteList[nameLow] then
                Settings.WhiteList[nameLow] = nil
                btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
                btn.Text = plr.Name
                Rayfield:Notify({Title = "白名单", Content = "已移除: " .. plr.Name, Duration = 1})
            else
                Settings.WhiteList[nameLow] = true
                btn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
                btn.Text = plr.Name .. " ✓"
                Rayfield:Notify({Title = "白名单", Content = "已添加: " .. plr.Name, Duration = 1})
            end
        end)
        y = y + 40
    end
    playerListFrame.CanvasSize = UDim2.new(0, 0, 0, y + 10)
end
UpdatePlayerList()
Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoving:Connect(UpdatePlayerList)

WhiteListTab:CreateButton({
    Name = "清空白名单",
    Callback = function()
        Settings.WhiteList = {}
        UpdatePlayerList()
        Rayfield:Notify({Title = "白名单", Content = "已清空", Duration = 2})
    end
})

-- ================= 启动所有功能循环（默认关闭） =================
StartSilentAim()
StartKillAura()
StartRocketSpam()
StartRPGTrack()
StartFly()
StartNoclip()
StartNoFallDamage()
StartAntiAFK()
startAutoFarm()

Rayfield:Notify({Title = "脚本加载完成", Content = "RPG全图追踪已就绪 | 在白名单中添加队友 | 按 RightControl 开关菜单", Duration = 6})
