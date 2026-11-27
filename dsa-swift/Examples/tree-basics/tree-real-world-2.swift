// Generated from src/dsa/content/lessons/tree-basics/tree-real-world.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

enum JSON {
    case null
    case bool(Bool)
    case number(Double)
    case string(String)
    case array([JSON])
    case object([String: JSON])
}

func depth(_ json: JSON) -> Int {
    switch json {
    case .array(let items):
        return 1 + (items.map(depth).max() ?? 0)
    case .object(let fields):
        return 1 + (fields.values.map(depth).max() ?? 0)
    default:
        return 1                                     // a leaf
    }
}

// The path to every leaf. Object keys are sorted, so the output is the same on every run.
func leafPaths(_ json: JSON, _ path: String = "$") -> [String] {
    switch json {
    case .array(let items):
        return items.indices.flatMap { leafPaths(items[$0], "\(path)[\($0)]") }
    case .object(let fields):
        return fields.keys.sorted().flatMap { leafPaths(fields[$0]!, "\(path).\($0)") }
    default:
        return [path]
    }
}

let order = JSON.object([
    "id": .number(1042),
    "customer": .object(["name": .string("Asha"), "vip": .bool(true)]),
    "items": .array([
        .object(["sku": .string("A1"), "quantity": .number(2)]),
        .object(["sku": .string("B7"), "quantity": .number(1)]),
    ]),
    "note": .null,
])
print("depth", depth(order))
for path in leafPaths(order) {
    print(path)
}
