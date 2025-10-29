
# KetoPlannerDemo (WWDC 2025 Demo Starter Kit)

A minimal, local-only SwiftUI demo using **Foundation Models** (on-device), **SwiftData with Model Inheritance**, **C++ Interop**, and **modern Swift concurrency** (`actor`, `nonisolated`, and optional `@concurrent`).

This starter kit is designed for teh ICSCon 2025 conference demo. It can be used as a starting point **iOS App** project in Xcode.

---

## Build & Run
- Open the project in XCode
- Run the app.
- Type a message to the chatbot.
- Type: `netCarbs 10 3 2` to trigger the C++ path (net carb calc), then the on-device LLM suggestion.
- Tap **History** to show saved messages (SwiftData).

---

## File map
```
Sources/
├─ App.swift
├─ Models.swift
├─ AI.swift
├─ Views.swift
├─ Interop/
│  ├─ CarbBridge.h
│  ├─ CarbBridge.mm
│  └─ carbs.cpp
└─ Config/
   └─ BridgingHeader.h   (optional consolidated header)
```

---

## Notes
- The app guards on-device availability and will show an error if Apple Intelligence is not available.
- The `On-Device Foundation Models`, `SwiftData with Model Inheritance` and the `@concurrent` attribute are only avaliable in iOS 26 or later.
