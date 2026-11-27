// Problem: Where to build the depot (M67 · Randomised quickselect)

public enum WeightedMedianDepot {
    /// The cheapest depot spot among `positions` (the smallest one if several tie), where a spot x
    /// costs the sum of weights[i] × |x − positions[i]|, and that cost. Expected O(n) with randomised
    /// selection: draw every random choice from `generator`, and don't sort.
    public static func bestSpot(positions: [Int], weights: [Int], using generator: inout some RandomNumberGenerator) -> (spot: Int, cost: Int) {
        // Write your solution here, then run:
        // swift test --filter WeightedMedianDepotTests
        return (0, 0)
    }
}
