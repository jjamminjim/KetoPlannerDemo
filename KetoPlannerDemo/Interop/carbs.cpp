
// carbs.cpp
#include <algorithm>


/*
 [TP] Swift ⟷ C++ Interoperability Notes (WWDC Highlights)

This C++ file is intended to be called directly from Swift using modern C++ interop (no C shim required). The examples below illustrate how to import and use the function defined later in this file from Swift.

Key ideas
- Direct import: Swift can import many C++ free functions, structs, and classes directly via the Clang importer.
- Modules: Expose headers through a module map (preferred) or umbrella header so Swift can import the C++ API as a Swift module.
- Build settings: Ensure C++ interop is enabled (Xcode 15+/Swift 5.9+ broadened support). Typically: Enable Modules (C and Objective-C), and set the Swift compiler C++ interop flags as needed.
- No exceptions across boundary: C++ exceptions must not escape into Swift. Prefer error codes/optionals or wrap with a thin adapter.
- Favor simple types: Primitive types and PODs interop best. STL support has improved but avoid templates in your public surface unless necessary.

*/

double cpp_net_carbs(double total, double fiber, double polyols) {
    const double net = total - fiber - (0.5 * polyols);
    return std::max(0.0, net);
}
