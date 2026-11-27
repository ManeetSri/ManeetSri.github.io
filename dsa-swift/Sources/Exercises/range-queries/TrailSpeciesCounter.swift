// Problem: Species on trail segments (M62 · Mo's algorithm)

public enum TrailSpeciesCounter {
    /// `sightings[i]` is the species id seen at survey point i. For each segment `[left, right]` (both
    /// ends included), returns how many different species were seen at points `left...right`, in the
    /// order the segments are given.
    ///
    /// Aim for O((n + q)√n) with Mo's algorithm, after compressing the species ids.
    public static func distinctSpecies(sightings: [Int], segments: [[Int]]) -> [Int] {
        // Write your solution here, then run:
        // swift test --filter TrailSpeciesCounterTests
        return []
    }
}
