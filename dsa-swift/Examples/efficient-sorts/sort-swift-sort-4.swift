// Generated from src/dsa/content/lessons/efficient-sorts/sort-swift-sort.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let arrivals = [(priority: 1, id: "a"), (priority: 1, id: "b"), (priority: 1, id: "c"),
                (priority: 0, id: "d"), (priority: 1, id: "e")]

print(arrivals.sorted { $0.priority < $1.priority }.map { $0.id })
print(arrivals.sorted { $0.priority <= $1.priority }.map { $0.id })
