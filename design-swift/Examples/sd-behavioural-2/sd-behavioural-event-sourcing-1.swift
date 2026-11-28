// Generated from src/dsa/design/content/lessons/sd-behavioural-2/sd-behavioural-event-sourcing.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

// Facts, in the past tense. Once appended, never edited.
enum ListEvent {
    case itemAdded(id: Int, name: String)
    case itemRenamed(id: Int, name: String)
    case itemChecked(id: Int)
    case itemRemoved(id: Int)
}

struct Item {
    let id: Int
    var name: String
    var isChecked = false
}

// A projection: the current list, derived by applying events in order
struct ShoppingList {
    private(set) var items: [Item] = []

    mutating func apply(_ event: ListEvent) {
        switch event {
        case .itemAdded(let id, let name):
            items.append(Item(id: id, name: name))
        case .itemRenamed(let id, let name):
            if let index = items.firstIndex(where: { $0.id == id }) { items[index].name = name }
        case .itemChecked(let id):
            if let index = items.firstIndex(where: { $0.id == id }) { items[index].isChecked = true }
        case .itemRemoved(let id):
            items.removeAll { $0.id == id }
        }
    }

    var summary: String {
        items.map { "\($0.isChecked ? "[x]" : "[ ]") \($0.name)" }.joined(separator: ", ")
    }
}

func replay(_ events: some Sequence<ListEvent>, from start: ShoppingList = ShoppingList()) -> ShoppingList {
    events.reduce(into: start) { list, event in list.apply(event) }
}

let log: [ListEvent] = [
    .itemAdded(id: 1, name: "Milk"),
    .itemAdded(id: 2, name: "Bread"),
    .itemAdded(id: 3, name: "Eggs"),
    .itemRenamed(id: 2, name: "Sourdough"),
    .itemChecked(id: 1),
    .itemRemoved(id: 3),
]

print("now:", replay(log).summary)
print("after 3 events:", replay(log.prefix(3)).summary)   // time travel

// A second projection of the same facts
let activity = log.map { event -> String in
    switch event {
    case .itemAdded(_, let name): "added \(name)"
    case .itemRenamed(_, let name): "renamed to \(name)"
    case .itemChecked: "checked an item"
    case .itemRemoved: "removed an item"
    }
}
print("activity:", activity.suffix(3).joined(separator: "; "))

// A snapshot (a memento) after 4 events, so launch replays only the tail
let snapshot = replay(log.prefix(4))
let fromSnapshot = replay(log.dropFirst(4), from: snapshot)
print("from snapshot:", fromSnapshot.summary, "· replayed", log.count - 4, "events")
