-- Persistent routing rules. Chat events are independent of the native chat window's filters.
local _, ns = ...
local F = {}
ns.Filters = F
local defaultTabs = {
    {key="all",label="TAB_ALL"}, {key="whisper",label="TAB_WHISPER"},
    {key="guild",label="TAB_GUILD"}, {key="group",label="TAB_GROUP"},
    {key="channels",label="TAB_CHANNELS"}, {key="system",label="TAB_SYSTEM"},
}
F.Tabs = {}
F.MAX_TABS = 12
F.Types = {
    {key="say",label="FILTER_SAY"}, {key="yell",label="FILTER_YELL"},
    {key="emote",label="FILTER_EMOTE"}, {key="whisper",label="FILTER_WHISPER"},
    {key="bnet",label="FILTER_BNET"}, {key="guild",label="FILTER_GUILD"},
    {key="officer",label="FILTER_OFFICER"}, {key="party",label="FILTER_PARTY"},
    {key="raid",label="FILTER_RAID"}, {key="instance",label="FILTER_INSTANCE"},
    {key="channels",label="FILTER_CHANNELS"}, {key="system",label="FILTER_SYSTEM"},
    {key="loot",label="FILTER_LOOT"}, {key="money",label="FILTER_MONEY"},
    {key="xp",label="FILTER_XP"}, {key="reputation",label="FILTER_REPUTATION"},
    {key="skill",label="FILTER_SKILL"}, {key="achievement",label="FILTER_ACHIEVEMENT"},
    {key="addon",label="FILTER_ADDON"},
}
F.Events = {
    CHAT_MSG_SAY="say", CHAT_MSG_YELL="yell", CHAT_MSG_EMOTE="emote", CHAT_MSG_TEXT_EMOTE="emote",
    CHAT_MSG_WHISPER="whisper", CHAT_MSG_WHISPER_INFORM="whisper",
    CHAT_MSG_BN_WHISPER="bnet", CHAT_MSG_BN_WHISPER_INFORM="bnet",
    CHAT_MSG_GUILD="guild", CHAT_MSG_GUILD_ACHIEVEMENT="guild", CHAT_MSG_OFFICER="officer",
    CHAT_MSG_PARTY="party", CHAT_MSG_PARTY_LEADER="party", CHAT_MSG_RAID="raid",
    CHAT_MSG_RAID_LEADER="raid", CHAT_MSG_RAID_WARNING="raid",
    CHAT_MSG_INSTANCE_CHAT="instance", CHAT_MSG_INSTANCE_CHAT_LEADER="instance",
    CHAT_MSG_CHANNEL="channels", CHAT_MSG_COMMUNITIES_CHANNEL="channels",
    CHAT_MSG_SYSTEM="system", CHAT_MSG_LOOT="loot", CHAT_MSG_MONEY="money", CHAT_MSG_CURRENCY="money",
    CHAT_MSG_COMBAT_XP_GAIN="xp", CHAT_MSG_COMBAT_FACTION_CHANGE="reputation", CHAT_MSG_COMBAT_HONOR_GAIN="xp",
    CHAT_MSG_SKILL="skill", CHAT_MSG_TRADESKILLS="skill", CHAT_MSG_OPENING="skill", CHAT_MSG_ACHIEVEMENT="achievement",
}
local defaults = {
    whisper={whisper=true,bnet=true}, guild={guild=true,officer=true},
    group={party=true,raid=true,instance=true}, channels={channels=true},
    system={system=true,loot=true,money=true,xp=true,reputation=true,skill=true,achievement=true},
}
local validTabs, validTypes = {}, {}
local builtins = {}
for _,t in ipairs(defaultTabs) do builtins[t.key]=t end
for _,t in ipairs(F.Types) do validTypes[t.key]=true end
function F:ValidTab(key) return validTabs[key] == true end
function F:Label(tab) return tab.name or ns.L[tab.label] end
local function CleanName(name)
    if type(name)~="string" then return nil end
    name=name:gsub("|", ""):gsub("%c", " "):gsub("%s+", " "):match("^%s*(.-)%s*$")
    local _,length=name:gsub("[^\128-\191]", "")
    if length<1 or length>24 then return nil end
    return name
end
local function Default(tab,typ) return tab=="all" or (defaults[tab] and defaults[tab][typ]) or false end
local function ChannelKey(name)
    if type(name)~="string" or ns.IsSecret(name) then return nil end
    return name:lower():gsub("%s+%-%s+.*$", "")
