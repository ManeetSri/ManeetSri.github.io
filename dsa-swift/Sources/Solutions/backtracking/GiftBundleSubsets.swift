// Reference solution: Gift bundles from a price list. Sort the prices so equal ones sit side by side,
// then grow bundles with the "choose the next item" tree: every node is a bundle, and its children add
// one price from further right. At each depth only the first of a run of equal prices is tried, since
// choosing a later copy instead would grow exactly the same subtree a second time.
// O(n · 2ⁿ) time in the worst case (all prices different), O(n) extra space besides the output.

public enum GiftBundleSubsets {
    public static func bundles(_ prices: [Int]) -> [[Int]] {
        let sorted = prices.sorted()
        var result: [[Int]] = []
        var bundle: [Int] = []

        func explore(from start: Int) {
            result.append(bundle)                                   // every node is a bundle
            for i in start..<sorted.count {
                if i > start && sorted[i] == sorted[i - 1] { continue }   // equal sibling: same subtree
                bundle.append(sorted[i])                            // choose
                explore(from: i + 1)                                // explore
                bundle.removeLast()                                 // unchoose
            }
        }

        explore(from: 0)
        return result
    }
}
