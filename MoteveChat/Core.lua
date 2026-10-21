-- Moteve Chat - core: saved data, events, error log, theme helpers (shared look with Moteve Quest)
local ADDON_NAME, ns = ...
local format = string.format

ns.ADDON = ADDON_NAME

---------------------------------------------------------------------------
-- Saved data
---------------------------------------------------------------------------
local DEFAULTS = {
    lang = "hu",
    hideBlizzard = true,      -- hide the default chat windows (our window shows everything)
    point = "BOTTOMLEFT", relPoint = "BOTTOMLEFT", x = 20, y = 46,
    width = 470, height = 250,
    tab = "all",
    errors = {},
}
local CHAR_DEFAULTS = {
    whispers = {},            -- [name] = { msgs = { {t=, out=, text=} }, last = time, unread = n, bn = bool }
    selected = nil,           -- selected whisper conversation
}

local function ApplyDefaults(t, d)
    for k, v in pairs(d) do
        if t[k] == nil then
            if type(v) == "table" then t[k] = {}; ApplyDefaults(t[k], v) else t[k] = v end
        end
    end
end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------
local eventFrame = CreateFrame("Frame")
local handlers = {}

function ns:On(event, fn)
    if not handlers[event] then
        handlers[event] = {}
        if not event:find("^MC_") then pcall(eventFrame.RegisterEvent, eventFrame, event) end
    end
    table.insert(handlers[event], fn)
end

local reported = {}
function ns:Error(where, err)
    local msg = tostring(where) .. ": " .. tostring(err)
    if reported[msg] then return end
    reported[msg] = true
    if ns.db then
        table.insert(ns.db.errors, 1, { msg = msg, time = date and date("%Y-%m-%d %H:%M") or "" })
        for i = #ns.db.errors, 21, -1 do ns.db.errors[i] = nil end
    end
end