end
function F:Initialize()
    if type(ns.db.tabFilters)~="table" then ns.db.tabFilters={} end
    local saved=ns.db.tabs
    if type(saved)~="table" or #saved==0 then saved=defaultTabs end
    local normalized={}
    for key in pairs(validTabs) do validTabs[key]=nil end
    for i=#self.Tabs,1,-1 do self.Tabs[i]=nil end
    local highest=0
    for _,tab in ipairs(saved) do
        if type(tab)=="table" and type(tab.key)=="string" and not validTabs[tab.key] and #normalized<self.MAX_TABS then
            local builtin=builtins[tab.key]
            local number=tab.key:match("^custom_(%d+)$")
            local name=CleanName(tab.name)
            if builtin or (number and name) then
                local entry=builtin and {key=builtin.key,label=builtin.label} or {key=tab.key,name=name}
                normalized[#normalized+1]=entry; self.Tabs[#self.Tabs+1]=entry
                validTabs[tab.key]=true
                highest=math.max(highest,tonumber(number) or 0)
            end
        end
    end
    if #normalized==0 then
        local first={key="all",label="TAB_ALL"}
        normalized[1]=first;self.Tabs[1]=first;validTabs.all=true
    end
    ns.db.tabs=normalized
    local nextID=tonumber(ns.db.nextTabID) or 1
    if nextID~=nextID or nextID<1 or nextID==math.huge then nextID=1 end
    ns.db.nextTabID=math.max(math.floor(nextID),highest+1)
    for _,tab in ipairs(self.Tabs) do
        local rule=ns.db.tabFilters[tab.key]
        if type(rule)~="table" then rule={};ns.db.tabFilters[tab.key]=rule end
        if type(rule.types)~="table" then rule.types={} end
        if type(rule.channels)~="table" then rule.channels={} end
        for _,typ in ipairs(self.Types) do
            if type(rule.types[typ.key])~="boolean" then rule.types[typ.key]=Default(tab.key,typ.key) end
        end
    end
end
function F:AddTab(name)
    if #self.Tabs>=self.MAX_TABS then return nil,"TAB_LIMIT" end
    name=CleanName(name)
    if not name then return nil,"TAB_NAME_INVALID" end
    for _,tab in ipairs(self.Tabs) do
        if self:Label(tab):lower()==name:lower() then return nil,"TAB_NAME_DUPLICATE" end
    end
    local id=ns.db.nextTabID
    local key="custom_"..id
    while validTabs[key] or ns.db.tabFilters[key] do id=id+1;key="custom_"..id end
    ns.db.nextTabID=id+1
    local tab={key=key,name=name}
    self.Tabs[#self.Tabs+1]=tab;ns.db.tabs[#ns.db.tabs+1]=tab;validTabs[key]=true
    local types={}
    for _,typ in ipairs(self.Types) do types[typ.key]=false end
    ns.db.tabFilters[key]={types=types,channels={}}
    ns:Fire("MC_TABS")
    return key
end
function F:RemoveTab(key)
    if not validTabs[key] then return nil,"TAB_NOT_FOUND" end
    if #self.Tabs<=1 then return nil,"TAB_LAST" end
    for i,tab in ipairs(self.Tabs) do if tab.key==key then table.remove(self.Tabs,i);break end end
    for i,tab in ipairs(ns.db.tabs) do if tab.key==key then table.remove(ns.db.tabs,i);break end end
    validTabs[key]=nil;ns.db.tabFilters[key]=nil
    if ns.db.tab==key then ns.db.tab=self.Tabs[1].key end
    ns:Fire("MC_TABS")
    return true
end
function F:Allows(tab,typ,channel)
    local rule=ns.db and ns.db.tabFilters and ns.db.tabFilters[tab]
    if not rule or not rule.types[typ] then return false end
    if typ=="channels" then
        local key=ChannelKey(channel)
        if key then return rule.channels[key]~=false end
        -- If the client conceals a channel name, do not bypass explicit channel exclusions.
        for _,enabled in pairs(rule.channels) do if enabled==false then return false end end
    end
    return true
end
function F:SetType(tab,typ,enabled)
    if not validTabs[tab] or not validTypes[typ] then return end
    ns.db.tabFilters[tab].types[typ]=not not enabled
    ns:Fire("MC_FILTERS",tab)
end
function F:SetChannel(tab,name,enabled)
    local key=ChannelKey(name)
    if not validTabs[tab] or not key then return end
    ns.db.tabFilters[tab].channels[key]=not not enabled
    if enabled then ns.db.tabFilters[tab].types.channels=true end
    ns:Fire("MC_FILTERS",tab)
end
function F:Reset(tab)
    if not validTabs[tab] then return end
    ns.db.tabFilters[tab]=nil
    self:Initialize(); ns:Fire("MC_FILTERS",tab)
end
function F:SetAll(tab,enabled)
    if not validTabs[tab] then return end
    local rule=ns.db.tabFilters[tab]
    for _,typ in ipairs(self.Types) do rule.types[typ.key]=not not enabled end
    if enabled then rule.channels={} end
    ns:Fire("MC_FILTERS",tab)
end
function F:ConversationMode()
    if not self:Allows("whisper","whisper") or not self:Allows("whisper","bnet") then return false end
    for _,typ in ipairs(self.Types) do
        if typ.key~="whisper" and typ.key~="bnet" and self:Allows("whisper",typ.key) then return false end
    end
    return true
end
function F:JoinedChannels()
    local out={}
    if GetChannelList then
        local entries={GetChannelList()}
        for i=1,#entries,3 do
            if type(entries[i+1])=="string" and not ns.IsSecret(entries[i],entries[i+1]) then
                out[#out+1]={id=entries[i],name=entries[i+1]}
            end
        end
    end
    return out
end
ns:On("MC_INIT",function() F:Initialize() end)
