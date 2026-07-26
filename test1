-- ============================================================
-- AutoMail Grow a Garden 2 — DEEP GAME DATABASE SCANNER
-- Creator: Moimoi
-- Features:
--   [1] Deep-Scan ReplicatedStorage: Tự quét 100% Seeds, Pets, Gear từ Database Game
--   [2] Auto-Update: Game ra mắt Seed/Gear/Pet mới sẽ tự thêm vào UI
--   [3] Auto Username-to-UserId Lookup
--   [4] Lịch sử gửi (History Log) & Auto Save Config (.json)
-- ============================================================

local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService       = game:GetService("HttpService")

local LocalPlayer       = Players.LocalPlayer
local username          = LocalPlayer.Name
local configPath        = username .. "-sendmailgag2.json"
local historyPath       = username .. "-sendmailgag2-history.json"

-- Bảng phân loại Gear gửi Mail
local GEAR_SECTION_MAP = {
    ["Common Watering Can"]   = "WateringCans", ["Super Watering Can"]    = "WateringCans",
    ["Uncommon Sprinkler"]    = "Sprinklers",   ["Rare Sprinkler"]        = "Sprinklers",
    ["Legendary Sprinkler"]   = "Sprinklers",   ["Super Sprinkler"]       = "Sprinklers",
    ["Trowel"]                = "Trowels",      ["Sign"]                  = "Signs",
    ["Basic Pot"]             = "Pots",         ["Lantern"]               = "Lanterns",
    ["Gnome"]                 = "Gnomes",       ["Flashbang"]             = "Flashbangs",
    ["Teleporter"]            = "Teleporters",  ["Wheelbarrow"]           = "Wheelbarrows",
    ["Jump Mushroom"]         = "Mushrooms",    ["Speed Mushroom"]        = "Mushrooms",
    ["Supersize Mushroom"]    = "Mushrooms",    ["Invisibility Mushroom"] = "Mushrooms",
}

-- =====================================================================
-- FILE I/O (LƯU VÀ ĐỌC CAU HINH)
-- =====================================================================
local function loadConfig()
    if isfile and isfile(configPath) then
        local ok, d = pcall(function() return HttpService:JSONDecode(readfile(configPath)) end)
        if ok and type(d) == "table" then return d end
    end
    return nil
end

local function saveConfig(cfg)
    if writefile then
        local ok, enc = pcall(function() return HttpService:JSONEncode(cfg) end)
        if ok then writefile(configPath, enc) end
    end
end

local MAX_HISTORY = 200
local function loadHistory()
    if isfile and isfile(historyPath) then
        local ok, d = pcall(function() return HttpService:JSONDecode(readfile(historyPath)) end)
        if ok and type(d) == "table" then return d end
    end
    return {}
end

local function saveHistory(hist)
    if writefile then
        local ok, enc = pcall(function() return HttpService:JSONEncode(hist) end)
        if ok then writefile(historyPath, enc) end
    end
end

local historyData = loadHistory()
local cfg = loadConfig() or {}
cfg.Seeds     = cfg.Seeds or {}
cfg.Pets      = cfg.Pets or {}
cfg.Gear      = cfg.Gear or {}
cfg.Recipient = cfg.Recipient or ""
cfg.Note      = cfg.Note or "Moimoi AutoMail!"

