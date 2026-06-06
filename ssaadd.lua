--[[
    警告：此脚本仅供参考学习使用，请遵守Roblox服务条款。
    使用脚本可能违反游戏规则，可能导致账号受限。
    原始脚本中的功能完全保留，仅UI更换为Rayfield。
    使用前请确保已了解相关风险。
]]

-- 检查游戏ID，如果不是目标游戏则显示警告并退出
if game.GameId ~= 847722000 then
    print("警告：此脚本专为Rake游戏设计，当前游戏ID不匹配，脚本无法正常执行。")
    return
end

-- 加载Rayfield UI库，增加加载失败处理
local RayfieldLoaded, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)
if not RayfieldLoaded then
    warn("Rayfield库加载失败，无法显示UI。请检查网络后重试。")
    return
end

local Window = Rayfield:CreateWindow({
    Name = "Rake GUI | Rayfield",
    Icon = 0,
    LoadingTitle = "正在加载 Rake GUI",
    LoadingSubtitle = "by lts",
    ToggleUIKeybind = "K",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false
})

-- 创建各个标签页
local MainTab = Window:CreateTab("玩家增强")
local CombatTab = Window:CreateTab("战斗辅助")
local ESPTab = Window:CreateTab("透视ESP")
local WorldTab = Window:CreateTab("世界修改")
local MuteTab = Window:CreateTab("音量调节")
local MiscTab = Window:CreateTab("杂项设置")
local UISettingsTab = Window:CreateTab("界面设置")

-- 原有的配置读取与持久化逻辑（保留自原始脚本）
local __lt = (function()
    local globalEnv = _G or {}
    local sharedEnv = rawget(_G, "shared")
    local cacheHost = type(sharedEnv) == "table" and sharedEnv or (type(globalEnv) == "table" and globalEnv or nil)
    if cacheHost then
        local cached = rawget(cacheHost, "__lt_service_resolver")
        if type(cached) == "table" then return cached end
    end
    local loader = loadstring or load
    if type(loader) ~= "function" then error("Service resolver loader unavailable") end
    local resolver = loader(game:HttpGet("https://ltseverydayyou.github.io/ServiceResolver.luau"), "@ServiceResolver.luau")
    if type(resolver) ~= "function" then error("Service resolver failed to compile") end
    local loaded = resolver()
    if type(loaded) ~= "table" then error("Service resolver failed to load") end
    if cacheHost then cacheHost.__lt_service_resolver = loaded end
    return loaded
end)()

local genv = _G
local Http = game:GetService("HttpService")
local cfgFolder = "ProjectTheRake"
local fileApi = type(readfile) == "function" and type(writefile) == "function"
local hasFile = type(isfile) == "function"
local folderApi = type(makefolder) == "function"
local cfgFile = folderApi and (cfgFolder .. "/ProjectState.json") or "ProjectTheRake_ProjectState.json"
local hasFolder = type(isfolder) == "function"
local saved = {}
local function makeCfgFolder()
    if not folderApi then return end
    pcall(function()
        if not hasFolder or not isfolder(cfgFolder) then makefolder(cfgFolder) end
    end)
end
local function loadCfg()
    if not fileApi then return {} end
    local ok, res = pcall(function()
        if hasFile and not isfile(cfgFile) then return {} end
        local raw = readfile(cfgFile)
        if type(raw) ~= "string" or raw == "" then return {} end
        local dec = Http:JSONDecode(raw)
        return type(dec) == "table" and dec or {}
    end)
    return ok and res or {}
end
local function saveCfg(tbl)
    if not fileApi then return false end
    makeCfgFolder()
    local out = {}
    for k, v in tbl or {} do
        local tv = typeof(v)
        if tv == "boolean" or tv == "number" or tv == "string" then out[k] = v end
    end
    local ok = pcall(function() writefile(cfgFile, Http:JSONEncode(out)) end)
    return ok
end
local saveQueued = false
local saveDirty = false
local function saveLater()
    if not fileApi then return end
    saveDirty = true
    if saveQueued then return end
    saveQueued = true
    if type(task) ~= "table" or type(task.delay) ~= "function" then
        saveQueued = false
        saveDirty = false
        saveCfg(saved)
        return
    end
    task.delay(0.6, function()
        saveQueued = false
        if saveDirty then
            saveDirty = false
            saveCfg(saved)
        end
    end)
end
saved = loadCfg()
local st = genv.RakeGuiState
if type(st) ~= "table" then st = {} genv.RakeGuiState = st end

local function cfgGet(k, def)
    if saved[k] ~= nil then return saved[k] end
    if st[k] ~= nil then return st[k] end
    return def
end
local function cfgSet(k, v)
    st[k] = v
    saved[k] = v
    saveLater()
end
local function cfgBool(k, def) return cfgGet(k, def) == true end
local function cfgNum(k, def, min, max)
    local n = tonumber(cfgGet(k, def)) or def
    if min and max then n = math.clamp(n, min, max) end
    return n
end
local function uiKeyCode(v, def)
    if typeof(v) == "EnumItem" then return v end
    local s = tostring(v or "")
    s = s:gsub("^Enum%.%KeyCode%.", ""):gsub("^KeyCode%.", "")
    local ok, key = pcall(function() return Enum.KeyCode[s] end)
    if ok and key then return key end
    return def or Enum.KeyCode.RightControl
end
local function uiKeyName(v, def)
    if typeof(v) == "EnumItem" then return v.Name end
    local key = uiKeyCode(v, nil)
    if key then return key.Name end
    return tostring(def or "RightControl")
end
local function uiBoolSet(k, v) cfgSet(k, v == true) end

