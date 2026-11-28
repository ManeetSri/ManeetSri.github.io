// Reference solution: Split the chores into equal teams. After the quick rejections, fill the teams one
// after another, so a set of used chores fixes everything: fill[mask] is how full the current team is
// (or −1 if unreachable), and a chore may be added if it fits in the remaining room. Remember the last
// chore for each mask, walk back from the full mask, and number the teams from running totals.
// O(2^n · n) time, O(2^n) space.

public enum EqualChoreTeams {
    public static func assign(_ minutes: [Int], teams k: Int) -> [Int]? {
        let n = minutes.count
        let total = minutes.reduce(0, +)
        guard total % k == 0 else { return nil }
        let target = total / k
        guard minutes.allSatisfy({ $0 <= target }) else { return nil }

        let full = (1 << n) - 1
        var fill = [Int](repeating: -1, count: 1 << n)     // fill of the team being built, or −1
        var lastChore = [Int](repeating: -1, count: 1 << n)
        fill[0] = 0
        for mask in 0..<full where fill[mask] >= 0 {
            for chore in 0..<n where mask & (1 << chore) == 0 && fill[mask] + minutes[chore] <= target {
                let next = mask | (1 << chore)
                if fill[next] < 0 {
                    fill[next] = (fill[mask] + minutes[chore]) % target
                    lastChore[next] = chore
                }
            }
        }
        guard fill[full] == 0 else { return nil }

        // Walk back from the full mask to recover the order the chores were added in
        var order: [Int] = []
        var mask = full
        while mask != 0 {
            order.append(lastChore[mask])
            mask &= ~(1 << lastChore[mask])
        }
        var teams = [Int](repeating: 0, count: n)
        var used = 0
        for chore in order.reversed() {
            teams[chore] = used / target                 // teams fill up one after another
            used += minutes[chore]
        }
        return teams
    }
}
