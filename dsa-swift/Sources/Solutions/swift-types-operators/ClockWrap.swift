// Reference solution: Round the clock. In Swift, % keeps the sign of the left-hand number, so a
// negative total gives a negative remainder. Adding 24 and taking % 24 again always lands in 0...23.
// O(1) time and space.

public enum ClockWrap {
    public static func hour(from start: Int, adding hours: Int) -> Int {
        ((start + hours) % 24 + 24) % 24
    }
}
