// Generated from src/dsa/design/content/lessons/sd-principles/sd-principles-package-coupling.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

// Each module and the modules it imports, as a fitness function would read them from Package.swift
let imports: [String: [String]] = [
    "App": ["Checkout", "Profile", "Settings", "DesignSystem"],
    "Checkout": ["DesignSystem", "Networking"],
    "Profile": ["DesignSystem", "Settings"],
    "Settings": ["DesignSystem", "Profile"],
    "DesignSystem": ["Experiments"],
    "Experiments": ["Networking"],
    "Networking": [],
]
let modules = imports.keys.sorted()

func instability(of module: String) -> Double {
    let efferent = imports[module, default: []].count
    let afferent = imports.values.filter { $0.contains(module) }.count
    return afferent + efferent == 0 ? 0 : Double(efferent) / Double(afferent + efferent)
}

// ADP: a depth-first search that reports an import leading back to a module on the current path
func firstCycle() -> [String]? {
    var finished: Set<String> = []
    var path: [String] = []

    func visit(_ module: String) -> [String]? {
        if let start = path.firstIndex(of: module) { return Array(path[start...]) + [module] }
        if finished.contains(module) { return nil }
        path.append(module)
        for dependency in imports[module, default: []] {
            if let cycle = visit(dependency) { return cycle }
        }
        path.removeLast()
        finished.insert(module)
        return nil
    }

    for module in modules {
        if let cycle = visit(module) { return cycle }
    }
    return nil
}

for module in modules {
    print("\(module.padding(toLength: 13, withPad: " ", startingAt: 0)) I = \(String(format: "%.2f", instability(of: module)))")
}
if let cycle = firstCycle() {
    print("ADP: cycle \(cycle.joined(separator: " → "))")
}
// SDP: an import should point at a module at least as stable as the importer
for module in modules {
    for dependency in imports[module, default: []] where instability(of: dependency) > instability(of: module) {
        print("SDP: \(module) (\(String(format: "%.2f", instability(of: module)))) imports less stable \(dependency) (\(String(format: "%.2f", instability(of: dependency))))")
    }
}
