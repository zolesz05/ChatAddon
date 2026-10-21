-- Moteve Chat - the chat window: tabs (All, Whisper, Guild, Group, Channels, System), message
-- views, the restyled chat input, and hiding of the default chat windows.
-- Every tab has persistent message filters. Untyped native output is routed as addon/other output.
local _, ns = ...
local C, L = ns.C, ns.L
local format, max, min = string.format, math.max, math.min

local TAB_H, INPUT_H, HEAD_H = 32, 26, 24
local TABS = ns.Filters.Tabs

---------------------------------------------------------------------------
-- Window
---------------------------------------------------------------------------
local W = CreateFrame("Frame", "MoteveChatFrame", UIParent)
W:SetFrameStrata("LOW")
W:SetMovable(true)
W:SetResizable(true)
W:SetClampedToScreen(true)
W:SetSize(470, 250)
if W.SetResizeBounds then W:SetResizeBounds(320, 210, 900, 600) elseif W.SetMinResize then W:SetMinResize(320, 210) end
ns.Window = W

-- soft backdrop: darker at the bottom, fading out upwards, so it covers as little as possible
local bg = W:CreateTexture(nil, "BACKGROUND", nil, -7)
bg:SetAllPoints()
local function Backdrop(strong)
    ns.Grad(bg, "VERTICAL", C.glass, strong and 0.72 or 0.5, C.glass, 0)
end
Backdrop(false)

local content = CreateFrame("Frame", nil, W)
content:SetPoint("TOPLEFT", 12, -(TAB_H + 16))
content:SetPoint("BOTTOMRIGHT", -12, INPUT_H + 14)
W.content = content

---------------------------------------------------------------------------
-- Message views (one ScrollingMessageFrame per tab)
---------------------------------------------------------------------------
local views, unread, current = {}, {}, nil

local function OnHyperlink(_, link, text, button)
    if ns.Links.Handle(link) then return end
    pcall(SetItemRef, link, text, button, DEFAULT_CHAT_FRAME)
end
local function OnHyperlinkEnter(self, link)
    local kind = type(link) == "string" and link:match("^(%a+):")
    if kind == "item" or kind == "spell" or kind == "quest" or kind == "achievement" or kind == "enchant" or kind == "talent" then
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        pcall(GameTooltip.SetHyperlink, GameTooltip, link)
        GameTooltip:Show()
    end
end

local newest -- "Newest" chip

local function MakeView(key)
    local f = CreateFrame("ScrollingMessageFrame", nil, content)
    f:SetAllPoints()
    f:SetFont(ns.FONT_BODY, 13, "")
    if not f:GetFont() then f:SetFont(STANDARD_TEXT_FONT, 13, "") end
    f:SetShadowColor(0, 0, 0, 0.9)
    f:SetShadowOffset(1, -1)
    f:SetJustifyH("LEFT")
    f:SetMaxLines(500)
    f:SetFading(true)
    f:SetTimeVisible(120)
    f:SetFadeDuration(4)
    f:SetSpacing(2)
    f:SetHyperlinksEnabled(true)
    f:SetScript("OnHyperlinkClick", OnHyperlink)
    f:SetScript("OnHyperlinkEnter", OnHyperlinkEnter)
    f:SetScript("OnHyperlinkLeave", function() GameTooltip:Hide() end)
    f:EnableMouseWheel(true)
    f:SetScript("OnMouseWheel", function(self, d)
        if IsShiftKeyDown() then if d > 0 then self:ScrollToTop() else self:ScrollToBottom() end
        elseif d > 0 then self:ScrollUp(); self:ScrollUp()
        else self:ScrollDown(); self:ScrollDown() end
        newest:SetShown(not self:AtBottom())
    end)
    f:Hide()
    views[key] = f
    unread[key] = 0
    return f
end
for _, t in ipairs(TABS) do MakeView(t.key) end
W.views = views

