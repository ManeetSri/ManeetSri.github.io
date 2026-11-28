// Reference solution: The leap year rule. Check the most specific rule first. O(1) time and space.

public enum LeapYearRule {
    public static func isLeapYear(_ year: Int) -> Bool {
        if year % 400 == 0 {
            return true
        } else if year % 100 == 0 {
            return false
        } else {
            return year % 4 == 0
        }
    }
}
