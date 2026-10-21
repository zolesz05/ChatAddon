-- Moteve Chat - web links in chat become clickable; a click opens a small box with the link
-- selected, ready for Ctrl+C (addons cannot write to the clipboard directly).
local _, ns = ...
local C, L = ns.C, ns.L

local Links = {}
ns.Links = Links

local PREFIX = "addon:MoteveChat:url:"
local COLOR = "|cff7fd8ff"

-- patterns, most specific first. Captures stop at whitespace and at WoW escape codes ("|").
local PATTERNS = {
    "%f[%S](%a[%w+.-]+://[^%s|]+)",                  -- https://..., ftp://...
    "%f[%S](www%.[%w_-]+%.[^%s|]+)",                 -- www.example.com/...
    "%f[%S]([%w_-]+%.[%w_-]+%.%a%a%a?/[^%s|]*)",     -- sub.example.com/path
    "%f[%S]([%w_-]+%.%a%a%a?/[^%s|]*)",              -- example.com/path
    "%f[%S]([%w_-]+%.com)%f[%s%p%z]",                -- example.com
    "%f[%S](discord%.gg/[^%s|]+)",
}

local function Encode(url) return (url:gsub("|", "")) end

local function Wrap(url)
    -- keep trailing punctuation outside the link
    local tail = url:match("[%.,;:!%?%)]+$") or ""
    if #tail > 0 then url = url:sub(1, -#tail - 1) end
    return COLOR .. "|H" .. PREFIX .. Encode(url) .. "|h" .. url .. "|h|r" .. tail
end

-- Replace web addresses in a chat line with copy links. Existing game links (|H...|h) are left alone:
-- only the plain text between them is scanned.
function Links.Linkify(text)
    if type(text) ~= "string" or ns.IsSecret(text) or not text:find("[%./]") then return text end
    local out, pos = {}, 1
    while pos <= #text do
        local s, e = text:find("|H.-|h.-|h", pos)
        local plain = text:sub(pos, s and s - 1 or #text)
        if plain ~= "" then
            -- a leading space lets the frontier patterns match at the very start of the text
            local seg, done = " " .. plain, false
            for _, pat in ipairs(PATTERNS) do
                if not done and seg:find(pat) then
                    seg = seg:gsub(pat, Wrap)
                    done = true
                end
            end
            out[#out + 1] = seg:sub(2)
        end
        if not s then break end
        out[#out + 1] = text:sub(s, e)
        pos = e + 1
    end
    return table.concat(out)
end

-- link click: true when it was one of ours
function Links.Handle(link)
    if type(link) ~= "string" then return false end
    local url = link:match("^" .. PREFIX:gsub("%p", "%%%0") .. "(.+)$")
    if not url then return false end
    Links.ShowCopy(url)
    return true
end

---------------------------------------------------------------------------
-- Copy box
---------------------------------------------------------------------------
local box
local function Build()
    box = CreateFrame("Frame", "MoteveChatCopy", UIParent)
    box:SetSize(340, 96)
    box:SetFrameStrata("DIALOG")
    box:SetClampedToScreen(true)
    box:EnableMouse(true)
    box:SetMovable(true)
    box:RegisterForDrag("LeftButton")
    box:SetScript("OnDragStart", box.StartMoving)
    box:SetScript("OnDragStop", box.StopMovingOrSizing)
    ns.Glass(box, { radius = 12, alpha = 0.94, edge = 0.3 })
    box.title = ns.Font(box, "bold", 11, C.sub)
    box.title:SetPoint("TOPLEFT", 14, -12)
    box.close = CreateFrame("Button", nil, box)
    box.close:SetSize(18, 18)
    box.close:SetPoint("TOPRIGHT", -8, -8)
    box.close.text = ns.Font(box.close, "bold", 14, C.muted, "CENTER")
    box.close.text:SetPoint("CENTER")
    box.close.text:SetText("×")
    box.close:SetScript("OnClick", function() box:Hide() end)

    local field = CreateFrame("Frame", nil, box)
    field:SetPoint("TOPLEFT", 14, -32)
    field:SetPoint("TOPRIGHT", -14, -32)
    field:SetHeight(26)
    local f1 = ns.Slice(field, "round", 0.25, "BACKGROUND", 1):Fit(field, 7)
    f1:SetColor({ 1, 1, 1 }, 0.06)
    local f2 = ns.Slice(field, "roundline", 0.25, "BORDER", 1):Fit(field, 7)
    f2:SetColor(C.cyan, 0.55)

    local eb = CreateFrame("EditBox", nil, field)
    eb:SetPoint("TOPLEFT", 8, -2)
    eb:SetPoint("BOTTOMRIGHT", -8, 2)
    eb:SetAutoFocus(false)
    eb:SetFont(ns.FONT_BODY, 13, "")
    if not eb:GetFont() then eb:SetFont(STANDARD_TEXT_FONT, 13, "") end
    eb:SetTextColor(C.cyanPale[1], C.cyanPale[2], C.cyanPale[3])
    eb:SetScript("OnEscapePressed", function() box:Hide() end)
    eb:SetScript("OnEnterPressed", function() box:Hide() end)
    -- the text cannot be edited: typing restores it, so a stray key never changes the link
    eb:SetScript("OnTextChanged", function(self, user)
        if user and self:GetText() ~= box.url then self:SetText(box.url or ""); self:HighlightText() end
    end)
    eb:SetScript("OnKeyUp", function(_, key)
        if key == "C" and IsControlKeyDown() then C_Timer.After(0.1, function() box:Hide() end) end
    end)
    box.eb = eb

    box.hint = ns.Font(box, "body", 11, C.muted)
    box.hint:SetPoint("TOPLEFT", field, "BOTTOMLEFT", 2, -8)
    box:Hide()
    tinsert(UISpecialFrames, "MoteveChatCopy")
end

function Links.ShowCopy(text, title)
    if not box then Build() end
    box.url = text
    box.title:SetText(title or L.COPY_TITLE)
    box.hint:SetText(L.COPY_HINT)
    box:ClearAllPoints()
    if ns.Window and ns.Window:IsShown() then
        box:SetPoint("BOTTOMLEFT", ns.Window, "TOPLEFT", 0, 10)
    else
        box:SetPoint("CENTER", UIParent, "CENTER", 0, 120)
    end
    box:Show()
    box.eb:SetText(text)
    box.eb:SetFocus()
    box.eb:HighlightText()
    box.eb:SetCursorPosition(0)
    box.eb:HighlightText()
end

-- links clicked in Blizzard's own chat frames (if they are kept visible)
if EventRegistry and EventRegistry.RegisterCallback then
    pcall(EventRegistry.RegisterCallback, EventRegistry, "SetItemRef", function(_, link) ns.Safe("link", Links.Handle, link) end, Links)
end