newest = ns.Pill(content, 11)
newest:SetFrameLevel(content:GetFrameLevel() + 10)
newest:SetPoint("BOTTOMRIGHT", 0, 2)
newest:EnableMouse(true)
newest:SetScript("OnMouseUp", function(self)
    if current and views[current] then views[current]:ScrollToBottom() end
    self:Hide()
end)
newest:Hide()

-- whisper view
ns.Whisper:Build(content)

---------------------------------------------------------------------------
-- Tabs
---------------------------------------------------------------------------
local tabButtons = {}
W.tabButtons = tabButtons
local function UpdateTabs()
    local x, row = 12, 0
    local available = W:GetWidth() - 12
    for _, t in ipairs(TABS) do
        local b = tabButtons[t.key]
        local active = t.key == current
        b.text:SetText(ns.Filters:Label(t))
        local c = active and C.text or C.muted
        b.text:SetTextColor(c[1], c[2], c[3])
        b.line:SetShown(active)
        b.fill:SetColor(active and C.violet or C.glass, active and 0.18 or 0.28)
        local n = (t.key == "whisper" and ns.char) and ns.Whisper:Unread() or (unread[t.key] or 0)
        if t.key == "all" or active then n = 0 end
        local natural = b.text.GetUnboundedStringWidth and b.text:GetUnboundedStringWidth() or b.text:GetStringWidth()
        local w = max(52, natural + 22)
        local badgeWidth = 0
        if n > 0 then
            b.badge:Set(n > 99 and "99+" or tostring(n), C.ink, C.violet, 1)
            b.badge:ClearAllPoints(); b.badge:SetPoint("LEFT", b.text, "RIGHT", 5, 0)
            b.badge:Show()
            badgeWidth = 5 + b.badge:GetWidth()
            w = w + badgeWidth
        else
            b.badge:Hide()
        end
        w = min(120, w)
        b.text:SetWidth(max(20, w - 22 - badgeWidth))
        if x > 12 and x + w > available then x, row = 12, row + 1 end
        b:SetWidth(w)
        b:ClearAllPoints()
        b:SetPoint("TOPLEFT", W, "TOPLEFT", x, -(HEAD_H + 5 + row * (TAB_H + 4)))
        x = x + w + 4
    end
    content:ClearAllPoints()
    content:SetPoint("TOPLEFT", W, "TOPLEFT", 12, -(HEAD_H + 13 + (row + 1) * (TAB_H + 4)))
    content:SetPoint("BOTTOMRIGHT", W, "BOTTOMRIGHT", -12, INPUT_H + 14)
    local required = HEAD_H + 13 + (row + 1) * (TAB_H + 4) + INPUT_H + 14 + 60
    if ns.db and W:GetHeight() < required then
        W:SetHeight(required)
        ns.db.height = required
    end
end
ns.UpdateTabs = UpdateTabs

local function Select(key)
    if not ns.Filters:ValidTab(key) then key = TABS[1] and TABS[1].key end
    if not key then return end
    current = key
    ns.db.tab = key
    local conversations = key == "whisper" and ns.Filters:ConversationMode()
    if key == "whisper" and not conversations then
        for _,conversation in pairs(ns.char.whispers) do
            if ns.Filters:Allows("whisper", conversation.bn and "bnet" or "whisper") then conversation.unread = 0 end
        end
    end
    for k, f in pairs(views) do f:SetShown(k == key and not conversations) end
    ns.Whisper.view:SetShown(conversations)
    unread[key] = 0
    newest:SetShown(not conversations and views[key] and not views[key]:AtBottom() or false)
    UpdateTabs()
end
W.Select = Select

