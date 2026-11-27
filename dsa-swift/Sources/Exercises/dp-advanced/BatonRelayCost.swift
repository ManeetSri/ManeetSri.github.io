// Problem: The cheapest baton relay (M58 · Monotonic queue, convex hull trick, Knuth and D&C optimisations)

public enum BatonRelayCost {
    /// Checkpoints 0..<fees.count lie along a route. The baton starts at checkpoint 0 and must end at the
    /// last one. It travels in legs, and every leg moves it forward by at least `shortest` and at most
    /// `longest` checkpoints. A fee fees[i] is paid at checkpoint 0 and at every checkpoint where a leg
    /// ends. Returns the smallest total fee, or -1 if the last checkpoint can't be reached.
    public static func cheapestRelay(fees: [Int], shortest: Int, longest: Int) -> Int {
        // Write your solution here, then run:
        // swift test --filter BatonRelayCostTests
        return 0
    }
}
