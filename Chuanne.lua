-- ============================================================
-- AutoMail GAG2 — MERGED & FIXED by Moimoi!!
-- Gộp: automail gear.lua + automail history.lua + automail config.lua
-- Fix:
--   [1] SEED_KEY_MAP: key game = display name y chang
--   [2] GEAR_KEY_MAP: key game = display name y chang
--   [3] Ghost send: dùng Mailbox.SendBatch + GEAR_SECTION_MAP
--   [4] Dynamic Recipient: Tự động tra UserId theo Tên nhập vào
--   [5] History: addHistoryEntry cho cả Gear send
-- ============================================================

local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local LocalPlayer       = Players.LocalPlayer
local username          = LocalPlayer.Name
local configPath        = username .. "-sendmailgag2.json"
local historyPath       = username .. "-sendmailgag2-history.json"

-- =====================================================================
-- DEFAULT CONFIG
-- =====================================================================
local defaultConfig = {
    Recipient      = "",
    RecipientUserId = 0,
    Note           = "Moimoi!!!",
    Seeds = {
        Acorn              = { enabled = false, amount = 1 },
        Apple              = { enabled = false, amount = 1 },
        Bamboo             = { enabled = false, amount = 1 },
        ["Baby Cactus"]    = { enabled = false, amount = 1 },
        Banana             = { enabled = false, amount = 1 },
        Blueberry          = { enabled = false, amount = 1 },
        Beanstalk          = { enabled = false, amount = 1 },
        ["Magic Beanstalk"]= { enabled = false, amount = 1 },
        Cactus             = { enabled = false, amount = 1 },
        Carrot             = { enabled = false, amount = 1 },
        Cherry             = { enabled = false, amount = 1 },
        Coconut            = { enabled = false, amount = 1 },
        Corn               = { enabled = false, amount = 1 },
        ["Dragon Fruit"]   = { enabled = false, amount = 1 },
        ["Dragon's Breath"]= { enabled = false, amount = 1 },
        ["Ghost Pepper"]   = { enabled = false, amount = 1 },
        ["Glow Mushroom"]  = { enabled = false, amount = 1 },
        ["Gold Seed"]      = { enabled = false, amount = 1 },
        Grape              = { enabled = false, amount = 1 },
        ["Green Bean"]     = { enabled = false, amount = 1 },
        Hypnobloom         = { enabled = false, amount = 1 },
        ["Horned Melon"]   = { enabled = false, amount = 1 },
        Mango              = { enabled = false, amount = 1 },
        ["Moon Bloom"]     = { enabled = false, amount = 1 },
        Mushroom           = { enabled = false, amount = 1 },
        Pineapple          = { enabled = false, amount = 1 },
        ["Poison Apple"]   = { enabled = false, amount = 1 },
        ["Poison Ivy"]     = { enabled = false, amount = 1 },
        Pomegranate        = { enabled = false, amount = 1 },
        ["Rainbow Seed"]   = { enabled = false, amount = 1 },
        Romanesco          = { enabled = false, amount = 1 },
        Strawberry         = { enabled = false, amount = 1 },
        Sunflower          = { enabled = false, amount = 1 },
        Tomato             = { enabled = false, amount = 1 },
        Tulip              = { enabled = false, amount = 1 },
        ["Venus Fly Trap"] = { enabled = false, amount = 1 },
        ["Mega Seed"]      = { enabled = false, amount = 1 },
    },
    Pets = {
        Bee               = { enabled = false, amount = 1 },
        BlackDragon       = { enabled = false, amount = 1 },
        Bunny             = { enabled = false, amount = 1 },
        Deer              = { enabled = false, amount = 1 },
        Frog              = { enabled = false, amount = 1 },
        GoldenDragonfly   = { enabled = false, amount = 1 },
        IceSerpent        = { enabled = false, amount = 1 },
        Monkey            = { enabled = false, amount = 1 },
        Owl               = { enabled = false, amount = 1 },
        Raccoon           = { enabled = false, amount = 1 },
        Robin             = { enabled = false, amount = 1 },
        Unicorn           = { enabled = false, amount = 1 },
    },
    Gear = {
        ["Common Watering Can"]    = { enabled = false, amount = 1 },
        ["Super Watering Can"]     = { enabled = false, amount = 1 },
        ["Basic Pot"]              = { enabled = false, amount = 1 },
        ["Trowel"]                 = { enabled = false, amount = 1 },
        ["Sign"]                   = { enabled = false, amount = 1 },
        ["Lantern"]                = { enabled = false, amount = 1 },
        ["Gnome"]                  = { enabled = false, amount = 1 },
        ["Flashbang"]              = { enabled = false, amount = 1 },
        ["Teleporter"]             = { enabled = false, amount = 1 },
        ["Wheelbarrow"]            = { enabled = false, amount = 1 },
        ["Uncommon Sprinkler"]     = { enabled = false, amount = 1 },
        ["Rare Sprinkler"]         = { enabled = false, amount = 1 },
        ["Legendary Sprinkler"]    = { enabled = false, amount = 1 },
        ["Super Sprinkler"]        = { enabled = false, amount = 1 },
        ["Jump Mushroom"]          = { enabled = false, amount = 1 },
        ["Speed Mushroom"]         = { enabled = false, amount = 1 },
        ["Supersize Mushroom"]     = { enabled = false, amount = 1 },
        ["Invisibility Mushroom"]  = { enabled = false, amount = 1 },
    },
}

-- =====================================================================
-- FILE I/O — Config + History
-- =====================================================================
local HS = game:GetService("HttpService")

local function loadConfig()
    if isfile and isfile(configPath) then
        local ok, d = pcall(function() return HS:JSONDecode(readfile(configPath)) end)
        if ok and type(d) == "table" then return d end
    end
    return nil
end

local function saveConfig(cfg)
    if writefile then
        local ok, enc = pcall(function() return HS:JSONEncode(cfg) end)
        if ok then writefile(configPath, enc) end
    end
end

local MAX_HISTORY = 200
local function loadHistory()
    if isfile and isfile(historyPath) then
        local ok, d = pcall(function() return HS:JSONDecode(readfile(historyPath)) end)
        if ok and type(d) == "table" then return d end
    end
    return {}
end

local function saveHistory(hist)
    if writefile then
        local ok, enc = pcall(function() return HS:JSONEncode(hist) end)
        if ok then writefile(historyPath, enc) end
    end
end

local historyData = loadHistory()
local historyScrollRef = nil
local historyCountRef  = 0

local savedCfg = loadConfig()
local cfg = savedCfg or {}
for section, items in pairs(defaultConfig) do
    if type(items) == "table" and section ~= "Recipient"
        and section ~= "RecipientUserId" and section ~= "Note" then
        cfg[section] = cfg[section] or {}
        for name, def in pairs(items) do
            cfg[section][name] = cfg[section][name]
                or { enabled = false, amount = def.amount }
        end
    end
end
cfg.Recipient       = cfg.Recipient       or defaultConfig.Recipient
cfg.RecipientUserId = cfg.RecipientUserId or defaultConfig.RecipientUserId
cfg.Note            = cfg.Note            or defaultConfig.Note