function ns.Safe(where, fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then ns:Error(where, err) end
    return ok, err
end

function ns:Fire(event, ...)
    local list = handlers[event]
    if not list then return end
    for i = 1, #list do
        local ok, err = pcall(list[i], event, ...)
        if not ok then ns:Error(event, err) end
    end
end
eventFrame:SetScript("OnEvent", function(_, event, ...) ns:Fire(event, ...) end)

-- secret values (modern client, in instance combat): never inspect them
local secret = issecretvalue or function() return false end
function ns.IsSecret(...)
    for i = 1, select("#", ...) do
        if secret((select(i, ...))) then return true end
    end
    return false
end

function ns:Print(msg)
    print("|cffa88bffMoteve Chat|r: " .. msg)
end

---------------------------------------------------------------------------
-- Theme: "Arcane glass" (same as Moteve Quest)
-- Shapes (hexagons, rounded panels, glows) are small TGA textures in Textures\.
---------------------------------------------------------------------------
local WHITE = "Interface\\Buttons\\WHITE8X8"
local CIRCLE_MASK = "Interface\\CharacterFrame\\TempPortraitAlphaMask"
local MEDIA = "Interface\\AddOns\\" .. ADDON_NAME .. "\\"

ns.WHITE = WHITE
function ns.TEX(name) return MEDIA .. "Textures\\" .. name end

-- Marcellus (titles, map glyphs) and Barlow (text). Both OFL, both cover Hungarian ő/ű.
ns.FONT_TITLE = MEDIA .. "Fonts\\Marcellus-Regular.ttf"
ns.FONT_BODY = MEDIA .. "Fonts\\Barlow-Regular.ttf"
ns.FONT_BODY_BOLD = MEDIA .. "Fonts\\Barlow-SemiBold.ttf"
ns.FONT_LABEL = ns.FONT_BODY_BOLD

local function hex(s)
    return { tonumber(s:sub(1, 2), 16) / 255, tonumber(s:sub(3, 4), 16) / 255, tonumber(s:sub(5, 6), 16) / 255 }
end
ns.C = {
    cyan       = hex("7FD8FF"),   -- available quests, areas
    cyanPale   = hex("DFF4FF"),
    violet     = hex("A88BFF"),   -- focus, route, chain
    violetPale = hex("CDBBFF"),
    gold       = hex("FFCF5A"),   -- ready to turn in
    goldPale   = hex("FFF1C2"),
    goldSoft   = hex("FFE8A6"),
    text       = hex("EEF2FF"),
    sub        = hex("B9C2E6"),
    muted      = hex("9AA4C7"),
    low        = hex("7D86A8"),
    glass      = { 16 / 255, 20 / 255, 44 / 255 },
    navy       = { 18 / 255, 24 / 255, 52 / 255 },
    edge       = { 150 / 255, 180 / 255, 1 },
    ink        = hex("2A2140"),
    green      = hex("7FE3B0"),
    dungeon    = hex("A88BFF"),
    kill       = hex("FF6B81"),   -- objective: kill
    loot       = hex("FFB45A"),   -- objective: loot from mobs
    pickup     = hex("7CE38B"),   -- objective: pick up from the ground
    mint       = hex("6FE3D6"),   -- objective: use an object
}
local C = ns.C
-- older names still used in a few places
C.goldBright, C.goldDim, C.cream, C.xp, C.grey = C.gold, C.gold, C.text, C.violetPale, C.low

function ns.Hex(c) return format("|cff%02x%02x%02x", math.floor(c[1] * 255 + 0.5), math.floor(c[2] * 255 + 0.5), math.floor(c[3] * 255 + 0.5)) end

---------------------------------------------------------------------------
-- Widget helpers
---------------------------------------------------------------------------
function ns.Tex(parent, layer, c, a, sub)
    local t = parent:CreateTexture(nil, layer or "ARTWORK", nil, sub)
    t:SetTexture(WHITE)
    if c then t:SetVertexColor(c[1], c[2], c[3], a or 1) end
    return t
end

function ns.Img(parent, name, layer, sub, c, a)
    local t = parent:CreateTexture(nil, layer or "ARTWORK", nil, sub)
    t:SetTexture(ns.TEX(name))
    if c then t:SetVertexColor(c[1], c[2], c[3], a or 1) end
    return t
end

function ns.Grad(t, orient, c1, a1, c2, a2)
    t:SetTexture(WHITE)
    t:SetVertexColor(1, 1, 1, 1)
    t:SetGradient(orient, CreateColor(c1[1], c1[2], c1[3], a1 or 1), CreateColor(c2[1], c2[2], c2[3], a2 or 1))
end

-- SetFont's return value differs between client builds, so success is checked with GetFont
local function SetFontSafe(fs, path, size)
    local ok = pcall(fs.SetFont, fs, path, size, "")
    if not ok or not fs:GetFont() then fs:SetFont(STANDARD_TEXT_FONT, size, "") end
end
ns.SetFontSafe = SetFontSafe

function ns.Font(parent, kind, size, c, justify, layer)
    local fs = parent:CreateFontString(nil, layer or "OVERLAY")
    local path = (kind == "label" and ns.FONT_LABEL) or (kind == "title" and ns.FONT_TITLE)
        or (kind == "bold" and ns.FONT_BODY_BOLD) or ns.FONT_BODY
    SetFontSafe(fs, path, size)
    fs:SetShadowColor(0, 0, 0, 0.6)
    fs:SetShadowOffset(0, -1)
    if c then fs:SetTextColor(c[1], c[2], c[3]) end
    fs:SetJustifyH(justify or "LEFT")
    fs:SetWordWrap(false)
    return fs
end

function ns.SetFontKind(fs, kind, size)
    local path = (kind == "title" and ns.FONT_TITLE) or (kind == "bold" and ns.FONT_BODY_BOLD)
        or (kind == "label" and ns.FONT_LABEL) or ns.FONT_BODY
    SetFontSafe(fs, path, size)
end

-- a filled circle (or ellipse, if width ~= height)
function ns.Circle(parent, layer, sub)
    return ns.Img(parent, "circle", layer, sub)
end

-- Nine-slice made of 9 textures, so rounded shapes stay crisp at any size.
-- file: texture name; frac: corner size inside the texture (0..0.5)
local SLICE = {
    { "TOPLEFT", 0, 1, 0, 1 }, { "TOP", 1, 2, 0, 1 }, { "TOPRIGHT", 2, 3, 0, 1 },
    { "LEFT", 0, 1, 1, 2 }, { "CENTER", 1, 2, 1, 2 }, { "RIGHT", 2, 3, 1, 2 },
    { "BOTTOMLEFT", 0, 1, 2, 3 }, { "BOTTOM", 1, 2, 2, 3 }, { "BOTTOMRIGHT", 2, 3, 2, 3 },
}
local SliceMixin = {}
function SliceMixin:SetColor(c, a)
    for i = 1, 9 do self[i]:SetVertexColor(c[1], c[2], c[3], a or 1) end
end
function SliceMixin:SetShown(v) for i = 1, 9 do self[i]:SetShown(v) end end
function SliceMixin:Show() self:SetShown(true) end
function SliceMixin:Hide() self:SetShown(false) end
function SliceMixin:SetBlendMode(m) for i = 1, 9 do self[i]:SetBlendMode(m) end end
-- region: what to wrap; r: corner size in pixels; out: grow outwards (glows/shadows)
function SliceMixin:Fit(region, r, out)
    out = out or 0
    local t = self
    -- corners
    t[1]:ClearAllPoints(); t[1]:SetPoint("TOPLEFT", region, "TOPLEFT", -out, out); t[1]:SetSize(r, r)
    t[3]:ClearAllPoints(); t[3]:SetPoint("TOPRIGHT", region, "TOPRIGHT", out, out); t[3]:SetSize(r, r)
    t[7]:ClearAllPoints(); t[7]:SetPoint("BOTTOMLEFT", region, "BOTTOMLEFT", -out, -out); t[7]:SetSize(r, r)
    t[9]:ClearAllPoints(); t[9]:SetPoint("BOTTOMRIGHT", region, "BOTTOMRIGHT", out, -out); t[9]:SetSize(r, r)
    -- edges
    t[2]:ClearAllPoints(); t[2]:SetPoint("TOPLEFT", t[1], "TOPRIGHT"); t[2]:SetPoint("BOTTOMRIGHT", t[3], "BOTTOMLEFT")
    t[8]:ClearAllPoints(); t[8]:SetPoint("TOPLEFT", t[7], "TOPRIGHT"); t[8]:SetPoint("BOTTOMRIGHT", t[9], "BOTTOMLEFT")
    t[4]:ClearAllPoints(); t[4]:SetPoint("TOPLEFT", t[1], "BOTTOMLEFT"); t[4]:SetPoint("BOTTOMRIGHT", t[7], "TOPRIGHT")
    t[6]:ClearAllPoints(); t[6]:SetPoint("TOPLEFT", t[3], "BOTTOMLEFT"); t[6]:SetPoint("BOTTOMRIGHT", t[9], "TOPRIGHT")
    t[5]:ClearAllPoints(); t[5]:SetPoint("TOPLEFT", t[1], "BOTTOMRIGHT"); t[5]:SetPoint("BOTTOMRIGHT", t[9], "TOPLEFT")
    return self
end

function ns.Slice(parent, file, frac, layer, sub)
    local s = {}
    local cuts = { 0, frac, 1 - frac, 1 }
    for i, d in ipairs(SLICE) do
        local t = parent:CreateTexture(nil, layer or "BACKGROUND", nil, sub)
        t:SetTexture(ns.TEX(file))
        t:SetTexCoord(cuts[d[2] + 1], cuts[d[3] + 1], cuts[d[4] + 1], cuts[d[5] + 1])
        s[i] = t
    end
    for k, v in pairs(SliceMixin) do s[k] = v end
    return s
end

-- Glass panel: translucent navy fill, thin light edge, soft shadow, faint top sheen.
-- opts: radius, alpha, edge (edge alpha), shadow (bool), tint (colour of the fill)
function ns.Glass(f, opts)
    opts = opts or {}
    local r = opts.radius or 14
    local g = {}
    if opts.shadow ~= false then
        g.shadow = ns.Slice(f, "shadow", 0.5, "BACKGROUND", -8):Fit(f, r + 18, 18)
        g.shadow:SetColor({ 0, 0, 0 }, 0.45)
    end
    g.fill = ns.Slice(f, "round", 0.25, "BACKGROUND", -7):Fit(f, r)
    g.fill:SetColor(opts.tint or C.glass, opts.alpha or 0.72)
    g.line = ns.Slice(f, "roundline", 0.25, "BORDER", -7):Fit(f, r)
    g.line:SetColor(opts.edgeColor or C.edge, opts.edge or 0.28)
    -- top sheen (inset highlight)
    g.sheen = f:CreateTexture(nil, "BORDER", nil, -6)
    g.sheen:SetPoint("TOPLEFT", r * 0.6, -1); g.sheen:SetPoint("TOPRIGHT", -r * 0.6, -1); g.sheen:SetHeight(1)
    ns.Grad(g.sheen, "HORIZONTAL", { 1, 1, 1 }, 0.02, { 1, 1, 1 }, 0.1)
    function g:SetShown(v)
        if self.shadow then self.shadow:SetShown(v) end
        self.fill:SetShown(v); self.line:SetShown(v); self.sheen:SetShown(v)
    end
    return g
end

-- Pill / chip: rounded label. pill:Set(text, textColor, fill, fillAlpha, edge, edgeAlpha)
function ns.Pill(parent, size, kind)
    local p = CreateFrame("Frame", nil, parent)
    p.padX = 8
    p.text = ns.Font(p, kind or "bold", size or 11, C.text, "CENTER")
    p.text:SetPoint("CENTER", 0, 0)
    local h = (size or 11) + 8
    p:SetHeight(h)
    p.fill = ns.Slice(p, "circle", 0.5, "BACKGROUND", 1):Fit(p, h / 2)
    p.line = ns.Slice(p, "circlering", 0.5, "BORDER", 1):Fit(p, h / 2)
    function p:Set(text, tc, fc, fa, ec, ea)
        self.text:SetText(text or "")
        self.text:SetTextColor(tc[1], tc[2], tc[3])
        self.fill:SetColor(fc or { 1, 1, 1 }, fa or 0.08)
        if ec then self.line:SetColor(ec, ea or 0.4); self.line:Show() else self.line:Hide() end
        self:SetWidth(math.floor(self.text:GetStringWidth() + 0.5) + self.padX * 2)
        return self
    end
    return p
end

-- fading horizontal rule
function ns.Rule(parent, c, a)
    local t = parent:CreateTexture(nil, "ARTWORK")
    t:SetHeight(1)
    ns.Grad(t, "HORIZONTAL", c or C.edge, a or 0.4, c or C.edge, 0)
    return t
end


---------------------------------------------------------------------------
-- Language
---------------------------------------------------------------------------
ns.L = setmetatable({}, { __index = function(_, k) return ns.LOCALES.hu[k] or k end })
function ns:SetLanguage(code)
    local t = ns.LOCALES[code] or ns.LOCALES.hu
    setmetatable(ns.L, { __index = function(_, k) return t[k] or ns.LOCALES.hu[k] or k end })
    ns:Fire("MC_LANGUAGE")
end

---------------------------------------------------------------------------
-- Startup
---------------------------------------------------------------------------
ns:On("ADDON_LOADED", function(_, name)
    if name ~= ADDON_NAME then return end
    MoteveChatDB = MoteveChatDB or {}
    MoteveChatChar = MoteveChatChar or {}
    ApplyDefaults(MoteveChatDB, DEFAULTS)
    ApplyDefaults(MoteveChatChar, CHAR_DEFAULTS)
    ns.db, ns.char = MoteveChatDB, MoteveChatChar
    ns:SetLanguage(ns.db.lang)
    ns:Fire("MC_INIT")
end)

---------------------------------------------------------------------------
-- Slash commands
---------------------------------------------------------------------------
SLASH_MOTEVECHAT1, SLASH_MOTEVECHAT2 = "/mc", "/motevechat"
SlashCmdList.MOTEVECHAT = function(input)
    local L = ns.L
    local cmd, arg = (input or ""):lower():match("^(%S*)%s*(%S*)")
    if cmd == "lang" and (arg == "hu" or arg == "en") then
        ns.db.lang = arg
        ns:SetLanguage(arg)
        ns:Print(L.LANG_SET)
    elseif cmd == "blizzard" then
        ns.db.hideBlizzard = not ns.db.hideBlizzard
        ns:Print(ns.db.hideBlizzard and L.BLIZZ_HIDDEN or L.BLIZZ_SHOWN)
    elseif cmd == "addtab" or cmd == "ujful" then
        if ns.ShowNewTabDialog then ns.ShowNewTabDialog() end
    elseif cmd == "filters" or cmd == "szurok" then
        if ns.ShowTabFilters then ns.ShowTabFilters(arg ~= "" and arg or ns.db.tab) end
    elseif cmd == "reset" then
        ns:Fire("MC_RESET")
    elseif cmd == "clear" then
        ns:Fire("MC_CLEAR")
    elseif cmd == "errors" then
        local list = ns.db.errors or {}
        if #list == 0 then ns:Print(L.NO_ERRORS) end
        for i = 1, math.min(5, #list) do print(format("|cffa88bff%d.|r %s  %s", i, list[i].time or "", list[i].msg)) end
        if arg == "clear" then wipe(list) end
    else
        for _, line in ipairs(L.HELP) do print("   " .. line) end
    end
end
