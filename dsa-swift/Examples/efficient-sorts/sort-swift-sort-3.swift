// Generated from src/dsa/content/lessons/efficient-sorts/sort-swift-sort.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Task {
    let title: String
    let priority: Int
}

let inbox = [
    Task(title: "reply to Sam", priority: 1),
    Task(title: "fix login bug", priority: 3),
    Task(title: "book flights", priority: 1),
    Task(title: "review PR", priority: 3),
    Task(title: "water plants", priority: 2),
]

// Highest priority first. Equal priorities keep their inbox order: the sort is stable.
print(inbox.sorted { $0.priority > $1.priority }.map { $0.title })

// Sorting upwards and then reversing also reverses the order of equal priorities
print(inbox.sorted { $0.priority < $1.priority }.reversed().map { $0.title })
