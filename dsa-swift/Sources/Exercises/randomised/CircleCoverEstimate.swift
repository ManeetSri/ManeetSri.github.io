// Problem: Estimate the area of overlapping circles (M67 · Monte Carlo vs Las Vegas)

public enum CircleCoverEstimate {
    /// A Monte Carlo estimate of the area covered by the union of `circles` (each [x, y, r]): `samples`
    /// uniform points from the circles' bounding box, drawn from `generator`, and the estimate's
    /// standard error B · √(p(1 − p) / N). Returns (0, 0) with no circles or no samples.
    public static func estimate(circles: [[Double]], samples: Int, using generator: inout some RandomNumberGenerator) -> (area: Double, standardError: Double) {
        // Write your solution here, then run:
        // swift test --filter CircleCoverEstimateTests
        return (-1, -1)
    }
}
