// Reference solution: Split the seconds. Integer division counts the whole hours and minutes,
// and % keeps what's left over at each step. O(1) time and space.

public enum TimeSplitter {
    public static func split(seconds: Int) -> (hours: Int, minutes: Int, seconds: Int) {
        let hours = seconds / 3600
        let minutes = seconds % 3600 / 60
        return (hours: hours, minutes: minutes, seconds: seconds % 60)
    }
}