-- =====================================================================
-- UI HELPERS
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
    f.Size = size; f.Position = pos
    f.BackgroundColor3 = bg or C.panel
    f.BorderSizePixel = 0
    if radius then Instance.new("UICorner", f).CornerRadius = UDim.new(0, radius) end
    if border then
        local s = Instance.new("UIStroke", f)
        s.Color = border; s.Thickness = 1
    end
    f.Parent = parent
    return f
end

local function mkLabel(parent, text, size, color, font, align)
    local l = Instance.new("TextLabel")
    l.Text = text; l.TextSize = size or 13
    l.TextColor3 = color or C.text
    l.Font = font or Enum.Font.Gotham
    l.BackgroundTransparency = 1
    l.TextXAlignment = align or Enum.TextXAlignment.Left
    l.Size = UDim2.new(1, 0, 0, size and size + 6 or 19)
    l.Parent = parent
    return l
end

local function mkBtn(parent, text, size, pos, bg, textColor)
    local b = Instance.new("TextButton")
    b.Text = text; b.Size = size
    b.Position = pos or UDim2.new(0,0,0,0)
    b.BackgroundColor3 = bg or C.accent
    b.TextColor3 = textColor or Color3.fromRGB(10,10,20)
    b.TextSize = 13; b.Font = Enum.Font.GothamBold
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.Parent = parent
    return b
end

local function isBeginInput(inp)
    return inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch
end
local function isEndInput(inp)
    return inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch
end
local function isMoveInput(inp)
    return inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch
end

-- =====================================================================
-- MAIN WINDOW
-- =====================================================================
local Main = mkFrame(ScreenGui,
    UDim2.new(0, 340, 0, 530),
    UDim2.new(0.5, -170, 0.5, -265),
    C.bg, 10, C.border)
Main.ClipsDescendants = true

local dragging, dragStart, startPos
local HistGui = nil
local histWasVisible = false
local HIST_GAP = 6

local function syncHistPos()
    if HistGui then
        local mp = Main.Position
        HistGui.Position = UDim2.new(
            mp.X.Scale, mp.X.Offset - 340 - HIST_GAP,
            mp.Y.Scale, mp.Y.Offset)
    end
end

-- Header
local Header = mkFrame(Main, UDim2.new(1,0,0,38), UDim2.new(0,0,0,0), C.header, 10)
mkFrame(Header, UDim2.new(1,0,0,10), UDim2.new(0,0,1,-10), C.header)

local titleLbl = mkLabel(Header, "📦 AutoMail By Moimoi!!", 14, C.accent, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
titleLbl.Position = UDim2.new(0, 12, 0, 0)
titleLbl.Size = UDim2.new(1, -95, 1, 0)

local senderLbl = mkLabel(Header, "Sender: " .. username, 11, C.muted, Enum.Font.Gotham, Enum.TextXAlignment.Left)
senderLbl.Position = UDim2.new(0, 12, 0, 20)
senderLbl.Size = UDim2.new(1, -95, 0, 16)

-- Minimize button
local miniBtn = mkBtn(Header, "—", UDim2.new(0,26,0,26), UDim2.new(1,-92,0.5,-13), Color3.fromRGB(80,80,100), Color3.new(1,1,1))
local minimized = false
local oldSize = Main.Size

miniBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        oldSize = Main.Size
        Main.Size = UDim2.new(0,340,0,38)
        miniBtn.Text = "+"
        for _,v in ipairs(Main:GetChildren()) do
            if v ~= Header then v.Visible = false end
        end
    else
        Main.Size = oldSize
        miniBtn.Text = "—"
        for _,v in ipairs(Main:GetChildren()) do
            if v ~= Header then v.Visible = true end
        end
    end
end)

local closeBtn = mkBtn(Header, "✕", UDim2.new(0,26,0,26), UDim2.new(1,-32,0.5,-13), C.red, Color3.new(1,1,1))
closeBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local histBtn = mkBtn(Header, "📋", UDim2.new(0,26,0,26), UDim2.new(1,-62,0.5,-13), Color3.fromRGB(30,50,80), C.blue)
histBtn.TextSize = 14

-- MT toggle button
local MTBtn = Instance.new("TextButton")
MTBtn.Size = UDim2.new(0,48,0,48)
MTBtn.Position = UDim2.new(0,20,0.5,-24)
MTBtn.BackgroundColor3 = Color3.fromRGB(14,40,24)
MTBtn.TextColor3 = Color3.fromRGB(80,200,140)
MTBtn.Text = "MT"; MTBtn.Font = Enum.Font.GothamBold
MTBtn.TextSize = 15; MTBtn.BorderSizePixel = 0; MTBtn.ZIndex = 10
Instance.new("UICorner", MTBtn).CornerRadius = UDim.new(1,0)
local mtStroke = Instance.new("UIStroke", MTBtn)
mtStroke.Color = Color3.fromRGB(60,180,100); mtStroke.Thickness = 2
MTBtn.Parent = ScreenGui

local function getPos2(inp)
    return Vector2.new(inp.Position.X, inp.Position.Y)
end

Header.InputBegan:Connect(function(inp)
    if isBeginInput(inp) then
        dragging = true
        dragStart = getPos2(inp)
        startPos  = Main.Position
    end
end)
Header.InputEnded:Connect(function(inp)
    if isEndInput(inp) then dragging = false end
end)
UserInputService.InputChanged:Connect(function(inp)
    if dragging and isMoveInput(inp) then
        local p = getPos2(inp)
        local dx = p.X - dragStart.X
        local dy = p.Y - dragStart.Y
        Main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + dx,
            startPos.Y.Scale, startPos.Y.Offset + dy)
        syncHistPos()
    end
end)

-- =====================================================================
-- HISTORY WINDOW
-- =====================================================================
HistGui = mkFrame(ScreenGui,
    UDim2.new(0, 340, 0, 530),
    UDim2.new(0.5, -516, 0.5, -265),
    C.bg, 10, C.histBorder)
HistGui.ClipsDescendants = true
HistGui.Visible = false; HistGui.ZIndex = 5

