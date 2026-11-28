// Generated from src/dsa/design/content/lessons/sd-styles/sd-styles-intro.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

// The layered style as rules a script can check: every module sits in a layer, and imports only
// modules in layers below its own. Two features in the same layer may not import each other.
let layer = [
    "App": 0,
    "Checkout": 1, "Profile": 1,
    "Payments": 2,
    "Networking": 3, "DesignSystem": 3,
]

// What each module imports, as its Package.swift target would declare it
let imports = [
    "App": ["Checkout", "Profile"],
    "Checkout": ["Payments", "Profile", "DesignSystem"],
    "Profile": ["Networking", "DesignSystem"],
    "Payments": ["Networking"],
    "Networking": ["Checkout"],
    "DesignSystem": [],
]

var violations = 0
for module in imports.keys.sorted() {
    for dependency in imports[module, default: []] {
        let from = layer[module]!, to = layer[dependency]!
        if to < from {
            print("✘ \(module) → \(dependency): imports upwards")
            violations += 1
        } else if to == from {
            print("✘ \(module) → \(dependency): imports a neighbour in its own layer")
            violations += 1
        }
    }
}
print(violations == 0 ? "The layering holds" : "\(violations) imports break the style")
