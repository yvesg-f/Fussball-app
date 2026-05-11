# Tactix — Fussball Taktik App

Native iOS-App zur Verwaltung von Fussball-Aufstellungen für ein Team. Gebaut mit SwiftUI und StoreKit 2, keine externen Abhängigkeiten.

## Was die App kann

**Team & Spieler**
- Ein Team mit bis zu 25 Spielern definieren
- Spielernamen jederzeit bearbeiten oder löschen (doppelte Namen werden verhindert)
- Spieler bleiben über alle Aufstellungen gleich

**Aufstellungen**
- Bis zu 2 benannte Aufstellungen gratis (unbegrenzt mit Pro)
- Aufstellungen umbenennen (Bleistift-Icon) und löschen
- Jede Aufstellung hat eigene Formation, Positionen und Spielerzuteilungen
- Formationswechsel fragt vor dem Zurücksetzen der Positionen nach Bestätigung
- Aufstellungen unabhängig voneinander bearbeiten und speichern

**Spielfeld**
- 8 Formationen: 4-4-2 · 4-3-3 · 3-5-2 · 4-2-3-1 · 5-3-2 · 4-1-4-1 · 3-4-3 · 4-5-1
- Grünes Spielfeld mit Feldlinien
- Spieler per Drag frei auf dem Feld positionieren
- Spieler antippen → auswechseln, Kapitän setzen oder von der Bank tauschen
- Torwart-Chip in Gelb, Feldspieler in Weiss
- Kapitän-Markierung (Krone)

**Feldzonen**
- 5 Feldzonen einblendbar: Links · Halbspur L · Zentrum · Halbspur R · Rechts

**Bank**
- Spieler haben 3 Status: Startelf · Bank · Nicht dabei
- Bank-Spieler über `+` hinzufügen, über `−` entfernen
- „Nicht dabei"-Spieler können im Laufe des Spiels nicht eingewechselt werden
- Tauschen mit einem Bankspieler direkt über den Auswahl-Panel

**Standards & Taktik**
- Bis zu 5 Standards gratis (unbegrenzt mit Pro)
- Typen: Eckball links/rechts · Freistoß · Elfmeter · Einwurf · **Freie Taktik**
- Freie Taktik zeigt das **komplette Spielfeld** für eigene Formations- oder Spielzug-Skizzen
- Eigene Spieler auf dem Halbfeld oder Gesamtfeld platzieren und verschieben
- **Gegner-Marker** (rote X) platzieren, verschieben und entfernen
- Ball-Position frei verschiebbar
- Laufwege zeichnen: Lauf (blau) · Flanke (orange) · Block (rot)
- Letzten Pfeil rückgängig machen
- Name des Standards wird vor dem Speichern erzwungen

**Taktiknotizen**
- Freitext-Notizen pro Team speichern

**Einstellungen** (Zahnrad-Icon im Hauptmenü)
- **Sprache**: Deutsch · English · Español · Français · Italiano · Português · Nederlands · Türkçe · Polski · العربية — wechselt sofort, wird gespeichert
- **Darstellung**: System · Hell · Dunkel — wird app-weit angewendet

**Tactix Pro** (einmaliger Kauf, kein Abo)
- Unbegrenzte Aufstellungen
- Unbegrenzte Standards
- Alle zukünftigen Pro-Features inklusive
- Kauf über Apple IAP, Restore-Funktion vorhanden

**Allgemein**
- Alles wird lokal gespeichert (UserDefaults, kein Account nötig)
- Datenmigration von älteren App-Versionen

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
4. Bundle Identifier: `com.tactixapp.ios`

### 6. StoreKit-Konfiguration aktivieren (für IAP-Tests im Simulator)

1. In Xcode: **Product → Scheme → Edit Scheme…**
2. Tab **Run** → **Options**
3. Bei **StoreKit Configuration** die Datei `Tactix.storekit` auswählen

### 7. iPhone verbinden

1. iPhone per USB-Kabel an den Mac anschliessen
2. Im iPhone-Dialog „Diesem Computer vertrauen" antippen und Passcode eingeben
3. In Xcode oben links beim Geräteselektor dein iPhone auswählen (nicht „iPhone 16 Simulator")

### 8. App starten

**⌘R** drücken oder den ▶ Play-Button klicken.

Xcode baut die App und lädt sie direkt aufs iPhone. Beim ersten Mal dauert das 1–2 Minuten.

> **Wichtig nach Icon-Änderungen:** Zuerst `⇧⌘K` (Clean Build Folder), dann App vom Gerät löschen, dann neu installieren — sonst zeigt iOS das alte Icon aus dem Cache.

### 9. App auf dem iPhone freischalten (einmalig)

Nach der Installation erscheint die App, lässt sich aber noch nicht öffnen.

1. iPhone: **Einstellungen → Allgemein → VPN & Geräteverwaltung**
2. Unter „Entwickler-App" deine Apple ID antippen
3. **Vertrauen** antippen → bestätigen

Danach öffnet sich die App normal — und bleibt 7 Tage installiert (Free Account). Danach einfach nochmal ⌘R in Xcode.

---

## Projektstruktur

```
FussballApp.xcodeproj/
Tactix.storekit                     ← StoreKit-Testkonfiguration (Simulator)
FussballApp/
  App/
    FussballAppApp.swift            ← Einstiegspunkt, AppSettings + PurchaseManager
  Models/
    Formation.swift                 ← 8 Formationen mit Reihen-Definitionen
    Team.swift                      ← Team & SavedLineup Datenmodell
    AppStore.swift                  ← Team-Persistenz (UserDefaults)
    LineupStore.swift               ← Aufstellungs-State pro Lineup-Index
    SetPiece.swift                  ← Standards-Datenmodell inkl. Gegner-Positionen
    PurchaseManager.swift           ← StoreKit 2: Kauf, Restore, Entitlement-Check
    AppSettings.swift               ← Sprache + Hell/Dunkel, UserDefaults-Persistenz
    Translations.swift              ← 70+ UI-Strings in 10 Sprachen
  Views/
    HomeView.swift                  ← Hauptmenü: Aufstellungen, Zahnrad-Button
    TeamSetupView.swift             ← Spieler hinzufügen / bearbeiten
    ContentView.swift               ← Aufstellungs-View mit Formation & Bank
    PitchView.swift                 ← Spielfeld mit Drag & Drop
    PitchLines.swift                ← Feldlinien ganzes Spielfeld (Canvas)
    PitchZone.swift                 ← Feldzonen-Definitionen
    HalfPitchLines.swift            ← Halbfeld-Linien für Standards
    PlayerChip.swift                ← Spieler-Chip
    BenchView.swift                 ← Bank (Bank / Nicht dabei) mit Tausch-Panel
    TacticNotesView.swift           ← Taktiknotizen
    SetPieceListView.swift          ← Standards-Übersicht
    SetPieceEditorView.swift        ← Standards-Editor (Halbfeld & Gesamtfeld, Pfeile)
    ProUpgradeView.swift            ← Tactix Pro Kauf-Screen
    SettingsView.swift              ← Sprache & Darstellung
  Assets.xcassets/
    AppIcon.appiconset/             ← App-Icon (1024×1024, RGB, kein Alpha)
```
