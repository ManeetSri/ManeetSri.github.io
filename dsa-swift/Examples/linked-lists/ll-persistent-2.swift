// Generated from src/dsa/content/lessons/linked-lists/ll-persistent.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

indirect enum PersistentList: CustomStringConvertible {
    case empty
    case node(Int, PersistentList)

    func prepending(_ value: Int) -> PersistentList {
        .node(value, self)                     // O(1): the old list becomes the rest
    }

    var first: Int? {
        if case .node(let value, _) = self { return value }
        return nil
    }

    var rest: PersistentList {
        if case .node(_, let rest) = self { return rest }
        return .empty
    }

    var description: String {
        var parts: [String] = []
        var current = self
        while case .node(let value, let rest) = current {
            parts.append(String(value))
            current = rest
        }
        parts.append("nil")
        return parts.joined(separator: " -> ")
    }
}

let base = PersistentList.empty.prepending(3).prepending(2)
let withOne = base.prepending(1)
let withNine = base.prepending(9)

print(base)
print(withOne)
print(withNine)
print(withOne.rest)
print(withOne.first ?? 0, withNine.rest.first ?? 0)
