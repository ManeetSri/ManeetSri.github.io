// Problem: Gap between two pipes (M65 · Segment intersection, Floating-point epsilon handling)

public enum PipeGap {
    /// Each pipe is a segment `[[x1, y1], [x2, y2]]` with whole-number ends; the two ends may be the same
    /// point. Returns the shortest distance between a point of one pipe and a point of the other: 0 if
    /// they touch or cross.
    public static func shortestGap(_ first: [[Int]], _ second: [[Int]]) -> Double {
        // Write your solution here, then run:
        // swift test --filter PipeGapTests
        return -1
    }
}
