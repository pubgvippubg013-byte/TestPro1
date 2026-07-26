local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local username = LocalPlayer.Name
local configPath = username .. "-sendmailgag2.json"
local historyPath = username .. "-sendmailgag2-history.json"

-- ===================== DEFAULT CONFIG =====================
local defaultConfig = {
    Recipient = "nhap ten ngnhan",
    RecipientUserId = 0,
    Note = "Mtr Chill",
    Seeds = {
        Bamboo        = { enabled = false, amount = 1 },
        ["Glow Mushroom"] = { enabled = false, amount = 1 },
        Mushroom      = { enabled = false, amount = 1 },
        ["Gold Seed"] = { enabled = false, amount = 1 },
        ["Rainbow Seed"] = { enabled = false, amount = 1 },
        Acorn         = { enabled = false, amount = 1 },
        Apple         = { enabled = false, amount = 1 },
        ["Baby Cactus"] = { enabled = false, amount = 1 },
        Banana        = { enabled = false, amount = 1 },
        Blueberry     = { enabled = false, amount = 1 },
        Cactus        = { enabled = false, amount = 1 },
        Carrot        = { enabled = false, amount = 1 },
        Cherry        = { enabled = false, amount = 1 },
        Coconut       = { enabled = false, amount = 1 },
        Corn          = { enabled = false, amount = 1 },
        ["Dragon Fruit"] = { enabled = false, amount = 1 },
        ["Dragon's Breath"] = { enabled = false, amount = 1 },
        ["Ghost Pepper"] = { enabled = false, amount = 1 },
        Grape         = { enabled = false, amount = 1 },
        ["Green Bean"] = { enabled = false, amount = 1 },
        ["Horned Melon"] = { enabled = false, amount = 1 },
        Mango         = { enabled = false, amount = 1 },
        ["Moon Bloom"] = { enabled = false, amount = 1 },
        Pineapple     = { enabled = false, amount = 1 },
        ["Poison Apple"] = { enabled = false, amount = 1 },
        ["Poison Ivy"] = { enabled = false, amount = 1 },
        Pomegranate   = { enabled = false, amount = 1 },
        Romanesco     = { enabled = false, amount = 1 },
        Strawberry    = { enabled = false, amount = 1 },
        Sunflower     = { enabled = false, amount = 1 },
        Tomato        = { enabled = false, amount = 1 },
        Tulip         = { enabled = false, amount = 1 },
        ["Venus Fly Trap"] = { enabled = false, amount = 1 },
        ["Mega Seed"]      = { enabled = false, amount = 1 },
    },

    Pets = {
        Bee           = { enabled = false, amount = 1 },
        BlackDragon   = { enabled = false, amount = 1 },
        Bunny         = { enabled = false, amount = 1 },
        Deer          = { enabled = false, amount = 1 },
        Frog          = { enabled = false, amount = 1 },
        GoldenDragonfly = { enabled = false, amount = 1 },
        IceSerpent    = { enabled = false, amount = 1 },
        Monkey        = { enabled = false, amount = 1 },
        Owl           = { enabled = false, amount = 1 },
        Raccoon       = { enabled = false, amount = 1 },
        Robin         = { enabled = false, amount = 1 },
        Unicorn       = { enabled = false, amount = 1 },
    },
}

-- ===================== FILE IO =====================
local function loadConfig()
    if isfile and isfile(configPath) then
        local ok, decoded = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile(configPath))
        end)
        if ok and type(decoded) == "table" then
            print("[AutoMailUI] Loaded config từ", configPath)
            return decoded
        end
    end
    return nil
end

local function saveConfig(cfg)
    if writefile then
        local ok, encoded = pcall(function()
            return game:GetService("HttpService"):JSONEncode(cfg)
        end)
        if ok then
            writefile(configPath, encoded)
        end
    end
end

-- ===================== HISTORY IO =====================
local MAX_HISTORY = 200  -- tối đa 200 bản ghi

local function loadHistory()
    if isfile and isfile(historyPath) then
        local ok, decoded = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile(historyPath))
        end)
        if ok and type(decoded) == "table" then
            return decoded
        end
    end
    return {}
end

local function saveHistory(hist)
    if writefile then
        local ok, encoded = pcall(function()
            return game:GetService("HttpService"):JSONEncode(hist)
        end)
        if ok then
            writefile(historyPath, encoded)
        end
    end
end

-- historyData: array of {time, recipient, item, amount, status, category}
local historyData = loadHistory()

local historyScrollRef   -- forward ref, được gán sau khi tạo UI
local historyCountRef = 0

local function rebuildHistoryUI()
    if not historyScrollRef then return end
    for _, ch in ipairs(historyScrollRef:GetChildren()) do
        if ch:IsA("Frame") then ch:Destroy() end
    end
    historyCountRef = 0
    for i = #historyData, math.max(1, #historyData - MAX_HISTORY + 1), -1 do
        local entry = historyData[i]
        if type(entry) ~= "table" then continue end
        historyCountRef += 1

        local isOk = entry.status == "ok"
        local rowBg   = isOk and Color3.fromRGB(14,45,28) or Color3.fromRGB(50,14,14)
        local barColor = isOk and Color3.fromRGB(60,210,120) or Color3.fromRGB(220,70,70)
        local tagText  = isOk and "✅" or "❌"

        local row = Instance.new("Frame")
        row.Size = UDim2.new(1,-6,0,48)
        row.BackgroundColor3 = rowBg
        row.BackgroundTransparency = 0.15
        row.LayoutOrder = historyCountRef
        row.BorderSizePixel = 0
        local rc = Instance.new("UICorner")
        rc.CornerRadius = UDim.new(0,6)
        rc.Parent = row
        row.Parent = historyScrollRef

        -- Left bar
        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(0,3,1,-6)
        bar.Position = UDim2.new(0,0,0,3)
        bar.BackgroundColor3 = barColor
        bar.BorderSizePixel = 0
        local bc2 = Instance.new("UICorner")
        bc2.CornerRadius = UDim.new(0,2)
        bc2.Parent = bar
        bar.Parent = row

        -- Tag + item name
        local itemLbl = Instance.new("TextLabel")
        itemLbl.Size = UDim2.new(1,-70,0,20)
        itemLbl.Position = UDim2.new(0,10,0,4)
        itemLbl.BackgroundTransparency = 1
        itemLbl.TextColor3 = barColor
        itemLbl.Font = Enum.Font.GothamBold
        itemLbl.TextSize = 12
        itemLbl.TextXAlignment = Enum.TextXAlignment.Left
        itemLbl.TextTruncate = Enum.TextTruncate.AtEnd
        itemLbl.Text = tagText .. " " .. tostring(entry.item or "?")
        itemLbl.Parent = row

        -- Amount badge
        local amtLbl = Instance.new("TextLabel")
        amtLbl.Size = UDim2.new(0,58,0,18)
        amtLbl.Position = UDim2.new(1,-62,0,5)
        amtLbl.BackgroundColor3 = isOk and Color3.fromRGB(20,60,35) or Color3.fromRGB(60,20,20)
        amtLbl.BackgroundTransparency = 0
        amtLbl.TextColor3 = barColor
        amtLbl.Font = Enum.Font.GothamBold
        amtLbl.TextSize = 11
        amtLbl.TextXAlignment = Enum.TextXAlignment.Center
        amtLbl.Text = "x" .. tostring(entry.amount or 1)
        amtLbl.BorderSizePixel = 0
        local alc = Instance.new("UICorner")
        alc.CornerRadius = UDim.new(0,4)
        alc.Parent = amtLbl
        amtLbl.Parent = row

        -- Recipient
        local recipLbl = Instance.new("TextLabel")
        recipLbl.Size = UDim2.new(1,-10,0,16)
        recipLbl.Position = UDim2.new(0,10,0,24)
        recipLbl.BackgroundTransparency = 1
        recipLbl.TextColor3 = Color3.fromRGB(130,130,155)
        recipLbl.Font = Enum.Font.Gotham
        recipLbl.TextSize = 10
        recipLbl.TextXAlignment = Enum.TextXAlignment.Left
        recipLbl.TextTruncate = Enum.TextTruncate.AtEnd
        recipLbl.Text = "→ " .. tostring(entry.recipient or "?") .. "  •  " .. tostring(entry.time or "")
        recipLbl.Parent = row
    end
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
    if #historyData > MAX_HISTORY then
        table.remove(historyData, 1)
    end
    saveHistory(historyData)
    rebuildHistoryUI()
