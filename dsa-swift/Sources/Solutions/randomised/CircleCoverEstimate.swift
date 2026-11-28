// Reference solution: Estimate the area of overlapping circles. Sample uniform points in the circles'
// bounding box and count the ones inside any circle (squared distances, stopping at the first circle that
// covers the point). With p = hits / N and box area B, the estimate is B · p and its standard error
// B · √(p(1 − p) / N). O(samples × circles) time, O(1) space.

public enum CircleCoverEstimate {
    public static func estimate(circles: [[Double]], samples: Int, using generator: inout some RandomNumberGenerator) -> (area: Double, standardError: Double) {
        guard !circles.isEmpty, samples > 0 else { return (0, 0) }
        var minX = Double.infinity
        var maxX = -Double.infinity
        var minY = Double.infinity
        var maxY = -Double.infinity
        for circle in circles {
            minX = min(minX, circle[0] - circle[2])
            maxX = max(maxX, circle[0] + circle[2])
            minY = min(minY, circle[1] - circle[2])
            maxY = max(maxY, circle[1] + circle[2])
        }
        var hits = 0
        for _ in 0..<samples {
            let x = Double.random(in: minX..<maxX, using: &generator)
            let y = Double.random(in: minY..<maxY, using: &generator)
            let covered = circles.contains { circle in
                let dx = x - circle[0]
                let dy = y - circle[1]
                return dx * dx + dy * dy <= circle[2] * circle[2]
            }
            if covered {
                hits += 1
            }
        }
        let box = (maxX - minX) * (maxY - minY)
        let p = Double(hits) / Double(samples)
        return (box * p, box * (p * (1 - p) / Double(samples)).squareRoot())
    }
}
