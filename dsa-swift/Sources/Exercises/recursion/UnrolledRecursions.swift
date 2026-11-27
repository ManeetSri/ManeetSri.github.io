// Problem: Unroll two recursions (M17 · Recursion vs iteration, and tail calls)

public enum UnrolledRecursions {
    /// The same answer as the recursion survivor(n, k) = n == 1 ? 0 : (survivor(n − 1, k) + k) % n,
    /// for n up to 10⁶, without recursing.
    public static func survivor(people n: Int, step k: Int) -> Int {
        // Write your solution here, then run:
        // swift test --filter UnrolledRecursionsTests
        return -1
    }

    /// The number of hops from position 0 to past the end, jumping forward jumps[i] from position i,
    /// for arrays up to 10⁶ long, without recursing.
    public static func hops(_ jumps: [Int]) -> Int {
        return -1
    }
}