end

local savedCfg = loadConfig()
local cfg = savedCfg or {}
-- Merge defaults
for section, items in pairs(defaultConfig) do
    if type(items) == "table" and section ~= "Recipient" and section ~= "RecipientUserId" and section ~= "Note" then
        cfg[section] = cfg[section] or {}
        for name, def in pairs(items) do
            cfg[section][name] = cfg[section][name] or { enabled = false, amount = def.amount }
        end
    end
end
cfg.Recipient = cfg.Recipient or defaultConfig.Recipient
cfg.RecipientUserId = cfg.RecipientUserId or defaultConfig.RecipientUserId
cfg.Note = cfg.Note or defaultConfig.Note

-- ===================== UI BUILD =====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoMailGAG2_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

-- Colors
local C = {
    bg      = Color3.fromRGB(18, 18, 24),
    panel   = Color3.fromRGB(26, 26, 36),
    border  = Color3.fromRGB(50, 50, 70),
    accent  = Color3.fromRGB(80, 200, 140),
    accentDim = Color3.fromRGB(30, 80, 55),
    text    = Color3.fromRGB(220, 220, 230),
    muted   = Color3.fromRGB(130, 130, 155),
    red     = Color3.fromRGB(220, 70, 70),
    tab     = Color3.fromRGB(35, 35, 50),
    tabSel  = Color3.fromRGB(50, 180, 110),
    itemBg  = Color3.fromRGB(30, 30, 44),
    itemOn  = Color3.fromRGB(20, 65, 45),
    itemOnBorder = Color3.fromRGB(60, 200, 120),
    header  = Color3.fromRGB(22, 22, 32),
}

local function mkFrame(parent, size, pos, bg, radius, border)
    local f = Instance.new("Frame")
    f.Size = size
    f.Position = pos
    f.BackgroundColor3 = bg or C.panel
    f.BorderSizePixel = 0
    if radius then
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, radius)
        c.Parent = f
    end
    if border then
        local s = Instance.new("UIStroke")
        s.Color = border
        s.Thickness = 1
        s.Parent = f
    end
    f.Parent = parent
    return f
end

local function mkLabel(parent, text, size, color, font, align)
    local l = Instance.new("TextLabel")
    l.Text = text
    l.TextSize = size or 13
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
    b.Text = text
    b.Size = size
    b.Position = pos or UDim2.new(0,0,0,0)
    b.BackgroundColor3 = bg or C.accent
    b.TextColor3 = textColor or Color3.fromRGB(10, 10, 20)
    b.TextSize = 13
    b.Font = Enum.Font.GothamBold
    b.BorderSizePixel = 0
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = b
    b.Parent = parent
    return b
end

-- ===================== MAIN WINDOW =====================
local Main = mkFrame(ScreenGui,
    UDim2.new(0, 340, 0, 530),
    UDim2.new(0.5, -170, 0.5, -265),
    C.bg, 10, C.border)
Main.ClipsDescendants = true

-- Drag (cập nhật cả HistGui liền kề)
local dragging, dragStart, startPos
local HistGui  -- forward ref
local histWasVisible = false  -- ghi nhớ trạng thái HistGui trước khi ẩn
local HIST_GAP = 6  -- khoảng cách giữa Main và History panel

local function syncHistPos()
    if HistGui then
        local mp = Main.Position
        HistGui.Position = UDim2.new(
            mp.X.Scale, mp.X.Offset - 340 - HIST_GAP,
            mp.Y.Scale, mp.Y.Offset)
    end
end

-- Helper: nhận input touch lẫn mouse
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

Main.InputBegan:Connect(function(inp)
    if isBeginInput(inp) then
        dragging = true
        dragStart = inp.Position
        startPos = Main.Position
    end
end)
Main.InputEnded:Connect(function(inp)
    if isEndInput(inp) then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if dragging and isMoveInput(inp) then
        local delta = inp.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        syncHistPos()
    end
end)

-- Header
local Header = mkFrame(Main, UDim2.new(1,0,0,38), UDim2.new(0,0,0,0), C.header, 0)
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)
-- fix bottom corners
local topFix = mkFrame(Header, UDim2.new(1,0,0,10), UDim2.new(0,0,1,-10), C.header)