local function MakeTab(t)
    local key = t.key
    local b = CreateFrame("Button", nil, W)
    b:SetFrameLevel(W:GetFrameLevel() + 6)
    b:SetHeight(TAB_H)
    b.fill = ns.Slice(b, "round", 0.25, "BACKGROUND", 1):Fit(b, 6)
    b.text = ns.Font(b, "bold", 12.5, C.sub)
    b.text:SetPoint("LEFT", 11, 0)
    b.line = ns.Tex(b, "ARTWORK", C.violet)
    b.line:SetPoint("BOTTOMLEFT", 6, 1); b.line:SetPoint("BOTTOMRIGHT", -6, 1); b.line:SetHeight(2)
    b.badge = ns.Pill(b, 9)
    b.badge:EnableMouse(false)
    b.badge.padX = 4
    b.badge:SetHeight(14)
    b.badge.fill:Fit(b.badge, 7); b.badge.line:Fit(b.badge, 7)
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    b:SetScript("OnClick", function(_, button)
        if button == "RightButton" then ns.ShowTabFilters(key) else Select(key) end
    end)
    b:SetScript("OnEnter", function(self)
        self.fill:SetColor(C.violet, 0.24)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(ns.Filters:Label(t), C.violet[1], C.violet[2], C.violet[3])
        GameTooltip:AddLine(L.FILTER_TAB_HINT, 1, 1, 1); GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function() GameTooltip:Hide(); UpdateTabs() end)
    tabButtons[key] = b
end
local function SyncTabs()
    for key,b in pairs(tabButtons) do
        if not ns.Filters:ValidTab(key) then
            b:Hide(); views[key]:Hide(); views[key]:Clear(); unread[key] = 0
        end
    end
    for _,tab in ipairs(TABS) do
        if not views[tab.key] then MakeView(tab.key) end
        if not tabButtons[tab.key] then MakeTab(tab) end
        tabButtons[tab.key]:Show()
    end
    Select(ns.Filters:ValidTab(current) and current or ns.db.tab)
end
ns:On("MC_TABS", SyncTabs)

-- Only the dedicated title strip moves the window; tab clicks cannot become drags.
local mover = CreateFrame("Frame", nil, W)
W.mover = mover
mover:SetPoint("TOPLEFT", 0, 0); mover:SetPoint("TOPRIGHT", -70, 0)
mover:SetHeight(HEAD_H)
mover:SetFrameLevel(W:GetFrameLevel() + 1)
mover:EnableMouse(true); mover:RegisterForDrag("LeftButton")
mover:SetScript("OnDragStart", function() W:StartMoving() end)
mover:SetScript("OnDragStop", function() W:StopMovingOrSizing(); W:SavePos() end)
mover:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP"); GameTooltip:SetText(L.MOVE_HINT); GameTooltip:Show()
end)
mover:SetScript("OnLeave", function() GameTooltip:Hide() end)
local title = ns.Font(mover, "title", 12, C.muted)
title:SetPoint("LEFT", 13, -1); title:SetText("Moteve Chat")
local settings = CreateFrame("Button", nil, W)
settings:SetFrameLevel(W:GetFrameLevel() + 7); settings:SetSize(28, 24)
settings:SetPoint("TOPRIGHT", -8, -1)
local settingsText = ns.Font(settings, "bold", 17, C.violet, "CENTER")
settingsText:SetPoint("CENTER"); settingsText:SetText("…")
settings:SetScript("OnClick", function() ns.ShowTabFilters(current or "all") end)
settings:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP"); GameTooltip:SetText(L.FILTER_TITLE); GameTooltip:Show()
end)
settings:SetScript("OnLeave", function() GameTooltip:Hide() end)
local addTab = CreateFrame("Button", nil, W)
W.addTabButton = addTab
addTab:SetFrameLevel(W:GetFrameLevel() + 7); addTab:SetSize(28, 24)
addTab:SetPoint("TOPRIGHT", -38, -1)
local plus = ns.Font(addTab, "bold", 19, C.violet, "CENTER")
plus:SetPoint("CENTER"); plus:SetText("+")
addTab:SetScript("OnClick", function() ns.ShowNewTabDialog() end)
addTab:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP"); GameTooltip:SetText(L.TAB_ADD); GameTooltip:Show()
end)
addTab:SetScript("OnLeave", function() GameTooltip:Hide() end)
W:SetScript("OnSizeChanged", function() UpdateTabs(); ns.Whisper:Refresh() end)

