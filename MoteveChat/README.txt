Moteve Chat 0.3.0 - WoW Forever (Interface 16001)

TELEPÍTÉS
  A "MoteveChat" mappát másold a WoW Forever Interface\AddOns mappájába, majd /reload.

MIT TUD
  Chatablak
    - Az eredeti áttetsző kék–lila felület, felfelé elhalványuló háttérrel,
      jól elkülönülő, 32 egység magas fülekkel.
      A régi sorok egy idő után elhalványulnak (görgetésre visszajönnek).
    - Fülek: Mind, Whisper, Guild, Csapat, Csatornák, Rendszer.
      Minden fül tartalma külön beállítható, a "Mind" fülé is.
      Az addonok és egyéb típusjelzés nélküli kiírások külön kapcsolhatók.
      A Guild és a Csapat fülön lila szám jelzi az olvasatlan üzeneteket.
    - Nevek osztályszínnel; névre kattintás = whisper, mint a játékban.
    - Item / spell linkre vitt egér: tooltip.
    - Görgő: görgetés, Shift + görgő: ugrás a tetejére / aljára, "Legújabb" gomb az aljára.
    - Húzás a Moteve Chat címsoron: mozgatás. A fülek kattintása nem indít húzást. Jobb alsó sarok: átméretezés.
  Linkek
    - A webcímek (https://..., www..., valami.com/...) kék, kattintható linkek lesznek.
      Kattintásra felugrik egy kis ablak a kijelölt linkkel: Ctrl+C, és kész.
      (Az addonok nem írhatnak közvetlenül a vágólapra, ezért kell ez az egy lépés.)
  Whisper
    - Messenger-szerű nézet: balra a partnerek (legutóbbi üzenet, lila pötty = olvasatlan),
      jobbra a beszélgetés buborékokban, időponttal. A saját üzeneteid lilák, jobbra.
    - Karakterenként mentve: /reload és kilépés után is megmarad (beszélgetésenként 100 üzenet).
    - A beszélgetésre kattintva vagy Entert nyomva a Whisper fülön a kiválasztott partnernek írsz.
    - Jobb klikk egy partneren: a beszélgetés törlése.
  Írásmező
    - A játék saját chat-beviteli mezője, átszínezve és az ablak aljára helyezve,
      így minden parancs és billentyű ugyanúgy működik.

PARANCSOK (/mc)
  /mc lang hu|en    nyelv
  /mc blizzard      a játék alap chatablakainak elrejtése / visszaállítása (utána /reload)
  /mc reset         ablak alaphelyzetbe
  /mc clear         az aktuális fül törlése
  /mc errors        utolsó hibák

TUDNIVALÓK
  - A játék alap chatablakai csak rejtve vannak (átlátszók), nem törlődnek; /mc blizzard visszahozza.
    A harci napló (Combat Log) ablak is rejtve van.
  - Dungeonban / raidben harc közben a kliens elrejti az üzenetek tartalmát az addonok elől.
    Ilyenkor az üzenetek feldolgozás nélkül jelennek meg (linkmásolás nélkül), és a whisper-
    nézetbe sem kerülnek be. Harc után minden a megszokott módon működik.
  - Battle.net whisperek a whisper-nézetben az adott belépés alatt működnek megbízhatóan.
  - Betűtípusok: Marcellus és Barlow (SIL Open Font License, a Fonts mappában a licenccel).


ÚJDONSÁGOK A 0.2.0 VERZIÓBAN
  - Nagyobb kattintható fülek, külön mozgatósáv, lila aktív jelzés.
  - Keskeny ablakban a fülek automatikusan több sorba rendeződnek.
  - Jobb klikk bármelyik fülön: annak az üzenetszűrői.
  - A fejléc jobb oldali ... gombja vagy /mc szurok (/mc filters) az aktuális fül szűrőit nyitja.
  - 19 üzenetcsoport külön kapcsolható bármelyik fülön: helyi beszéd, kiáltás, emote,
    whisper, Battle.net, guild, officer, party, raid, instance, nyilvános csatornák,
    rendszer, loot, pénz/currency, XP/honor, reputation, skill, achievement, addon/egyéb.
  - A csatlakoztatott csatornák (General, Trade stb.) külön is szűrhetők. Ez nem lép ki a csatornából.
  - Egy csatorna bekapcsolása bekapcsolja a nyilvános csatornák üzenetcsoportját is.
  - Minden módosítás automatikusan mentődik és a legutóbbi 500 beérkezett üzenetből
    azonnal újraépíti az adott fül tartalmát. A normál chatelőzmény nem marad meg /reload után.
  - A Whisper fül alaphelyzetben a korábbi, mentett beszélgetésnézetet mutatja.
    Más üzenettípusokkal keverve vagy egy privát típus kikapcsolásakor üzenetlistát használ.
    Az Alaphelyzet gombbal visszakapható a beszélgetésnézet. A mentett privát beszélgetések megmaradnak.
  - A beállítások ablakában a Mind be, Mind ki és Alaphelyzet gombok csak a kiválasztott fület módosítják.
  - A címsáv ... gombja az aktív fül szűrőit mutatja; a beállítóablak Esc-pel is bezárható.
  - Az alap WoW-chat szűrőitől függetlenül történik az események szétosztása.
    A natív chat típussal ellátott sorai nem kerülnek be másodszor.
  - A szűrők a MoteveChatDB mentésbe kerülnek. A WTF mappát frissítéskor nem kell módosítani.

ELLENŐRZÉS
  A Lua-fájlok betöltése, a beállítások, a fülek rétegezése és tördelése, a szűrők,
  a 31 eseményhez tartozó útvonal, az előzmény újraépítése, a duplázás elkerülése,
  a whisper-nézet és az olvasatlan jelzések helyi WoW-szimulációban ellenőrizve.
  A WoW-kliensben a tényleges kattintás és megjelenés még ellenőrizendő.

0.2.1 – Az eredeti kék–lila színek és a keret nélküli, áttetsző háttér visszaállítva.
A nagyobb fülek, a fülenkénti és csatornánkénti szűrők, a mentés és a többi 0.2.0 funkció megmaradt.


0.3.0 – SAJÁT FÜLEK HOZZÁADÁSA ÉS TÖRLÉSE
  - Új fül: a chat fejlécében a + gomb, a szűrőablakban a + gomb, vagy /mc ujful (/mc addtab).
  - Adj meg egy 1–24 karakter hosszú nevet, majd Enter vagy Létrehozás.
  - Az új fülre vált az addon és megnyitja annak szűrőit. Kezdetben minden üzenettípus ki van kapcsolva.
  - Jobb klikk a fülön: üzenettípusok és csatornák beállítása a megszokott módon.
  - Fül törlése: a fül beállításaiban a Fül törlése gomb. Ezután megerősítést kér.
  - Az alapból meglevő fülek is törölhetők; törlés után /reload-kor sem jönnek vissza.
  - Az utolsó megmaradó fül nem törölhető. Egyszerre legfeljebb 12 fül lehet.
  - A törölt aktív fül helyett egy megmaradó fül lesz kiválasztva.
  - A mentett privát beszélgetéseket a fül törlése nem törli.
    Egy később létrehozott, Whisper nevű saját fül normál üzenetlistaként működik.
  - A nevek, a fülek listája és a hozzájuk tartozó szűrők automatikusan mentődnek.
  - A hosszú nevek a fülsoron rövidítve jelenhetnek meg; föléjük vitt egérrel a teljes név látszik.
  - Több fül esetén a sorok tördelődnek, és az ablak szükség esetén nő, hogy a chatnek is maradjon helye.
  - Az eredeti áttetsző kék–lila megjelenés változatlan.

  Ellenőrizve helyi Lua/WoW-szimulációban: névellenőrzés, gombok és Enter, törlési megerősítés,
  saját és alapfülek törlése, szűrés, mentés betöltése, törlés utáni váltás, 12 füles korlát,
  keskeny ablak és az utolsó fül védelme. A tényleges játékbeli felület külön ellenőrizendő.