local titleLbl = mkLabel(Header, "📦 AutoMail By Mtr Chill", 14, C.accent, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
titleLbl.Position = UDim2.new(0, 12, 0, 0)
titleLbl.Size = UDim2.new(1, -80, 1, 0)

local senderLbl = mkLabel(Header, "Sender: " .. username, 11, C.muted, Enum.Font.Gotham, Enum.TextXAlignment.Left)
senderLbl.Position = UDim2.new(0, 12, 0, 20)
senderLbl.Size = UDim2.new(1, -80, 0, 16)

local closeBtn = mkBtn(Header, "✕", UDim2.new(0,26,0,26), UDim2.new(1,-32,0.5,-13), C.red, Color3.new(1,1,1))
closeBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Nút History trên Header
local histBtn = mkBtn(Header, "📋", UDim2.new(0,26,0,26), UDim2.new(1,-62,0.5,-13),
    Color3.fromRGB(30,50,80), Color3.fromRGB(120,180,255))
histBtn.TextSize = 14

-- ── Nút tròn MT (toggle UI) ──────────────────────────────
local MTBtn = Instance.new("TextButton")
MTBtn.Size = UDim2.new(0, 48, 0, 48)
MTBtn.Position = UDim2.new(0, 20, 0.5, -24)
MTBtn.BackgroundColor3 = Color3.fromRGB(14, 40, 24)
MTBtn.TextColor3 = Color3.fromRGB(80, 200, 140)
MTBtn.Text = "MT"
MTBtn.Font = Enum.Font.GothamBold
MTBtn.TextSize = 15
MTBtn.BorderSizePixel = 0
MTBtn.ZIndex = 10
local mtCorner = Instance.new("UICorner")
mtCorner.CornerRadius = UDim.new(1, 0)
mtCorner.Parent = MTBtn
local mtStroke = Instance.new("UIStroke")
mtStroke.Color = Color3.fromRGB(60, 180, 100)
mtStroke.Thickness = 2
mtStroke.Parent = MTBtn
MTBtn.Parent = ScreenGui

-- ===================== HISTORY WINDOW (gắn liền bên trái Main) =====================
-- Tạo trước để forward ref hoạt động
HistGui = mkFrame(ScreenGui,
    UDim2.new(0, 340, 0, 530),
    UDim2.new(0.5, -516, 0.5, -265),  -- bên trái Main (170+6+340=516)
    C.bg, 10, Color3.fromRGB(60,100,180))
HistGui.ClipsDescendants = true
HistGui.Visible = false
HistGui.ZIndex = 5

-- ── Layout HistGui (530px tổng) ─────────────────────────
--  [0  →  38]  Header
--  [44 →  72]  StatBar (28px)
--  [78 → 104]  Toolbar: Filter + Clear (26px)
--  [110→ 130]  Column header (20px)
--  [131→ 132]  Divider
--  [134→ 502]  Scroll list (368px)
--  [506→ 524]  Footer filepath (18px)
--  [526→ 528]  padding bottom
-- ─────────────────────────────────────────────────────────

-- History Header
local HistHeader = mkFrame(HistGui, UDim2.new(1,0,0,38), UDim2.new(0,0,0,0),
    Color3.fromRGB(16,22,38), 10)
Instance.new("UICorner", HistHeader).CornerRadius = UDim.new(0,10)
mkFrame(HistHeader, UDim2.new(1,0,0,10), UDim2.new(0,0,1,-10), Color3.fromRGB(16,22,38))

local hTitleLbl = mkLabel(HistHeader, "📋 Lịch Sử Gửi", 14,
    Color3.fromRGB(120,180,255), Enum.Font.GothamBold, Enum.TextXAlignment.Left)
hTitleLbl.Position = UDim2.new(0, 12, 0.5, -7)
hTitleLbl.Size = UDim2.new(1, -46, 0, 18)

local hCloseBtn = mkBtn(HistHeader, "✕",
    UDim2.new(0,26,0,26), UDim2.new(1,-32,0.5,-13),
    C.red, Color3.new(1,1,1))
hCloseBtn.MouseButton1Click:Connect(function()
    HistGui.Visible = false
end)

-- Stat bar
local histStatBar = mkFrame(HistGui, UDim2.new(1,-20,0,28),
    UDim2.new(0,10,0,44), Color3.fromRGB(16,22,38), 6,
    Color3.fromRGB(40,60,100))
local histStatLbl = mkLabel(histStatBar, "Tổng: 0  |  ✅ 0  |  ❌ 0", 11,
    Color3.fromRGB(120,180,255), Enum.Font.GothamBold, Enum.TextXAlignment.Left)
histStatLbl.Size = UDim2.new(1,-10,1,0)
histStatLbl.Position = UDim2.new(0,8,0,0)

local function updateHistStat()
    local ok2, fail2 = 0, 0
    for _, e in ipairs(historyData) do
        if type(e) == "table" then
            if e.status == "ok" then ok2 += 1 else fail2 += 1 end
        end
    end
    histStatLbl.Text = string.format("Tổng: %d  |  ✅ %d  |  ❌ %d", #historyData, ok2, fail2)
end

-- Toolbar: Filter buttons + Clear (1 hàng, Y=78, cao 26px)
local toolbar = mkFrame(HistGui, UDim2.new(1,-20,0,26),
    UDim2.new(0,10,0,78), Color3.fromRGB(16,22,38), 6)

local filterVal = "all"
local fBtnAll  = mkBtn(toolbar, "Tất cả",
    UDim2.new(0,72,1,-2), UDim2.new(0,1,0,1),
    Color3.fromRGB(40,60,100), Color3.fromRGB(180,200,255))
local fBtnOk   = mkBtn(toolbar, "✅ OK",
    UDim2.new(0,72,1,-2), UDim2.new(0,76,0,1),
    Color3.fromRGB(15,45,28), Color3.fromRGB(80,210,130))
local fBtnFail = mkBtn(toolbar, "❌ Fail",
    UDim2.new(0,72,1,-2), UDim2.new(0,151,0,1),
    Color3.fromRGB(50,15,15), Color3.fromRGB(220,80,80))
local hClearBtn = mkBtn(toolbar, "🗑 Xóa",
    UDim2.new(1,-228,1,-2), UDim2.new(0,226,0,1),
    Color3.fromRGB(40,15,15), C.red)

for _, b in ipairs({fBtnAll, fBtnOk, fBtnFail, hClearBtn}) do
    b.TextSize = 10
    b.Font = Enum.Font.GothamBold
end

-- Column headers (Y=110)
local colHdr = mkFrame(HistGui, UDim2.new(1,-20,0,20),
    UDim2.new(0,10,0,110), Color3.fromRGB(16,22,38))

local function mkColLabel(parent, txt, xScale, xOff, wScale, wOff)
    local l = Instance.new("TextLabel")
    l.Text = txt
    l.Size = UDim2.new(wScale, wOff, 1, 0)
    l.Position = UDim2.new(xScale, xOff, 0, 0)
    l.BackgroundTransparency = 1
    l.TextColor3 = Color3.fromRGB(70,100,150)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end
mkColLabel(colHdr, "ITEM",        0,    8, 0.55, 0)
mkColLabel(colHdr, "SL",          0.55, 0, 0.18, 0)
mkColLabel(colHdr, "NGƯỜI NHẬN",  0.73, 0, 0.27, -4)

-- Divider (Y=130)
mkFrame(HistGui, UDim2.new(1,-20,0,1), UDim2.new(0,10,0,130), Color3.fromRGB(40,60,100))

-- Scroll list (Y=134, cao=368, chiếm đến Y=502)
local histListFrame = mkFrame(HistGui, UDim2.new(1,-20,0,368),
    UDim2.new(0,10,0,134), Color3.fromRGB(16,22,38), 6,
    Color3.fromRGB(30,50,90))
histListFrame.ClipsDescendants = true

local histScroll = Instance.new("ScrollingFrame")
histScroll.Size = UDim2.new(1,0,1,0)
histScroll.BackgroundTransparency = 1
histScroll.BorderSizePixel = 0
histScroll.ScrollBarThickness = 3
histScroll.ScrollBarImageColor3 = Color3.fromRGB(80,140,255)
histScroll.CanvasSize = UDim2.new(0,0,0,0)
histScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
histScroll.Parent = histListFrame

local histLayout = Instance.new("UIListLayout")
histLayout.Padding = UDim.new(0, 4)
histLayout.SortOrder = Enum.SortOrder.LayoutOrder
histLayout.Parent = histScroll

local histPad = Instance.new("UIPadding")
histPad.PaddingTop = UDim.new(0,4)
histPad.PaddingLeft = UDim.new(0,4)
histPad.PaddingRight = UDim.new(0,4)
histPad.Parent = histScroll

-- Assign forward ref
historyScrollRef = histScroll

-- Footer filepath (Y=506, cao=18)
local hFooterFrame = mkFrame(HistGui, UDim2.new(1,-20,0,18),
    UDim2.new(0,10,0,506), Color3.fromRGB(12,18,30), 4)
local hFooterLbl = mkLabel(hFooterFrame, "📁 " .. historyPath, 9,
    Color3.fromRGB(50,70,110), Enum.Font.Gotham, Enum.TextXAlignment.Left)
hFooterLbl.Size = UDim2.new(1,-4,1,0)
hFooterLbl.Position = UDim2.new(0,4,0,0)
hFooterLbl.TextTruncate = Enum.TextTruncate.AtEnd

-- Rebuild với filter
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

        local isOk = entry.status == "ok"
        local rowBg    = isOk and Color3.fromRGB(14,45,28) or Color3.fromRGB(50,14,14)
        local barColor = isOk and Color3.fromRGB(60,210,120) or Color3.fromRGB(220,70,70)
        local tagText  = isOk and "✅" or "❌"

        local row = Instance.new("Frame")
        row.Size = UDim2.new(1,-6,0,48)
        row.BackgroundColor3 = rowBg
        row.BackgroundTransparency = 0.15
        row.LayoutOrder = historyCountRef
        row.BorderSizePixel = 0
        local rc2 = Instance.new("UICorner")
        rc2.CornerRadius = UDim.new(0,6)
        rc2.Parent = row
        row.Parent = histScroll

        local bar2 = Instance.new("Frame")
        bar2.Size = UDim2.new(0,3,1,-6)
        bar2.Position = UDim2.new(0,0,0,3)
        bar2.BackgroundColor3 = barColor
        bar2.BorderSizePixel = 0
        local bc3 = Instance.new("UICorner")
        bc3.CornerRadius = UDim.new(0,2)
        bc3.Parent = bar2
        bar2.Parent = row

        local itemLbl2 = Instance.new("TextLabel")
        itemLbl2.Size = UDim2.new(1,-70,0,20)
        itemLbl2.Position = UDim2.new(0,10,0,4)
        itemLbl2.BackgroundTransparency = 1
        itemLbl2.TextColor3 = barColor
        itemLbl2.Font = Enum.Font.GothamBold
        itemLbl2.TextSize = 12
        itemLbl2.TextXAlignment = Enum.TextXAlignment.Left
        itemLbl2.TextTruncate = Enum.TextTruncate.AtEnd
        itemLbl2.Text = tagText .. " " .. tostring(entry.item or "?")
        itemLbl2.Parent = row

        local amtLbl2 = Instance.new("TextLabel")
        amtLbl2.Size = UDim2.new(0,56,0,18)
        amtLbl2.Position = UDim2.new(1,-60,0,5)
        amtLbl2.BackgroundColor3 = isOk and Color3.fromRGB(20,60,35) or Color3.fromRGB(60,20,20)
        amtLbl2.BackgroundTransparency = 0
        amtLbl2.TextColor3 = barColor
        amtLbl2.Font = Enum.Font.GothamBold
        amtLbl2.TextSize = 11
        amtLbl2.TextXAlignment = Enum.TextXAlignment.Center
        amtLbl2.Text = "x" .. tostring(entry.amount or 1)
        amtLbl2.BorderSizePixel = 0
        local alc2 = Instance.new("UICorner")
        alc2.CornerRadius = UDim.new(0,4)
        alc2.Parent = amtLbl2
        amtLbl2.Parent = row

        local recipLbl2 = Instance.new("TextLabel")
        recipLbl2.Size = UDim2.new(1,-10,0,16)
        recipLbl2.Position = UDim2.new(0,10,0,26)
        recipLbl2.BackgroundTransparency = 1
        recipLbl2.TextColor3 = Color3.fromRGB(100,110,140)
        recipLbl2.Font = Enum.Font.Gotham
        recipLbl2.TextSize = 10
        recipLbl2.TextXAlignment = Enum.TextXAlignment.Left
        recipLbl2.TextTruncate = Enum.TextTruncate.AtEnd
        recipLbl2.Text = "→ " .. tostring(entry.recipient or "?") .. "  •  " .. tostring(entry.time or "")
        recipLbl2.Parent = row
    end
    updateHistStat()
    -- Scroll xuống cuối
    task.defer(function()
        histScroll.CanvasPosition = Vector2.new(0, math.huge)
    end)
end

-- Override rebuildHistoryUI để dùng filter hiện tại
rebuildHistoryUI = function()
    rebuildHistoryFiltered(filterVal)
end

fBtnAll.MouseButton1Click:Connect(function()
    filterVal = "all"
    rebuildHistoryFiltered("all")
end)
fBtnOk.MouseButton1Click:Connect(function()
    filterVal = "ok"
    rebuildHistoryFiltered("ok")
end)
fBtnFail.MouseButton1Click:Connect(function()
    filterVal = "fail"
    rebuildHistoryFiltered("fail")
end)

hClearBtn.MouseButton1Click:Connect(function()
    historyData = {}
    saveHistory(historyData)
    rebuildHistoryFiltered(filterVal)
    updateHistStat()
end)

-- Toggle HistGui từ nút Header, sync position
histBtn.MouseButton1Click:Connect(function()
    HistGui.Visible = not HistGui.Visible
    if HistGui.Visible then
        syncHistPos()
        rebuildHistoryFiltered(filterVal)
    end
end)

-- Render history cũ từ file
syncHistPos()
rebuildHistoryFiltered(filterVal)

-- Drag MTBtn - dùng threshold 6px để phân biệt click vs drag (hỗ trợ mobile touch)
local mtDragStart, mtStartPos, mtMoved
MTBtn.InputBegan:Connect(function(inp)
    if isBeginInput(inp) then
        mtDragStart = inp.Position
        mtStartPos = MTBtn.Position
        mtMoved = false
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if mtDragStart and isMoveInput(inp) then
        local delta = inp.Position - mtDragStart
        if math.abs(delta.X) > 6 or math.abs(delta.Y) > 6 then
            mtMoved = true
        end
        if mtMoved then
            MTBtn.Position = UDim2.new(
                mtStartPos.X.Scale, mtStartPos.X.Offset + delta.X,
                mtStartPos.Y.Scale, mtStartPos.Y.Offset + delta.Y)
        end
    end
end)
MTBtn.InputEnded:Connect(function(inp)
    if isEndInput(inp) then
        if not mtMoved then
            -- click thật: toggle Main + xử lý HistGui theo trạng thái
            local nowVisible = not Main.Visible
            if not nowVisible then
                -- Đang ẩn: lưu trạng thái HistGui rồi ẩn theo
                histWasVisible = HistGui.Visible
                HistGui.Visible = false
            else
                -- Đang hiện lại: khôi phục trạng thái HistGui cũ
                HistGui.Visible = histWasVisible
                if histWasVisible then syncHistPos() end
            end
            Main.Visible = nowVisible
            MTBtn.BackgroundColor3 = nowVisible
                and Color3.fromRGB(14,40,24)
                or  Color3.fromRGB(40,14,14)
            MTBtn.TextColor3 = nowVisible
                and Color3.fromRGB(80,200,140)
                or  Color3.fromRGB(200,80,80)
        end
        mtDragStart = nil
        mtMoved = false
    end
end)

-- Recipient row
local recipRow = mkFrame(Main, UDim2.new(1,-20,0,28), UDim2.new(0,10,0,44), C.panel, 6, C.border)
local recipIcon = mkLabel(recipRow, "→", 12, C.muted, Enum.Font.GothamBold)
recipIcon.Size = UDim2.new(0,20,1,0)
recipIcon.Position = UDim2.new(0,6,0,0)
recipIcon.TextXAlignment = Enum.TextXAlignment.Center

local recipBox = Instance.new("TextBox")
recipBox.Text = cfg.Recipient or ""
recipBox.PlaceholderText = "Tên người nhận..."
recipBox.Size = UDim2.new(1,-30,1,0)
recipBox.Position = UDim2.new(0,26,0,0)
recipBox.BackgroundTransparency = 1
recipBox.TextColor3 = C.text
recipBox.PlaceholderColor3 = C.muted
recipBox.TextSize = 12
recipBox.Font = Enum.Font.Gotham
recipBox.TextXAlignment = Enum.TextXAlignment.Left
recipBox.Parent = recipRow
recipBox:GetPropertyChangedSignal("Text"):Connect(function()
    cfg.Recipient = recipBox.Text
    saveConfig(cfg)
end)

-- Note row
local noteRow = mkFrame(Main, UDim2.new(1,-20,0,26), UDim2.new(0,10,0,76), C.panel, 6, C.border)
local noteBox = Instance.new("TextBox")
noteBox.Text = cfg.Note or ""
noteBox.PlaceholderText = "Ghi chú..."
noteBox.Size = UDim2.new(1,-10,1,0)
noteBox.Position = UDim2.new(0,8,0,0)
noteBox.BackgroundTransparency = 1
noteBox.TextColor3 = C.muted
noteBox.PlaceholderColor3 = C.border
noteBox.TextSize = 11
noteBox.Font = Enum.Font.Gotham
noteBox.TextXAlignment = Enum.TextXAlignment.Left
noteBox.Parent = noteRow
noteBox:GetPropertyChangedSignal("Text"):Connect(function()
    cfg.Note = noteBox.Text
    saveConfig(cfg)
end)

-- Tab bar
local tabBar = mkFrame(Main, UDim2.new(1,-20,0,28), UDim2.new(0,10,0,108), C.panel, 6)
local tabNames = {"Seeds", "Pets", "Log"}
local tabs = {}
local activeTab = "Seeds"
local tabBtns = {}

for i, name in ipairs(tabNames) do
    local tabW = 100
    local tb = mkBtn(tabBar, name,
        UDim2.new(0, tabW, 1, -4),
        UDim2.new(0, (i-1)*(tabW+4) + 2, 0, 2),
        C.tab, C.muted)
    tb.Font = Enum.Font.GothamBold
    tb.TextSize = 12
    tabBtns[name] = tb
    tabs[name] = {}
end

-- Search bar
local searchRow = mkFrame(Main, UDim2.new(1,-20,0,28), UDim2.new(0,10,0,140), C.panel, 6, C.border)
local searchIcon = mkLabel(searchRow, "🔍", 12, C.muted, Enum.Font.Gotham)
searchIcon.Size = UDim2.new(0,24,1,0)
searchIcon.TextXAlignment = Enum.TextXAlignment.Center

local searchBox = Instance.new("TextBox")
searchBox.Text = ""
searchBox.PlaceholderText = "Tìm kiếm item..."
searchBox.Size = UDim2.new(1,-28,1,0)
searchBox.Position = UDim2.new(0,26,0,0)
searchBox.BackgroundTransparency = 1
searchBox.TextColor3 = C.text
searchBox.PlaceholderColor3 = C.muted
searchBox.TextSize = 12
searchBox.Font = Enum.Font.Gotham
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.Parent = searchRow

-- Item list area
local listFrame = mkFrame(Main, UDim2.new(1,-20,0,228), UDim2.new(0,10,0,174), C.panel, 6, C.border)
listFrame.ClipsDescendants = true

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1,0,1,0)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 3
scrollFrame.ScrollBarImageColor3 = C.accent
scrollFrame.CanvasSize = UDim2.new(0,0,0,0)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.Parent = listFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 3)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollFrame

