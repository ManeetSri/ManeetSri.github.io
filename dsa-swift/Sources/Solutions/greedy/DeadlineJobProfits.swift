// Reference solution: Most profitable jobs before deadlines. Take jobs from most to least profitable and
// put each in the latest free hour at or before its deadline, turning it down if there's none. A
// union-find finds that hour: a full hour points at the hour before it, so following the pointers from
// the deadline lands on the latest free hour, with hour 0 meaning none, and path compression keeps the
// walks short. Deadlines are capped at n, because n jobs never need more than n hours.
// O(n log n) time for the sort, O(n) space.

public enum DeadlineJobProfits {
    public static func maxProfit(_ jobs: [[Int]]) -> Int {
        let n = jobs.count
        var parent = Array(0...n)                  // a free hour points at itself
        func latestFree(_ hour: Int) -> Int {
            var root = hour
            while parent[root] != root { root = parent[root] }
            var current = hour
            while parent[current] != root {        // path compression
                let next = parent[current]
                parent[current] = root
                current = next
            }
            return root
        }
        var total = 0
        for job in jobs.sorted(by: { $0[1] > $1[1] }) {
            let hour = latestFree(min(job[0], n))
            if hour > 0 {
                parent[hour] = hour - 1            // full: look one hour earlier next time
                total += job[1]
            }
        }
        return total
    }
}
