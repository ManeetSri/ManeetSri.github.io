// Generated from src/dsa/content/lessons/heaps/heap-swift-collections.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Job: Comparable {
    let name: String
    let priority: Int       // 1 is the most urgent
    let arrival: Int        // breaks ties: first come, first served

    static func < (a: Job, b: Job) -> Bool {
        (a.priority, a.arrival) < (b.priority, b.arrival)
    }
}

let jobs = [
    Job(name: "backup", priority: 3, arrival: 0),
    Job(name: "email", priority: 1, arrival: 1),
    Job(name: "report", priority: 2, arrival: 2),
    Job(name: "alert", priority: 1, arrival: 3),
]
print(jobs.min()!.name)                  // what heap.min would be
print(jobs.max()!.name)                  // what heap.max would be
print(jobs.sorted().map(\.name))         // the order repeated popMin() calls would give
