-- Moteve Chat - UI strings
local _, ns = ...

local hu = {
    TAB_ALL = "Mind",
    TAB_WHISPER = "Whisper",
    TAB_GUILD = "Guild",
    TAB_GROUP = "Csapat",
    TAB_CHANNELS = "Csatornák",
    TAB_SYSTEM = "Rendszer",
    COPY_TITLE = "LINK MÁSOLÁSA",
    COPY_HINT = "Ctrl+C a másoláshoz  ·  Esc bezárja",
    NEWEST = "Legújabb",
    NO_WHISPERS = "Még nincs whisper-beszélgetés.",
    PICK_CONVO = "Válassz beszélgetést balra.",
    N_MESSAGES = "%d üzenet",
    REPLY_HINT = "Kattints ide, vagy nyomj Entert a válaszhoz",
    CONVO_HINT = "Bal klikk: megnyitás  ·  Jobb klikk: törlés",
    DELETE_CONVO = "Törlöd a beszélgetést vele: %s?",
    YOU = "te",
    LANG_SET = "nyelv: magyar",
    BLIZZ_HIDDEN = "a játék alap chatablakai rejtve. Írd be: /reload",
    BLIZZ_SHOWN = "a játék alap chatablakai újra látszanak. Írd be: /reload",
    NO_ERRORS = "nincs rögzített hiba",
    MOVE_HINT = "Húzás: mozgatás  ·  jobb alsó sarok: átméretezés",
    HELP = {
        "/mc lang hu|en    nyelv",
        "/mc blizzard      a játék alap chatablakainak elrejtése / visszaállítása",
        "/mc reset         ablak alaphelyzetbe",
        "/mc clear         az aktuális fül törlése",
        "/mc errors        utolsó hibák",
        "Kék linkre kattintás: másolás",
    },
}

local en = {
    TAB_ALL = "All",
    TAB_WHISPER = "Whisper",
    TAB_GUILD = "Guild",
    TAB_GROUP = "Group",
    TAB_CHANNELS = "Channels",
    TAB_SYSTEM = "System",
    COPY_TITLE = "COPY LINK",
    COPY_HINT = "Ctrl+C to copy  ·  Esc closes",
    NEWEST = "Newest",
    NO_WHISPERS = "No whisper conversations yet.",
    PICK_CONVO = "Pick a conversation on the left.",
    N_MESSAGES = "%d messages",
    REPLY_HINT = "Click here or press Enter to reply",
    CONVO_HINT = "Left-click: open  ·  Right-click: delete",
    DELETE_CONVO = "Delete the conversation with %s?",
    YOU = "you",
    LANG_SET = "language: English",
    BLIZZ_HIDDEN = "default chat windows hidden. Type: /reload",
    BLIZZ_SHOWN = "default chat windows visible again. Type: /reload",
    NO_ERRORS = "no errors logged",
    MOVE_HINT = "Drag: move  ·  bottom-right corner: resize",
    HELP = {
        "/mc lang hu|en    language",
        "/mc blizzard      hide / restore the default chat windows",
        "/mc reset         reset window position",
        "/mc clear         clear the current tab",
        "/mc errors        last errors",
        "Click a blue link: copy it",
    },
}


