-- Per-tab settings. Changes apply immediately and rebuild the recent chat history.
local _,ns=...
local C,L,F=ns.C,ns.L,ns.Filters
local P=CreateFrame("Frame","MoteveChatFilters",UIParent)
ns.FilterPanel=P
P:SetSize(466,485)
P:SetPoint("CENTER")
P:SetFrameStrata("DIALOG")
P:SetClampedToScreen(true)
P:EnableMouse(true)
P:SetMovable(true);P:RegisterForDrag("LeftButton")
P:SetScript("OnDragStart",P.StartMoving)
P:SetScript("OnDragStop",P.StopMovingOrSizing)
ns.Glass(P,{alpha=0.98,radius=12,edge=0.7,edgeColor=C.edge})
P:Hide()
if UISpecialFrames then table.insert(UISpecialFrames,"MoteveChatFilters") end
P.title=ns.Font(P,"title",17,C.violet)
P.title:SetPoint("TOPLEFT",18,-16);P.title:SetPoint("RIGHT",-80,0)
local hint=ns.Font(P,"body",12,C.sub)
hint:SetPoint("TOPLEFT",18,-42);hint:SetPoint("RIGHT",-18,0)
local function Button(parent,w,text,fn)
    local b=CreateFrame("Button",nil,parent)
    b:SetSize(w,26);ns.Glass(b,{radius=6,alpha=0.9,shadow=false,edge=0.35})
    b.text=ns.Font(b,"bold",12,C.text,"CENTER");b.text:SetPoint("CENTER");b.text:SetText(text)
    b:SetScript("OnClick",fn)
    return b
end
local close=Button(P,26,"×",function() P:Hide() end)
close:SetPoint("TOPRIGHT",-12,-12)
local selectors={}
P.selectors=selectors
local Refresh
local add=Button(P,26,"+",function() ns.ShowNewTabDialog() end)
add:SetPoint("TOPRIGHT",-44,-12)
local scroll=CreateFrame("ScrollFrame",nil,P,"UIPanelScrollFrameTemplate")
scroll:SetPoint("TOPLEFT",16,-105);scroll:SetPoint("BOTTOMRIGHT",-34,72)
local body=CreateFrame("Frame",nil,scroll)
body:SetWidth(408);body:SetHeight(350);scroll:SetScrollChild(body)
local checks,channelChecks={},{}
local function Check(y,x,fn)
    local row=CreateFrame("CheckButton",nil,body,"UICheckButtonTemplate")
    row:SetSize(24,24);row:SetPoint("TOPLEFT",x,y)
    local stock=row.Text or row.text
    if stock and stock.SetText then stock:SetText("") end
    row.label=ns.Font(row,"body",12.5,C.text)
    row.label:SetPoint("LEFT",row,"RIGHT",3,0);row.label:SetWidth(170)
    -- Label and checkbox share one large click target.
    row:SetHitRectInsets(0,-170,-2,-2)
    row:SetScript("OnClick",fn)
    return row
end
for i,typ in ipairs(F.Types) do
    local key=typ.key
    local cb=Check(-math.floor((i-1)/2)*28,((i-1)%2)*207,function(self)
        F:SetType(P.selectedTab,key,self:GetChecked())
    end)
    cb.filterLabel=typ.label;checks[key]=cb
