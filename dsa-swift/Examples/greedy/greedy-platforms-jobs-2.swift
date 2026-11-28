// Generated from src/dsa/content/lessons/greedy/greedy-platforms-jobs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Each job takes one time slot and pays only if it's done in a slot at or before its deadline
let jobs = [
    (name: "logo", deadline: 2, profit: 40),
    (name: "flyer", deadline: 1, profit: 25),
    (name: "banner", deadline: 3, profit: 30),
    (name: "menu", deadline: 1, profit: 35),
    (name: "poster", deadline: 3, profit: 10),
    (name: "card", deadline: 2, profit: 20),
]

let lastSlot = jobs.map(\.deadline).max() ?? 0
var slots: [String?] = Array(repeating: nil, count: lastSlot + 1)     // slots[1...lastSlot]; 0 is unused
var total = 0
for job in jobs.sorted(by: { $0.profit > $1.profit }) {             // most profitable first
    var slot = job.deadline
    while slot >= 1 && slots[slot] != nil {                          // the latest free slot by the deadline
        slot -= 1
    }
    if slot >= 1 {
        slots[slot] = job.name
        total += job.profit
        print("\(job.name) (\(job.profit)) -> slot \(slot)")
    } else {
        print("\(job.name) (\(job.profit)) -> no free slot by \(job.deadline)")
    }
}
print(slots.dropFirst().map { $0 ?? "-" }, total)