-- Tab routing settings
hu.FILTER_TITLE = "Fül beállításai"
en.FILTER_TITLE = "Tab settings"
hu.FILTER_HINT = "Jelöld be, milyen üzenetek jelenjenek meg ezen a fülön."
en.FILTER_HINT = "Choose which messages appear in this tab."
hu.FILTER_TAB_HINT = "Bal klikk: megnyitás · Jobb klikk: üzenetszűrők"
en.FILTER_TAB_HINT = "Left-click: open · Right-click: message filters"
hu.FILTER_JOINED = "Aktív csatornák"
en.FILTER_JOINED = "Joined channels"
hu.FILTER_SAVED = "Automatikusan mentve. A közelmúlt üzeneteire is érvényes."
en.FILTER_SAVED = "Saved automatically. Also applies to recent messages."
hu.FILTER_WHISPER_NOTE = "Vegyes szűrésnél a beszélgetésnézet helyett üzenetlista látszik."
en.FILTER_WHISPER_NOTE = "Mixed filters switch conversations to a message list."
hu.FILTER_ALL = "Mind be"
en.FILTER_ALL = "Select all"
hu.FILTER_NONE = "Mind ki"
en.FILTER_NONE = "Select none"
hu.FILTER_RESET = "Alaphelyzet"
en.FILTER_RESET = "Restore defaults"
hu.FILTER_SAY = "Helyi beszéd /say"
en.FILTER_SAY = "Local speech /say"
hu.FILTER_YELL = "Kiáltás /yell"
en.FILTER_YELL = "Shouts /yell"
hu.FILTER_EMOTE = "Érzelmek /emote"
en.FILTER_EMOTE = "Emotes"
hu.FILTER_WHISPER = "Privát üzenetek"
en.FILTER_WHISPER = "Whispers"
hu.FILTER_BNET = "Battle.net privát"
en.FILTER_BNET = "Battle.net whispers"
hu.FILTER_GUILD = "Guild üzenetek"
en.FILTER_GUILD = "Guild messages"
hu.FILTER_OFFICER = "Officer üzenetek"
en.FILTER_OFFICER = "Officer messages"
hu.FILTER_PARTY = "Party / csapat"
en.FILTER_PARTY = "Party messages"
hu.FILTER_RAID = "Raid és figyelmeztetés"
en.FILTER_RAID = "Raid and warnings"
hu.FILTER_INSTANCE = "Dungeon / instance"
en.FILTER_INSTANCE = "Instance messages"
hu.FILTER_CHANNELS = "Nyilvános csatornák"
en.FILTER_CHANNELS = "Public channels"
hu.FILTER_SYSTEM = "Rendszerüzenetek"
en.FILTER_SYSTEM = "System messages"
hu.FILTER_LOOT = "Zsákmány / loot"
en.FILTER_LOOT = "Loot"
hu.FILTER_MONEY = "Pénz és currency"
en.FILTER_MONEY = "Money and currency"
hu.FILTER_XP = "XP és honor"
en.FILTER_XP = "XP and honor"
hu.FILTER_REPUTATION = "Hírnév / reputation"
en.FILTER_REPUTATION = "Reputation"
hu.FILTER_SKILL = "Szakmák és skillek"
en.FILTER_SKILL = "Professions and skills"
hu.FILTER_ACHIEVEMENT = "Achievementek"
en.FILTER_ACHIEVEMENT = "Achievements"
hu.FILTER_ADDON = "Addon / egyéb kiírások"
en.FILTER_ADDON = "Addon / other output"
table.insert(hu.HELP, "/mc szurok       az aktuális fül üzenetszűrői")
table.insert(en.HELP, "/mc filters      message filters for the current tab")


-- Custom tabs
hu.TAB_ADD = "Új fül"
en.TAB_ADD = "New tab"
hu.TAB_CREATE = "Létrehozás"
en.TAB_CREATE = "Create"
hu.TAB_DELETE = "Fül törlése"
en.TAB_DELETE = "Delete tab"
hu.TAB_CANCEL = "Mégse"
en.TAB_CANCEL = "Cancel"
hu.TAB_NAME_HINT = "Add meg az új fül nevét (legfeljebb 24 karakter)."
en.TAB_NAME_HINT = "Enter a tab name (up to 24 characters)."
hu.TAB_NAME_INVALID = "A név 1–24 karakter hosszú lehet."
en.TAB_NAME_INVALID = "The name must contain 1–24 characters."
hu.TAB_NAME_DUPLICATE = "Már van ilyen nevű fül."
en.TAB_NAME_DUPLICATE = "A tab with this name already exists."
hu.TAB_LIMIT = "Legfeljebb 12 fül hozható létre."
en.TAB_LIMIT = "You can have up to 12 tabs."
hu.TAB_LAST = "Az utolsó megmaradó fül nem törölhető."
en.TAB_LAST = "You cannot delete the last remaining tab."
hu.TAB_NOT_FOUND = "Ez a fül már nem létezik."
en.TAB_NOT_FOUND = "This tab no longer exists."
hu.TAB_DELETE_CONFIRM = "Törlöd ezt a fület: %s?\nA mentett privát beszélgetések megmaradnak."
en.TAB_DELETE_CONFIRM = "Delete the tab %s?\nSaved private conversations are kept."
table.insert(hu.HELP, "/mc ujful        új chatfül létrehozása")
table.insert(en.HELP, "/mc addtab        create a chat tab")

ns.LOCALES = { hu = hu, en = en }
