// Reference solution: Critical path of a project. First a topological order, from Kahn's algorithm.
// A forward pass in that order finds each task's earliest start: the latest finish among its
// prerequisites. The project's finish time is the largest earliest finish. A backward pass in
// reverse order finds each task's latest finish that doesn't delay the project: the earliest of
// its dependants' latest starts, or the finish time if nothing depends on it. A task is critical
// when its earliest and latest starts are equal: it has no slack. O(n + d) time and space.

public enum ProjectCriticalPath {
    public static func plan(durations: [Int], dependencies: [[Int]]) -> (finishTime: Int, criticalTasks: [Int]) {
        let count = durations.count
        var dependants = Array(repeating: [Int](), count: count)
        var waitingOn = Array(repeating: 0, count: count)
        for pair in dependencies {
            dependants[pair[0]].append(pair[1])
            waitingOn[pair[1]] += 1
        }
        var order = (0..<count).filter { waitingOn[$0] == 0 }
        var head = 0
        while head < order.count {
            let task = order[head]
            head += 1
            for next in dependants[task] {
                waitingOn[next] -= 1
                if waitingOn[next] == 0 {
                    order.append(next)
                }
            }
        }

        // Forward pass: relax every edge in topological order, keeping the latest finish
        var earliestStart = Array(repeating: 0, count: count)
        for task in order {
            let finish = earliestStart[task] + durations[task]
            for next in dependants[task] {
                earliestStart[next] = max(earliestStart[next], finish)
            }
        }
        let finishTime = (0..<count).map { earliestStart[$0] + durations[$0] }.max() ?? 0

        // Backward pass: the latest each task may finish without moving finishTime
        var latestFinish = Array(repeating: finishTime, count: count)
        for task in order.reversed() {
            for next in dependants[task] {
                latestFinish[task] = min(latestFinish[task], latestFinish[next] - durations[next])
            }
        }
        let critical = (0..<count).filter { latestFinish[$0] - durations[$0] == earliestStart[$0] }
        return (finishTime, critical)
    }
}