-- =====================================================================
-- DEEP GAME DATABASE SCANNER (QUET TOAN BO DATABASE GAME)
-- =====================================================================
local function deepScanGameDatabase()
    local scannedSeeds, scannedPets, scannedGear = 0, 0, 0

    local function processTable(tbl, sourceName)
        if type(tbl) ~= "table" then return end
        
        for k, v in pairs(tbl) do
            local itemName = nil
            local category = nil

            if type(v) == "table" then
                itemName = v.Name or v.DisplayName or v.Title or (type(k) == "string" and k or nil)
                category = v.Category or v.Type or v.Kind or sourceName
            elseif type(k) == "string" and #k > 1 then
                itemName = k
            end

            if itemName and type(itemName) == "string" and #itemName > 1 and not tonumber(itemName) then
                local lowerName = itemName:lower()
                local lowerSrc  = tostring(sourceName):lower()
                local lowerCat  = tostring(category):lower()

                -- Phân loại Seed
                if lowerCat:find("seed") or lowerSrc:find("seed") or lowerName:find("seed") or lowerName:find("sprout") then
                    if not cfg.Seeds[itemName] then
                        cfg.Seeds[itemName] = { enabled = false, amount = 1 }
                        scannedSeeds += 1
                    end
                -- Phân loại Pet
                elseif lowerCat:find("pet") or lowerSrc:find("pet") or lowerName:find("egg") then
                    if not cfg.Pets[itemName] then
                        cfg.Pets[itemName] = { enabled = false, amount = 1 }
                        scannedPets += 1
                    end
                -- Phân loại Gear
                elseif lowerCat:find("gear") or lowerCat:find("tool") or lowerSrc:find("gear") or GEAR_SECTION_MAP[itemName] then
                    if not cfg.Gear[itemName] then
                        cfg.Gear[itemName] = { enabled = false, amount = 1 }
                        scannedGear += 1
                    end
                end
            end

            if type(v) == "table" and k ~= "Parent" and k ~= "Client" then
                pcall(function() processTable(v, sourceName) end)
            end
        end
    end

    for _, desc in ipairs(ReplicatedStorage:GetDescendants()) do
        if desc:IsA("ModuleScript") then
            local modName = desc.Name
            if modName:find("Data") or modName:find("Item") or modName:find("Seed") or modName:find("Pet") or modName:find("Gear") or modName:find("Registry") or modName:find("Config") then
                local ok, modData = pcall(require, desc)
                if ok and type(modData) == "table" then
                    processTable(modData, modName)
                end
            end
        end
    end

    saveConfig(cfg)
    print(string.format("[AutoMail DeepScan] Scanning finished! Added: %d Seeds, %d Pets, %d Gear from Game Database.", scannedSeeds, scannedPets, scannedGear))
end

pcall(deepScanGameDatabase)

-- =====================================================================
-- UI SYSTEM
-- =====================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name            = "AutoMailGAG2_UI"
ScreenGui.ResetOnSpawn    = false
ScreenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent          = (gethui and gethui()) or game:GetService("CoreGui")

local C = {
    bg           = Color3.fromRGB(18, 18, 24),
    panel        = Color3.fromRGB(26, 26, 36),
    border       = Color3.fromRGB(50, 50, 70),
    accent       = Color3.fromRGB(80, 200, 140),
    text         = Color3.fromRGB(220, 220, 230),
    muted        = Color3.fromRGB(130, 130, 155),
    red          = Color3.fromRGB(220, 70, 70),
    tab          = Color3.fromRGB(35, 35, 50),
    tabSel       = Color3.fromRGB(50, 180, 110),
    itemBg       = Color3.fromRGB(30, 30, 44),
    itemOn       = Color3.fromRGB(20, 65, 45),
    itemOnBorder = Color3.fromRGB(60, 200, 120),
    header       = Color3.fromRGB(22, 22, 32),
    histBg       = Color3.fromRGB(16, 22, 38),
    histBorder   = Color3.fromRGB(60, 100, 180),
    blue         = Color3.fromRGB(120, 180, 255),
}

local function mkFrame(parent, size, pos, bg, radius, border)
    local f = Instance.new("Frame")
    f.Size = size; f.Position = pos; f.BackgroundColor3 = bg or C.panel; f.BorderSizePixel = 0
    if radius then Instance.new("UICorner", f).CornerRadius = UDim.new(0, radius) end
    if border then local s = Instance.new("UIStroke", f); s.Color = border; s.Thickness = 1 end
    f.Parent = parent; return f
end

