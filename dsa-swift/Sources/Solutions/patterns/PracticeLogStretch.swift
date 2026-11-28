// Reference solution: The longest mostly-on-track stretch. Score each day +1 (on track) or -1, so a
// stretch qualifies exactly when its scores add up to more than 0. With prefix sums, the stretch after
// prefix i up to prefix j qualifies when prefix[i] < prefix[j]. For each j we want the earliest such i.
// The prefix moves by exactly 1 per day and starts at 0, so if prefix[j] > 0 the whole log so far works;
// otherwise the earliest prefix below prefix[j] is the first time the prefix reached prefix[j] - 1 (it
// had to pass through that value to get any lower). A dictionary of first occurrences finds it in O(1).
// This is a window-shaped question where a window fails: adding a bad day can be undone by later good
// days, so validity isn't monotonic.
// O(n) time, O(n) space.

public enum PracticeLogStretch {
    public static func longestStretch(minutes: [Int], goal: Int) -> Int {
        var firstSeen: [Int: Int] = [:]       // prefix value → the first day index after which it appeared
        var prefix = 0
        var best = 0
        for (day, value) in minutes.enumerated() {
            prefix += value >= goal ? 1 : -1
            if prefix > 0 {
                best = day + 1                // every day so far
            } else if let start = firstSeen[prefix - 1] {
                best = max(best, day - start)
            }
            if firstSeen[prefix] == nil {
                firstSeen[prefix] = day
            }
        }
        return best
    }
}