-- resize grip (bottom-right corner)
local grip = CreateFrame("Button", nil, W)
grip:SetSize(14, 14)
grip:SetPoint("BOTTOMRIGHT", -2, 2)
grip.tex = grip:CreateTexture(nil, "OVERLAY")
grip.tex:SetAllPoints()
grip.tex:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
grip.tex:SetVertexColor(C.muted[1], C.muted[2], C.muted[3], 0.6)
grip:SetScript("OnMouseDown", function() W:StartSizing("BOTTOMRIGHT") end)
grip:SetScript("OnMouseUp", function()
    W:StopMovingOrSizing()
    ns.db.width, ns.db.height = W:GetWidth(), W:GetHeight()
    W:SavePos()
    ns.Whisper:Refresh()
end)

function W:SavePos()
    local p, _, rp, x, y = self:GetPoint()
    ns.db.point, ns.db.relPoint, ns.db.x, ns.db.y = p, rp, x, y
end

local function Place()
    W:ClearAllPoints()
    W:SetPoint(ns.db.point, UIParent, ns.db.relPoint, ns.db.x, ns.db.y)
    W:SetSize(max(320, ns.db.width), max(210, ns.db.height))
end

-- hover: stronger backdrop, faded lines come back
W:SetScript("OnEnter", function() end)
local hovered = false
W:SetScript("OnUpdate", function(self)
    local over = self:IsMouseOver()
    if over ~= hovered then
        hovered = over
        Backdrop(over)
        if over and current and views[current] and views[current].ResetAllFadeTimes then views[current]:ResetAllFadeTimes() end
    end
end)

---------------------------------------------------------------------------
-- Routing chat events to the tabs
---------------------------------------------------------------------------
local CATEGORY = ns.Filters.Events
local SHORT = {
    SAY="S", YELL="Y", EMOTE="E", WHISPER="W", WHISPER_INFORM="→ W",
    BN_WHISPER="BN", BN_WHISPER_INFORM="→ BN", GUILD="G", OFFICER="O",
    PARTY="P", PARTY_LEADER="P", RAID="R", RAID_LEADER="R", RAID_WARNING="RW",
    INSTANCE_CHAT="I", INSTANCE_CHAT_LEADER="I", COMMUNITIES_CHANNEL="C",
}
local plainGroups = {system=true,loot=true,money=true,xp=true,reputation=true,skill=true,achievement=true}
local history, sequence, clearedAt = {}, 0, {}
local function AddToView(key, entry)
    if entry.seq <= (clearedAt[key] or 0) or not ns.Filters:Allows(key, entry.group, entry.channel) then return end
    local f = views[key]
    if not pcall(f.AddMessage, f, entry.text, entry.r, entry.g, entry.b) then return end
    if key ~= current and (key == "guild" or key == "group") then
        unread[key] = (unread[key] or 0) + 1
    elseif key == current and not f:AtBottom() then newest:Show() end