end
local channelTitle=ns.Font(body,"bold",12,C.violet)
channelTitle:SetPoint("TOPLEFT",0,-294)
local foot=ns.Font(P,"body",11,C.muted)
foot:SetPoint("BOTTOMLEFT",18,48);foot:SetPoint("RIGHT",-18,0)
local all=Button(P,88,"",function() F:SetAll(P.selectedTab,true) end);all:SetPoint("BOTTOMLEFT",16,14)
local none=Button(P,88,"",function() F:SetAll(P.selectedTab,false) end);none:SetPoint("LEFT",all,"RIGHT",8,0)
local reset=Button(P,132,"",function() F:Reset(P.selectedTab) end);reset:SetPoint("LEFT",none,"RIGHT",8,0)
local delete=Button(P,98,"",function() ns.ConfirmDeleteTab(P.selectedTab) end)
delete:SetPoint("BOTTOMRIGHT",-16,14)
P.deleteButton=delete
Refresh=function()
    if not ns.db or not P.selectedTab then return end
    if not F:ValidTab(P.selectedTab) then P.selectedTab=ns.db.tab end
    if not F:ValidTab(P.selectedTab) then P.selectedTab=F.Tabs[1] and F.Tabs[1].key end
    if not P.selectedTab then return end
    local rule=ns.db.tabFilters[P.selectedTab]
    local tabLabel=""
    for key,b in pairs(selectors) do if not F:ValidTab(key) then b:Hide() end end
    local extra=math.floor((#F.Tabs-1)/6)*30
    P:SetHeight(485+extra)
    scroll:ClearAllPoints()
    scroll:SetPoint("TOPLEFT",16,-105-extra);scroll:SetPoint("BOTTOMRIGHT",-34,72)
    for i,tab in ipairs(F.Tabs) do
        local b=selectors[tab.key]
        if not b then
            local key=tab.key
            b=Button(P,68,"",function() P.selectedTab=key;Refresh() end)
            b.text:SetWidth(60)
            selectors[key]=b
        end
        b:ClearAllPoints();b:SetPoint("TOPLEFT",16+((i-1)%6)*72,-66-math.floor((i-1)/6)*30)
        b:Show();b.text:SetText(F:Label(tab))
        local color=tab.key==P.selectedTab and C.violet or C.sub
        b.text:SetTextColor(color[1],color[2],color[3])
        if tab.key==P.selectedTab then tabLabel=F:Label(tab) end
    end
    P.title:SetText(L.FILTER_TITLE.." · "..tabLabel)
    hint:SetText(L.FILTER_HINT)
    for _,typ in ipairs(F.Types) do
        local cb=checks[typ.key];cb.label:SetText(L[typ.label]);cb:SetChecked(rule.types[typ.key])
    end
    for _,cb in ipairs(channelChecks) do cb:Hide() end
    channelTitle:SetText(L.FILTER_JOINED)
    local channels=F:JoinedChannels()
    for i,channel in ipairs(channels) do
        local cb=channelChecks[i]
        if not cb then
            cb=Check(-316-math.floor((i-1)/2)*28,((i-1)%2)*207,function(self)
                F:SetChannel(P.selectedTab,self.channelName,self:GetChecked())
            end)
            channelChecks[i]=cb
        end
        cb.channelName=channel.name
        cb.label:SetText(tostring(channel.id)..". "..channel.name)
        cb:SetChecked(F:Allows(P.selectedTab,"channels",channel.name));cb:Show()
    end
    body:SetHeight(324+math.ceil(#channels/2)*28)
    foot:SetText(P.selectedTab=="whisper" and L.FILTER_WHISPER_NOTE or L.FILTER_SAVED)
    all.text:SetText(L.FILTER_ALL);none.text:SetText(L.FILTER_NONE);reset.text:SetText(L.FILTER_RESET)
    delete.text:SetText(L.TAB_DELETE);delete:SetAlpha(#F.Tabs>1 and 1 or 0.4)
end
function ns.ShowTabFilters(tab)
    P.selectedTab=F:ValidTab(tab) and tab or (ns.db and ns.db.tab) or "all"
    scroll:SetVerticalScroll(0);Refresh();P:Show()
end
ns:On("MC_FILTERS",function() if P:IsShown() then Refresh() end end)
ns:On("MC_LANGUAGE",function() if P:IsShown() then Refresh() end end)
ns:On("CHANNEL_UI_UPDATE",function() if P:IsShown() then Refresh() end end)
ns:On("MC_TABS",function() if P:IsShown() then Refresh() end end)

-- Naming uses an ordinary edit box so Hungarian names work like the chat input.
local D=CreateFrame("Frame","MoteveChatNewTab",UIParent)
ns.NewTabDialog=D
D:SetSize(320,156);D:SetPoint("CENTER")
D:SetFrameStrata("DIALOG");D:SetFrameLevel(P:GetFrameLevel()+30)
D:SetClampedToScreen(true);D:EnableMouse(true)
ns.Glass(D,{alpha=0.98,radius=12,edge=0.5})
D:Hide()
if UISpecialFrames then table.insert(UISpecialFrames,"MoteveChatNewTab") end
local title=ns.Font(D,"title",16,C.violet);title:SetPoint("TOPLEFT",18,-16)
local input=CreateFrame("EditBox",nil,D,"InputBoxTemplate")
D.input=input
input:SetSize(272,28);input:SetPoint("TOPLEFT",24,-49)
input:SetAutoFocus(false);input:SetMaxLetters(96);ns.SetFontSafe(input,ns.FONT_BODY,13)
local errorText=ns.Font(D,"body",11,C.kill);errorText:SetPoint("TOPLEFT",18,-83);errorText:SetPoint("RIGHT",-18,0)
local function Create()
    local key,err=F:AddTab(input:GetText())
    if not key then errorText:SetText(L[err]);return end
    D:Hide();ns.Window.Select(key);ns.ShowTabFilters(key)
end
local create=Button(D,132,"",Create);create:SetPoint("BOTTOMLEFT",18,14)
local cancel=Button(D,132,"",function() D:Hide() end);cancel:SetPoint("BOTTOMRIGHT",-18,14)
input:SetScript("OnEnterPressed",Create)
input:SetScript("OnEscapePressed",function() D:Hide() end)
D:SetScript("OnHide",function() if input.ClearFocus then input:ClearFocus() end end)
function ns.ShowNewTabDialog()
    title:SetText(L.TAB_ADD);create.text:SetText(L.TAB_CREATE);cancel.text:SetText(L.TAB_CANCEL)
    input:SetText("");errorText:SetText(L.TAB_NAME_HINT);D:Show();input:SetFocus()
end
StaticPopupDialogs["MOTEVECHAT_DELETE_TAB"]={
    text="%s",button1=YES or "Yes",button2=NO or "No",timeout=0,whileDead=true,hideOnEscape=true,
    OnAccept=function(_,key)
        local ok,err=F:RemoveTab(key)
        if not ok then ns:Print(L[err]) end
    end,
}
function ns.ConfirmDeleteTab(key)
    if #F.Tabs<=1 then ns:Print(L.TAB_LAST);return end
    for _,tab in ipairs(F.Tabs) do
        if tab.key==key then
            local dialog=StaticPopupDialogs.MOTEVECHAT_DELETE_TAB
            dialog.text=L.TAB_DELETE_CONFIRM;dialog.button1=L.TAB_DELETE;dialog.button2=L.TAB_CANCEL
            StaticPopup_Show("MOTEVECHAT_DELETE_TAB",F:Label(tab),nil,key)
            return
        end
    end
end
