// Generated from src/dsa/content/lessons/advanced-graphs/ag-matching.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let workers = ["Ana", "Ben", "Caz", "Dev"]
let jobs = ["camera", "lights", "sound", "edit"]
let canDo = [[0, 1], [1, 2], [2, 3], [0]]          // Ana: camera or lights, … Dev: camera only

// Greedy: each worker takes the first free job on their list
var takenBy = [Int](repeating: -1, count: jobs.count)
for worker in workers.indices {
    if let job = canDo[worker].first(where: { takenBy[$0] == -1 }) {
        takenBy[job] = worker
    }
}
print("greedy places", takenBy.filter { $0 != -1 }.count, "workers")

// Kuhn's algorithm: for each worker, search for an augmenting path with DFS
var workerOfJob = [Int](repeating: -1, count: jobs.count)
var seen = [Bool](repeating: false, count: jobs.count)
var steps: [String] = []

func findJob(for worker: Int) -> Bool {
    for job in canDo[worker] where !seen[job] {
        seen[job] = true
        let holder = workerOfJob[job]
        steps.append(holder == -1 ? "\(jobs[job]) is free" : "\(jobs[job]) is \(workers[holder])'s")
        if holder == -1 || findJob(for: holder) {
            workerOfJob[job] = worker               // flip: this job now goes to this worker
            return true
        }
    }
    return false
}

for worker in workers.indices {
    seen = [Bool](repeating: false, count: jobs.count)   // a fresh search for each worker
    steps = []
    let placed = findJob(for: worker)
    print("\(workers[worker]): \(steps.joined(separator: " → "))\(placed ? "" : " → no luck")")
}
for job in jobs.indices where workerOfJob[job] != -1 {
    print("  \(workers[workerOfJob[job]]) does \(jobs[job])")
}
