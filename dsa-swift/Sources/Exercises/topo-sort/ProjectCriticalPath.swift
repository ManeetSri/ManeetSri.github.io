// Problem: Critical path of a project (M43 · Longest and shortest paths in a DAG)

public enum ProjectCriticalPath {
    /// Task i takes `durations[i]` days. Each pair `[before, after]` in `dependencies` means `after`
    /// can't start until `before` has finished; the pairs never form a cycle. With as many workers as
    /// you like, returns the earliest day the whole project can be finished, and the critical tasks,
    /// in increasing order: the tasks that would delay that day if they started any later than their
    /// earliest possible start.
    public static func plan(durations: [Int], dependencies: [[Int]]) -> (finishTime: Int, criticalTasks: [Int]) {
        // Write your solution here, then run:
        // swift test --filter ProjectCriticalPathTests
        return (0, [])
    }
}
