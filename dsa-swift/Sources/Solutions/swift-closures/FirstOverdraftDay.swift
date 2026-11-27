// Reference solution: The first overdrawn day. One loop carries the running balance and returns
// the moment it goes negative. O(n) time in the worst case, O(1) space.

public enum FirstOverdraftDay {
    public static func day(startingWith balance: Int, changes: [Int]) -> Int? {
        var current = balance
        for (day, change) in changes.enumerated() {
            current += change
            if current < 0 {
                return day
            }
        }
        return nil
    }
}
