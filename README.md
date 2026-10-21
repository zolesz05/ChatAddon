# Moteve Chat

**Moteve Chat** egy World of Warcraft chat-addon a WoW Forever klienshez. Áttetsző kék–lila felületen, jól elkülönített fülekkel rendezi az üzeneteket. Minden fülhöz saját üzenet- és csatornaszűrők állíthatók, új fülek is létrehozhatók, a privát beszélgetések pedig külön nézetben követhetők.

**Aktuális verzió: 0.3.0**

[Legfrissebb addon letöltése (ZIP)](downloads/MoteveChat.zip?raw=true)

A `downloads` mappában csak a legfrissebb telepíthető `MoteveChat.zip` marad. Frissítéskor ugyanaz a letöltési link használható.

## Telepítés

1. Töltsd le és csomagold ki a fenti ZIP-et.
2. Másold a `MoteveChat` mappát a játék `Interface/AddOns/` könyvtárába.
3. A karakterválasztón engedélyezd a **Moteve Chat** addont, majd lépj be.
4. A fejléc `…` gombjával vagy a `/mc szurok` paranccsal nyithatod meg az aktuális fül szűrőit.

```text
Interface/
└── AddOns/
    └── MoteveChat/
        ├── MoteveChat.toc
        ├── Core.lua
        ├── Window.lua
        ├── Fonts/
        └── Textures/
```

A mappanevet tartsd meg; a `MoteveChat.toc` közvetlenül a `MoteveChat` mappában legyen. Új addon telepítése után indítsd újra a klienst, ha a listában még nem jelenik meg. Frissítés után `/reload` használható. A `WTF` könyvtárat tartsd meg, mert abban vannak a mentett beállítások és privát beszélgetések.

## Funkciók

- Áttetsző sötétkék háttér, lila kiemelések, magyar és angol kezelőfelület.
- Nagyobb kattintható fülek, külön mozgatósáv; keskeny ablakban a fülek több sorba rendeződnek.
- Fülenként állítható üzenettípusok és csatornák.
- Saját fülek hozzáadása és törlése, automatikusan mentett nevekkel és szűrőkkel.
- Osztályszínű nevek; kattintás a néven privát üzenethez.
- Item- és spell-linkek súgóbuborékkal, másolható webcímek.
- Partnerlista és üzenetbuborékos whisper-nézet, időponttal és olvasatlan jelöléssel.
- Mozgatható, átméretezhető ablak; görgetés és ugrás a legújabb üzenetekhez.
- A játék saját chat-beviteli mezője, a szokásos parancsokkal és billentyűkkel.

## Fülek és szűrés

Alapból a **Mind, Whisper, Guild, Csapat, Csatornák és Rendszer** fülek érhetők el. A Mind fül tartalma is szabadon szűrhető.

**Jobb kattintás egy fülön** megnyitja annak szűrőit. Ugyanezt az aktív fülhöz a fejléc `…` gombja vagy a `/mc szurok` parancs is megteszi. A módosítás azonnal mentődik, és a legutóbbi 500 beérkezett üzenetből újraépíti a fül tartalmát.

A 19 külön kapcsolható csoport: helyi beszéd, kiáltás, emote, whisper, Battle.net, guild, officer, party, raid, instance, nyilvános csatornák, rendszer, loot, pénz/currency, XP/honor, reputation, skill, achievement és addon/egyéb üzenetek.

A csatlakoztatott nyilvános csatornák, például a General és Trade, külön is szűrhetők. Egy csatorna elrejtése nem léptet ki abból a csatornából. A **Mind be**, **Mind ki** és **Alaphelyzet** gombok csak a kiválasztott fület módosítják.

### Saját fülek

1. Kattints a fejléc `+` gombjára, vagy írd be: `/mc ujful`.
2. Adj meg egy 1–24 karakteres nevet, majd Enter vagy **Létrehozás**.
3. Az addon átvált az új fülre és megnyitja a szűrőit. Kezdetben minden üzenettípus ki van kapcsolva; válaszd ki, mi jelenjen meg rajta.

Fület a saját szűrőablakában a **Fül törlése** gombbal, megerősítés után törölhetsz. Az alapfülek is eltávolíthatók, és újratöltés után sem jönnek vissza. Egyszerre legfeljebb **12 fül** lehet; az utolsó megmaradó fül nem törölhető. A fül törlése a mentett privát beszélgetéseket nem törli.