local HH = mkFrame(HistGui, UDim2.new(1,0,0,38), UDim2.new(0,0,0,0), C.histBg, 10)
mkFrame(HH, UDim2.new(1,0,0,10), UDim2.new(0,0,1,-10), C.histBg)
local hTitleLbl = mkLabel(HH, "📋 Lịch Sử Gửi", 14, C.blue, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
hTitleLbl.Position = UDim2.new(0,12,0.5,-7); hTitleLbl.Size = UDim2.new(1,-46,0,18)
local hCloseBtn = mkBtn(HH, "✕", UDim2.new(0,26,0,26), UDim2.new(1,-32,0.5,-13), C.red, Color3.new(1,1,1))
hCloseBtn.MouseButton1Click:Connect(function() HistGui.Visible = false end)

local histStatBar = mkFrame(HistGui, UDim2.new(1,-20,0,28), UDim2.new(0,10,0,44), C.histBg, 6, Color3.fromRGB(40,60,100))
local histStatLbl = mkLabel(histStatBar, "Tổng: 0  |  ✅ 0  |  ❌ 0", 11, C.blue, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
histStatLbl.Size = UDim2.new(1,-10,1,0); histStatLbl.Position = UDim2.new(0,8,0,0)

local function updateHistStat()
    local ok2, fail2 = 0, 0
    for _, e in ipairs(historyData) do
        if type(e) == "table" then
            if e.status == "ok" then ok2 += 1 else fail2 += 1 end
        end
    end
    histStatLbl.Text = string.format("Tổng: %d  |  ✅ %d  |  ❌ %d", #historyData, ok2, fail2)
end

local toolbar = mkFrame(HistGui, UDim2.new(1,-20,0,26), UDim2.new(0,10,0,78), C.histBg, 6)
local filterVal = "all"
local fBtnAll  = mkBtn(toolbar, "Tất cả", UDim2.new(0,72,1,-2), UDim2.new(0,1,0,1), Color3.fromRGB(40,60,100), Color3.fromRGB(180,200,255))
local fBtnOk   = mkBtn(toolbar, "✅ OK", UDim2.new(0,72,1,-2), UDim2.new(0,76,0,1), Color3.fromRGB(15,45,28), Color3.fromRGB(80,210,130))
local fBtnFail = mkBtn(toolbar, "❌ Fail", UDim2.new(0,72,1,-2), UDim2.new(0,151,0,1), Color3.fromRGB(50,15,15), Color3.fromRGB(220,80,80))
local hClearBtn = mkBtn(toolbar, "🗑 Xóa", UDim2.new(1,-228,1,-2), UDim2.new(0,226,0,1), Color3.fromRGB(40,15,15), C.red)
for _, b in ipairs({fBtnAll,fBtnOk,fBtnFail,hClearBtn}) do
    b.TextSize = 10; b.Font = Enum.Font.GothamBold
end

local colHdr = mkFrame(HistGui, UDim2.new(1,-20,0,20), UDim2.new(0,10,0,110), C.histBg)
local function mkColLabel(parent, txt, xScale, xOff, wScale, wOff)
    local l = Instance.new("TextLabel")
    l.Text = txt; l.Size = UDim2.new(wScale,wOff,1,0)
    l.Position = UDim2.new(xScale,xOff,0,0)
    l.BackgroundTransparency = 1; l.TextColor3 = Color3.fromRGB(70,100,150)
    l.Font = Enum.Font.GothamBold; l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = parent
end
mkColLabel(colHdr, "ITEM",        0,    8,  0.45, 0)
mkColLabel(colHdr, "LOẠI",        0.45, 0,  0.20, 0)
mkColLabel(colHdr, "SL",          0.65, 0,  0.12, 0)
mkColLabel(colHdr, "NGƯỜI NHẬN",  0.77, 0,  0.23, -4)

mkFrame(HistGui, UDim2.new(1,-20,0,1), UDim2.new(0,10,0,130), Color3.fromRGB(40,60,100))

local histListFrame = mkFrame(HistGui, UDim2.new(1,-20,0,368), UDim2.new(0,10,0,134), C.histBg, 6, Color3.fromRGB(30,50,90))
histListFrame.ClipsDescendants = true

local histScroll = Instance.new("ScrollingFrame")
histScroll.Size = UDim2.new(1,0,1,0); histScroll.BackgroundTransparency = 1; histScroll.BorderSizePixel = 0
histScroll.ScrollBarThickness = 3; histScroll.ScrollBarImageColor3 = C.blue
histScroll.CanvasSize = UDim2.new(0,0,0,0); histScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
histScroll.Parent = histListFrame
local histLayout = Instance.new("UIListLayout")
histLayout.Padding = UDim.new(0,4); histLayout.SortOrder = Enum.SortOrder.LayoutOrder
histLayout.Parent = histScroll
local histPad = Instance.new("UIPadding")
histPad.PaddingTop = UDim.new(0,4); histPad.PaddingLeft = UDim.new(0,4)
histPad.PaddingRight = UDim.new(0,4); histPad.Parent = histScroll
historyScrollRef = histScroll

local hFooterFrame = mkFrame(HistGui, UDim2.new(1,-20,0,18), UDim2.new(0,10,0,506), Color3.fromRGB(12,18,30), 4)
local hFooterLbl = mkLabel(hFooterFrame, "📁 " .. historyPath, 9, Color3.fromRGB(50,70,110), Enum.Font.Gotham, Enum.TextXAlignment.Left)
hFooterLbl.Size = UDim2.new(1,-4,1,0); hFooterLbl.Position = UDim2.new(0,4,0,0)
hFooterLbl.TextTruncate = Enum.TextTruncate.AtEnd

local function rebuildHistoryFiltered(filter)
    for _, ch in ipairs(histScroll:GetChildren()) do
        if ch:IsA("Frame") then ch:Destroy() end
    end
    historyCountRef = 0
    for i = #historyData, math.max(1, #historyData - MAX_HISTORY + 1), -1 do
        local entry = historyData[i]
        if type(entry) ~= "table" then continue end
        if filter == "ok"   and entry.status ~= "ok"   then continue end
        if filter == "fail" and entry.status ~= "fail" then continue end
        historyCountRef += 1

        local isOk     = entry.status == "ok"
        local rowBg    = isOk and Color3.fromRGB(14,45,28) or Color3.fromRGB(50,14,14)
        local barColor = isOk and Color3.fromRGB(60,210,120) or Color3.fromRGB(220,70,70)

        local row = Instance.new("Frame")
        row.Size = UDim2.new(1,-6,0,48)
        row.BackgroundColor3 = rowBg; row.BackgroundTransparency = 0.15
        row.LayoutOrder = historyCountRef; row.BorderSizePixel = 0
        Instance.new("UICorner", row).CornerRadius = UDim.new(0,6)
        row.Parent = histScroll

        local bar2 = Instance.new("Frame")
        bar2.Size = UDim2.new(0,3,1,-6); bar2.Position = UDim2.new(0,0,0,3)
        bar2.BackgroundColor3 = barColor; bar2.BorderSizePixel = 0
        Instance.new("UICorner", bar2).CornerRadius = UDim.new(0,2)
        bar2.Parent = row

        local tag = isOk and "✅" or "❌"
        local il = Instance.new("TextLabel")
        il.Size = UDim2.new(0.55,-14,0,20); il.Position = UDim2.new(0,10,0,4)
        il.BackgroundTransparency = 1; il.TextColor3 = barColor
        il.Font = Enum.Font.GothamBold; il.TextSize = 12
        il.TextXAlignment = Enum.TextXAlignment.Left
        il.TextTruncate = Enum.TextTruncate.AtEnd
        il.Text = tag .. " " .. tostring(entry.item or "?")
        il.Parent = row

        local catLbl = Instance.new("TextLabel")
        catLbl.Size = UDim2.new(0.20,0,0,16); catLbl.Position = UDim2.new(0.45,0,0,6)
        catLbl.BackgroundTransparency = 1; catLbl.TextColor3 = Color3.fromRGB(160,160,200)
        catLbl.Font = Enum.Font.Gotham; catLbl.TextSize = 9
        catLbl.TextXAlignment = Enum.TextXAlignment.Left
        catLbl.TextTruncate = Enum.TextTruncate.AtEnd
        catLbl.Text = tostring(entry.category or "")
        catLbl.Parent = row

        local amtLbl = Instance.new("TextLabel")
        amtLbl.Size = UDim2.new(0,44,0,16); amtLbl.Position = UDim2.new(0.65,0,0,6)
        amtLbl.BackgroundColor3 = isOk and Color3.fromRGB(20,60,35) or Color3.fromRGB(60,20,20)
        amtLbl.TextColor3 = barColor; amtLbl.Font = Enum.Font.GothamBold
        amtLbl.TextSize = 11; amtLbl.TextXAlignment = Enum.TextXAlignment.Center
        amtLbl.Text = "x" .. tostring(entry.amount or 1)
        amtLbl.BorderSizePixel = 0
        Instance.new("UICorner", amtLbl).CornerRadius = UDim.new(0,4)
        amtLbl.Parent = row

        local rl = Instance.new("TextLabel")
        rl.Size = UDim2.new(1,-10,0,16); rl.Position = UDim2.new(0,10,0,26)
        rl.BackgroundTransparency = 1; rl.TextColor3 = Color3.fromRGB(100,110,140)
        rl.Font = Enum.Font.Gotham; rl.TextSize = 10
        rl.TextXAlignment = Enum.TextXAlignment.Left
        rl.TextTruncate = Enum.TextTruncate.AtEnd
        rl.Text = "→ " .. tostring(entry.recipient or "?") .. "  •  " .. tostring(entry.time or "")
        rl.Parent = row
    end
    updateHistStat()
    task.defer(function()
        histScroll.CanvasPosition = Vector2.new(0, math.huge)
    end)
end

local function addHistoryEntry(recipient, item, amount, isOk, category)
    local entry = {
        time      = os.date("%H:%M:%S"),
        recipient = tostring(recipient or ""),
        item      = tostring(item or ""),
        amount    = amount or 1,
        status    = isOk and "ok" or "fail",
        category  = tostring(category or ""),
    }
    table.insert(historyData, entry)
    if #historyData > MAX_HISTORY then table.remove(historyData, 1) end
    saveHistory(historyData)
    rebuildHistoryFiltered(filterVal)
end

fBtnAll.MouseButton1Click:Connect(function() filterVal = "all"; rebuildHistoryFiltered("all") end)
fBtnOk.MouseButton1Click:Connect(function() filterVal = "ok"; rebuildHistoryFiltered("ok") end)
fBtnFail.MouseButton1Click:Connect(function() filterVal = "fail"; rebuildHistoryFiltered("fail") end)
hClearBtn.MouseButton1Click:Connect(function() historyData = {}; saveHistory(historyData); rebuildHistoryFiltered(filterVal); updateHistStat() end)
histBtn.MouseButton1Click:Connect(function()
    HistGui.Visible = not HistGui.Visible
    if HistGui.Visible then syncHistPos(); rebuildHistoryFiltered(filterVal) end
end)

-- MT Button drag + toggle
local mtDragStart, mtStartPos, mtMoved
MTBtn.InputBegan:Connect(function(inp)
    if isBeginInput(inp) then mtDragStart = getPos2(inp); mtStartPos = MTBtn.Position; mtMoved = false end
end)
UserInputService.InputChanged:Connect(function(inp)
    if mtDragStart and isMoveInput(inp) then
        local p = getPos2(inp)
        local dx = p.X - mtDragStart.X
        local dy = p.Y - mtDragStart.Y
        if math.abs(dx) > 6 or math.abs(dy) > 6 then mtMoved = true end
        if mtMoved then
            MTBtn.Position = UDim2.new(mtStartPos.X.Scale, mtStartPos.X.Offset + dx, mtStartPos.Y.Scale, mtStartPos.Y.Offset + dy)
        end
    end
end)
MTBtn.InputEnded:Connect(function(inp)
    if isEndInput(inp) then
        if not mtMoved then
            local now = not Main.Visible
            if not now then
                histWasVisible = HistGui.Visible
                HistGui.Visible = false
            else
                HistGui.Visible = histWasVisible
                if histWasVisible then syncHistPos() end
            end
            Main.Visible = now
            MTBtn.BackgroundColor3 = now and Color3.fromRGB(14,40,24) or Color3.fromRGB(40,14,14)
            MTBtn.TextColor3 = now and Color3.fromRGB(80,200,140) or Color3.fromRGB(200,80,80)
        end
        mtDragStart = nil; mtMoved = false
    end
end)

-- =====================================================================
-- MAIN UI CONTENT
-- =====================================================================
-- Recipient row
local recipRow = mkFrame(Main, UDim2.new(1,-20,0,28), UDim2.new(0,10,0,44), C.panel, 6, C.border)
local recipIcon = mkLabel(recipRow, "→", 12, C.muted, Enum.Font.GothamBold)
recipIcon.Size = UDim2.new(0,20,1,0); recipIcon.Position = UDim2.new(0,6,0,0)
recipIcon.TextXAlignment = Enum.TextXAlignment.Center

local recipBox = Instance.new("TextBox")
recipBox.Text = cfg.Recipient or ""
recipBox.PlaceholderText = "Tên người nhận (Username)..."
recipBox.Size = UDim2.new(1,-30,1,0); recipBox.Position = UDim2.new(0,26,0,0)
recipBox.BackgroundTransparency = 1; recipBox.TextColor3 = C.text
recipBox.PlaceholderColor3 = C.muted; recipBox.TextSize = 12
recipBox.Font = Enum.Font.Gotham; recipBox.TextXAlignment = Enum.TextXAlignment.Left
recipBox.Parent = recipRow
recipBox:GetPropertyChangedSignal("Text"):Connect(function()
    cfg.Recipient = recipBox.Text; saveConfig(cfg)
end)

-- Note row
local noteRow = mkFrame(Main, UDim2.new(1,-20,0,26), UDim2.new(0,10,0,76), C.panel, 6, C.border)
local noteBox = Instance.new("TextBox")
noteBox.Text = cfg.Note or ""; noteBox.PlaceholderText = "Ghi chú..."
noteBox.Size = UDim2.new(1,-10,1,0); noteBox.Position = UDim2.new(0,8,0,0)
noteBox.BackgroundTransparency = 1; noteBox.TextColor3 = C.muted
noteBox.PlaceholderColor3 = C.border; noteBox.TextSize = 11
noteBox.Font = Enum.Font.Gotham; noteBox.TextXAlignment = Enum.TextXAlignment.Left
noteBox.Parent = noteRow
noteBox:GetPropertyChangedSignal("Text"):Connect(function()
    cfg.Note = noteBox.Text; saveConfig(cfg)
end)

-- Tab bar
local tabNames = {"Seeds", "Pets", "Gear", "Log"}
local tabBar = mkFrame(Main, UDim2.new(1,-20,0,28), UDim2.new(0,10,0,108), C.panel, 6)
local activeTab = "Seeds"
local tabBtns = {}

local _tw = math.floor((316 - (#tabNames - 1) * 4) / #tabNames)
for i, name in ipairs(tabNames) do
    local tb = mkBtn(tabBar, name, UDim2.new(0, _tw, 1, -4), UDim2.new(0, (i-1)*(_tw+4) + 2, 0, 2), C.tab, C.muted)
    tb.Font = Enum.Font.GothamBold; tb.TextSize = 11
    tabBtns[name] = tb
end

-- Search bar
local searchRow = mkFrame(Main, UDim2.new(1,-20,0,28), UDim2.new(0,10,0,140), C.panel, 6, C.border)
local searchIcon = mkLabel(searchRow, "🔍", 12, C.muted, Enum.Font.Gotham)
searchIcon.Size = UDim2.new(0,24,1,0); searchIcon.TextXAlignment = Enum.TextXAlignment.Center

local searchBox = Instance.new("TextBox")
searchBox.Text = ""; searchBox.PlaceholderText = "Tìm kiếm item..."
searchBox.Size = UDim2.new(1,-28,1,0); searchBox.Position = UDim2.new(0,26,0,0)
searchBox.BackgroundTransparency = 1; searchBox.TextColor3 = C.text
searchBox.PlaceholderColor3 = C.muted; searchBox.TextSize = 12
searchBox.Font = Enum.Font.Gotham; searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.Parent = searchRow

-- Item list
local listFrame = mkFrame(Main, UDim2.new(1,-20,0,228), UDim2.new(0,10,0,174), C.panel, 6, C.border)
listFrame.ClipsDescendants = true

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1,0,1,0); scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0; scrollFrame.ScrollBarThickness = 3
scrollFrame.ScrollBarImageColor3 = C.accent
scrollFrame.CanvasSize = UDim2.new(0,0,0,0); scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.Parent = listFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0,3); listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollFrame
local listPad = Instance.new("UIPadding")
listPad.PaddingTop = UDim.new(0,4); listPad.PaddingLeft = UDim.new(0,4); listPad.PaddingRight = UDim.new(0,4); listPad.Parent = scrollFrame

-- Log frame
local logFrame = mkFrame(Main, UDim2.new(1,-20,0,228), UDim2.new(0,10,0,174), C.panel, 6, C.border)
logFrame.ClipsDescendants = true; logFrame.Visible = false

local logScroll = Instance.new("ScrollingFrame")
logScroll.Size = UDim2.new(1,0,1,0); logScroll.BackgroundTransparency = 1
logScroll.BorderSizePixel = 0; logScroll.ScrollBarThickness = 3
logScroll.ScrollBarImageColor3 = C.accent
logScroll.CanvasSize = UDim2.new(0,0,0,0); logScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
logScroll.Parent = logFrame

local logListLayout = Instance.new("UIListLayout")
logListLayout.Padding = UDim.new(0,2); logListLayout.SortOrder = Enum.SortOrder.LayoutOrder
logListLayout.Parent = logScroll
local logPad = Instance.new("UIPadding")
logPad.PaddingTop = UDim.new(0,4); logPad.PaddingLeft = UDim.new(0,6); logPad.PaddingRight = UDim.new(0,4); logPad.Parent = logScroll

local clearLogBtn = mkBtn(Main, "🗑 Clear Log", UDim2.new(1,-20,0,22), UDim2.new(0,10,0,406), Color3.fromRGB(40,20,20), C.red)
clearLogBtn.TextSize = 11; clearLogBtn.Visible = false

local logCount = 0
local MAX_LOG = 300
local LOG_COLORS = {
    ok    = { bg = Color3.fromRGB(18,55,35),  text = Color3.fromRGB(80,220,140)  },
    fail  = { bg = Color3.fromRGB(55,18,18),  text = Color3.fromRGB(220,80,80)   },
    warn  = { bg = Color3.fromRGB(50,38,10),  text = Color3.fromRGB(220,170,50)  },
    info  = { bg = Color3.fromRGB(20,28,45),  text = Color3.fromRGB(120,160,220) },
    sep   = { bg = Color3.fromRGB(22,22,32),  text = Color3.fromRGB(70,70,90)    },
    gift  = { bg = Color3.fromRGB(20,45,55),  text = Color3.fromRGB(80,190,220)  },
    claim = { bg = Color3.fromRGB(35,18,55),  text = Color3.fromRGB(180,130,255) },
}

local function addLog(msg, kind)
    logCount += 1
    local frames = {}
    for _, c in ipairs(logScroll:GetChildren()) do
        if c:IsA("Frame") then table.insert(frames, c) end
    end
    if #frames >= MAX_LOG then frames[1]:Destroy() end

    if not kind then
        if msg:find("✅") or msg:find("OK") then kind = "ok"
        elseif msg:find("❌") or msg:find("FAIL") or msg:find("fail") then kind = "fail"
        elseif msg:find("⚠") or msg:find("SKIP") then kind = "warn"
        elseif msg:find("📬") or msg:find("Claim") then kind = "claim"
        elseif msg:find("🎁") then kind = "gift"
        elseif msg:find("──") then kind = "sep"
        else kind = "info" end
    end

    local scheme = LOG_COLORS[kind] or LOG_COLORS.info
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,-4,0,18); row.BackgroundColor3 = scheme.bg
    row.BackgroundTransparency = 0.3; row.LayoutOrder = logCount
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,4)
    row.Parent = logScroll

    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(0,56,1,0); tl.Position = UDim2.new(0,4,0,0)
    tl.BackgroundTransparency = 1; tl.TextColor3 = Color3.fromRGB(70,70,90)
    tl.Font = Enum.Font.Gotham; tl.TextSize = 10
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.Text = os.date("%H:%M:%S"); tl.Parent = row

    local ml = Instance.new("TextLabel")
    ml.Size = UDim2.new(1,-64,1,0); ml.Position = UDim2.new(0,62,0,0)
    ml.BackgroundTransparency = 1; ml.TextColor3 = scheme.text
    ml.Font = Enum.Font.GothamBold; ml.TextSize = 11
    ml.TextXAlignment = Enum.TextXAlignment.Left
    ml.TextTruncate = Enum.TextTruncate.AtEnd
    ml.Text = msg:gsub("^[✅❌⚠ℹ🎁📬%s]+", "")
    ml.Parent = row

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0,3,1,-4); bar.Position = UDim2.new(0,0,0,2)
    bar.BackgroundColor3 = scheme.text; bar.BorderSizePixel = 0
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0,2)
    bar.Parent = row

    task.defer(function()
        logScroll.CanvasPosition = Vector2.new(0, math.huge)
    end)