local function mkLabel(parent, text, size, color, font, align)
    local l = Instance.new("TextLabel")
    l.Text = text; l.TextSize = size or 13; l.TextColor3 = color or C.text; l.Font = font or Enum.Font.Gotham
    l.BackgroundTransparency = 1; l.TextXAlignment = align or Enum.TextXAlignment.Left
    l.Size = UDim2.new(1, 0, 0, size and size + 6 or 19); l.Parent = parent; return l
end

local function mkBtn(parent, text, size, pos, bg, textColor)
    local b = Instance.new("TextButton")
    b.Text = text; b.Size = size; b.Position = pos or UDim2.new(0,0,0,0); b.BackgroundColor3 = bg or C.accent
    b.TextColor3 = textColor or Color3.fromRGB(10,10,20); b.TextSize = 13; b.Font = Enum.Font.GothamBold; b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6); b.Parent = parent; return b
end

local Main = mkFrame(ScreenGui, UDim2.new(0, 340, 0, 530), UDim2.new(0.5, -170, 0.5, -265), C.bg, 10, C.border)
Main.ClipsDescendants = true

local dragging, dragStart, startPos
local HistGui = nil

local function syncHistPos()
    if HistGui then
        local mp = Main.Position
        HistGui.Position = UDim2.new(mp.X.Scale, mp.X.Offset - 346, mp.Y.Scale, mp.Y.Offset)
    end
end

-- Header UI
local Header = mkFrame(Main, UDim2.new(1,0,0,38), UDim2.new(0,0,0,0), C.header, 10)
mkFrame(Header, UDim2.new(1,0,0,10), UDim2.new(0,0,1,-10), C.header)

local titleLbl = mkLabel(Header, "📦 AutoMail (Deep-Scan) By Moimoi!!", 12, C.accent, Enum.Font.GothamBold)
titleLbl.Position = UDim2.new(0, 12, 0, 0); titleLbl.Size = UDim2.new(1, -95, 1, 0)

local miniBtn = mkBtn(Header, "—", UDim2.new(0,26,0,26), UDim2.new(1,-92,0.5,-13), Color3.fromRGB(80,80,100), Color3.new(1,1,1))
local closeBtn = mkBtn(Header, "✕", UDim2.new(0,26,0,26), UDim2.new(1,-32,0.5,-13), C.red, Color3.new(1,1,1))
closeBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
local histBtn = mkBtn(Header, "📋", UDim2.new(0,26,0,26), UDim2.new(1,-62,0.5,-13), Color3.fromRGB(30,50,80), C.blue)

Header.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = Vector2.new(inp.Position.X, inp.Position.Y); startPos = Main.Position
    end
end)
Header.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)
UserInputService.InputChanged:Connect(function(inp)
    if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
        local p = Vector2.new(inp.Position.X, inp.Position.Y)
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + (p.X - dragStart.X), startPos.Y.Scale, startPos.Y.Offset + (p.Y - dragStart.Y))
        syncHistPos()
    end
end)

-- History Frame UI
HistGui = mkFrame(ScreenGui, UDim2.new(0, 340, 0, 530), UDim2.new(0.5, -516, 0.5, -265), C.bg, 10, C.histBorder)
HistGui.Visible = false; HistGui.ZIndex = 5
local HH = mkFrame(HistGui, UDim2.new(1,0,0,38), UDim2.new(0,0,0,0), C.histBg, 10)
mkLabel(HH, "📋 Lịch Sử Gửi Mail", 13, C.blue, Enum.Font.GothamBold).Position = UDim2.new(0,12,0,8)
local hCloseBtn = mkBtn(HH, "✕", UDim2.new(0,26,0,26), UDim2.new(1,-32,0.5,-13), C.red, Color3.new(1,1,1))
hCloseBtn.MouseButton1Click:Connect(function() HistGui.Visible = false end)

