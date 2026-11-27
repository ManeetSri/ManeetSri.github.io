// Reference solution: The majority value. Boyer–Moore voting finds the only possible candidate in
// one pass, by cancelling pairs of different values; a second pass counts it to confirm it really
// is a majority. O(n) time, O(1) extra space.

public enum MajorityVote {
    public static func majority(in numbers: [Int]) -> Int? {
        var candidate = 0
        var votes = 0
        for number in numbers {
            if votes == 0 {
                candidate = number
                votes = 1
            } else if number == candidate {
                votes += 1
            } else {
                votes -= 1
            }
        }

        // The vote only guarantees: if there is a majority, it's the candidate. Check it.
        var occurrences = 0
        for number in numbers where number == candidate {
            occurrences += 1
        }
        return occurrences > numbers.count / 2 ? candidate : nil
    }
}
