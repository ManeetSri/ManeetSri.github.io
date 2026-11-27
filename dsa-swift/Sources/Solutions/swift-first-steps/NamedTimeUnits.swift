// Reference solution: Name the time units. Each factor is a named constant built from the one
// before, so the code needs no comments. O(1) time and space.

public enum NamedTimeUnits {
    public static func totalSeconds(weeks: Int, days: Int, hours: Int, minutes: Int) -> Int {
        let secondsPerMinute = 60
        let secondsPerHour = secondsPerMinute * 60
        let secondsPerDay = secondsPerHour * 24
        let secondsPerWeek = secondsPerDay * 7
        return weeks * secondsPerWeek + days * secondsPerDay + hours * secondsPerHour + minutes * secondsPerMinute
    }
}