end
local function Append(group, text, r, g, b, channel)
    if not ns.db or not ns.db.tabFilters then return end
    sequence = sequence + 1
    local entry = {seq=sequence,group=group,text=text,r=r,g=g,b=b,channel=channel}
    history[#history+1] = entry
    if #history > 500 then table.remove(history, 1) end
    for _,tab in ipairs(TABS) do AddToView(tab.key, entry) end
    UpdateTabs()
end
local function ClassColored(name, guid)
    local short = ns.Whisper.Short(name)
    if guid and not ns.IsSecret(guid) and GetPlayerInfoByGUID then
        local ok, _, class = pcall(GetPlayerInfoByGUID, guid)
        local cc = ok and class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[class]
        if cc then return format("|cff%02x%02x%02x%s|r", math.floor(cc.r*255+0.5), math.floor(cc.g*255+0.5), math.floor(cc.b*255+0.5), short) end
    end
    return short
end
local function Route(event, text, sender, _, _, _, _, _, chanIndex, chanBase, _, lineID, guid)
    local group = CATEGORY[event]
    if not group then return end
    local typ = event:sub(10)
    local restricted = ns.IsSecret(text, sender, chanIndex, chanBase, lineID, guid)
    if not restricted and text == nil then return end
    local colorKey = typ
    if not restricted and typ == "CHANNEL" then colorKey = "CHANNEL" .. tostring(chanIndex or 1) end
    local info = ChatTypeInfo and ChatTypeInfo[colorKey]
    local r, g, b = info and info.r or 1, info and info.g or 1, info and info.b or 1
    local line = text
    if not restricted then
        if plainGroups[group] or typ == "TEXT_EMOTE" then
            if typ == "ACHIEVEMENT" and sender and sender ~= "" then
                local ok, formatted = pcall(format, text, "|Hplayer:"..sender.."|h"..ClassColored(sender,guid).."|h")
                if ok then line = formatted end
            end
            line = ns.Links.Linkify(line)
        else
            local label = SHORT[typ]
            if typ == "CHANNEL" then
                local base = (chanBase and chanBase ~= "") and chanBase or ""
                label = tostring(chanIndex or "") .. (base ~= "" and (". " .. base) or "")
            end
            local who = sender and sender ~= "" and ("|Hplayer:" .. sender .. ":" .. tostring(lineID or 0) .. "|h" .. ClassColored(sender,guid) .. "|h") or ""
            if group == "bnet" then who = sender and sender ~= "" and ns.Whisper.Short(sender) or "" end
            if typ == "GUILD_ACHIEVEMENT" then
                local ok, formatted = pcall(format, text, who)
                if ok then line = formatted end
            else
                line = "|cff9aa4c7[" .. (label or "?") .. "]|r " .. who .. ": " .. ns.Links.Linkify(text)
            end
        end
    end
    Append(group, line, r, g, b, chanBase)
    if current == "whisper" and (group == "whisper" or group == "bnet") and not restricted
        and ns.Filters:Allows("whisper", group) and ns.char.whispers[sender] then
        ns.char.whispers[sender].unread = 0
    end
end
for event in pairs(CATEGORY) do ns:On(event, function(...) ns.Safe("route", Route, ...) end) end

-- Typed Blizzard chat lines are already captured from events. Mirror only untyped prints.
local function Mirror(_, text, r, g, b, chatTypeID)
    if ns.IsSecret(chatTypeID) or chatTypeID ~= nil then return end
    local line
    if ns.IsSecret(text) then line = text
    elseif text == nil then return
    else line = ns.Links.Linkify(tostring(text)) end
    Append("addon", line, r or 1, g or 1, b or 1)
end
ns:On("MC_FILTERS", function(_, key)
    local f = views[key]
    if not f then return end
    f:Clear(); unread[key] = 0
    for _,entry in ipairs(history) do
        if entry.seq > (clearedAt[key] or 0) and ns.Filters:Allows(key, entry.group, entry.channel) then
            pcall(f.AddMessage, f, entry.text, entry.r, entry.g, entry.b)
        end
    end
    Select(current or "all")
end)

---------------------------------------------------------------------------
-- Default chat windows: hidden (not destroyed), the input box moves into our window
---------------------------------------------------------------------------
local BLIZZ = { "GeneralDockManager", "ChatFrameMenuButton", "ChatFrameChannelButton",
    "ChatFrameToggleVoiceDeafenButton", "ChatFrameToggleVoiceMuteButton", "QuickJoinToastButton",
    "CombatLogQuickButtonFrame_Custom" }

local function Fade(f)
    if not f then return end
    pcall(f.SetAlpha, f, 0)
    if f.EnableMouse then pcall(f.EnableMouse, f, false) end
    if f.EnableMouseWheel then pcall(f.EnableMouseWheel, f, false) end
end

local function HideBlizzard()
    for i = 1, (NUM_CHAT_WINDOWS or 10) do
        Fade(_G["ChatFrame" .. i])
        Fade(_G["ChatFrame" .. i .. "Tab"])
        Fade(_G["ChatFrame" .. i .. "ButtonFrame"])
    end
    for _, n in ipairs(BLIZZ) do Fade(_G[n]) end
end

local eb -- the game's chat input
local function PlaceInput()
    if not eb then return end
    eb:ClearAllPoints()
    eb:SetPoint("BOTTOMLEFT", W, "BOTTOMLEFT", 10, 8)
    eb:SetPoint("BOTTOMRIGHT", W, "BOTTOMRIGHT", -20, 8)
    eb:SetHeight(INPUT_H)
end

local function StyleInput()
    eb = DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.editBox or _G.ChatFrame1EditBox
    if not eb then return end
    eb:SetParent(W)
    eb:SetFrameLevel(W:GetFrameLevel() + 20)
    -- hide the game's frame art, then add our rounded field
    for _, r in ipairs({ eb:GetRegions() }) do
        if r.GetObjectType and r:GetObjectType() == "Texture" then r:SetAlpha(0) end
    end
    local fill = ns.Slice(eb, "round", 0.25, "BACKGROUND", -6):Fit(eb, INPUT_H / 2)
    fill:SetColor(C.glass, 0.78)
    local line = ns.Slice(eb, "roundline", 0.25, "BORDER", -6):Fit(eb, INPUT_H / 2)
    line:SetColor(C.edge, 0.3)
    eb:HookScript("OnShow", function(self)
        PlaceInput()
        -- on the Whisper tab, Enter replies to the selected conversation
        local name = ns.char and ns.char.selected
        if current == "whisper" and ns.Filters:ConversationMode() and name and ns.char.whispers[name] and not ns.char.whispers[name].bn
            and self:GetAttribute("chatType") ~= "WHISPER" then
            self:SetAttribute("chatType", "WHISPER")
            self:SetAttribute("tellTarget", name)
            if self.UpdateHeader then pcall(self.UpdateHeader, self)
            elseif ChatEdit_UpdateHeader then pcall(ChatEdit_UpdateHeader, self) end
        end
    end)
    PlaceInput()
end

---------------------------------------------------------------------------
-- Startup
---------------------------------------------------------------------------
ns:On("MC_INIT", function()
    SyncTabs()
    Place()
    Select(ns.db.tab or "all")
end)

ns:On("PLAYER_LOGIN", function()
    if DEFAULT_CHAT_FRAME then
        hooksecurefunc(DEFAULT_CHAT_FRAME, "AddMessage", function(...) ns.Safe("mirror", Mirror, ...) end)
    end
    if ns.db.hideBlizzard then
        ns.Safe("input", StyleInput)
        ns.Safe("hide", HideBlizzard)
        -- the game re-shows parts of its chat UI now and then (new windows, dock updates); keep them hidden
        C_Timer.NewTicker(1, function()
            ns.Safe("hide", HideBlizzard)
            if eb and eb:GetParent() ~= W then ns.Safe("input", StyleInput) end
        end)
    end
    W:Show()
end)

ns:On("MC_WHISPER", function() UpdateTabs() end)
ns:On("MC_LANGUAGE", function() UpdateTabs(); ns.Whisper:Refresh() end)
ns:On("MC_RESET", function()
    ns.db.point, ns.db.relPoint, ns.db.x, ns.db.y = "BOTTOMLEFT", "BOTTOMLEFT", 20, 46
    ns.db.width, ns.db.height = 470, 250
    Place()
end)
ns:On("MC_CLEAR", function()
    if current == "whisper" and ns.Filters:ConversationMode() then
        local c = ns.char.selected and ns.char.whispers[ns.char.selected]
        if c then wipe(c.msgs); ns.Whisper:Refresh() end
    elseif views[current] then
        clearedAt[current] = sequence
        views[current]:Clear()
    end
end)