local listPad = Instance.new("UIPadding")
listPad.PaddingTop = UDim.new(0, 4)
listPad.PaddingLeft = UDim.new(0, 4)
listPad.PaddingRight = UDim.new(0, 4)
listPad.Parent = scrollFrame

-- Log scroll frame (hiện khi tab Log active)
local logFrame = mkFrame(Main, UDim2.new(1,-20,0,228), UDim2.new(0,10,0,174), C.panel, 6, C.border)
logFrame.ClipsDescendants = true
logFrame.Visible = false

local logScroll = Instance.new("ScrollingFrame")
logScroll.Size = UDim2.new(1,0,1,0)
logScroll.BackgroundTransparency = 1
logScroll.BorderSizePixel = 0
logScroll.ScrollBarThickness = 3
logScroll.ScrollBarImageColor3 = C.accent
logScroll.CanvasSize = UDim2.new(0,0,0,0)
logScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
logScroll.Parent = logFrame

local logLayout = Instance.new("UIListLayout")
logLayout.Padding = UDim.new(0, 2)
logLayout.SortOrder = Enum.SortOrder.LayoutOrder
logLayout.Parent = logScroll

local logPad2 = Instance.new("UIPadding")
logPad2.PaddingTop = UDim.new(0,4)
logPad2.PaddingLeft = UDim.new(0,6)
logPad2.PaddingRight = UDim.new(0,4)
logPad2.Parent = logScroll