st.fov = cfgNum("fov", tonumber(_G.FieldOfView) or 70, 1, 120)
st.fovOn = cfgBool("fovOn", _G.enableFOV == true)
st.fovUiFix = cfgBool("fovUiFix", true)
st.spd = cfgNum("spd", tonumber(_G.WalkSpeedd) or 16, 0, 30)
st.spdOn = cfgBool("spdOn", _G.enableSpeed == true)
st.freeCam = false
st.freeCamSpeed = 0.2
st.noFog = cfgBool("noFog", false)
st.infStamina = cfgBool("infStamina", false)
st.infNight = cfgBool("infNight", false)
st.rakeAura = cfgBool("rakeAura", false)
st.rakeAuraRange = cfgNum("rakeAuraRange", 12, 6, 30)
st.rakeAuraDelay = cfgNum("rakeAuraDelay", 0.12, 0.05, 0.6)
st.rakeAuraAutoEquip = cfgBool("rakeAuraAutoEquip", true)
st.rakeChams = cfgBool("rakeChams", false)
st.playerEsp = cfgBool("playerEsp", false)
st.flareEsp = cfgBool("flareEsp", false)
st.dropEsp = cfgBool("dropEsp", false)
st.locEsp = cfgBool("locEsp", false)
st.scrapEsp = cfgBool("scrapEsp", false)
st.trapEsp = cfgBool("trapEsp", false)
st.hide = false
st.noFall = cfgBool("noFall", false)
st.instaDrop = cfgBool("instaDrop", false)
st.instaTrap = cfgBool("instaTrap", false)
st.espSize = cfgNum("espSize", 12, 8, 24)
st.espScan = cfgNum("espScan", 0.75, 0.2, 3)
st.espMax = cfgNum("espMax", 0, 0, 5000)
st.espOutline = false
st.espChams = cfgBool("espChams", true)
st.espDist = cfgBool("espDist", false)
st.uiBind = uiKeyName(cfgGet("uiBind", "RightControl"), "RightControl")
st.uiCursor = cfgBool("uiCursor", true)
st.uiDragLock = cfgBool("uiDragLock", false)
st.uiCompact = cfgBool("uiCompact", false)
st.uiResizable = cfgBool("uiResizable", true)
st.uiMobileButtons = cfgBool("uiMobileButtons", true)
st.uiMobileRight = cfgBool("uiMobileRight", false)
st.uiUnlockMouse = cfgBool("uiUnlockMouse", true)
st.uiSearchBar = cfgBool("uiSearchBar", true)
st.uiGlobalSearch = cfgBool("uiGlobalSearch", false)
st.uiSidebarResize = cfgBool("uiSidebarResize", true)
st.uiCompacting = cfgBool("uiCompacting", true)
st.uiNoSnap = cfgBool("uiNoSnap", false)
st.uiToggleFrames = cfgBool("uiToggleFrames", true)
st.uiCorner = cfgNum("uiCorner", 4, 0, 20)
st.uiDpi = cfgNum("uiDpi", 100, 50, 200)
st.infoBubble = cfgBool("infoBubble", true)
st.radioSounds = cfgBool("radioSounds", true)
st.radioNotifications = cfgBool("radioNotifications", false)
st.disableDeathFx = cfgBool("disableDeathFx", false)
st.disableMotionBlur = cfgBool("disableMotionBlur", false)
st.disableMenuFx = cfgBool("disableMenuFx", false)
st.introBypass = cfgBool("introBypass", false)
st.promptBypass = cfgBool("promptBypass", false)
st.promptDistance = cfgNum("promptDistance", 25, 5, 100)
st.disableShadows = cfgBool("disableShadows", false)
st.forceChat = cfgBool("forceChat", false)
st.muteGameMusic = cfgBool("muteGameMusic", false)
st.muteChaseMusic = cfgBool("muteChaseMusic", false)
st.enableNametags = cfgBool("enableNametags", false)
st.enableSixthSense = cfgBool("enableSixthSense", false)
st.muteMovementSounds = cfgBool("muteMovementSounds", false)
st.muteFootsteps = cfgBool("muteFootsteps", false)
st.muteJumpLand = cfgBool("muteJumpLand", false)
st.muteWaterFall = cfgBool("muteWaterFall", false)
st.muteDeathSounds = cfgBool("muteDeathSounds", false)
st.hidePromptUi = cfgBool("hidePromptUi", false)
st.freezeLookAngles = cfgBool("freezeLookAngles", false)
st.hideDeathMessages = cfgBool("hideDeathMessages", false)
st.blockFavoritePrompts = cfgBool("blockFavoritePrompts", false)
st.blockGroupPrompts = cfgBool("blockGroupPrompts", false)
st.forcePcDevice = cfgBool("forcePcDevice", false)
st.flashlightNoShadows = cfgBool("flashlightNoShadows", false)
st.flashlightBoost = cfgBool("flashlightBoost", false)
st.disableMenuReopen = cfgBool("disableMenuReopen", false)
st.forceBackpack = cfgBool("forceBackpack", false)
st.forceTopbar = cfgBool("forceTopbar", false)
st.forceMouseIcon = cfgBool("forceMouseIcon", false)
st.disableCameraShake = cfgBool("disableCameraShake", false)
st.disableCameraBobbing = cfgBool("disableCameraBobbing", false)
st.disableVisualFx = cfgBool("disableVisualFx", false)
st.hideLocationPopups = cfgBool("hideLocationPopups", false)
st.hideScrapPopups = cfgBool("hideScrapPopups", false)
st.hideTrapGui = cfgBool("hideTrapGui", false)
st.knownPromptBypass = cfgBool("knownPromptBypass", false)
st.noDowned = cfgBool("noDowned", false)
st.noMoveLock = cfgBool("noMoveLock", false)
st.noTrapLock = cfgBool("noTrapLock", false)
st.noJumpCooldown = cfgBool("noJumpCooldown", false)
st.noJumpscareCam = cfgBool("noJumpscareCam", false)
st.noChaseStatic = cfgBool("noChaseStatic", false)
st.safeRecover = cfgBool("safeRecover", false)
st.fullbright = cfgBool("fullbright", false)
st.autoDropPrompts = false
st.autoSafePrompts = false
st.autoTowerPrompts = false
st.autoPowerPrompts = false
st.adonisBypass = cfgBool("adonisBypass", true)

_G.FieldOfView = st.fov
_G.enableFOV = st.fovOn
_G.RakeFovUiFix = st.fovUiFix
_G.WalkSpeedd = st.spd
_G.enableSpeed = st.spdOn
_G.FreeCam = false
_G.FreeCamSpeed = st.freeCamSpeed
_G.NoFog = st.noFog
_G.InfStamina = st.infStamina
_G.InfNightVision = st.infNight
_G.RakeKillAura = st.rakeAura
_G.RakeAuraRange = st.rakeAuraRange
_G.RakeAuraDelay = st.rakeAuraDelay
_G.RakeAuraAutoEquip = st.rakeAuraAutoEquip
_G.RakeChams = st.rakeChams
_G.PlayerESP = st.playerEsp
_G.PlayerESPShowDistance = st.showDist
_G.FlareGunESP = st.flareEsp
_G.SupplyDropESP = st.dropEsp
_G.LocationESP = st.locEsp
_G.ScrapESP = st.scrapEsp
_G.RakeTrapESP = st.trapEsp
_G.NoFallDMG = st.noFall
_G.InstaOpenSupplyDrop = st.instaDrop
_G.InstaCloseRakeTrap = st.instaTrap
_G.RakeDisableDeathFx = st.disableDeathFx
_G.RakeDisableMotionBlur = st.disableMotionBlur
_G.RakeDisableMenuFx = st.disableMenuFx
_G.RakeIntroBypass = st.introBypass
_G.RakePromptBypass = st.promptBypass
_G.RakeDisableShadows = st.disableShadows
_G.RakeForceChat = st.forceChat
_G.RakeForceNametags = st.enableNametags
_G.RakeForceSixthSense = st.enableSixthSense
_G.RakeMuteMovementSounds = st.muteMovementSounds
_G.RakeMuteFootsteps = st.muteFootsteps
_G.RakeMuteJumpLand = st.muteJumpLand
_G.RakeMuteWaterFall = st.muteWaterFall
_G.RakeMuteDeathSounds = st.muteDeathSounds
_G.RakeHidePromptUi = st.hidePromptUi
_G.RakeFreezeLookAngles = st.freezeLookAngles
_G.RakeHideDeathMessages = st.hideDeathMessages
_G.RakeBlockFavoritePrompts = st.blockFavoritePrompts
_G.RakeBlockGroupPrompts = st.blockGroupPrompts
_G.RakeFlashlightNoShadows = st.flashlightNoShadows
_G.RakeFlashlightBoost = st.flashlightBoost
_G.RakeDisableMenuReopen = st.disableMenuReopen
_G.RakeHideLocationPopups = st.hideLocationPopups
_G.RakeHideScrapPopups = st.hideScrapPopups
_G.RakeHideTrapGui = st.hideTrapGui
_G.RakeKnownPromptBypass = st.knownPromptBypass
_G.RakeNoDowned = st.noDowned
_G.RakeNoMoveLock = st.noMoveLock
_G.RakeNoTrapLock = st.noTrapLock
_G.RakeNoJumpCooldown = st.noJumpCooldown
_G.RakeNoJumpscareCam = st.noJumpscareCam
_G.RakeNoChaseStatic = st.noChaseStatic
_G.RakeSafeRecover = st.safeRecover
_G.RakeFullbright = st.fullbright
_G.RakeAutoDropPrompts = false
_G.RakeAutoSafePrompts = false
_G.RakeAutoTowerPrompts = false
_G.RakeAutoPowerPrompts = false

