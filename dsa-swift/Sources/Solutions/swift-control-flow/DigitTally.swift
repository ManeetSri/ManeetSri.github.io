// Reference solution: Digit tally. Drop the last digit until nothing is left. repeat-while makes 0
// count as one digit, and dividing a negative number by 10 also moves it towards 0, so the sign never
// needs flipping. O(d) time for d digits, O(1) space.

public enum DigitTally {
    public static func count(of number: Int) -> Int {
        var remaining = number
        var digits = 0
        repeat {
            digits += 1
            remaining /= 10
        } while remaining != 0
        return digits
    }
}
