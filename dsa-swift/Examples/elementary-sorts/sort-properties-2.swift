// Generated from src/dsa/content/lessons/elementary-sorts/sort-properties.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Task {
    let title: String
    let priority: Int
    let due: Int
}

let tasks = [
    Task(title: "Pay rent", priority: 1, due: 28),
    Task(title: "Book dentist", priority: 2, due: 12),
    Task(title: "Fix login bug", priority: 1, due: 3),
    Task(title: "Renew passport", priority: 3, due: 12),
    Task(title: "Reply to Sam", priority: 2, due: 5),
]

let byDue = tasks.sorted { $0.due < $1.due }
let byPriorityThenDue = byDue.sorted { $0.priority < $1.priority }
for task in byPriorityThenDue {
    print(task.priority, task.due, task.title)
}