local histListFrame = mkFrame(HistGui, UDim2.new(1,-20,0,460), UDim2.new(0,10,0,50), C.histBg, 6, Color3.fromRGB(30,50,90))
local histScroll = Instance.new("ScrollingFrame")
histScroll.Size = UDim2.new(1,0,1,0); histScroll.BackgroundTransparency = 1; histScroll.BorderSizePixel = 0
histScroll.ScrollBarThickness = 3; histScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; histScroll.Parent = histListFrame
local histLayout = Instance.new("UIListLayout"); histLayout.Padding = UDim.new(0,4); histLayout.Parent = histScroll

local function rebuildHistory()
    for _, ch in ipairs(histScroll:GetChildren()) do if ch:IsA("Frame") then ch:Destroy() end end
    for i = #historyData, 1, -1 do
        local entry = historyData[i]
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1,-6,0,36); row.BackgroundColor3 = entry.status == "ok" and Color3.fromRGB(14,45,28) or Color3.fromRGB(50,14,14)
        Instance.new("UICorner", row).CornerRadius = UDim.new(0,6)
        row.Parent = histScroll

        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(1,-12,1,0); txt.Position = UDim2.new(0,8,0,0); txt.BackgroundTransparency = 1
        txt.TextColor3 = entry.status == "ok" and C.accent or C.red; txt.Font = Enum.Font.Gotham; txt.TextSize = 10
        txt.Text = string.format("[%s] %s x%d → %s", entry.time or "", entry.item or "?", entry.amount or 1, entry.recipient or "?")
        txt.Parent = row
    end
end
histBtn.MouseButton1Click:Connect(function() HistGui.Visible = not HistGui.Visible; if HistGui.Visible then syncHistPos(); rebuildHistory() end end)

-- Recipient Input & Tabs
local recipRow = mkFrame(Main, UDim2.new(1,-20,0,28), UDim2.new(0,10,0,44), C.panel, 6, C.border)
local recipBox = Instance.new("TextBox")
recipBox.Text = cfg.Recipient or ""; recipBox.PlaceholderText = "Username người nhận..."
recipBox.Size = UDim2.new(1,-12,1,0); recipBox.Position = UDim2.new(0,8,0,0)
recipBox.BackgroundTransparency = 1; recipBox.TextColor3 = C.text; recipBox.TextSize = 12; recipBox.Font = Enum.Font.Gotham; recipBox.Parent = recipRow
recipBox:GetPropertyChangedSignal("Text"):Connect(function() cfg.Recipient = recipBox.Text; saveConfig(cfg) end)

local tabNames = {"Seeds", "Pets", "Gear", "Log"}
local tabBar = mkFrame(Main, UDim2.new(1,-20,0,28), UDim2.new(0,10,0,76), C.panel, 6)
local activeTab = "Seeds"
local tabBtns = {}

