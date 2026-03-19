# iLifeDesign

Ein persönlicher Lebensplaner für iOS, der Ihnen hilft, Ihre Ziele strukturiert zu verwirklichen.

## 🎯 Features

- **9-Phasen-System** für strukturiertes Vorgehen
- **Aufgaben-Management** mit Fortschrittsverfolgung  
- **Lebensbereiche** organisieren
- **Intuitive Benutzeroberfläche** mit SwiftUI
- **Lokale Datenspeicherung** mit SwiftData für Privatsphäre

## 📱 Technische Details

- **Plattform:** iOS 17.0+
- **Framework:** SwiftUI + SwiftData
- **Sprache:** Swift 5.9+
- **Architektur:** MVVM mit SwiftData Models

## 🏗️ Projektstruktur

```
iLifeDesign/
├── iLifeDesignApp.swift          # App Entry Point
├── Models/
│   ├── VorhabenModel.swift       # Hauptdatenmodell
│   └── AufgabeModel.swift        # Aufgaben-Datenmodell
├── Views/
│   ├── VorhabenListeView.swift   # Hauptliste der Vorhaben
│   ├── AufgabenListeView.swift   # Aufgaben-Detailansicht
│   ├── VorhabenEditor.swift      # Bearbeitung von Vorhaben
│   ├── PhasenListeView.swift     # Phasen-Übersicht
│   └── LebensbereicheView.swift  # Lebensbereiche-View
└── Components/
    ├── CompactVorhabenCard.swift # Kompakte Karten-Darstellung
    └── SymbolPickerView.swift    # Symbol-Auswahl
```

## 🚀 App Store Vorbereitung

### ✅ Completed
- Kritische Bug Fixes (Force Unwrapping entfernt)
- Sichere Error Handling implementiert
- SwiftData Crash-Resistenz verbessert
- Preview-Code stabilisiert

### 🔄 Next Steps
1. Bundle Identifier konfigurieren
2. Code Signing einrichten
3. App Icon erstellen (1024x1024)
4. Screenshots für App Store
5. App Store-Beschreibung verfassen
6. TestFlight Upload

## 📄 Lizenz

© 2024 Sandra Sulzberger. All rights reserved.

## 🛠️ Entwicklung

### Setup
1. Xcode 15.0+ erforderlich
2. iOS 17.0+ Deployment Target
3. Keine externen Dependencies

### Build
```bash
# Development Build
Product → Build (⌘+B)

# Archive für App Store
Product → Archive (⌘+R)
```

### Testing
Alle SwiftData-Operationen sind nun crash-sicher und für den App Store geeignet.