-- Clear log button (chỉ hiện khi tab Log)
local clearLogBtn = mkBtn(Main, "🗑 Clear Log", UDim2.new(1,-20,0,22),
    UDim2.new(0,10,0,406), Color3.fromRGB(40,20,20), C.red)
clearLogBtn.TextSize = 11
clearLogBtn.Visible = false

local logCount = 0
local MAX_LOG = 300

-- Màu theo loại log
local LOG_COLORS = {
    ok      = { bg = Color3.fromRGB(18,55,35),  text = Color3.fromRGB(80,220,140),  tag = "✅" },
    fail    = { bg = Color3.fromRGB(55,18,18),  text = Color3.fromRGB(220,80,80),   tag = "❌" },
    warn    = { bg = Color3.fromRGB(50,38,10),  text = Color3.fromRGB(220,170,50),  tag = "⚠" },
    info    = { bg = Color3.fromRGB(20,28,45),  text = Color3.fromRGB(120,160,220), tag = "ℹ" },
    sep     = { bg = Color3.fromRGB(22,22,32),  text = Color3.fromRGB(70,70,90),    tag = "" },
    gift    = { bg = Color3.fromRGB(20,45,55),  text = Color3.fromRGB(80,190,220),  tag = "🎁" },
    claim   = { bg = Color3.fromRGB(35,18,55),  text = Color3.fromRGB(180,130,255), tag = "📬" },
}

local function addLog(msg, kind)
    logCount += 1
    local frames = {}
    for _, c in ipairs(logScroll:GetChildren()) do
        if c:IsA("Frame") then table.insert(frames, c) end
    end
    if #frames >= MAX_LOG then frames[1]:Destroy() end

    -- Auto-detect kind nếu không truyền
    if not kind then
        if msg:find("✅") or msg:find("thành công") or msg:find("Gift OK") then kind = "ok"
        elseif msg:find("❌") or msg:find("fail") or msg:find("Fail") or msg:find("lỗi") then kind = "fail"
        elseif msg:find("⚠") or msg:find("skip") or msg:find("Skip") then kind = "warn"
        elseif msg:find("📬") or msg:find("Claim") or msg:find("claim") then kind = "claim"
        elseif msg:find("🎁") or msg:find("Gift") or msg:find("gift") then kind = "gift"
        elseif msg:find("──") or msg:find("---") then kind = "sep"
        else kind = "info" end
    end

    local scheme = LOG_COLORS[kind] or LOG_COLORS.info

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,-4,0,18)
    row.BackgroundColor3 = scheme.bg
    row.BackgroundTransparency = 0.3
    row.LayoutOrder = logCount
    local rc = Instance.new("UICorner")
    rc.CornerRadius = UDim.new(0,4)
    rc.Parent = row
    row.Parent = logScroll

    -- Time label
    local timeLbl = Instance.new("TextLabel")
    timeLbl.Size = UDim2.new(0,56,1,0)
    timeLbl.Position = UDim2.new(0,4,0,0)
    timeLbl.BackgroundTransparency = 1
    timeLbl.TextColor3 = Color3.fromRGB(70,70,90)
    timeLbl.Font = Enum.Font.Gotham
    timeLbl.TextSize = 10
    timeLbl.TextXAlignment = Enum.TextXAlignment.Left
    timeLbl.Text = os.date("%H:%M:%S")
    timeLbl.Parent = row

    -- Message label
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-64,1,0)
    lbl.Position = UDim2.new(0,62,0,0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = scheme.text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    -- Bỏ emoji tag thừa, chỉ giữ nội dung
    local cleanMsg = msg:gsub("^[✅❌⚠ℹ🎁📬%s]+", "")
    lbl.Text = cleanMsg
    lbl.Parent = row

    -- Left color bar
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0,3,1,-4)
    bar.Position = UDim2.new(0,0,0,2)
    bar.BackgroundColor3 = scheme.text
    bar.BorderSizePixel = 0
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0,2)
    bc.Parent = bar
    bar.Parent = row

    task.defer(function()
        logScroll.CanvasPosition = Vector2.new(0, math.huge)
    end)
