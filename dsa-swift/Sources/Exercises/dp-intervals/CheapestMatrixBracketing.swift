// Problem: Cheapest matrix bracketing (M56 · Matrix chain multiplication)

public enum CheapestMatrixBracketing {
    /// Matrix i (counting from 0) is `dims[i] × dims[i + 1]`. Returns the fewest scalar multiplications
    /// needed to multiply the whole chain.
    public static func minimumCost(dims: [Int]) -> Int {
        // Write your solution here, then run:
        // swift test --filter CheapestMatrixBracketingTests
        return 0
    }

    /// Returns a cheapest bracketing, naming the matrices A1, A2, … in order and writing each
    /// multiplication as "(left right)", for example "((A1 A2) A3)". A single matrix is just "A1".
    public static func bracketing(dims: [Int]) -> String {
        return ""
    }
}
