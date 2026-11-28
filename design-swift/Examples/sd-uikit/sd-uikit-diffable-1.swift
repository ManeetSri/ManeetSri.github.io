// Generated from src/dsa/design/content/lessons/sd-uikit/sd-uikit-diffable.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct Todo: Hashable {
    let id: Int
    var title: String
    var isDone: Bool
}

func describe<T>(_ difference: CollectionDifference<T>) -> String {
    "deletions: \(difference.removals.count), insertions: \(difference.insertions.count)"
}

let before = [Todo(id: 1, title: "Milk", isDone: false), Todo(id: 2, title: "Eggs", isDone: false), Todo(id: 3, title: "Bread", isDone: false)]
var after = before
after[1].isDone = true // tick "Eggs"

// Whole models as identifiers: the edited row is a different value, so it looks like a different item
print("Models as identifiers:", describe(after.difference(from: before)))

// Stable IDs as identifiers: nothing was inserted or deleted...
print("IDs as identifiers:", describe(after.map(\.id).difference(from: before.map(\.id))))

// ...and the content change is a separate question: which IDs now have different content?
let old = Dictionary(uniqueKeysWithValues: before.map { ($0.id, $0) })
print("Reconfigure:", after.filter { old[$0.id] != $0 }.map(\.id))