end

clearLogBtn.MouseButton1Click:Connect(function()
    for _, c in ipairs(logScroll:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    logCount = 0
    addLog("Log cleared", "sep")
end)

-- Status bar
local statusBar = mkFrame(Main, UDim2.new(1,-20,0,20), UDim2.new(0,10,0,406), C.header)
local statusLbl = mkLabel(statusBar, "Ready", 11, C.muted, Enum.Font.Gotham, Enum.TextXAlignment.Left)
statusLbl.Size = UDim2.new(1,0,1,0)

-- Start loop button
local startBtn = mkBtn(Main, "▶  Start Gift ALL",
    UDim2.new(1,-20,0,28),
    UDim2.new(0,10,0,430),
    C.accent, Color3.fromRGB(10,20,15))
startBtn.Font = Enum.Font.GothamBold
startBtn.TextSize = 13

-- Send 1 lần button
local onceBtn = mkBtn(Main, "⚡  Send Gift 1 lần",
    UDim2.new(1,-20,0,26),
    UDim2.new(0,10,0,462),
    Color3.fromRGB(60,80,160), Color3.fromRGB(200,210,255))
onceBtn.Font = Enum.Font.GothamBold
onceBtn.TextSize = 12

-- Auto Claim Mail button
local claimBtn = mkBtn(Main, "📬  Auto Claim Mail",
    UDim2.new(1,-20,0,26),
    UDim2.new(0,10,0,496),
    Color3.fromRGB(70,40,100), Color3.fromRGB(210,180,255))
claimBtn.Font = Enum.Font.GothamBold
claimBtn.TextSize = 12

-- ===================== ITEM ROWS =====================
local function setStatus(msg, color)
    statusLbl.Text = msg
    statusLbl.TextColor3 = color or C.muted
end

local itemRows = {}  -- { tabName: { name: {frame, toggle, amtBox} } }
for _, t in ipairs(tabNames) do
    itemRows[t] = {}
end

local function buildRows(tabName)
    -- clear
    for _, ch in ipairs(scrollFrame:GetChildren()) do
        if ch:IsA("Frame") then ch:Destroy() end
    end

    local section = cfg[tabName] or {}

    local filter = searchBox.Text:lower()
    local order = 0

    -- enabled lên trên, cùng nhóm sort theo tên
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
                UDim2.new(1,-4,0,32),
                UDim2.new(0,0,0,0),
                data.enabled and C.itemOn or C.itemBg,
                6,
                data.enabled and C.itemOnBorder or C.border)
            row.LayoutOrder = order

            -- Toggle (click row)
            local toggleBtn = Instance.new("TextButton")
            toggleBtn.Size = UDim2.new(1,-80,1,0)
            toggleBtn.Position = UDim2.new(0,0,0,0)
            toggleBtn.BackgroundTransparency = 1
            toggleBtn.Text = ""
            toggleBtn.Parent = row

            local dot = mkLabel(row, data.enabled and "●" or "○", 12,
                data.enabled and C.accent or C.muted, Enum.Font.GothamBold)
            dot.Size = UDim2.new(0,18,1,0)
            dot.Position = UDim2.new(0,8,0,0)
            dot.TextXAlignment = Enum.TextXAlignment.Center

            local nameLbl = mkLabel(row, name, 12,
                data.enabled and C.accent or C.text, Enum.Font.Gotham)
            nameLbl.Size = UDim2.new(1,-100,1,0)
            nameLbl.Position = UDim2.new(0,28,0,0)

            -- Amount box
            local amtLbl = mkLabel(row, "x", 11, C.muted, Enum.Font.Gotham, Enum.TextXAlignment.Right)
            amtLbl.Size = UDim2.new(0,14,1,0)
            amtLbl.Position = UDim2.new(1,-72,0,0)

            local amtBox = Instance.new("TextBox")
            amtBox.Text = tostring(math.min(data.amount or 1, 10000))
            amtBox.Size = UDim2.new(0,52,0,22)
            amtBox.Position = UDim2.new(1,-58,0.5,-11)
            amtBox.BackgroundColor3 = C.bg
            amtBox.TextColor3 = C.text
            amtBox.TextSize = 12
            amtBox.Font = Enum.Font.GothamBold
            amtBox.TextXAlignment = Enum.TextXAlignment.Center
            amtBox.BorderSizePixel = 0
            local amc = Instance.new("UICorner")
            amc.CornerRadius = UDim.new(0,4)
            amc.Parent = amtBox
            local ams = Instance.new("UIStroke")
            ams.Color = C.border
            ams.Thickness = 1
            ams.Parent = amtBox
            amtBox.Parent = row

            amtBox.FocusLost:Connect(function()
                local v = tonumber(amtBox.Text) or 1
                v = math.clamp(math.floor(v), 1, 10000)
                amtBox.Text = tostring(v)
                section[name].amount = v
                saveConfig(cfg)
            end)

            -- Toggle logic
            toggleBtn.MouseButton1Click:Connect(function()
                data.enabled = not data.enabled
                section[name].enabled = data.enabled
                saveConfig(cfg)
                -- rebuild để item nhảy lên/xuống đúng vị trí
                buildRows(tabName)
            end)

            itemRows[tabName][name] = { frame = row, amtBox = amtBox }
        end
    end
end

-- Tab switching
local function switchTab(name)
    activeTab = name
    for _, t in ipairs(tabNames) do
        local tb = tabBtns[t]
        if t == name then
            tb.BackgroundColor3 = C.tabSel
            tb.TextColor3 = Color3.fromRGB(10,20,15)
        else
            tb.BackgroundColor3 = C.tab
            tb.TextColor3 = C.muted
        end
    end
    local isLog = (name == "Log")
    listFrame.Visible = not isLog
    searchRow.Visible = not isLog
    logFrame.Visible = isLog
    clearLogBtn.Visible = isLog
    -- status bar Y: Log tab dời lên vì không có clear btn overlap
    if not isLog then
        buildRows(name)
    end
end

for _, name in ipairs(tabNames) do
    tabBtns[name].MouseButton1Click:Connect(function()
        switchTab(name)
    end)
end

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    buildRows(activeTab)
end)

switchTab("Seeds")

-- ===================== SEND LOGIC =====================
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

local function resolveUserId(name, userId)
    if userId and userId > 0 then
        return userId
    end
    local ok, id = pcall(function()
        return Players:GetUserIdFromNameAsync(name)
    end)
    if ok and type(id) == "number" then return id end
    return nil
end

local function lookupRecipient()
    if not Networking or not Networking.Mailbox or not Networking.Mailbox.LookupPlayer then
        return nil, "Không tìm thấy Networking.Mailbox"
    end
    local ok, uid, displayName = pcall(function()
        return Networking.Mailbox.LookupPlayer:Fire(cfg.Recipient)
    end)
    if not ok or type(uid) ~= "number" or uid <= 0 then
        return nil, "Không tìm thấy người nhận: " .. tostring(cfg.Recipient)
    end
    return uid, displayName
end