end

clearLogBtn.MouseButton1Click:Connect(function()
    for _, c in ipairs(logScroll:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    logCount = 0; addLog("Log cleared", "sep")
end)

-- Status bar
local statusBar = mkFrame(Main, UDim2.new(1,-20,0,20), UDim2.new(0,10,0,406), C.header)
local statusLbl = mkLabel(statusBar, "Ready", 11, C.muted, Enum.Font.Gotham, Enum.TextXAlignment.Left)
statusLbl.Size = UDim2.new(1,0,1,0)
local function setStatus(msg, color)
    statusLbl.Text = msg; statusLbl.TextColor3 = color or C.muted
end

-- Buttons
local startBtn = mkBtn(Main, "▶  Start Gift ALL", UDim2.new(1,-20,0,28), UDim2.new(0,10,0,430), C.accent, Color3.fromRGB(10,20,15))
startBtn.Font = Enum.Font.GothamBold; startBtn.TextSize = 13

local onceBtn = mkBtn(Main, "⚡  Send Gift 1 lần", UDim2.new(1,-20,0,26), UDim2.new(0,10,0,462), Color3.fromRGB(60,80,160), Color3.fromRGB(200,210,255))
onceBtn.Font = Enum.Font.GothamBold; onceBtn.TextSize = 12

local claimBtn = mkBtn(Main, "📬  Auto Claim Mail", UDim2.new(1,-20,0,26), UDim2.new(0,10,0,496), Color3.fromRGB(70,40,100), Color3.fromRGB(210,180,255))
claimBtn.Font = Enum.Font.GothamBold; claimBtn.TextSize = 12

-- =====================================================================
-- ITEM ROWS
-- =====================================================================
local function buildRows(tabName)
    for _, ch in ipairs(scrollFrame:GetChildren()) do
        if ch:IsA("Frame") then ch:Destroy() end
    end
    local section = cfg[tabName] or {}
    local filter = searchBox.Text:lower()
    local order = 0

    local keys = {}
    for k in pairs(section) do table.insert(keys, k) end
    table.sort(keys, function(a, b)
        local ea = section[a] and section[a].enabled and 1 or 0
        local eb = section[b] and section[b].enabled and 1 or 0
        if ea ~= eb then return ea > eb end
        return a < b
    end)

    for _, name in ipairs(keys) do
        local data = section[name]
        if filter == "" or name:lower():find(filter, 1, true) then
            order += 1
            local row = mkFrame(scrollFrame,
                UDim2.new(1,-4,0,32), UDim2.new(0,0,0,0),
                data.enabled and C.itemOn or C.itemBg,
                6,
                data.enabled and C.itemOnBorder or C.border)
            row.LayoutOrder = order

            local toggleBtn = Instance.new("TextButton")
            toggleBtn.Size = UDim2.new(1,-80,1,0); toggleBtn.Position = UDim2.new(0,0,0,0)
            toggleBtn.BackgroundTransparency = 1; toggleBtn.Text = ""
            toggleBtn.Parent = row

            local dot = mkLabel(row, data.enabled and "●" or "○", 12, data.enabled and C.accent or C.muted, Enum.Font.GothamBold)
            dot.Size = UDim2.new(0,18,1,0); dot.Position = UDim2.new(0,8,0,0)
            dot.TextXAlignment = Enum.TextXAlignment.Center

            local nameLbl = mkLabel(row, name, 12, data.enabled and C.accent or C.text, Enum.Font.Gotham)
            nameLbl.Size = UDim2.new(1,-100,1,0); nameLbl.Position = UDim2.new(0,28,0,0)

            local amtLbl = mkLabel(row, "x", 11, C.muted, Enum.Font.Gotham, Enum.TextXAlignment.Right)
            amtLbl.Size = UDim2.new(0,14,1,0); amtLbl.Position = UDim2.new(1,-72,0,0)

            local amtBox = Instance.new("TextBox")
            amtBox.Text = tostring(math.min(data.amount or 1, 10000))
            amtBox.Size = UDim2.new(0,52,0,22); amtBox.Position = UDim2.new(1,-58,0.5,-11)
            amtBox.BackgroundColor3 = C.bg; amtBox.TextColor3 = C.text
            amtBox.TextSize = 12; amtBox.Font = Enum.Font.GothamBold
            amtBox.TextXAlignment = Enum.TextXAlignment.Center
            amtBox.BorderSizePixel = 0
            Instance.new("UICorner", amtBox).CornerRadius = UDim.new(0,4)
            local ams = Instance.new("UIStroke", amtBox)
            ams.Color = C.border; ams.Thickness = 1
            amtBox.Parent = row

            amtBox.FocusLost:Connect(function()
                local v = math.clamp(math.floor(tonumber(amtBox.Text) or 1), 1, 10000)
                amtBox.Text = tostring(v)
                section[name].amount = v; saveConfig(cfg)
            end)

            toggleBtn.MouseButton1Click:Connect(function()
                data.enabled = not data.enabled
                section[name].enabled = data.enabled
                saveConfig(cfg); buildRows(tabName)
            end)
        end
    end
end

local function switchTab(name)
    activeTab = name
    for _, t in ipairs(tabNames) do
        local tb = tabBtns[t]
        if t == name then
            tb.BackgroundColor3 = C.tabSel; tb.TextColor3 = Color3.fromRGB(10,20,15)
        else
            tb.BackgroundColor3 = C.tab; tb.TextColor3 = C.muted
        end
    end
    local isLog = (name == "Log")
    listFrame.Visible = not isLog; searchRow.Visible = not isLog
    logFrame.Visible = isLog; clearLogBtn.Visible = isLog
    if not isLog then buildRows(name) end
end

for _, name in ipairs(tabNames) do
    tabBtns[name].MouseButton1Click:Connect(function() switchTab(name) end)
end
searchBox:GetPropertyChangedSignal("Text"):Connect(function() buildRows(activeTab) end)
switchTab("Seeds")

-- =====================================================================
-- SEND LOGIC — Networking
-- =====================================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedModules = ReplicatedStorage:WaitForChild("SharedModules", 10)
local Networking = nil
if SharedModules then
    local nm = SharedModules:FindFirstChild("Networking")
    if nm then
        local ok, r = pcall(require, nm)
        if ok then Networking = r end
    end
end

local SEED_KEY_MAP = {
    ["Gold Seed"]        = "Gold",
    ["Rainbow Seed"]     = "Rainbow",
    ["Baby Cactus"]      = "BabyCactus",
    ["Dragon Fruit"]     = "DragonFruit",
    ["Dragon's Breath"] = "DragonsBreath",
    ["Ghost Pepper"]     = "GhostPepper",
    ["Glow Mushroom"]    = "GlowMushroom",
    ["Green Bean"]       = "GreenBean",
    ["Horned Melon"]     = "HornedMelon",
    ["Moon Bloom"]       = "MoonBloom",
    ["Poison Apple"]     = "PoisonApple",
    ["Poison Ivy"]       = "PoisonIvy",
    ["Venus Fly Trap"]   = "VenusFlyTrap",
}
local GEAR_KEY_MAP = {}

local GEAR_SECTION_MAP = {
    ["Common Watering Can"]   = "WateringCans",
    ["Super Watering Can"]    = "WateringCans",
    ["Uncommon Sprinkler"]    = "Sprinklers",
    ["Rare Sprinkler"]        = "Sprinklers",
    ["Legendary Sprinkler"]   = "Sprinklers",
    ["Super Sprinkler"]       = "Sprinklers",
    ["Trowel"]                = "Trowels",
    ["Sign"]                  = "Signs",
    ["Basic Pot"]             = "Pots",
    ["Jump Mushroom"]         = "Mushrooms",
    ["Speed Mushroom"]        = "Mushrooms",
    ["Supersize Mushroom"]    = "Mushrooms",
    ["Invisibility Mushroom"] = "Mushrooms",
    ["Lantern"]               = "Lanterns",
    ["Gnome"]                 = "Gnomes",
    ["Flashbang"]             = "Flashbangs",
    ["Teleporter"]            = "Teleporters",
    ["Wheelbarrow"]           = "Wheelbarrows",
}

local _PSC = nil
pcall(function()
    _PSC = require(
        ReplicatedStorage:WaitForChild("ClientModules", 10)
        :WaitForChild("PlayerStateClient", 10)
    )
end)

local function getInvSafe()
    if not _PSC then return nil end
    local replica = nil
    if type(_PSC.WaitForLocalReplica) == "function" then
        local ok, r = pcall(function() return _PSC:WaitForLocalReplica(15) end)
        if ok and r then replica = r end
    end
    if not replica and type(_PSC.GetLocalReplica) == "function" then
        local t0 = os.clock()
        repeat
            local ok, r = pcall(function() return _PSC:GetLocalReplica() end)
            if ok and r then replica = r break end
            task.wait(0.25)
        until os.clock() - t0 > 15
    end
    if replica and type(replica.Data) == "table" then
        return replica.Data.Inventory
    end
    return nil
end

-- ── DYNAMIC USER RESOLUTION (FIX CHÍNH TẠI ĐÂY) ──────────────────────
local function getTargetUid()
    local targetName = tostring(cfg.Recipient or ""):gsub("^%s*(.-)%s*$", "%1") -- Trim khoảng trắng
    if targetName == "" then
        return nil, "Chưa nhập tên người nhận!"
    end

    -- 1. Thử qua Networking Mailbox Lookup (nếu game có API riêng)
    if Networking and Networking.Mailbox and Networking.Mailbox.LookupPlayer then
        local ok, uid = pcall(function()
            return Networking.Mailbox.LookupPlayer:Fire(targetName)
        end)
        if ok and type(uid) == "number" and uid > 0 then
            if uid == LocalPlayer.UserId then return nil, "Không gửi cho chính mình" end
            return uid, nil
        end
    end

    -- 2. Thử tra cứu UserId trực tiếp từ Roblox Web API (Async)
    local ok, uid = pcall(function()
        return Players:GetUserIdFromNameAsync(targetName)
    end)

    if ok and type(uid) == "number" and uid > 0 then
        if uid == LocalPlayer.UserId then
            return nil, "Không gửi cho chính mình"
        end
        return uid, nil
    end

    return nil, "Không tìm thấy User: " .. targetName
end

-- ── Collect payloads ──────────────────────────────────────────────────
local function collectPayload()
    local payload = {}
    local inv = getInvSafe()

    local EVENT_SEEDS = {
        ["Mega"] = true,
        ["Rocket Pop"] = true,
    }

    local seedCfg = cfg["Seeds"] or {}
    for name, data in pairs(seedCfg) do
        if type(data) == "table" and data.enabled then
            local amt = math.clamp(math.floor(tonumber(data.amount) or 1), 1, 9999)
            local seedKey = SEED_KEY_MAP[name] or name
            local seedCategory = EVENT_SEEDS[seedKey] and "EventSeeds" or "Seeds"

            table.insert(payload, {
                Category    = seedCategory,
                ItemKey     = seedKey,
                Count       = amt,
                DisplayName = name,
            })
        end
    end
-- 🔍 DEBUG: In danh sách Seed thực sự có trong Inventory ra Log
    if inv and type(inv.Seeds) == "table" then
        print("=== DANH SÁCH SEED TRONG INVENTORY ===")
        for realKey, seedData in pairs(inv.Seeds) do
            addLog("FOUND SEED ID: " .. tostring(realKey), "warn")
            print("Found Seed Key:", realKey)
        end
    else
        addLog("⚠️ Không đọc được inv.Seeds!", "fail")
    end
    
    local petCfg = cfg["Pets"] or {}
    local quota = {}
    for name, data in pairs(petCfg) do
        if type(data) == "table" and data.enabled then
            quota[name] = math.clamp(math.floor(tonumber(data.amount) or 1), 1, 10000)
        end
    end
    if next(quota) ~= nil and inv and type(inv.Pets) == "table" then
        local used = {}
        for itemKey, entry in pairs(inv.Pets) do
            if type(entry) == "table" and entry.Id ~= nil then
                local petName = ""
                for _, f in ipairs({"Name","PetName","Species","DisplayName","Type","Kind"}) do
                    if entry[f] ~= nil and tostring(entry[f]) ~= "" then
                        petName = tostring(entry[f]); break
                    end
                end
                local normEntry = petName:lower():gsub("%s+","")
                for cfgName, q in pairs(quota) do
                    if cfgName:lower():gsub("%s+","") == normEntry or cfgName == petName then
                        used[cfgName] = used[cfgName] or 0
                        if used[cfgName] < q then
                            if entry.Equipped ~= true and entry.Locked ~= true
                                and entry.Favorite ~= true and entry.Favorited ~= true then
                                used[cfgName] += 1
                                table.insert(payload, {
                                    Category    = "Pets",
                                    ItemKey     = tostring(itemKey),
                                    Count       = 1,
                                    DisplayName = petName ~= "" and petName or cfgName,
                                })
                            end
                        end
                        break
                    end
                end
            end
        end
    end

    return payload
end

local function collectGearPayload()
    local gear = {}
    local gearCfg = cfg["Gear"] or {}
    for name, data in pairs(gearCfg) do
        if type(data) == "table" and data.enabled then
            local amt = math.clamp(math.floor(tonumber(data.amount) or 1), 1, 999)
            table.insert(gear, {
                name    = name,
                itemKey = GEAR_KEY_MAP[name] or name,
                amount  = amt,
            })
        end
    end
    return gear
end

-- ── Send functions ────────────────────────────────────────────────────
local function sendOneRound(uid, total, skip)
    local seedsPets = collectPayload()
    local gears     = collectGearPayload()

    local batchPayload = {}
    local batchMeta    = {}

    for _, item in ipairs(seedsPets) do
        table.insert(batchPayload, {
            Category = item.Category,
            ItemKey  = item.ItemKey,
            Count    = item.Count,
        })
        table.insert(batchMeta, {
            displayName = item.DisplayName,
            count       = item.Count,
            category    = item.Category,
        })
    end

    for _, item in ipairs(gears) do
        local category = GEAR_SECTION_MAP[item.name]
        if not category then
            addLog(string.format("Gear %s — SKIP: không biết section", item.name), "warn")
            skip += 1
        else
            table.insert(batchPayload, {
                Category = category,
                ItemKey  = item.itemKey,
                Count    = item.amount,
            })
            table.insert(batchMeta, {
                displayName = item.name,
                count       = item.amount,
                category    = category,
            })
        end
    end

    if #batchPayload == 0 then return total, skip end

    setStatus(string.format("📨 Gửi 1 batch (%d loại) → %s", #batchPayload, cfg.Recipient), C.accent)

    local ok2, result, msg2 = pcall(function()
        return Networking.Mailbox.SendBatch:Fire(uid, batchPayload, tostring(cfg.Note or ""))
    end)

    if ok2 and result == true then
        for _, m in ipairs(batchMeta) do
            addLog(string.format("Gift %s x%d — OK ✅", m.displayName, m.count), "ok")
            addHistoryEntry(cfg.Recipient, m.displayName, m.count, true, m.category)
            total += m.count
        end
        addLog(string.format("── Batch OK | %d loại | tổng +%d ──", #batchMeta, total), "sep")
    else
        local errMsg = tostring(msg2 or result or "server reject")
        addLog(string.format("Batch FAIL (%d loại): %s", #batchPayload, errMsg), "fail")
        for _, m in ipairs(batchMeta) do
            skip += 1
            addHistoryEntry(cfg.Recipient, m.displayName, m.count, false, m.category)
        end
        warn("[AutoMailUI] Batch fail:", errMsg)
    end

    return total, skip
end

-- ── Button handlers ───────────────────────────────────────────────────
local running = false
local stopRequested = false

startBtn.MouseButton1Click:Connect(function()
    if running then
        stopRequested = true
        startBtn.Text = "⏳ Dừng sau vòng này..."
        startBtn.BackgroundColor3 = Color3.fromRGB(160,80,20)
        return
    end

    setStatus("Đang tra cứu tên user...", C.muted)
    local uid, err = getTargetUid()
    if not uid then setStatus("❌ " .. err, C.red) addLog("Lỗi Tra Cứu: " .. err, "fail") return end

    local payload = collectPayload()
    local gearPayload = collectGearPayload()
    if #payload == 0 and #gearPayload == 0 then
        setStatus("⚠ Chưa chọn item nào!", C.muted) return
    end

    running = true
    startBtn.Text = "⏹  Stop"
    startBtn.BackgroundColor3 = C.red
    startBtn.TextColor3 = Color3.new(1,1,1)
    stopRequested = false

    local roundTotal, roundSkip = 0, 0
    task.spawn(function()
        while true do
            roundTotal, roundSkip = sendOneRound(uid, roundTotal, roundSkip)
            if stopRequested then break end
            setStatus(string.format("🔄 Vòng xong | gửi: %d | skip: %d — tiếp...", roundTotal, roundSkip), C.accent)
            task.wait(1)
        end
        running = false; stopRequested = false
        startBtn.Text = "▶  Start Gift ALL"
        startBtn.BackgroundColor3 = C.accent
        startBtn.TextColor3 = Color3.fromRGB(10,20,15)
        addLog(string.format("Stop | gửi: %d | skip: %d", roundTotal, roundSkip), "sep")
        setStatus(string.format("⏹ Đã dừng | tổng gửi: %d | skip: %d", roundTotal, roundSkip), C.muted)
    end)
end)

onceBtn.MouseButton1Click:Connect(function()
    if running then setStatus("⚠ Đang có loop chạy, dừng loop trước", C.red) return end

    setStatus("Đang tra cứu tên user...", C.muted)
    local uid, err = getTargetUid()
    if not uid then setStatus("❌ " .. err, C.red) addLog("Lỗi Tra Cứu: " .. err, "fail") return end

    local payload = collectPayload()
    local gearPayload = collectGearPayload()
    if #payload == 0 and #gearPayload == 0 then
        setStatus("⚠ Chưa chọn item nào!", C.muted) return
    end

    onceBtn.Text = "⏳ Đang gửi..."
    onceBtn.BackgroundColor3 = Color3.fromRGB(40,55,110)
    running = true

    local total, skip = 0, 0
    task.spawn(function()
        total, skip = sendOneRound(uid, total, skip)
        running = false
        onceBtn.Text = "⚡  Send Gift 1 lần"
        onceBtn.BackgroundColor3 = Color3.fromRGB(60,80,160)
        addLog(string.format("1 lần xong | gửi: %d | skip: %d", total, skip), "info")
        setStatus(string.format("✅ Done | gửi: %d | skip: %d", total, skip), skip > 0 and C.red or C.accent)
    end)
end)

-- ── Claim Mail ────────────────────────────────────────────────────────
local claimRunning = false
claimBtn.MouseButton1Click:Connect(function()
    if claimRunning then
        claimRunning = false
        claimBtn.Text = "📬  Auto Claim Mail"
        claimBtn.BackgroundColor3 = Color3.fromRGB(70,40,100)
        claimBtn.TextColor3 = Color3.fromRGB(210,180,255)
        setStatus("⏹ Đã dừng claim", C.muted)
        return
    end
    if not Networking or not Networking.Mailbox then
        setStatus("❌ Networking.Mailbox không tìm thấy", C.red) return
    end

    claimRunning = true
    claimBtn.Text = "⏹  Stop Claim"
    claimBtn.BackgroundColor3 = C.red
    claimBtn.TextColor3 = Color3.new(1,1,1)

    task.spawn(function()
        local totalClaimed = 0
        while claimRunning do
            local inbox = nil
            local ok, result = pcall(function()
                return Networking.Mailbox.OpenInbox:Fire()
            end)
            if ok and type(result) == "table" then
                inbox = (type(result.Mailbox) == "table") and result.Mailbox or result
            end

            if not inbox or next(inbox) == nil then
                setStatus(string.format("📭 Inbox trống | đã claim: %d", totalClaimed), C.muted)
                task.wait(2)
            else
                local ids = {}
                for mailId in pairs(inbox) do
                    if type(mailId) == "string" then table.insert(ids, mailId) end
                end
                for i, mailId in ipairs(ids) do
                    if not claimRunning then break end
                    setStatus(string.format("📬 Claim [%d/%d] | tổng: %d", i, #ids, totalClaimed), Color3.fromRGB(210,180,255))
                    local cok, success, reason = pcall(function()
                        return Networking.Mailbox.Claim:Fire(mailId)
                    end)
                    if cok and success then
                        totalClaimed += 1
                        addLog("Claimed mail #" .. i, "claim")
                    else
                        addLog("Claim fail #" .. i .. ": " .. tostring(reason or success), "fail")
                    end
                    task.wait(0.3)
                end
            end
        end
        claimBtn.Text = "📬  Auto Claim Mail"
        claimBtn.BackgroundColor3 = Color3.fromRGB(70,40,100)
        claimBtn.TextColor3 = Color3.fromRGB(210,180,255)
        setStatus(string.format("✅ Claim xong | tổng: %d", totalClaimed), C.accent)
    end)
end)

-- ── Hotkey Ctrl toggle ────────────────────────────────────────────────
UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.LeftControl then
        local now = not Main.Visible
        if not now then
            histWasVisible = HistGui.Visible; HistGui.Visible = false
        else
            HistGui.Visible = histWasVisible
            if histWasVisible then syncHistPos() end
        end
        Main.Visible = now
    end
end)

-- ── Init ─────────────────────────────────────────────────────────────
syncHistPos()
rebuildHistoryFiltered(filterVal)

print("[AutoMailUI] Dynamic User Fix Loaded — Config:", configPath)
setStatus("Ready — " .. configPath, C.muted)
