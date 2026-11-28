// Generated from src/dsa/content/lessons/elementary-sorts/sort-properties.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Task {
    let title: String
    let priority: Int      // 1 is the most urgent
    let due: Int           // day of the month
}

let tasks = [
    Task(title: "Pay rent", priority: 1, due: 28),
    Task(title: "Book dentist", priority: 2, due: 12),
    Task(title: "Fix login bug", priority: 1, due: 3),
    Task(title: "Renew passport", priority: 3, due: 12),
    Task(title: "Reply to Sam", priority: 2, due: 5),
]

let byPriority = tasks.sorted { $0.priority < $1.priority }
for task in byPriority {
    print(task.priority, task.title)
}
