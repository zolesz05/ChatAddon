-- Moteve Chat - whisper conversations: stored per character (kept after /reload and logout),
-- shown messenger-style: partners on the left, the selected conversation as bubbles on the right.
local _, ns = ...
local C, L = ns.C, ns.L
local format, max, min, floor = string.format, math.max, math.min, math.floor

local W = {}
ns.Whisper = W

local MAX_MSGS, MAX_CONVOS = 100, 40
local LIST_W = 140

---------------------------------------------------------------------------
-- Store
---------------------------------------------------------------------------
local function Short(name)
    if Ambiguate then
        local ok, s = pcall(Ambiguate, name, "short")
        if ok and s then return s end
    end
    return (name:gsub("%-.*$", ""))
end
W.Short = Short

function W:Sorted()
    local list = {}
    for name, c in pairs(ns.char.whispers) do list[#list + 1] = { name = name, c = c } end
    table.sort(list, function(a, b) return (a.c.last or 0) > (b.c.last or 0) end)
    return list
end

function W:Unread()
    local n = 0
    for _, c in pairs(ns.char.whispers) do
        if not ns.Filters or ns.Filters:Allows("whisper", c.bn and "bnet" or "whisper") then
            n = n + (c.unread or 0)
        end
    end
    return n
end

function W:IsViewing(name)
    return self.view and self.view:IsVisible() and ns.char.selected == name
end

function W:Add(name, text, out, bn, class)
    if not name or name == "" then return end
    local store = ns.char.whispers
    local c = store[name]
    if not c then
        c = { msgs = {}, unread = 0 }
        store[name] = c
        -- keep the number of conversations bounded: drop the oldest
        local list = self:Sorted()
        for i = MAX_CONVOS + 1, #list do store[list[i].name] = nil end
    end
    c.bn = bn or nil
    c.class = class or c.class
    c.msgs[#c.msgs + 1] = { t = time(), out = out or nil, text = text }
    for _ = 1, #c.msgs - MAX_MSGS do table.remove(c.msgs, 1) end
    c.last = time()
    if not out and not self:IsViewing(name) then c.unread = (c.unread or 0) + 1 end
    if not ns.char.selected then ns.char.selected = name end
    ns:Fire("MC_WHISPER", name)
end

function W:Select(name)
    ns.char.selected = name
    local c = name and ns.char.whispers[name]
    if c then c.unread = 0 end
    self.offset = 0
    ns:Fire("MC_WHISPER", name)
end

function W:Delete(name)
    ns.char.whispers[name] = nil
    if ns.char.selected == name then ns.char.selected = nil end
    ns:Fire("MC_WHISPER", name)
end

-- open the chat input aimed at the selected partner
function W:Reply(name)
    name = name or ns.char.selected
    if not name then return end
    local c = ns.char.whispers[name]
    if c and c.bn and ChatFrame_SendBNetTell then
        pcall(ChatFrame_SendBNetTell, name)
    elseif ChatFrameUtil and ChatFrameUtil.SendTell then
        pcall(ChatFrameUtil.SendTell, name)
    elseif ChatFrame_SendTell then
        pcall(ChatFrame_SendTell, name)
    end
end

---------------------------------------------------------------------------
-- View
---------------------------------------------------------------------------
local function Pool(ctor)
    local p = { all = {}, n = 0 }
    function p:Get()
        self.n = self.n + 1
        local o = self.all[self.n]
        if not o then o = ctor(); self.all[self.n] = o end
        o:Show()
        return o
    end
    function p:Reset()
        for i = 1, #self.all do self.all[i]:Hide() end
        self.n = 0
    end
    return p
end

function W:Build(parent)
    local v = CreateFrame("Frame", nil, parent)
    v:SetAllPoints()
    v:Hide()
    self.view = v

    -- conversation list
    local list = CreateFrame("Frame", nil, v)
    list:SetPoint("TOPLEFT", 0, 0)
    list:SetPoint("BOTTOMLEFT", 0, 0)
    list:SetWidth(LIST_W)
    list:SetClipsChildren(true)
    local sep = list:CreateTexture(nil, "ARTWORK")
    sep:SetPoint("TOPRIGHT", 0, 0); sep:SetPoint("BOTTOMRIGHT", 0, 0); sep:SetWidth(1)
    ns.Grad(sep, "VERTICAL", C.edge, 0.05, C.edge, 0.22)
    list:EnableMouseWheel(true)
    list:SetScript("OnMouseWheel", function(_, d)
        self.listOffset = max(0, (self.listOffset or 0) - d)
        self:Refresh()
    end)
    self.list = list

    self.convos = Pool(function()
        local b = CreateFrame("Button", nil, list)
        b:SetHeight(38)
        b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        b.bg = ns.Slice(b, "round", 0.25, "BACKGROUND", 1):Fit(b, 8)
        b.bg:SetColor(C.violet, 0.16)
        b.hl = ns.Slice(b, "round", 0.25, "BACKGROUND", 0):Fit(b, 8)
        b.hl:SetColor({ 1, 1, 1 }, 0.05); b.hl:Hide()
        b.name = ns.Font(b, "bold", 12.5, C.text)
        b.name:SetPoint("TOPLEFT", 8, -5); b.name:SetPoint("RIGHT", -18, 0)
        b.prev = ns.Font(b, "body", 11, C.muted)
        b.prev:SetPoint("TOPLEFT", 8, -21); b.prev:SetPoint("RIGHT", -8, 0)
        b.dot = ns.Img(b, "circle", "OVERLAY", 1, C.violet, 1)
        b.dot:SetSize(7, 7); b.dot:SetPoint("TOPRIGHT", -8, -9)
        b.glow = ns.Img(b, "glow", "OVERLAY", 0, C.violet, 0.8)
        b.glow:SetBlendMode("ADD"); b.glow:SetSize(18, 18); b.glow:SetPoint("CENTER", b.dot)
        b:SetScript("OnEnter", function(s)
            s.hl:Show()
            GameTooltip:SetOwner(s, "ANCHOR_TOPLEFT")
            GameTooltip:SetText(s.who or "", 1, 1, 1)
            GameTooltip:AddLine(L.CONVO_HINT, C.muted[1], C.muted[2], C.muted[3])
            GameTooltip:Show()
        end)
        b:SetScript("OnLeave", function(s) s.hl:Hide(); GameTooltip:Hide() end)
        b:SetScript("OnClick", function(s, button)
            if button == "RightButton" then
                StaticPopupDialogs["MOTEVECHAT_DELETE_CONVO"].text = L.DELETE_CONVO
                StaticPopup_Show("MOTEVECHAT_DELETE_CONVO", s.short or s.who, nil, s.who)
            else
                W:Select(s.who)
            end
        end)
        return b
    end)

    -- thread
    local th = CreateFrame("Button", nil, v)
    th:SetPoint("TOPLEFT", LIST_W + 12, 0)
    th:SetPoint("BOTTOMRIGHT", 0, 0)
    th:SetClipsChildren(true)
    th:RegisterForClicks("LeftButtonUp")
    th:SetScript("OnClick", function() W:Reply() end)
    th:EnableMouseWheel(true)
    th:SetScript("OnMouseWheel", function(_, d)
        self.offset = max(0, (self.offset or 0) + d)
        self:Refresh()
    end)
    self.thread = th

    th.head = ns.Font(th, "title", 15, C.text)
    th.head:SetPoint("TOPLEFT", 0, -1)
    th.info = ns.Font(th, "body", 11, C.muted)
    th.info:SetPoint("LEFT", th.head, "RIGHT", 8, -1)
    th.empty = ns.Font(th, "body", 12, C.muted, "CENTER")
    th.empty:SetPoint("CENTER")

    self.bubbles = Pool(function()
        local b = CreateFrame("Frame", nil, th)
        b.fill = ns.Slice(b, "round", 0.25, "BACKGROUND", 1):Fit(b, 10)
        b.line = ns.Slice(b, "roundline", 0.25, "BORDER", 1):Fit(b, 10)
        b.text = ns.Font(b, "body", 13, C.text)
        b.text:SetPoint("TOPLEFT", 10, -6)
        b.text:SetWordWrap(true)
        b.text:SetJustifyH("LEFT")
        b.time = ns.Font(b, "body", 10, C.low)
        b.time:SetPoint("BOTTOMLEFT", 10, 4)
        b:EnableMouse(true)
        b:SetHyperlinksEnabled(true)
        b:SetScript("OnHyperlinkClick", function(_, link, text, button)
            if not ns.Links.Handle(link) then pcall(SetItemRef, link, text, button, DEFAULT_CHAT_FRAME) end
        end)
        b:SetScript("OnMouseUp", function() W:Reply() end)
        return b
    end)

    ns:On("MC_WHISPER", function() W:Refresh() end)
    v:SetScript("OnShow", function() W:Select(ns.char.selected); W:Refresh() end)
end

function W:Refresh()
    if not self.view or not self.view:IsVisible() then return end
    local list = self:Sorted()

    -- conversations
    self.convos:Reset()
    local y = 2
    local first = min(self.listOffset or 0, max(0, #list - 1))
    self.listOffset = first
    for i = first + 1, #list do
        local e = list[i]
        local b = self.convos:Get()
        b:ClearAllPoints()
        b:SetPoint("TOPLEFT", 0, -y)
        b:SetPoint("RIGHT", self.list, "RIGHT", -6, 0)
        b.who, b.short = e.name, Short(e.name)
        b.name:SetText(b.short)
        local cc = e.c.class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[e.c.class]
        local unread = (e.c.unread or 0) > 0
        if cc then b.name:SetTextColor(cc.r, cc.g, cc.b)
        elseif unread then b.name:SetTextColor(C.text[1], C.text[2], C.text[3])
        else b.name:SetTextColor(C.sub[1], C.sub[2], C.sub[3]) end
        local last = e.c.msgs[#e.c.msgs]
        b.prev:SetText(last and ((last.out and (L.YOU .. ": ") or "") .. (last.text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|H.-|h(.-)|h", "%1"))) or "")
        b.bg:SetShown(e.name == ns.char.selected)
        b.dot:SetShown(unread); b.glow:SetShown(unread)
        y = y + 42
    end

    -- thread
    local th = self.thread
    self.bubbles:Reset()
    local name = ns.char.selected
    local c = name and ns.char.whispers[name]
    if #list == 0 or not c then
        th.head:SetText(""); th.info:SetText("")
        th.empty:SetText(#list == 0 and L.NO_WHISPERS or L.PICK_CONVO)
        th.empty:Show()
        return
    end
    th.empty:Hide()
    c.unread = 0
    th.head:SetText(Short(name))
    th.info:SetText(format(L.N_MESSAGES, #c.msgs))

    local W_, H_ = th:GetWidth(), th:GetHeight()
    if not W_ or W_ < 50 then W_ = 300 end
    if not H_ or H_ < 50 then H_ = 200 end
    local maxW = floor(W_ * 0.8)
    local top = 26
    local bottom = H_ - 2
    local offset = min(self.offset or 0, max(0, #c.msgs - 1))
    self.offset = offset
    for i = #c.msgs - offset, 1, -1 do
        local m = c.msgs[i]
        local b = self.bubbles:Get()
        b.text:SetWidth(maxW - 20)
        b.text:SetText(m.text)
        local tw = b.text.GetUnboundedStringWidth and b.text:GetUnboundedStringWidth() or b.text:GetStringWidth()
        local w = min(maxW - 20, max(tw or 0, 34))
        b.text:SetWidth(w)
        local h = (b.text:GetStringHeight() or 14) + 22
        b:SetSize(w + 20, h)
        b.time:SetText(date and date("%H:%M", m.t) or "")
        if m.out then
            b.fill:SetColor(C.violet, 0.22); b.line:SetColor(C.violet, 0.45)
        else
            b.fill:SetColor(C.glass, 0.75); b.line:SetColor(C.edge, 0.25)
        end
        b:ClearAllPoints()
        if m.out then b:SetPoint("BOTTOMRIGHT", th, "TOPRIGHT", -2, -bottom)
        else b:SetPoint("BOTTOMLEFT", th, "TOPLEFT", 0, -bottom) end
        bottom = bottom - h - 6
        if bottom < top then
            if bottom + h + 6 - top < h * 0.5 then b:Hide() end
            break
        end
    end
end

StaticPopupDialogs["MOTEVECHAT_DELETE_CONVO"] = {
    text = "%s",
    button1 = YES or "Yes",
    button2 = NO or "No",
    OnAccept = function(_, data) if data then W:Delete(data) end end,
    timeout = 0, whileDead = true, hideOnEscape = true, preferredIndex = 3,
}

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------
local function ClassOf(guid)
    if not guid or ns.IsSecret(guid) or not GetPlayerInfoByGUID then return end
    local ok, _, class = pcall(GetPlayerInfoByGUID, guid)
    if ok then return class end
end

ns:On("CHAT_MSG_WHISPER", function(_, text, sender, _, _, _, _, _, _, _, _, guid)
    if ns.IsSecret(text, sender) then return end
    W:Add(sender, ns.Links.Linkify(text), false, false, ClassOf(guid))
end)
ns:On("CHAT_MSG_WHISPER_INFORM", function(_, text, target, _, _, _, _, _, _, _, _, guid)
    if ns.IsSecret(text, target) then return end
    W:Add(target, ns.Links.Linkify(text), true, false, ClassOf(guid))
end)
ns:On("CHAT_MSG_BN_WHISPER", function(_, text, sender)
    if ns.IsSecret(text, sender) then return end
    W:Add(sender, ns.Links.Linkify(text), false, true)
end)
ns:On("CHAT_MSG_BN_WHISPER_INFORM", function(_, text, target)
    if ns.IsSecret(text, target) then return end
    W:Add(target, ns.Links.Linkify(text), true, true)
end)