## Privát beszélgetések és linkek

A Whisper fül alapbeállítása beszélgetésnézetet mutat: balra a partnerek, jobbra az üzenetek. A saját üzenetek jobbra igazítva, lilán jelennek meg. Enterrel a kiválasztott partnernek írhatsz, jobb kattintással egy partneren törölheted a beszélgetését.

A privát előzmények karakterenként, beszélgetésenként legfeljebb **100 üzenettel** mentődnek. A normál chatlista előzménye újratöltés után nem marad meg. Ha a Whisper fül szűrőit más üzenettípusokkal kevered, a fül normál üzenetlistára válthat; az **Alaphelyzet** visszaállítja a beszélgetésnézetet.

Egy webcímre kattintva megnyílik a másolóablak kijelölt szöveggel. **Ctrl+C**-vel másolhatod; az addon nem ír közvetlenül a vágólapra.

## Kezelés és parancsok

| Kezelés | Művelet |
| --- | --- |
| Címsor húzása | Ablak mozgatása |
| Jobb alsó sarok húzása | Átméretezés |
| Egérgörgő | Üzenetek görgetése |
| Shift + egérgörgő | Ugrás a lista tetejére vagy aljára |
| Legújabb gomb | Visszatérés a legújabb üzenetekhez |
| Jobb kattintás egy fülön | A fül szűrői |

| Parancs | Művelet |
| --- | --- |
| `/mc lang hu` | Magyar kezelőfelület |
| `/mc lang en` | Angol kezelőfelület |
| `/mc szurok` vagy `/mc filters` | Aktív fül szűrői |
| `/mc ujful` vagy `/mc addtab` | Új fül létrehozása |
| `/mc blizzard` | A játék alap chatablakainak elrejtése / visszaállítása; utána `/reload` |
| `/mc reset` | Ablak alaphelyzetbe állítása |
| `/mc clear` | Az aktuális fül üzeneteinek ürítése |
| `/mc errors` | Rögzített hibák kiírása |

## Kompatibilitás és tudnivalók

A célkliens **WoW Forever**, a TOC Interface-értéke **16001**. A beállítások a `MoteveChatDB`, a karakterhez tartozó adatok a `MoteveChatChar` változóban maradnak meg.

- A játék alap chatablakai, köztük a Combat Log, csak el vannak rejtve. A `/mc blizzard` paranccsal visszaállíthatók.
- Dungeonban vagy raidben, harc közben a kliens elrejtheti az üzenetek tartalmát az addon elől. Ilyenkor azok feldolgozás és linkmásolás nélkül jelenhetnek meg, a külön whisper-előzménybe pedig nem kerülnek be.
- Battle.net beszélgetések a külön whisper-nézetben az adott belépés alatt működnek megbízhatóan.
- Az újonnan létrehozott, Whisper nevű saját fül normál üzenetlistaként működik.

A csomag a jelenleg telepített **0.3.0-s verzió** másolata. Feltöltés előtt a fájlok azonosságát, a Lua-szintaxist és a ZIP tartalmát ellenőriztük. Az élő játékbeli viselkedést a feltöltéskor nem teszteltük újra.

## Hibajelentés

Hibát az [Issues oldalon](https://github.com/zolesz05/ChatAddon/issues) jelezhetsz. Add meg a kliens és az addon verzióját, az érintett fület és szűrőbeállításokat, valamint a reprodukálás lépéseit. A `/mc errors` kimenete és képernyőkép segíthet.

## Forrás és csomagolás

A teljes addon a [MoteveChat](MoteveChat/) mappában található. A [részletes leírás és változásnapló](MoteveChat/README.txt) további működési részleteket tartalmaz. A Marcellus és Barlow betűtípusok SIL Open Font License fájljai a `MoteveChat/Fonts/` könyvtárban szerepelnek.

A legfrissebb telepíthető csomag frissítése a repository gyökeréből:

```sh
python tools/package_addon.py
```

A csomagoló ellenőrzi a TOC bejegyzéseit és a ZIP tartalmát, lecseréli a `downloads/MoteveChat.zip` fájlt, és eltávolítja a korábbi verziószámos addoncsomagokat ebből a mappából. A forrást, a ZIP-et és a README-t együtt kell feltölteni.
