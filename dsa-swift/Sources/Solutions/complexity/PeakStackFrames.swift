// Reference solution: Peak stack frames. The peak is the longest path from the first call to a base case.
// sumRange: follow the bigger half, ⌈k/2⌉, about log₂ n steps. trim: follow n − 2, so n / 2 + 1 frames.

public enum PeakStackFrames {
    public static func rangeSumFrames(_ n: Int) -> Int {
        var frames = 1
        var size = n
        while size > 1 {
            size = (size + 1) / 2         // the left half gets the extra number
            frames += 1
        }
        return frames
    }

    public static func trimFrames(_ n: Int) -> Int {
        n / 2 + 1                          // n, n − 2, …, down to 1 or 0
    }
}