local function sendBatch(uid, payload, note)
    if not Networking or not Networking.Mailbox or not Networking.Mailbox.SendBatch then
        return false, "SendBatch không có"
    end
    local ok, result, msg = pcall(function()
        return Networking.Mailbox.SendBatch:Fire(uid, payload, tostring(note or ""))
    end)
    if not ok then return false, tostring(result) end
    if result == true then return true, tostring(msg or "OK") end
    return false, tostring(msg or "Lỗi gửi")
end

-- Map display name -> ItemKey đúng theo inventory game
-- Seeds dùng tên có space, game lưu key không space hoặc khác
-- Key thật trong inventory game (dump từ replica.Data.Inventory.Seeds)
-- Display name trong UI -> ItemKey thật gửi lên server
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
    ["Mega Seed"]        = "Mega",
}


-- Load PlayerStateClient đúng như file gốc
local _PlayerStateClient = nil
pcall(function()
    _PlayerStateClient = require(
        ReplicatedStorage:WaitForChild("ClientModules", 10)
        :WaitForChild("PlayerStateClient", 10)
    )
end)

local function getInvSafe()
    if not _PlayerStateClient then
        warn("[AutoMailUI] PlayerStateClient chưa load được")
        return nil
    end
    -- Thử WaitForLocalReplica trước, fallback GetLocalReplica
    local replica = nil
    if type(_PlayerStateClient.WaitForLocalReplica) == "function" then
        local ok, r = pcall(function()
            return _PlayerStateClient:WaitForLocalReplica(15)
        end)
        if ok and r then replica = r end
    end
    if not replica and type(_PlayerStateClient.GetLocalReplica) == "function" then
        local started = os.clock()
        repeat
            local ok, r = pcall(function()
                return _PlayerStateClient:GetLocalReplica()
            end)
            if ok and r then replica = r break end
            task.wait(0.25)
        until os.clock() - started > 15
    end
    if replica and type(replica.Data) == "table" then
        return replica.Data.Inventory
    end
    warn("[AutoMailUI] getInvSafe: không lấy được replica")
    return nil
end


-- Dump pet keys + tên để biết field name thật trong inventory
local function dumpPets()
    local inv = getInvSafe()
    if not inv or type(inv.Pets) ~= "table" then
        print("[AutoMailUI] dumpPets: inv.Pets không đọc được")
        return
    end
    print("[AutoMailUI] ===== DUMP PETS =====")
    for uuid, entry in pairs(inv.Pets) do
        print("  [KEY] " .. tostring(uuid))
        if type(entry) == "table" then
            for k, v in pairs(entry) do
                local tv = type(v)
                if tv == "string" or tv == "number" or tv == "boolean" then
                    print("    ." .. tostring(k) .. " = " .. tostring(v))
                elseif tv == "table" then
                    print("    ." .. tostring(k) .. " = {table}")
                end
            end
        else
            print("    (not a table: " .. type(entry) .. " = " .. tostring(entry) .. ")")
        end
    end
    print("[AutoMailUI] ===== END DUMP =====")
end