local _tw = math.floor((316 - (#tabNames - 1) * 4) / #tabNames)
for i, name in ipairs(tabNames) do
    local tb = mkBtn(tabBar, name, UDim2.new(0, _tw, 1, -4), UDim2.new(0, (i-1)*(_tw+4) + 2, 0, 2), C.tab, C.muted)
    tb.Font = Enum.Font.GothamBold; tb.TextSize = 11; tabBtns[name] = tb
end

local searchRow = mkFrame(Main, UDim2.new(1,-20,0,28), UDim2.new(0,10,0,108), C.panel, 6, C.border)
local searchBox = Instance.new("TextBox")
searchBox.Text = ""; searchBox.PlaceholderText = "🔍 Tìm kiếm item..."
searchBox.Size = UDim2.new(1,-12,1,0); searchBox.Position = UDim2.new(0,8,0,0)
searchBox.BackgroundTransparency = 1; searchBox.TextColor3 = C.text; searchBox.TextSize = 12; searchBox.Font = Enum.Font.Gotham; searchBox.Parent = searchRow

local listFrame = mkFrame(Main, UDim2.new(1,-20,0,260), UDim2.new(0,10,0,140), C.panel, 6, C.border)
listFrame.ClipsDescendants = true
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1,0,1,0); scrollFrame.BackgroundTransparency = 1; scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 3; scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y; scrollFrame.Parent = listFrame
local listLayout = Instance.new("UIListLayout"); listLayout.Padding = UDim.new(0,3); listLayout.Parent = scrollFrame

local logFrame = mkFrame(Main, UDim2.new(1,-20,0,260), UDim2.new(0,10,0,140), C.panel, 6, C.border)
logFrame.Visible = false
local logScroll = Instance.new("ScrollingFrame")
logScroll.Size = UDim2.new(1,0,1,0); logScroll.BackgroundTransparency = 1; logScroll.BorderSizePixel = 0
logScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; logScroll.Parent = logFrame
local logLayout = Instance.new("UIListLayout"); logLayout.Padding = UDim.new(0,2); logLayout.Parent = logScroll

local function addLog(msg, kind)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,-4,0,18); row.BackgroundColor3 = kind == "ok" and Color3.fromRGB(18,55,35) or (kind == "fail" and Color3.fromRGB(55,18,18) or Color3.fromRGB(20,28,45))
    row.Parent = logScroll
    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1,-8,1,0); tl.Position = UDim2.new(0,4,0,0); tl.BackgroundTransparency = 1
    tl.TextColor3 = kind == "ok" and C.accent or (kind == "fail" and C.red or C.text)
    tl.Font = Enum.Font.Gotham; tl.TextSize = 10; tl.Text = os.date("[%H:%M:%S] ") .. msg; tl.Parent = row
    task.defer(function() logScroll.CanvasPosition = Vector2.new(0, math.huge) end)
end

local function buildRows(tabName)
    for _, ch in ipairs(scrollFrame:GetChildren()) do if ch:IsA("Frame") then ch:Destroy() end end
    local section = cfg[tabName] or {}
    local filter = searchBox.Text:lower()

    for name, data in pairs(section) do
        if filter == "" or name:lower():find(filter, 1, true) then
            local row = mkFrame(scrollFrame, UDim2.new(1,-4,0,32), UDim2.new(0,0,0,0), data.enabled and C.itemOn or C.itemBg, 6, data.enabled and C.itemOnBorder or C.border)
            
            local toggleBtn = Instance.new("TextButton")
            toggleBtn.Size = UDim2.new(1,-70,1,0); toggleBtn.BackgroundTransparency = 1; toggleBtn.Text = ""; toggleBtn.Parent = row

            local nameLbl = mkLabel(row, name, 11, data.enabled and C.accent or C.text, Enum.Font.Gotham)
            nameLbl.Position = UDim2.new(0,8,0,0); nameLbl.Size = UDim2.new(1,-80,1,0)

            local amtBox = Instance.new("TextBox")
            amtBox.Text = tostring(data.amount or 1); amtBox.Size = UDim2.new(0,50,0,22); amtBox.Position = UDim2.new(1,-56,0.5,-11)
            amtBox.BackgroundColor3 = C.bg; amtBox.TextColor3 = C.text; amtBox.TextSize = 11; amtBox.Font = Enum.Font.GothamBold; amtBox.Parent = row
            amtBox.FocusLost:Connect(function()
                local v = math.clamp(math.floor(tonumber(amtBox.Text) or 1), 1, 10000)
                amtBox.Text = tostring(v); section[name].amount = v; saveConfig(cfg)
            end)

            toggleBtn.MouseButton1Click:Connect(function()
                data.enabled = not data.enabled; section[name].enabled = data.enabled; saveConfig(cfg); buildRows(tabName)
            end)
        end
    end
end

local function switchTab(name)
    activeTab = name
    for _, t in ipairs(tabNames) do tabBtns[t].BackgroundColor3 = (t == name) and C.tabSel or C.tab end
    local isLog = (name == "Log")
    listFrame.Visible = not isLog; searchRow.Visible = not isLog; logFrame.Visible = isLog
    if not isLog then buildRows(name) end
end

for _, name in ipairs(tabNames) do tabBtns[name].MouseButton1Click:Connect(function() switchTab(name) end) end
searchBox:GetPropertyChangedSignal("Text"):Connect(function() buildRows(activeTab) end)

