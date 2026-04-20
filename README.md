# Fussball App

iOS-App zur Verwaltung einer Fussball-Aufstellung. Gebaut mit SwiftUI, keine externen Dependencies.

## Features

- Formationen: 4-4-2 · 4-3-3 · 3-5-2 · 4-2-3-1
- Grünes Spielfeld mit Positionen (TW, ABW, MIT, STU)
- Spieler per Tap zuweisen oder entfernen
- Bank zeigt nicht eingeteilte Spieler
- Aufstellung wird gespeichert (UserDefaults)
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
FussballApp.xcodeproj/   ← Xcode-Projekt
FussballApp/
  App/
    FussballAppApp.swift     ← Einstiegspunkt
  Models/
    Formation.swift          ← Formationen & Positionen
    LineupStore.swift        ← State + UserDefaults
  Views/
    ContentView.swift        ← Haupt-View
    PitchView.swift          ← Spielfeld
    PitchLines.swift         ← Feldlinien (Canvas)
    PlayerChip.swift         ← Spieler-Chip
    PlayerPickerSheet.swift  ← Spieler-Auswahl Sheet
    BenchView.swift          ← Bank
  Assets.xcassets/
```
