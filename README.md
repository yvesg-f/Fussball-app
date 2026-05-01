# Aufstellung — Fussball Taktik App

Native iOS-App zur Verwaltung von Fussball-Aufstellungen für ein Team. Gebaut mit SwiftUI, keine externen Abhängigkeiten.

## Was die App kann

**Team & Spieler**
- Ein Team mit bis zu 25 Spielern definieren
- Spielernamen jederzeit bearbeiten oder löschen
- Spieler bleiben über alle Aufstellungen gleich

**Aufstellungen**
- Beliebig viele benannte Aufstellungen erstellen (Plan A, Plan B, Plan C …)
- Jede Aufstellung hat eigene Formation, Positionen und Spielerzuteilungen
- Aufstellungen unabhängig voneinander bearbeiten und speichern

**Spielfeld**
- 8 Formationen: 4-4-2 · 4-3-3 · 3-5-2 · 4-2-3-1 · 5-3-2 · 4-1-4-1 · 3-4-3 · 4-5-1
- Grünes Spielfeld mit Feldlinien
- Spieler per Drag frei auf dem Feld positionieren
- Spieler antippen → auswechseln oder von der Bank tauschen
- Torwart-Chip in Gelb, Feldspieler in Weiss
- Kapitän-Markierung (Krone)

**Feldzonen**
- 5 Feldzonen einblendbar: Links · Halbspur L · Zentrum · Halbspur R · Rechts

**Standards**
- Eckball links/rechts, Freistoß, Elfmeter, Einwurf
- Spieler auf dem Halbfeld platzieren und verschieben
- Ball-Position frei verschiebbar
- Laufwege zeichnen (Lauf, Flanke, Block)
- Angriff- und Verteidigung-Phase

**Taktiknotizen**
- Freitext-Notizen pro Team speichern

**Allgemein**
- Alles wird lokal gespeichert (UserDefaults, kein Account nötig)
- Light & Dark Mode

---

## Auf dem MacBook installieren und aufs iPhone laden

### 1. Voraussetzungen

- **Xcode** aus dem Mac App Store installieren (kostenlos, ~12 GB)
- **Apple ID** — dieselbe, mit der du im App Store eingeloggt bist

### 2. Repo klonen

Terminal öffnen (Spotlight → "Terminal") und eingeben:

```bash
cd ~/Desktop
git clone https://github.com/yvesg-f/Fussball-app.git FussballApp
```

### 3. Projekt in Xcode öffnen

```bash
open ~/Desktop/FussballApp/FussballApp.xcodeproj
```

Oder in Xcode: **File → Open** → `FussballApp.xcodeproj` auswählen.

### 4. Apple ID in Xcode hinterlegen

1. **Xcode → Settings** (⌘,) → Tab **Accounts**
2. Auf **+** klicken → **Apple ID** → mit deiner Apple ID einloggen

### 5. Team setzen

1. Im Xcode-Navigator links auf **FussballApp** (blau, ganz oben) klicken
2. Tab **Signing & Capabilities** wählen
3. Bei **Team** deine Apple ID auswählen (z. B. „Yves Fricker (Personal Team)")
4. Bundle Identifier kann bleiben wie er ist

### 6. iPhone verbinden

1. iPhone per USB-Kabel an den Mac anschliessen
2. Im iPhone-Dialog „Diesem Computer vertrauen" antippen und Passcode eingeben
3. In Xcode oben links beim Geräteselektor dein iPhone auswählen (nicht „iPhone 16 Simulator")

### 7. App starten

**⌘R** drücken oder den ▶ Play-Button klicken.

Xcode baut die App und lädt sie direkt aufs iPhone. Beim ersten Mal dauert das 1–2 Minuten.

### 8. App auf dem iPhone freischalten (einmalig)

Nach der Installation erscheint die App, lässt sich aber noch nicht öffnen.

1. iPhone: **Einstellungen → Allgemein → VPN & Geräteverwaltung**
2. Unter „Entwickler-App" deine Apple ID antippen
3. **Vertrauen** antippen → bestätigen

Danach öffnet sich die App normal — und bleibt 7 Tage installiert (Free Account). Danach einfach nochmal ⌘R in Xcode.

---

## Projektstruktur

```
FussballApp.xcodeproj/
FussballApp/
  App/
    FussballAppApp.swift          ← Einstiegspunkt
  Models/
    Formation.swift               ← 8 Formationen mit Reihen-Definitionen
    Team.swift                    ← Team & SavedLineup Datenmodell
    AppStore.swift                ← Team-Persistenz (UserDefaults)
    LineupStore.swift             ← Aufstellungs-State pro Lineup-Index
    SetPiece.swift                ← Standards-Datenmodell
  Views/
    HomeView.swift                ← Hauptmenü (Aufstellungs-Übersicht)
    TeamSetupView.swift           ← Spieler hinzufügen / bearbeiten
    ContentView.swift             ← Aufstellungs-View mit Formation & Bank
    PitchView.swift               ← Spielfeld mit Drag & Drop
    PitchLines.swift              ← Feldlinien (Canvas)
    PitchZone.swift               ← Feldzonen-Definitionen
    HalfPitchLines.swift          ← Halbfeld-Linien für Standards
    PlayerChip.swift              ← Spieler-Chip
    BenchView.swift               ← Bank mit Tausch-Panel
    TacticNotesView.swift         ← Taktiknotizen
    SetPieceListView.swift        ← Standards-Übersicht
    SetPieceEditorView.swift      ← Standards-Editor mit Zeichnen
  Assets.xcassets/
    AppIcon.appiconset/           ← App-Icon (1024×1024)
```
