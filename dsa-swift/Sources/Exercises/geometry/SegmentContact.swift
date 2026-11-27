// Problem: Segment contact (M65 · Segment intersection)

public enum SegmentContact {
    /// How two segments meet.
    public enum Contact: Equatable, Sendable {
        /// No point in common.
        case disjoint
        /// Exactly one point in common: a crossing, a touch, or a shared end.
        case point
        /// A whole stretch in common: collinear segments overlapping along a positive length.
        case overlap
    }

    /// Each segment is `[[x1, y1], [x2, y2]]`, and its two ends may be the same point. Returns how the
    /// two segments meet.
    public static func contact(_ first: [[Int]], _ second: [[Int]]) -> Contact {
        // Write your solution here, then run:
        // swift test --filter SegmentContactTests
        return .disjoint
    }
}
