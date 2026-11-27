// Generated from src/dsa/content/lessons/dp-advanced/dpa-bitmask.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Fewest work sessions of at most `limit` minutes to finish every task (each task in one session)
func fewestSessions(_ tasks: [Int], limit: Int) -> Int {
    let n = tasks.count
    let full = 1 << n
    // total[mask]: minutes for the tasks in mask, built from a smaller mask plus its lowest task
    var total = [Int](repeating: 0, count: full)
    for mask in 1..<full {
        let low = mask.trailingZeroBitCount
        total[mask] = total[mask & (mask - 1)] + tasks[low]
    }
    var sessions = [Int](repeating: Int.max, count: full)
    sessions[0] = 0
    var steps = 0
    for mask in 1..<full {
        // Try every non-empty submask as one session's worth of tasks
        var sub = mask
        while sub > 0 {
            steps += 1
            if total[sub] <= limit && sessions[mask ^ sub] != Int.max {
                sessions[mask] = min(sessions[mask], sessions[mask ^ sub] + 1)
            }
            sub = (sub - 1) & mask
        }
    }
    print("submask steps:", steps)
    return sessions[full - 1]
}

print(fewestSessions([3, 1, 3, 1, 1], limit: 8))
print(fewestSessions([5, 4, 3, 3, 2, 2, 2, 1, 6, 4], limit: 10))
