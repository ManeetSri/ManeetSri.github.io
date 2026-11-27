// Reference solution: The steepest climb. zip the altitudes with themselves shifted by one to
// get every leg, and enumerated() to number them. O(n) time, O(1) extra space.

public enum SteepestClimbLeg {
    public static func steepestClimb(in altitudes: [Int]) -> (start: Int, rise: Int)? {
        var best: (start: Int, rise: Int)? = nil
        for (start, (here, next)) in zip(altitudes, altitudes.dropFirst()).enumerated() {
            let rise = next - here
            if rise > (best?.rise ?? 0) {
                best = (start: start, rise: rise)
            }
        }
        return best
    }
}
