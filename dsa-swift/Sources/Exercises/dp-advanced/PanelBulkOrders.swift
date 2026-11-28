// Problem: Ordering panels in bulk (M58 · Monotonic queue, convex hull trick, Knuth and D&C optimisations)

public enum PanelBulkOrders {
    /// Every panel you need is a rectangle [width, height]. Panels are ordered in batches, and a batch
    /// costs (its widest panel's width) × (its tallest panel's height). Every panel goes in exactly one
    /// batch, and any panels can share one. Returns the smallest total cost.
    public static func cheapestOrders(_ panels: [[Int]]) -> Int {
        // Write your solution here, then run:
        // swift test --filter PanelBulkOrdersTests
        return 0
    }
}
