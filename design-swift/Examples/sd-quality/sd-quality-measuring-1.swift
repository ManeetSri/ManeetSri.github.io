// Generated from src/dsa/design/content/lessons/sd-quality/sd-quality-measuring.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

enum Layer: Int {
    case app, feature, domain, platform   // top to bottom
}

struct Module {
    let name: String
    let layer: Layer
    let imports: [String]
}

let modules = [
    Module(name: "App", layer: .app, imports: ["Feed", "Profile", "Networking"]),
    Module(name: "Feed", layer: .feature, imports: ["Posts", "Profile", "DesignSystem"]),
    Module(name: "Profile", layer: .feature, imports: ["Accounts", "DesignSystem"]),
    Module(name: "Posts", layer: .domain, imports: ["Networking"]),
    Module(name: "Accounts", layer: .domain, imports: ["Networking"]),
    Module(name: "Networking", layer: .platform, imports: ["Accounts"]),
    Module(name: "DesignSystem", layer: .platform, imports: []),
]

let layerOf = Dictionary(uniqueKeysWithValues: modules.map { ($0.name, $0.layer) })
var violations: [String] = []

for module in modules {
    for name in module.imports {
        guard let target = layerOf[name] else { continue }
        if target.rawValue < module.layer.rawValue {
            violations.append("\(module.name) imports \(name): dependencies must point down the layers")
        } else if module.layer == .feature && target == .feature {
            violations.append("\(module.name) imports \(name): features must not import each other")
        }
    }
}

violations.forEach { print("✘ \($0)") }
print(violations.isEmpty ? "✔ module rules hold" : "\(violations.count) violations: fail the build")