if genv.RakeGui then return end

local svc = {}
local ref = cloneref or function(v) return v end
local function ClonedService(name)
    local c = svc[name]
    if c then return c end
    local ok, res = pcall(function() return __lt.cs(name, ref) end)
    if ok and res then svc[name] = res return res end
    local raw = __lt.gs(name)
    local out = raw and ref(raw) or raw
    svc[name] = out
    return out
end
local function resolveAdonisEnv()
    local gc = getgc or (debug and debug.getgc)
    local hookf = hookfunction
    local env = getrenv
    local renv = nil
    if type(env) == "function" then pcall(function() renv = env() end) end
    local dbgInfo = (type(renv) == "table" and renv.debug and renv.debug.info) or (debug and debug.info)
    local newcc = newcclosure or function(fn) return fn end
    local typeOf = typeof or function(value) return type(value) end
    return gc, hookf, env, dbgInfo, newcc, typeOf
end
local function eachAdonisGc(fn)
    local gc = getgc or (debug and debug.getgc)
    if type(gc) ~= "function" then return false end
    local ok, list = pcall(gc, true)
    if not ok or type(list) ~= "table" then return false end
    for _, value in next, list do
        local stop = fn(value)
        if stop then return true end
    end
    return true
end
local function detectAdonis()
    local gc, hookf, env, dbgInfo, _, typeOf = resolveAdonisEnv()
    if not (type(gc) == "function" and type(hookf) == "function" and type(env) == "function" and type(dbgInfo) == "function") then return false end
    local found = false
    eachAdonisGc(function(value)
        if typeOf(value) == "table" then
            local hasDetected = typeOf(rawget(value, "Detected")) == "function"
            local hasKill = typeOf(rawget(value, "Kill")) == "function"
            local hasVars = rawget(value, "Variables") ~= nil
            local hasProcess = rawget(value, "Process") ~= nil
            if hasDetected or (hasKill and hasVars and hasProcess) then
                found = true
                return true
            end
        end
    end)
    return found
end
local function bypassAdonis()
    local gc, hookf, env, dbgInfo, newcc, typeOf = resolveAdonisEnv()
    if not (type(gc) == "function" and type(hookf) == "function" and type(env) == "function" and type(dbgInfo) == "function") then return false end
    local DetectedMeth, KillMeth
    eachAdonisGc(function(value)
        if typeOf(value) == "table" then
            local detected = rawget(value, "Detected")
            local kill = rawget(value, "Kill")
            if typeOf(detected) == "function" and not DetectedMeth then
                DetectedMeth = detected
                pcall(function()
                    hookf(detected, function() end)
                end)
            end
            if rawget(value, "Variables") and rawget(value, "Process") and typeOf(kill) == "function" and not KillMeth then
                KillMeth = kill
                pcall(function()
                    hookf(kill, function(killFunc) end)
                end)
            end
            if DetectedMeth and KillMeth then return true end
        end
    end)
    if DetectedMeth and dbgInfo then
        local old
        pcall(function()
            old = hookf(dbgInfo, newcc(function(...)
                local functionName = ...
                if functionName == DetectedMeth then
                    return coroutine.yield(coroutine.running())
                end
                return old(...)
            end))
        end)
    end
    return DetectedMeth ~= nil
end
local function runAdonisBypass(force)
    if st.adonisBypass ~= true and force ~= true then return false end
    if genv.RakeAdonisBypassed then return true end
    local ok, detected = pcall(detectAdonis)
    if ok and detected and bypassAdonis() then
        genv.RakeAdonisBypassed = true
        return true
    end
    return false
end
_G.RakeAdonisBypass = st.adonisBypass
task.spawn(runAdonisBypass)

local Me = {
    LocalPlayer = ClonedService("Players").LocalPlayer,
    Character = ClonedService("Players").LocalPlayer.Character,
}
local AllowRunService = true
local Run = ClonedService("RunService")
local Ws = ClonedService("Workspace")
local Plrs = ClonedService("Players")
local Rep = ClonedService("ReplicatedStorage")
local Lit = ClonedService("Lighting")
local Tws = ClonedService("TweenService")
local wait = task and task.wait or wait

