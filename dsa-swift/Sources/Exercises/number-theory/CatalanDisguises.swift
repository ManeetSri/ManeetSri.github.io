// Problem: One sequence, four disguises (M66 · Catalan, Stirling and Bell numbers)

public enum CatalanDisguises {
    /// The four kinds of question the site receives.
    public enum Question: Equatable {
        /// Strings of n "(" and n ")" where no prefix has more ")" than "(".
        case bracketStrings(pairs: Int)
        /// Shapes of binary trees with n nodes (left and right children are different).
        case treeShapes(nodes: Int)
        /// Ways to cut a convex polygon with this many corners (at least 3) into triangles.
        case triangulations(sides: Int)
        /// Ways to fully bracket a product of this many matrices (at least 1).
        case matrixOrders(matrices: Int)
    }

    /// The answer to each question, in order, modulo 1,000,000,007. Precompute once per batch.
    public static func answers(_ questions: [Question]) -> [Int] {
        // Write your solution here, then run:
        // swift test --filter CatalanDisguisesTests
        return []
    }
}