local function collectPayload()
    local payload = {}
    local inv = getInvSafe()

    -- ── SEEDS ──────────────────────────────────────────────
    local seedCfg = cfg["Seeds"] or {}
    for name, data in pairs(seedCfg) do
        if type(data) == "table" and data.enabled then
            local amt = math.clamp(math.floor(tonumber(data.amount) or 1), 1, 9999)
            local itemKey = SEED_KEY_MAP[name] or name
            table.insert(payload, {
                Category    = "Seeds",
                ItemKey     = itemKey,
                Count       = amt,
                DisplayName = name,
            })
        end
    end

    -- Fruits không được game hỗ trợ gift, bỏ scan

    -- ── PETS: đọc inventory, UUID làm ItemKey, match tên với config ──
    -- Logic copy từ file gốc: itemKey = UUID, check entry.Id ~= nil
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
            -- File gốc check entry.Id ~= nil để xác nhận đây là pet hợp lệ
            if type(entry) == "table" and entry.Id ~= nil then
                -- Lấy tên pet theo thứ tự ưu tiên giống file gốc
                local petName = ""
                for _, field in ipairs({"Name","PetName","Species","DisplayName","Type","Kind"}) do
                    if entry[field] ~= nil and tostring(entry[field]) ~= "" then
                        petName = tostring(entry[field])
                        break
                    end
                end
                -- Match với config (normalize: bỏ space, lowercase)
                local normEntry = petName:lower():gsub("%s+","")
                for cfgName, q in pairs(quota) do
                    local normCfg = cfgName:lower():gsub("%s+","")
                    if normCfg == normEntry or cfgName == petName then
                        used[cfgName] = used[cfgName] or 0
                        if used[cfgName] < q then
                            if entry.Equipped ~= true
                                and entry.Locked ~= true
                                and entry.Favorite ~= true
                                and entry.Favorited ~= true then
                                used[cfgName] += 1
                                table.insert(payload, {
                                    Category    = "Pets",
                                    ItemKey     = tostring(itemKey), -- UUID
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

local running = false

local function stopLoop()
    running = false
    startBtn.Text = "▶  Start Gift ALL"
    startBtn.BackgroundColor3 = C.accent
    startBtn.TextColor3 = Color3.fromRGB(10,20,15)
end

-- Hàm resolve uid dùng chung
local function getTargetUid()
    local uid, err = lookupRecipient()
    if not uid then
        uid = resolveUserId(cfg.Recipient, tonumber(cfg.RecipientUserId) or 0)
    end
    if not uid then return nil, err or "Không tìm thấy người nhận" end
    if uid == LocalPlayer.UserId then return nil, "Không gửi cho chính mình" end
    return uid, nil
end

-- Hàm send 1 vòng (dùng chung cho loop và once)
-- Method từ file gốc: gửi thẳng Count 9999 trong 1 lần SendBatch
-- Nếu nhập cao hơn số lượng thực có, server vẫn gift được bao nhiêu thì gift
local function sendOneRound(uid, total, skip)
    local payload = collectPayload()
    if #payload == 0 then
        setStatus("⚠ Chưa chọn item nào!", C.muted)
        return total, skip
    end
    for i, item in ipairs(payload) do
        setStatus(string.format(
            "📨 [%d/%d] %s x%d  |  total: %d",
            i, #payload, item.DisplayName, item.Count, total
        ), C.accent)
        local ok2, msg2 = sendBatch(uid, {
            { Category = item.Category, ItemKey = item.ItemKey, Count = item.Count }
        }, cfg.Note)
        if ok2 then
            -- msg2 có thể chứa số lượng thật được gửi từ server
            local actualCount = tonumber(tostring(msg2):match("%d+")) or item.Count
            total += actualCount
            if actualCount < item.Count then
                -- Gửi ít hơn nhập (server clamp theo inventory)
                addLog(string.format(
                    "Gift %s: đã gift x%d / yêu cầu x%d",
                    item.DisplayName, actualCount, item.Count
                ), "warn")
                addHistoryEntry(cfg.Recipient, item.DisplayName, actualCount, true, item.Category)
            else
                addLog(string.format(
                    "Gift %s x%d — OK",
                    item.DisplayName, actualCount
                ), "ok")
                addHistoryEntry(cfg.Recipient, item.DisplayName, actualCount, true, item.Category)
            end
        else
            skip += 1
            local errMsg = tostring(msg2 or "unknown")
            addLog(string.format("Gift %s — FAIL: %s", item.DisplayName, errMsg), "fail")
            warn(string.format("[AutoMailUI] Skip '%s': %s", item.DisplayName, errMsg))
            addHistoryEntry(cfg.Recipient, item.DisplayName, item.Count, false, item.Category)
        end
        if i < #payload then
            task.wait(1.8)
        end
    end
    return total, skip
end

-- ── LOOP button ──────────────────────────────────────────
local stopRequested = false
startBtn.MouseButton1Click:Connect(function()
    if running then
        stopRequested = true
        startBtn.Text = "⏳ Dừng sau vòng này..."
        startBtn.BackgroundColor3 = Color3.fromRGB(160,80,20)
        return
    end
    setStatus("Đang tìm người nhận...", C.muted)
    local uid, err = getTargetUid()
    if not uid then setStatus("❌ " .. err, C.red) return end

    local payload = collectPayload()
    if #payload == 0 then setStatus("⚠ Chưa chọn item nào!", C.muted) return end

    running = true
    startBtn.Text = "⏹  Stop"
    startBtn.BackgroundColor3 = C.red
    startBtn.TextColor3 = Color3.new(1,1,1)

    stopRequested = false
    local roundTotal, roundSkip = 0, 0
    task.spawn(function()
        while true do
            roundTotal, roundSkip = sendOneRound(uid, roundTotal, roundSkip)
            if stopRequested then
                break
            end
            setStatus(string.format(
                "🔄 Vòng xong | gửi: %d | skip: %d — tiếp...",
                roundTotal, roundSkip
            ), C.accent)
            task.wait(1)
        end
        running = false
        stopRequested = false
        startBtn.Text = "▶  Start Gift ALL"
        startBtn.BackgroundColor3 = C.accent
        startBtn.TextColor3 = Color3.fromRGB(10,20,15)
        addLog(string.format("Stop | gửi: %d | skip: %d", roundTotal, roundSkip), "sep")
        setStatus(string.format("⏹ Đã dừng | tổng gửi: %d | skip: %d", roundTotal, roundSkip), C.muted)
    end)
end)

-- ── ONCE button ──────────────────────────────────────────
onceBtn.MouseButton1Click:Connect(function()
    if running then
        setStatus("⚠ Đang có loop chạy, dừng loop trước", C.red)
        return
    end
    setStatus("Đang tìm người nhận...", C.muted)
    local uid, err = getTargetUid()
    if not uid then setStatus("❌ " .. err, C.red) return end

    local payload = collectPayload()
    if #payload == 0 then setStatus("⚠ Chưa chọn item nào!", C.muted) return end

    onceBtn.Text = "⏳ Đang gửi..."
    onceBtn.BackgroundColor3 = Color3.fromRGB(40,55,110)
    running = true  -- block double-click

    local total, skip = 0, 0
    task.spawn(function()
        total, skip = sendOneRound(uid, total, skip)
        running = false
        onceBtn.Text = "⚡  Send Gift 1 lần"
        onceBtn.BackgroundColor3 = Color3.fromRGB(60,80,160)
        addLog(string.format("1 lần xong | gửi: %d | skip: %d", total, skip), "info")
        setStatus(string.format("✅ Done | gửi: %d | skip: %d", total, skip),
            skip > 0 and C.red or C.accent)
    end)
end)

-- ── CLAIM button ─────────────────────────────────────────
local claimRunning = false

claimBtn.MouseButton1Click:Connect(function()
    if claimRunning then
        -- dừng
        claimRunning = false
        claimBtn.Text = "📬  Auto Claim Mail"
        claimBtn.BackgroundColor3 = Color3.fromRGB(70,40,100)
        claimBtn.TextColor3 = Color3.fromRGB(210,180,255)
        setStatus("⏹ Đã dừng claim", C.muted)
        return
    end

    -- Lấy Networking (đã load ở trên)
    if not Networking or not Networking.Mailbox then
        setStatus("❌ Networking.Mailbox không tìm thấy", C.red)
        return
    end

    claimRunning = true
    claimBtn.Text = "⏹  Stop Claim"
    claimBtn.BackgroundColor3 = C.red
    claimBtn.TextColor3 = Color3.new(1,1,1)

    task.spawn(function()
        local totalClaimed = 0
        local CLAIM_DELAY = 0.3  -- 0.3s per claim

        while claimRunning do
            -- Fetch inbox
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
                    if type(mailId) == "string" then
                        table.insert(ids, mailId)
                    end
                end

                for i, mailId in ipairs(ids) do
                    if not claimRunning then break end
                    setStatus(string.format(
                        "📬 Claim [%d/%d] | tổng: %d",
                        i, #ids, totalClaimed
                    ), Color3.fromRGB(210,180,255))

                    local cok, success, reason = pcall(function()
                        return Networking.Mailbox.Claim:Fire(mailId)
                    end)
                    if cok and success then
                        totalClaimed += 1
                        addLog("Claimed mail #" .. tostring(i), "claim")
                    else
                        addLog("Claim fail #" .. tostring(i) .. ": " .. tostring(reason or success), "fail")
                        warn("[AutoMailUI] Claim fail:", mailId, tostring(reason or success))
                    end
                    task.wait(CLAIM_DELAY)
                end
            end
        end

        claimBtn.Text = "📬  Auto Claim Mail"
        claimBtn.BackgroundColor3 = Color3.fromRGB(70,40,100)
        claimBtn.TextColor3 = Color3.fromRGB(210,180,255)
        setStatus(string.format("✅ Claim xong | tổng: %d", totalClaimed), C.accent)
    end)
end)

-- ── Ctrl+Left: toggle cả Main + HistGui (nhớ trạng thái) ─
local UserInputService2 = game:GetService("UserInputService")
UserInputService2.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.LeftControl then
        local nowVisible = not Main.Visible
        if not nowVisible then
            -- Đang ẩn: lưu trạng thái HistGui rồi ẩn theo
            histWasVisible = HistGui.Visible
            HistGui.Visible = false
        else
            -- Đang hiện lại: khôi phục trạng thái HistGui cũ
            HistGui.Visible = histWasVisible
            if histWasVisible then syncHistPos() end
        end
        Main.Visible = nowVisible
    end
end)

-- ── Auto-scan pet/fruit mỗi 3s, cập nhật status khi không send ──
task.spawn(function()
    while true do
        task.wait(3)
        if not running then
            local inv = getInvSafe()
            if inv then
                -- đếm pet enabled có trong inventory
                local petCfg = cfg["Pets"] or {}
                local petQuota = {}
                for name, data in pairs(petCfg) do
                    if type(data) == "table" and data.enabled then
                        petQuota[name] = true
                    end
                end
                local petCount = 0
                if next(petQuota) ~= nil and type(inv.Pets) == "table" then
                    for _, entry in pairs(inv.Pets) do
                        if type(entry) == "table" and entry.Id ~= nil then
                            local petName = ""
                            for _, f in ipairs({"Name","PetName","Species","DisplayName","Type","Kind"}) do
                                if entry[f] ~= nil and tostring(entry[f]) ~= "" then
                                    petName = tostring(entry[f]) break
                                end
                            end
                            local ne = petName:lower():gsub("%s+","")
                            for cfgName in pairs(petQuota) do
                                if cfgName:lower():gsub("%s+","") == ne then
                                    petCount += 1 break
                                end
                            end
                        end
                    end
                end
                if petCount > 0 then
                    setStatus(string.format("🔍 Sẵn sàng | 🐾 %d pet sẵn sàng gửi", petCount), C.accent)
                else
                    setStatus("🔍 Không tìm thấy pet đã chọn trong inventory", C.muted)
                end
            else
                setStatus("⚠ Không đọc được inventory", C.muted)
            end
        end
    end
end)

print("[AutoMailUI] GAG2 UI By Mtr Chill Loaded - Config:", configPath)
setStatus("Config: " .. configPath, C.muted)
