// Reference solution: Longest consecutive run. Put every value in a Set, then count upwards only from
// values that start a run (value - 1 is missing). Each value is visited once as a candidate start
// and at most once more while some run walks over it, so the whole thing is O(n) time on average,
// O(n) space. Looping over the set, not the array, means duplicates never start the same walk twice.

public enum LongestConsecutiveRun {
    public static func length(in numbers: [Int]) -> Int {
        let present = Set(numbers)
        var longest = 0
        for start in present where !present.contains(start - 1) {
            var end = start
            while present.contains(end + 1) {
                end += 1
            }
            longest = max(longest, end - start + 1)
        }
        return longest
    }
}
