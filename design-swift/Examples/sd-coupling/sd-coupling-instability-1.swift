// Generated from src/dsa/design/content/lessons/sd-coupling/sd-coupling-instability.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

// Each module and the modules it imports
let imports: [String: [String]] = [
    "App": ["Feed", "Checkout"],
    "Feed": ["Networking", "DesignSystem", "Analytics", "Models"],
    "Checkout": ["Networking", "DesignSystem", "Analytics", "Models"],
    "Networking": ["Models"],
    "Analytics": ["AcmeSDK"],
    "DesignSystem": [],
    "Models": [],
    "AcmeSDK": [],
]

struct Metrics {
    let module: String
    let afferent: Int    // Ca: modules that import this one
    let efferent: Int    // Ce: modules this one imports

    var instability: Double {
        afferent + efferent == 0 ? 0 : Double(efferent) / Double(afferent + efferent)
    }
}

let metrics = imports.keys.map { module in
    Metrics(
        module: module,
        afferent: imports.values.filter { $0.contains(module) }.count,
        efferent: imports[module, default: []].count
    )
}

let mostUnstableFirst = metrics.sorted { a, b in
    a.instability != b.instability ? a.instability > b.instability : a.module < b.module
}
for m in mostUnstableFirst {
    let name = m.module.padding(toLength: 13, withPad: " ", startingAt: 0)
    print("\(name) Ca \(m.afferent)  Ce \(m.efferent)  I \(String(format: "%.2f", m.instability))")
}
