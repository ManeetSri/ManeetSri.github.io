// Generated from src/dsa/content/lessons/topo-sort/topo-dag-paths.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let tasks = ["design", "api", "ui", "tests", "docs", "review", "ship"]
let days = [3, 5, 4, 2, 1, 2, 1]
let dependencies = [[0, 1], [0, 2], [1, 3], [2, 3], [0, 4], [3, 5], [4, 5], [5, 6]]   // [before, after]
var next = Array(repeating: [Int](), count: tasks.count)
for pair in dependencies {
    next[pair[0]].append(pair[1])
}
let order = Array(tasks.indices)   // every dependency goes from a lower label to a higher one here

// Forward: the earliest each task can start is when the last of its dependencies finishes
var earliest = Array(repeating: 0, count: tasks.count)
for task in order {
    for after in next[task] {
        earliest[after] = max(earliest[after], earliest[task] + days[task])
    }
}
let finish = tasks.indices.map { earliest[$0] + days[$0] }.max()!

// Backward: the latest each task can start without delaying the finish
var latest = tasks.indices.map { finish - days[$0] }
for task in order.reversed() {
    for after in next[task] {
        latest[task] = min(latest[task], latest[after] - days[task])
    }
}

print("finished after", finish, "days")
for task in tasks.indices {
    let slack = latest[task] - earliest[task]
    let note = slack == 0 ? " (critical)" : ""
    print("\(tasks[task]): starts day \(earliest[task]), slack \(slack)\(note)")
}