local statusLbl = mkLabel(Main, "Ready (Deep Game-Scan Active)", 11, C.muted, Enum.Font.Gotham, Enum.TextXAlignment.Center)
statusLbl.Position = UDim2.new(0,10,0,405); statusLbl.Size = UDim2.new(1,-20,0,20)

local startBtn = mkBtn(Main, "▶ Start Send ALL", UDim2.new(1,-20,0,30), UDim2.new(0,10,0,430), C.accent, Color3.fromRGB(10,20,15))
local onceBtn  = mkBtn(Main, "⚡ Send 1 Lần", UDim2.new(1,-20,0,26), UDim2.new(0,10,0,466), Color3.fromRGB(60,80,160), Color3.fromRGB(200,210,255))

-- Net Sender System
local Networking = nil
pcall(function() Networking = require(ReplicatedStorage.SharedModules.Networking) end)

local function getTargetUid()
    local targetName = tostring(cfg.Recipient or ""):gsub("^%s*(.-)%s*$", "%1")
    if targetName == "" then return nil, "Chưa nhập Username!" end
    local ok, uid = pcall(function() return Players:GetUserIdFromNameAsync(targetName) end)
    if ok and type(uid) == "number" and uid > 0 then
        if uid == LocalPlayer.UserId then return nil, "Không thể gửi cho chính mình" end
        return uid, nil
    end
    return nil, "Không tìm thấy User!"
end

local function executeSend(uid)
    local batchPayload = {}
    for name, data in pairs(cfg.Seeds) do
        if data.enabled then table.insert(batchPayload, { Category = "Seeds", ItemKey = name, Count = data.amount }) end
    end
    for name, data in pairs(cfg.Gear) do
        if data.enabled then
            local sec = GEAR_SECTION_MAP[name] or "Equipment"
            table.insert(batchPayload, { Category = sec, ItemKey = name, Count = data.amount })
        end
    end
    for name, data in pairs(cfg.Pets) do
        if data.enabled then table.insert(batchPayload, { Category = "Pets", ItemKey = name, Count = data.amount }) end
    end

    if #batchPayload == 0 then return false, "Chưa chọn Item nào!" end

    local ok, res = pcall(function()
        return Networking.Mailbox.SendBatch:Fire(uid, batchPayload, tostring(cfg.Note or ""))
    end)

    if ok and res == true then
        for _, item in ipairs(batchPayload) do
            addLog(string.format("Gửi %s x%d — OK", item.ItemKey, item.Count), "ok")
            table.insert(historyData, { time = os.date("%H:%M:%S"), recipient = cfg.Recipient, item = item.ItemKey, amount = item.Count, status = "ok" })
        end
        saveHistory(historyData); return true, "Thành công!"
    else
        addLog("Gửi Thất Bại!", "fail")
        return false, "Server Reject"
    end
end

local isRunning = false
startBtn.MouseButton1Click:Connect(function()
    if isRunning then isRunning = false; startBtn.Text = "▶ Start Send ALL"; return end
    local uid, err = getTargetUid()
    if not uid then statusLbl.Text = "❌ " .. err; return end

    isRunning = true; startBtn.Text = "⏹ Stop"
    task.spawn(function()
        while isRunning do
            statusLbl.Text = "⏳ Đang gửi..."
            local ok, msg = executeSend(uid)
            statusLbl.Text = ok and "✅ Gửi thành công!" or ("❌ Lỗi: " .. msg)
            task.wait(2)
        end
    end)
end)

onceBtn.MouseButton1Click:Connect(function()
    local uid, err = getTargetUid()
    if not uid then statusLbl.Text = "❌ " .. err; return end
    statusLbl.Text = "⏳ Đang gửi 1 lần..."
    local ok, msg = executeSend(uid)
    statusLbl.Text = ok and "✅ Gửi thành công!" or ("❌ Lỗi: " .. msg)
end)

switchTab("Seeds")
print("[AutoMail GAG2] Script loaded successfully!")