local conns = {}
local wipeFog
local cleanupEsp
local esp
local function bind(sig, fn)
    if not sig or type(fn) ~= "function" then return nil end
    local ok, c = pcall(function() return sig:Connect(fn) end)
    if ok and c then
        conns[#conns + 1] = c
        return c
    end
    return nil
end
local function wipeConns()
    for i = #conns, 1, -1 do
        local c = conns[i]
        if c then pcall(function() c:Disconnect() end) end
        conns[i] = nil
    end
end
local function safeDestroy(v)
    if v then pcall(function() v:Destroy() end) end
end
local function safeDrawRemove(v)
    if v then
        pcall(function()
            v.Visible = false
            if type(v.Remove) == "function" then v:Remove()
            elseif type(v.Destroy) == "function" then v:Destroy() end
        end)
    end
end
local function kids(v)
    if not v then return {} end
    local ok, res = pcall(function() return v:GetChildren() end)
    return ok and res or {}
end
local function desc(v)
    if not v then return {} end
    local ok, res = pcall(function() return v:QueryDescendants("Instance") end)
    if ok and res then return res end
    ok, res = pcall(function() return v:GetDescendants() end)
    return ok and res or {}
end
local function addEnv(list, seen, env)
    if type(env) == "table" and not seen[env] then
        seen[env] = true
        list[#list + 1] = env
    end
end
local function getModuleEnvList()
    local list = {}
    local seen = {}
    addEnv(list, seen, _G)
    pcall(function() addEnv(list, seen, shared) end)
    pcall(function() addEnv(list, seen, rawget(_G, "shared")) end)
    local envs = getScriptEnvs()
    for i = 1, #envs do
        local env = envs[i]
        addEnv(list, seen, env)
        pcall(function()
            addEnv(list, seen, rawget(env, "_G"))
            addEnv(list, seen, rawget(env, "shared"))
        end)
    end
    return list
end
local function isLiveInst(obj)
    if typeof(obj) ~= "Instance" then return false end
    local ok, par = pcall(function() return obj.Parent end)
    if not ok or par == nil then return false end
    local ok2, live = pcall(function() return obj:IsDescendantOf(game) end)
    return ok2 and live == true
end
local function isLiveMod(mod)
    return isLiveInst(mod) and mod:IsA("ModuleScript")
end
local function safeReq(mod)
    if type(require) ~= "function" then return false end
    if not isLiveMod(mod) then return false end
    return pcall(require, mod)
end
local function ffc(v, name)
    if not v then return nil end
    local ok, res = pcall(function() return v:FindFirstChild(name) end)
    return ok and res or nil
end
local function ffcr(v, name)
    if not v then return nil end
    local ok, res = pcall(function() return v:FindFirstChild(name, true) end)
    return ok and res or nil
end
local function ffca(v, class)
    if not v then return nil end
    local ok, res = pcall(function() return v:FindFirstChildWhichIsA(class, true) end)
    return ok and res or nil
end
local zeroVelocity = Vector3.new(0, 0, 0)
local function isPlayerCharacterPart(part)
    local model = part and part:FindFirstAncestorOfClass("Model")
    while model do
        local ok, player = pcall(function() return Plrs:GetPlayerFromCharacter(model) end)
        if ok and player then return true end
        local parent = model.Parent
        model = parent and parent:FindFirstAncestorOfClass("Model") or nil
    end
    return false
end
local function zeroBasePartVelocity(obj)
    if not obj or not obj:IsA("BasePart") or isPlayerCharacterPart(obj) then return end
    pcall(function()
        if obj.AssemblyLinearVelocity ~= zeroVelocity then obj.AssemblyLinearVelocity = zeroVelocity end
    end)
end
local function zeroWorkspaceBasePartVelocities()
    local ok, objects = pcall(function() return Ws:GetDescendants() end)
    for _, obj in ok and objects or {} do zeroBasePartVelocity(obj) end
end
bind(Ws.DescendantAdded, function(obj) zeroBasePartVelocity(obj) end)
bind(Ws.DescendantRemoving, function(obj) zeroBasePartVelocity(obj) end)
if type(task) == "table" and type(task.defer) == "function" then task.defer(zeroWorkspaceBasePartVelocities)
else zeroWorkspaceBasePartVelocities() end

local function valOf(v, def)
    if not v then return def end
    local ok, res = pcall(function() return v.Value end)
    if ok and res ~= nil then return res end
    return def
end
local function eachGc(fn)
    if type(getgc) ~= "function" then return false end
    local ok, res = pcall(getgc, true)
    if not ok or type(res) ~= "table" then return false end
    for _, v in res do pcall(fn, v) end
    return true
end
local infSys = { tabs = setmetatable({}, { __mode = "k" }), token = 0, fast = 1, scan = 2.5 }
local function patchInfTab(v)
    if type(v) ~= "table" then return false end
    local hit = false
    if st.infStamina == true and rawget(v, "STAMINA_REGEN") ~= nil then
        v.STAMINA_REGEN = 100
        v.JUMP_STAMINA = 0
        v.JUMP_COOLDOWN = 0
        v.STAMINA_TAKE = 0
        v.stamina = 100
        hit = true
    end
    if st.infNight == true and rawget(v, "NVG_TAKE") ~= nil then
        v.NVG_TAKE = 0
        v.NVG_REGEN = 100
        hit = true
    end
    if hit then infSys.tabs[v] = true end
    return hit
end
local function applyInfTabs(scan)
    if st.infStamina ~= true and st.infNight ~= true then return end
    for v in infSys.tabs do pcall(patchInfTab, v) end
    if scan == true then eachGc(patchInfTab) end
end
local function queueInfTabs(loops)
    if st.infStamina ~= true and st.infNight ~= true then return end
    infSys.token += 1
    local token = infSys.token
    task.spawn(function()
        for i = 1, loops or 12 do
            if token ~= infSys.token or AllowRunService ~= true then return end
            applyInfTabs(i == 1)
            task.wait(i <= 4 and 0.25 or 0.75)
        end
    end)
end

local HidePart
local HidePartHightLight
local curChar
local curHum
local curHrp
local charConns = {}
local function wipeCharConns()
    for i = #charConns, 1, -1 do
        local c = charConns[i]
        if c then pcall(function() c:Disconnect() end) end
        charConns[i] = nil
    end
end
local function bindChar(sig, fn)
    if not sig or type(fn) ~= "function" then return nil end
    local ok, c = pcall(function() return sig:Connect(fn) end)
    if ok and c then charConns[#charConns + 1] = c return c end
    return nil
end
local function getChar()
    local lp = Plrs.LocalPlayer
    local ch = lp and lp.Character
    if ch then curChar = ch end
    return curChar
end
local function getHum()
    if curHum and curHum.Parent then return curHum end
    local ch = getChar()
    if not ch then return nil end
    local hum = ffca(ch, "Humanoid")
    if hum then curHum = hum return hum end
    return nil
end
local function GET_HRP()
    local ch = getChar()
    if not ch then return nil end
    if curHrp and curHrp.Parent == ch then return curHrp end
    local r = ffcr(ch, "HumanoidRootPart")
    if r then curHrp = r end
    return r
end
local function SET_HRP_CFRAME(cframer)
    local r = GET_HRP()
    if r then r.CFrame = cframer return true end
    return false
end
local function SET_HRP_ANCHORED(v)
    local r = GET_HRP()
    if r then r.Anchored = v == true return true end
    return false
end
local clientBypass = {}
clientBypass.originals = {}
clientBypass.mutedSounds = setmetatable({}, { __mode = "k" })
clientBypass.prompts = setmetatable({}, { __mode = "k" })
clientBypass.promptHold = setmetatable({}, { __mode = "k" })
clientBypass.ch = setmetatable({}, { __mode = "k" })
clientBypass.chT = 3
clientBypass.fullbrightOn = false
clientBypass.lastSafe = nil
clientBypass.fovUiCache = setmetatable({}, { __mode = "k" })
clientBypass.fovUiScanned = false
clientBypass.bobFns = setmetatable({}, { __mode = "k" })
clientBypass.uiState = setmetatable({}, { __mode = "k" })
clientBypass.stamMods = setmetatable({}, { __mode = "k" })
clientBypass.mainMods = setmetatable({}, { __mode = "k" })
clientBypass.modRoots = setmetatable({}, { __mode = "k" })
clientBypass.stamTk = setmetatable({}, { __mode = "k" })
clientBypass.stamScanT = 12
clientBypass.gstmnaOwned = false
function clientBypass.getCamera() return Ws.CurrentCamera or workspace.CurrentCamera end
function clientBypass.getPlayerGui()
    local lp = Plrs.LocalPlayer
    return lp and ffc(lp, "PlayerGui") or nil
end
function clientBypass.getGSettings()
    local gs = getScriptTable("GSettings")
    return gs
end
function clientBypass.setCoreGuiEnabled(kind, enabled)
    local starter = ClonedService("StarterGui")
    pcall(function() starter:SetCoreGuiEnabled(kind, enabled == true) end)
end
function clientBypass.restoreCoreGui()
    local starter = ClonedService("StarterGui")
    pcall(function() starter:SetCore("TopbarEnabled", true) end)
    pcall(function() starter:SetCore("ResetButtonCallback", true) end)
    clientBypass.setCoreGuiEnabled(Enum.CoreGuiType.Health, true)
    clientBypass.setCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
    clientBypass.setCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
    clientBypass.setCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
    pcall(function() ClonedService("UserInputService").MouseIconEnabled = true end)
end
function clientBypass.forceCoreParts()
    if st.forceTopbar == true then
        pcall(function() ClonedService("StarterGui"):SetCore("TopbarEnabled", true) end)
    end
    if st.forceBackpack == true then
        clientBypass.setCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
    end
    if st.forceMouseIcon == true then
        pcall(function() ClonedService("UserInputService").MouseIconEnabled = true end)
    end
end
function clientBypass.destroyCameraEffects(match)
    local cam = clientBypass.getCamera()
    if not cam then return 0 end
    local removed = 0
    for _, v in kids(cam) do if match(v) then removed += 1 safeDestroy(v) end end
    return removed
end
function clientBypass.applyMotionBlurBypass()
    if st.disableMotionBlur ~= true then return 0 end
    local gs = clientBypass.getGSettings()
    gs.MotionBlur = false
    setScriptGlobal("GSettings", gs)
    return clientBypass.destroyCameraEffects(function(v)
        return (v:IsA("BlurEffect") and (v.Name == "MotionBlur" or v.Name == "ESCB")) or (v:IsA("ColorCorrectionEffect") and v.Name == "ESCC")
    end)
end
function clientBypass.applyMenuFxBypass()
    if st.disableMenuFx ~= true then return 0 end
    return clientBypass.destroyCameraEffects(function(v)
        return (v:IsA("BlurEffect") and v.Name == "ESCB") or (v:IsA("ColorCorrectionEffect") and v.Name == "ESCC")
    end)
end
function clientBypass.fireSettingsChanged(name, value)
    pcall(function()
        local ev = ffc(Rep, "SettingsChangedEvent")
        if ev and ev.Fire then ev:Fire(name, value) end
    end)
end
function clientBypass.defaultOriginal(key, value)
    if clientBypass.originals[key] == nil then clientBypass.originals[key] = value end
    return clientBypass.originals[key]
end
function clientBypass.setSoundVolume(name, muted)
    local ss = ClonedService("SoundService")
    local snd = ss and ffc(ss, name)
    if not snd then return false end
    local key = "SoundVolume_" .. tostring(name)
    local original = clientBypass.defaultOriginal(key, snd.Volume)
    if muted ~= true and (tonumber(original) or 0) <= 0 and (name == "GameMusic" or name == "ChaseMusic") then
        original = 1
        clientBypass.originals[key] = original
    end
    pcall(function() snd.Volume = muted == true and 0 or original end)
    return true
end
function clientBypass.ensureLocalPlayerMarker(name, enabled, className)
    local lp = Plrs.LocalPlayer
    if not lp then return nil end
    local marker = ffc(lp, name)
    if enabled ~= true then
        if marker and marker:GetAttribute("RakeAdminMarker") == true then safeDestroy(marker) end
        return nil
    end
    if not marker then
        local ok, obj = pcall(function() return Instance.new(className or "BoolValue") end)
        if not ok or not obj then return nil end
        obj.Name = name
        obj:SetAttribute("RakeAdminMarker", true)
        obj.Parent = lp
        marker = obj
    end
    pcall(function() if marker:IsA("BoolValue") then marker.Value = true end end)
    return marker
end
function clientBypass.applyGameSettingOverrides()
    local gs = clientBypass.getGSettings()
    gs.MotionBlur = st.disableMotionBlur == true and false or clientBypass.defaultOriginal("GSettings_MotionBlur", gs.MotionBlur ~= false)
    gs.Shadows = st.disableShadows == true and false or clientBypass.defaultOriginal("GSettings_Shadows", gs.Shadows ~= false)
    gs.Chat = st.forceChat == true and true or clientBypass.defaultOriginal("GSettings_Chat", gs.Chat ~= false)
    gs.GameMusic = st.muteGameMusic == true and false or clientBypass.defaultOriginal("GSettings_GameMusic", gs.GameMusic ~= false)
    gs.ChaseMusic = st.muteChaseMusic == true and false or clientBypass.defaultOriginal("GSettings_ChaseMusic", gs.ChaseMusic ~= false)
    gs.Nametags = st.enableNametags == true and true or clientBypass.defaultOriginal("GSettings_Nametags", gs.Nametags ~= false)
    pcall(function()
        local original = clientBypass.defaultOriginal("Lighting_GlobalShadows", Lit.GlobalShadows)
        Lit.GlobalShadows = st.disableShadows == true and false or original
    end)
    pcall(function() ClonedService("Chat").BubbleChatEnabled = gs.Chat == true end)
    clientBypass.setCoreGuiEnabled(Enum.CoreGuiType.Chat, gs.Chat == true)
    clientBypass.setSoundVolume("GameMusic", st.muteGameMusic == true)
    clientBypass.setSoundVolume("ChaseMusic", st.muteChaseMusic == true)
    if st.enableSixthSense == true then
        clientBypass.ensureLocalPlayerMarker("SixthSenseGamepass", true, "BoolValue")
        gs.SixthSense = true
    else
        clientBypass.ensureLocalPlayerMarker("SixthSenseGamepass", false, "BoolValue")
        gs.SixthSense = clientBypass.defaultOriginal("GSettings_SixthSense", gs.SixthSense == true)
    end
    setScriptGlobal("GSettings", gs)
end
function clientBypass.applyDeathFxBypass()
    if st.disableDeathFx ~= true then return 0 end
    pcall(function()
        local died = ffc(Rep, "DiedEvent")
        if died and died.Fire then died:Fire(false, true) end
    end)
    return clientBypass.destroyCameraEffects(function(v)
        return (v:IsA("BlurEffect") and (v.Name == "Blur" or v.Name == "BlurEffect")) or (v:IsA("ColorCorrectionEffect") and (v.Name == "ColorCorrection" or v.Name == "ColorCorrectionEffect"))
    end)
end
function clientBypass.removeIntroGui()
    local pg = clientBypass.getPlayerGui()
    if not pg then return 0 end
    local removed = 0
    for _, gui in kids(pg) do
        if gui:IsA("ScreenGui") and (gui.Name == "IntroGUI" or (ffc(gui, "LoadingFrame") and ffc(gui, "MenuFrame"))) then
            removed += 1
            safeDestroy(gui)
        end
    end
    return removed
end
function clientBypass.applyIntroBypass()
    if st.introBypass ~= true then return 0 end
    setScriptGlobal("IsLoading", nil)
    setScriptGlobal("SLoaded", true)
    local lp = Plrs.LocalPlayer
    pcall(function() if lp then lp:SetAttribute("Started", true) end end)
    clientBypass.restoreCoreGui()
    local removed = clientBypass.removeIntroGui()
    pcall(function()
        local died = ffc(Rep, "DiedEvent")
        if died and died.Fire then died:Fire(false, true) end
    end)
    return removed
end
clientBypass.applyGameSettingOverrides()
clientBypass.applyMotionBlurBypass()
clientBypass.applyMenuFxBypass()
clientBypass.applyIntroBypass()
clientBypass.applyDeathFxBypass()

-- ==================== UI 构建区 (Rayfield) - 错误隔离修复版 ====================

-- 辅助函数：安全创建控件，捕获错误并输出警告
local function safeCreate(controlType, tab, config, errorMsg)
    local success, result = pcall(function()
        if controlType == "Slider" then
            return tab:CreateSlider(config)
        elseif controlType == "Toggle" then
            return tab:CreateToggle(config)
        elseif controlType == "Keybind" then
            return tab:CreateKeybind(config)
        else
            error("未知控件类型: " .. tostring(controlType))
        end
    end)
    if not success then
        warn("[Rayfield错误] 创建控件 '" .. (config.Flag or "未命名") .. "' 失败: " .. tostring(result) .. " | " .. (errorMsg or ""))
    end
    return success, result
end

-- 玩家增强标签页
safeCreate("Slider", MainTab, {
    Name = "视野范围 (FOV)",
    Range = {1, 120},
    Increment = 1,
    CurrentValue = tonumber(st.fov) or 70,
    Flag = "fovSlider",
    Callback = function(Value)
        st.fov = Value
        _G.FieldOfView = Value
        cfgSet("fov", Value)
    end
}, "视野范围滑块")
safeCreate("Toggle", MainTab, {
    Name = "启用自定义FOV",
    CurrentValue = st.fovOn == true,
    Flag = "fovToggle",
    Callback = function(Value)
        st.fovOn = Value
        _G.enableFOV = Value
        uiBoolSet("fovOn", Value)
    end
}, "FOV开关")
safeCreate("Toggle", MainTab, {
    Name = "FOV UI修复",
    CurrentValue = st.fovUiFix == true,
    Flag = "fovUiFixToggle",
    Callback = function(Value)
        st.fovUiFix = Value
        _G.RakeFovUiFix = Value
        uiBoolSet("fovUiFix", Value)
    end
}, "FOV UI修复")
safeCreate("Slider", MainTab, {
    Name = "移动速度",
    Range = {0, 30},
    Increment = 1,
    CurrentValue = tonumber(st.spd) or 16,
    Flag = "speedSlider",
    Callback = function(Value)
        st.spd = Value
        _G.WalkSpeedd = Value
        cfgSet("spd", Value)
    end
}, "移动速度滑块")
safeCreate("Toggle", MainTab, {
    Name = "启用自定义移动速度",
    CurrentValue = st.spdOn == true,
    Flag = "speedToggle",
    Callback = function(Value)
        st.spdOn = Value
        _G.enableSpeed = Value
        uiBoolSet("spdOn", Value)
    end
}, "速度开关")
safeCreate("Toggle", MainTab, {
    Name = "无限耐力",
    CurrentValue = st.infStamina == true,
    Flag = "infStaminaToggle",
    Callback = function(Value)
        st.infStamina = Value
        _G.InfStamina = Value
        uiBoolSet("infStamina", Value)
        queueInfTabs()
    end
}, "无限耐力")
safeCreate("Toggle", MainTab, {
    Name = "无限夜视",
    CurrentValue = st.infNight == true,
    Flag = "infNightToggle",
    Callback = function(Value)
        st.infNight = Value
        _G.InfNightVision = Value
        uiBoolSet("infNight", Value)
        queueInfTabs()
    end
}, "无限夜视")
safeCreate("Toggle", MainTab, {
    Name = "无坠落伤害",
    CurrentValue = st.noFall == true,
    Flag = "noFallToggle",
    Callback = function(Value)
        st.noFall = Value
        _G.NoFallDMG = Value
        uiBoolSet("noFall", Value)
    end
}, "无坠落伤害")
safeCreate("Toggle", MainTab, {
    Name = "无跌落/倒地状态",
    CurrentValue = st.noDowned == true,
    Flag = "noDownedToggle",
    Callback = function(Value)
        st.noDowned = Value
        _G.RakeNoDowned = Value
        uiBoolSet("noDowned", Value)
    end
}, "无倒地")
safeCreate("Toggle", MainTab, {
    Name = "无移动锁定",
    CurrentValue = st.noMoveLock == true,
    Flag = "noMoveLockToggle",
    Callback = function(Value)
        st.noMoveLock = Value
        _G.RakeNoMoveLock = Value
        uiBoolSet("noMoveLock", Value)
    end
}, "无移动锁定")

-- 战斗辅助标签页
safeCreate("Toggle", CombatTab, {
    Name = "Rake Kill Aura",
    CurrentValue = st.rakeAura == true,
    Flag = "killAuraToggle",
    Callback = function(Value)
        st.rakeAura = Value
        _G.RakeKillAura = Value
        uiBoolSet("rakeAura", Value)
    end
}, "Kill aura开关")
safeCreate("Slider", CombatTab, {
    Name = "Kill Aura 范围",
    Range = {6, 30},
    Increment = 1,
    CurrentValue = tonumber(st.rakeAuraRange) or 12,
    Flag = "auraRangeSlider",
    Callback = function(Value)
        st.rakeAuraRange = Value
        _G.RakeAuraRange = Value
        cfgSet("rakeAuraRange", Value)
    end
}, "aura范围")
safeCreate("Slider", CombatTab, {
    Name = "Kill Aura 延迟 (秒)",
    Range = {0.05, 0.6},
    Increment = 0.01,
    CurrentValue = tonumber(st.rakeAuraDelay) or 0.12,
    Flag = "auraDelaySlider",
    Callback = function(Value)
        st.rakeAuraDelay = Value
        _G.RakeAuraDelay = Value
        cfgSet("rakeAuraDelay", Value)
    end
}, "aura延迟")
safeCreate("Toggle", CombatTab, {
    Name = "Kill Aura 自动装备武器",
    CurrentValue = st.rakeAuraAutoEquip == true,
    Flag = "autoEquipToggle",
    Callback = function(Value)
        st.rakeAuraAutoEquip = Value
        _G.RakeAuraAutoEquip = Value
        uiBoolSet("rakeAuraAutoEquip", Value)
    end
}, "自动装备")
safeCreate("Toggle", CombatTab, {
    Name = "Rake Chams (高亮)",
    CurrentValue = st.rakeChams == true,
    Flag = "rakeChamsToggle",
    Callback = function(Value)
        st.rakeChams = Value
        _G.RakeChams = Value
        uiBoolSet("rakeChams", Value)
    end
}, "chams")
safeCreate("Toggle", CombatTab, {
    Name = "无陷阱锁定",
    CurrentValue = st.noTrapLock == true,
    Flag = "noTrapLockToggle",
    Callback = function(Value)
        st.noTrapLock = Value
        _G.RakeNoTrapLock = Value
        uiBoolSet("noTrapLock", Value)
    end
}, "无陷阱锁定")
safeCreate("Toggle", CombatTab, {
    Name = "无跳跃冷却",
    CurrentValue = st.noJumpCooldown == true,
    Flag = "noJumpCooldownToggle",
    Callback = function(Value)
        st.noJumpCooldown = Value
        _G.RakeNoJumpCooldown = Value
        uiBoolSet("noJumpCooldown", Value)
    end
}, "无跳跃冷却")
safeCreate("Toggle", CombatTab, {
    Name = "无跳跃惊吓镜头",
    CurrentValue = st.noJumpscareCam == true,
    Flag = "noJumpscareCamToggle",
    Callback = function(Value)
        st.noJumpscareCam = Value
        _G.RakeNoJumpscareCam = Value
        uiBoolSet("noJumpscareCam", Value)
    end
}, "无惊吓镜头")
safeCreate("Toggle", CombatTab, {
    Name = "无追逐静电效果",
    CurrentValue = st.noChaseStatic == true,
    Flag = "noChaseStaticToggle",
    Callback = function(Value)
        st.noChaseStatic = Value
        _G.RakeNoChaseStatic = Value
        uiBoolSet("noChaseStatic", Value)
    end
}, "无静电")

-- 透视ESP标签页
safeCreate("Toggle", ESPTab, {
    Name = "玩家ESP",
    CurrentValue = st.playerEsp == true,
    Flag = "playerEspToggle",
    Callback = function(Value)
        st.playerEsp = Value
        _G.PlayerESP = Value
        uiBoolSet("playerEsp", Value)
    end
}, "玩家ESP")
safeCreate("Toggle", ESPTab, {
    Name = "信号枪ESP",
    CurrentValue = st.flareEsp == true,
    Flag = "flareEspToggle",
    Callback = function(Value)
        st.flareEsp = Value
        _G.FlareGunESP = Value
        uiBoolSet("flareEsp", Value)
    end
}, "信号枪ESP")
safeCreate("Toggle", ESPTab, {
    Name = "空投箱ESP",
    CurrentValue = st.dropEsp == true,
    Flag = "dropEspToggle",
    Callback = function(Value)
        st.dropEsp = Value
        _G.SupplyDropESP = Value
        uiBoolSet("dropEsp", Value)
    end
}, "空投ESP")
safeCreate("Toggle", ESPTab, {
    Name = "地点ESP",
    CurrentValue = st.locEsp == true,
    Flag = "locEspToggle",
    Callback = function(Value)
        st.locEsp = Value
        _G.LocationESP = Value
        uiBoolSet("locEsp", Value)
    end
}, "地点ESP")
safeCreate("Toggle", ESPTab, {
    Name = "物资ESP",
    CurrentValue = st.scrapEsp == true,
    Flag = "scrapEspToggle",
    Callback = function(Value)
        st.scrapEsp = Value
        _G.ScrapESP = Value
        uiBoolSet("scrapEsp", Value)
    end
}, "物资ESP")
safeCreate("Toggle", ESPTab, {
    Name = "陷阱ESP",
    CurrentValue = st.trapEsp == true,
    Flag = "trapEspToggle",
    Callback = function(Value)
        st.trapEsp = Value
        _G.RakeTrapESP = Value
        uiBoolSet("trapEsp", Value)
    end
}, "陷阱ESP")
safeCreate("Slider", ESPTab, {
    Name = "ESP文字大小",
    Range = {8, 24},
    Increment = 1,
    CurrentValue = tonumber(st.espSize) or 12,
    Flag = "espSizeSlider",
    Callback = function(Value)
        st.espSize = Value
        cfgSet("espSize", Value)
    end
}, "ESP文字大小")
safeCreate("Slider", ESPTab, {
    Name = "ESP扫描间隔 (秒)",
    Range = {0.2, 3},
    Increment = 0.05,
    CurrentValue = tonumber(st.espScan) or 0.75,
    Flag = "espScanSlider",
    Callback = function(Value)
        st.espScan = Value
        cfgSet("espScan", Value)
    end
}, "扫描间隔")
safeCreate("Toggle", ESPTab, {
    Name = "ESP Chams效果",
    CurrentValue = st.espChams == true,
    Flag = "espChamsToggle",
    Callback = function(Value)
        st.espChams = Value
        uiBoolSet("espChams", Value)
    end
}, "ESP Chams")
safeCreate("Toggle", ESPTab, {
    Name = "ESP显示距离",
    CurrentValue = st.espDist == true,
    Flag = "espDistToggle",
    Callback = function(Value)
        st.espDist = Value
        uiBoolSet("espDist", Value)
    end
}, "显示距离")

-- 世界修改标签页
safeCreate("Toggle", WorldTab, {
    Name = "无迷雾",
    CurrentValue = st.noFog == true,
    Flag = "noFogToggle",
    Callback = function(Value)
        st.noFog = Value
        _G.NoFog = Value
        uiBoolSet("noFog", Value)
    end
}, "无迷雾")
safeCreate("Toggle", WorldTab, {
    Name = "禁用阴影",
    CurrentValue = st.disableShadows == true,
    Flag = "disableShadowsToggle",
    Callback = function(Value)
        st.disableShadows = Value
        _G.RakeDisableShadows = Value
        uiBoolSet("disableShadows", Value)
        clientBypass.applyGameSettingOverrides()
    end
}, "禁用阴影")
safeCreate("Toggle", WorldTab, {
    Name = "全局全亮度",
    CurrentValue = st.fullbright == true,
    Flag = "fullbrightToggle",
    Callback = function(Value)
        st.fullbright = Value
        _G.RakeFullbright = Value
        uiBoolSet("fullbright", Value)
    end
}, "全亮度")
safeCreate("Toggle", WorldTab, {
    Name = "强制游戏内聊天显示",
    CurrentValue = st.forceChat == true,
    Flag = "forceChatToggle",
    Callback = function(Value)
        st.forceChat = Value
        _G.RakeForceChat = Value
        uiBoolSet("forceChat", Value)
        clientBypass.applyGameSettingOverrides()
    end
}, "强制聊天")
safeCreate("Toggle", WorldTab, {
    Name = "强制显示玩家名牌",
    CurrentValue = st.enableNametags == true,
    Flag = "nametagsToggle",
    Callback = function(Value)
        st.enableNametags = Value
        _G.RakeForceNametags = Value
        uiBoolSet("enableNametags", Value)
        clientBypass.applyGameSettingOverrides()
    end
}, "强制名牌")
safeCreate("Toggle", WorldTab, {
    Name = "强制启用第六感技能",
    CurrentValue = st.enableSixthSense == true,
    Flag = "sixthSenseToggle",
    Callback = function(Value)
        st.enableSixthSense = Value
        _G.RakeForceSixthSense = Value
        uiBoolSet("enableSixthSense", Value)
        clientBypass.applyGameSettingOverrides()
    end
}, "第六感")
safeCreate("Toggle", WorldTab, {
    Name = "禁用死亡特效",
    CurrentValue = st.disableDeathFx == true,
    Flag = "disableDeathFxToggle",
    Callback = function(Value)
        st.disableDeathFx = Value
        _G.RakeDisableDeathFx = Value
        uiBoolSet("disableDeathFx", Value)
        clientBypass.applyDeathFxBypass()
    end
}, "禁用死亡特效")
safeCreate("Toggle", WorldTab, {
    Name = "禁用动态模糊",
    CurrentValue = st.disableMotionBlur == true,
    Flag = "disableMotionBlurToggle",
    Callback = function(Value)
        st.disableMotionBlur = Value
        _G.RakeDisableMotionBlur = Value
        uiBoolSet("disableMotionBlur", Value)
        clientBypass.applyMotionBlurBypass()
    end
}, "禁用动态模糊")
safeCreate("Toggle", WorldTab, {
    Name = "禁用菜单特效",
    CurrentValue = st.disableMenuFx == true,
    Flag = "disableMenuFxToggle",
    Callback = function(Value)
        st.disableMenuFx = Value
        _G.RakeDisableMenuFx = Value
        uiBoolSet("disableMenuFx", Value)
        clientBypass.applyMenuFxBypass()
    end
}, "禁用菜单特效")
safeCreate("Toggle", WorldTab, {
    Name = "开场动画跳过",
    CurrentValue = st.introBypass == true,
    Flag = "introBypassToggle",
    Callback = function(Value)
        st.introBypass = Value
        _G.RakeIntroBypass = Value
        uiBoolSet("introBypass", Value)
        clientBypass.applyIntroBypass()
    end
}, "跳过开场")
safeCreate("Toggle", WorldTab, {
    Name = "禁用镜头抖动",
    CurrentValue = st.disableCameraShake == true,
    Flag = "disableCameraShakeToggle",
    Callback = function(Value)
        st.disableCameraShake = Value
        uiBoolSet("disableCameraShake", Value)
    end
}, "禁用镜头抖动")
safeCreate("Toggle", WorldTab, {
    Name = "禁用镜头摆动",
    CurrentValue = st.disableCameraBobbing == true,
    Flag = "disableCameraBobbingToggle",
    Callback = function(Value)
        st.disableCameraBobbing = Value
        uiBoolSet("disableCameraBobbing", Value)
    end
}, "禁用镜头摆动")

-- 音量调节标签页
safeCreate("Toggle", MuteTab, {
    Name = "静音游戏音乐",
    CurrentValue = st.muteGameMusic == true,
    Flag = "muteGameMusicToggle",
    Callback = function(Value)
        st.muteGameMusic = Value
        _G.RakeMuteGameMusic = Value
        uiBoolSet("muteGameMusic", Value)
        clientBypass.setSoundVolume("GameMusic", Value)
    end
}, "静音游戏音乐")
safeCreate("Toggle", MuteTab, {
    Name = "静音追逐音乐",
    CurrentValue = st.muteChaseMusic == true,
    Flag = "muteChaseMusicToggle",
    Callback = function(Value)
        st.muteChaseMusic = Value
        _G.RakeMuteChaseMusic = Value
        uiBoolSet("muteChaseMusic", Value)
        clientBypass.setSoundVolume("ChaseMusic", Value)
    end
}, "静音追逐音乐")
safeCreate("Toggle", MuteTab, {
    Name = "静音移动声音",
    CurrentValue = st.muteMovementSounds == true,
    Flag = "muteMovementToggle",
    Callback = function(Value)
        st.muteMovementSounds = Value
        _G.RakeMuteMovementSounds = Value
        uiBoolSet("muteMovementSounds", Value)
    end
}, "静音移动音效")
safeCreate("Toggle", MuteTab, {
    Name = "静音脚步声",
    CurrentValue = st.muteFootsteps == true,
    Flag = "muteFootstepsToggle",
    Callback = function(Value)
        st.muteFootsteps = Value
        _G.RakeMuteFootsteps = Value
        uiBoolSet("muteFootsteps", Value)
    end
}, "静音脚步声")
safeCreate("Toggle", MuteTab, {
    Name = "静音跳跃落地声",
    CurrentValue = st.muteJumpLand == true,
    Flag = "muteJumpLandToggle",
    Callback = function(Value)
        st.muteJumpLand = Value
        _G.RakeMuteJumpLand = Value
        uiBoolSet("muteJumpLand", Value)
    end
}, "静音跳跃落地")
safeCreate("Toggle", MuteTab, {
    Name = "静音落水声",
    CurrentValue = st.muteWaterFall == true,
    Flag = "muteWaterFallToggle",
    Callback = function(Value)
        st.muteWaterFall = Value
        _G.RakeMuteWaterFall = Value
        uiBoolSet("muteWaterFall", Value)
    end
}, "静音落水")
safeCreate("Toggle", MuteTab, {
    Name = "静音死亡音效",
    CurrentValue = st.muteDeathSounds == true,
    Flag = "muteDeathSoundsToggle",
    Callback = function(Value)
        st.muteDeathSounds = Value
        _G.RakeMuteDeathSounds = Value
        uiBoolSet("muteDeathSounds", Value)
    end
}, "静音死亡音效")

-- 杂项设置标签页
safeCreate("Toggle", MiscTab, {
    Name = "手电筒无阴影",
    CurrentValue = st.flashlightNoShadows == true,
    Flag = "flashlightNoShadowsToggle",
    Callback = function(Value)
        st.flashlightNoShadows = Value
        _G.RakeFlashlightNoShadows = Value
        uiBoolSet("flashlightNoShadows", Value)
    end
}, "手电筒无阴影")
safeCreate("Toggle", MiscTab, {
    Name = "手电筒亮度增强",
    CurrentValue = st.flashlightBoost == true,
    Flag = "flashlightBoostToggle",
    Callback = function(Value)
        st.flashlightBoost = Value
        _G.RakeFlashlightBoost = Value
        uiBoolSet("flashlightBoost", Value)
    end
}, "手电筒增强")
safeCreate("Toggle", MiscTab, {
    Name = "禁用菜单自动重新打开",
    CurrentValue = st.disableMenuReopen == true,
    Flag = "disableMenuReopenToggle",
    Callback = function(Value)
        st.disableMenuReopen = Value
        _G.RakeDisableMenuReopen = Value
        uiBoolSet("disableMenuReopen", Value)
    end
}, "禁用菜单自动打开")
safeCreate("Toggle", MiscTab, {
    Name = "隐藏位置弹窗",
    CurrentValue = st.hideLocationPopups == true,
    Flag = "hideLocationPopupsToggle",
    Callback = function(Value)
        st.hideLocationPopups = Value
        _G.RakeHideLocationPopups = Value
        uiBoolSet("hideLocationPopups", Value)
    end
}, "隐藏位置弹窗")
safeCreate("Toggle", MiscTab, {
    Name = "隐藏物资弹窗",
    CurrentValue = st.hideScrapPopups == true,
    Flag = "hideScrapPopupsToggle",
    Callback = function(Value)
        st.hideScrapPopups = Value
        _G.RakeHideScrapPopups = Value
        uiBoolSet("hideScrapPopups", Value)
    end
}, "隐藏物资弹窗")
safeCreate("Toggle", MiscTab, {
    Name = "隐藏陷阱界面",
    CurrentValue = st.hideTrapGui == true,
    Flag = "hideTrapGuiToggle",
    Callback = function(Value)
        st.hideTrapGui = Value
        _G.RakeHideTrapGui = Value
        uiBoolSet("hideTrapGui", Value)
    end
}, "隐藏陷阱界面")
safeCreate("Toggle", MiscTab, {
    Name = "隐藏死亡消息",
    CurrentValue = st.hideDeathMessages == true,
    Flag = "hideDeathMessagesToggle",
    Callback = function(Value)
        st.hideDeathMessages = Value
        _G.RakeHideDeathMessages = Value
        uiBoolSet("hideDeathMessages", Value)
    end
}, "隐藏死亡消息")
safeCreate("Toggle", MiscTab, {
    Name = "安全恢复 (死亡后保留装备)",
    CurrentValue = st.safeRecover == true,
    Flag = "safeRecoverToggle",
    Callback = function(Value)
        st.safeRecover = Value
        _G.RakeSafeRecover = Value
        uiBoolSet("safeRecover", Value)
    end
}, "安全恢复")

-- 界面设置标签页
safeCreate("Keybind", UISettingsTab, {
    Name = "GUI显示/隐藏快捷键",
    CurrentKeybind = st.uiBind,
    Flag = "uiBindKeybind",
    Callback = function(Keybind)
        st.uiBind = tostring(Keybind)
        cfgSet("uiBind", tostring(Keybind))
        Rayfield:ToggleUI()
    end
}, "界面快捷键")
safeCreate("Toggle", UISettingsTab, {
    Name = "显示光标",
    CurrentValue = st.uiCursor == true,
    Flag = "uiCursorToggle",
    Callback = function(Value)
        st.uiCursor = Value
        uiBoolSet("uiCursor", Value)
    end
}, "光标显示")
safeCreate("Toggle", UISettingsTab, {
    Name = "显示信息气泡",
    CurrentValue = st.infoBubble == true,
    Flag = "infoBubbleToggle",
    Callback = function(Value)
        st.infoBubble = Value
        uiBoolSet("infoBubble", Value)
    end
}, "信息气泡")
safeCreate("Toggle", UISettingsTab, {
    Name = "Adonis反脚本检测绕过",
    CurrentValue = st.adonisBypass == true,
    Flag = "adonisBypassToggle",
    Callback = function(Value)
        st.adonisBypass = Value
        _G.RakeAdonisBypass = Value
        uiBoolSet("adonisBypass", Value)
        task.spawn(runAdonisBypass)
    end
}, "Adonis绕过")
safeCreate("Toggle", UISettingsTab, {
    Name = "强制PC设备模式",
    CurrentValue = st.forcePcDevice == true,
    Flag = "forcePcDeviceToggle",
    Callback = function(Value)
        st.forcePcDevice = Value
        uiBoolSet("forcePcDevice", Value)
    end
}, "强制PC模式")
safeCreate("Toggle", UISettingsTab, {
    Name = "强制背包UI显示",
    CurrentValue = st.forceBackpack == true,
    Flag = "forceBackpackToggle",
    Callback = function(Value)
        st.forceBackpack = Value
        uiBoolSet("forceBackpack", Value)
        clientBypass.forceCoreParts()
    end
}, "强制背包")
safeCreate("Toggle", UISettingsTab, {
    Name = "强制顶栏UI显示",
    CurrentValue = st.forceTopbar == true,
    Flag = "forceTopbarToggle",
    Callback = function(Value)
        st.forceTopbar = Value
        uiBoolSet("forceTopbar", Value)
        clientBypass.forceCoreParts()
    end
}, "强制顶栏")
safeCreate("Toggle", UISettingsTab, {
    Name = "强制鼠标图标显示",
    CurrentValue = st.forceMouseIcon == true,
    Flag = "forceMouseIconToggle",
    Callback = function(Value)
        st.forceMouseIcon = Value
        uiBoolSet("forceMouseIcon", Value)
        clientBypass.forceCoreParts()
    end
}, "强制鼠标图标")

-- 界面加载完成通知
Rayfield:Notify({
    Title = "Rake GUI",
    Content = "界面加载完毕，按 'K' 键显示/隐藏菜单",
    Duration = 4
})

genv.RakeGui = true
print("Rake GUI with Rayfield has been loaded. Current version: " .. os.date("%Y-%m-%d %H:%M:%S"))
