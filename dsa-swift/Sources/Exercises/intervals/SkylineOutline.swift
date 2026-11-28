// Problem: Skyline outline (M33 · The skyline problem)

public enum SkylineOutline {
    /// Each building is `[left, right, height]`, covering the half-open stretch `[left, right)`, with
    /// `left < right` and `height > 0`. The buildings can arrive in any order. Returns the outline's
    /// key points `[x, height]`, sorted by x: at each x where the outline's height changes, its new
    /// height. Neighbouring key points never share a height, and the last one has height 0.
    public static func keyPoints(_ buildings: [[Int]]) -> [[Int]] {
        // Write your solution here, then run:
        // swift test --filter SkylineOutlineTests
        return []
    }
}
