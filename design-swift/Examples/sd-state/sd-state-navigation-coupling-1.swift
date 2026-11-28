// Generated from src/dsa/design/content/lessons/sd-state/sd-state-navigation-coupling.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

enum Route: Hashable, Codable {
    case order(id: Int)
    case receipt(orderID: Int)
    case help

    var name: String {
        switch self {
        case .order(let id): "order \(id)"
        case .receipt(let id): "receipt \(id)"
        case .help: "help"
        }
    }
}

/// The routes that still make sense. A screen above a broken one goes too: it was opened from it.
func pruned(_ path: [Route], existingOrders: Set<Int>) -> [Route] {
    var kept: [Route] = []
    for route in path {
        switch route {
        case .order(let id), .receipt(let id):
            guard existingOrders.contains(id) else { return kept }
        case .help:
            break
        }
        kept.append(route)
    }
    return kept
}

let existing: Set<Int> = [7]   // order 42 was just deleted on another device
let paths: [[Route]] = [
    [.order(id: 7), .receipt(orderID: 7)],
    [.order(id: 42), .receipt(orderID: 42)],
    [.order(id: 7), .order(id: 42), .help],
]
for path in paths {
    let before = path.map(\.name).joined(separator: " → ")
    let after = pruned(path, existingOrders: existing).map(\.name).joined(separator: " → ")
    print(before, "⇒", after.isEmpty ? "(the list)" : after)
}
