// Generated from src/dsa/content/lessons/two-pointers/tp-dutch-flag.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Task {
    let name: String
    let priority: Int    // 0 urgent, 1 normal, 2 later
}

func sortByPriority(_ tasks: inout [Task]) {
    var low = 0
    var mid = 0
    var high = tasks.count - 1
    while mid <= high {
        switch tasks[mid].priority {
        case 0:
            tasks.swapAt(low, mid)
            low += 1
            mid += 1
        case 1:
            mid += 1
        default:
            tasks.swapAt(mid, high)
            high -= 1
        }
    }
}

var tasks = [
    Task(name: "email", priority: 2),
    Task(name: "deploy", priority: 0),
    Task(name: "review", priority: 1),
    Task(name: "backup", priority: 2),
    Task(name: "hotfix", priority: 0),
    Task(name: "lunch", priority: 1),
]
sortByPriority(&tasks)
print(tasks.map { $0.name })
