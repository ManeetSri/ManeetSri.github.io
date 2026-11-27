// Reference solution: Seat the team together. If the team has k members, they finish in some block of k
// neighbouring seats. A swap can move one outsider out of that block and one team member in, so a block
// that already holds m team members needs exactly k - m swaps. The answer is k minus the most team members
// any block of k seats already holds: a fixed-size sliding window of length k, walked once around the
// circle by taking indexes modulo n.
// O(n) time, O(1) extra space.

public enum TeamSeatingSwaps {
    public static func fewestSwaps(seats: [Int]) -> Int {
        let n = seats.count
        let team = seats.reduce(0, +)
        if team == 0 || team == n { return 0 }

        // The first window: seats 0..<team
        var inWindow = 0
        for i in 0..<team {
            inWindow += seats[i]
        }
        var best = inWindow

        // Slide the window's start from 1 to n - 1; its end wraps around the table
        for start in 1..<n {
            inWindow -= seats[start - 1]
            inWindow += seats[(start + team - 1) % n]
            best = max(best, inWindow)
        }
        return team - best
    }
}
