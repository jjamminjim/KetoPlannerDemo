
# KetoPlannerDemo (WWDC 2025 Demo Starter Kit)

A minimal, local-only SwiftUI demo using **Foundation Models** (on-device), **SwiftData with Model Inheritance**, **C++ Interop**, and **modern Swift concurrency** (`actor`, `nonisolated`, and optional `@concurrent`).

This starter kit is designed for live conference demos. It ships as source files you can drop into a fresh **iOS App** project in Xcode.

---

## 1) Create a new Xcode project
1. Open **Xcode 16+**.
2. **File → New → Project… → App** (iOS).
3. Product Name: `KetoPlannerDemo`
4. Interface: **SwiftUI**
5. Language: **Swift**
6. Storage: **SwiftData**: ✅ (checked)
7. Save the project somewhere convenient.

> Ensure your run destination is an iOS 18 (or later) device/simulator that supports Apple Intelligence features.

---

## 2) Add the provided source files
1. In Finder, open this folder.
2. Drag the entire `Sources` folder into your Xcode project root (choose **Copy items if needed**).

File map:
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

## 3) Configure bridging + ObjC++
1. Select the **app target** → **Build Settings**.
2. Set **Objective-C Bridging Header** to: `KetoPlannerDemo/Sources/Config/BridgingHeader.h`
   - If your project path differs, point it to the correct relative path.
3. Ensure `CarbBridge.mm` file type is **Objective-C++ Source** (Xcode should infer from `.mm`).

No other special settings required.

---

## 4) Add Foundation Models framework
1. **Project** → **App Target** → **General** → **Frameworks, Libraries, and Embedded Content**.
2. Add **FoundationModels.framework** (Apple’s Foundation Models framework).

---

## 5) Build & Run
- Run the app. Type a message to the chatbot.
- Type: `netCarbs 10 3 2` to trigger the C++ path (net carb calc), then the on-device LLM suggestion.
- Tap **History** to show saved messages (SwiftData).

---

## Notes
- The app guards on-device availability and will show an error if Apple Intelligence is not available.
- The `@concurrent` attribute is wrapped in `#if compiler(>=6.0)` so it compiles on older toolchains and lights up on newer compilers.

Happy presenting!
