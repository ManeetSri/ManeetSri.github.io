// Reference solution: Choose, modulo a prime. Pascal's rule, C(n, k) = C(n-1, k-1) + C(n-1, k),
// builds each row from the previous one using only additions, so every entry can be reduced
// modulo 1,000,000,007 as it's made. O(n²) time, O(n) space.

public enum PascalChoose {
    private static let mod = 1_000_000_007

    public static func row(_ n: Int) -> [Int] {
        var current = [1]
        for _ in 0..<n {
            var next = [1]
            for k in 1..<current.count {
                next.append((current[k - 1] + current[k]) % mod)
            }
            next.append(1)
            current = next
        }
        return current
    }

    public static func choose(_ n: Int, _ k: Int) -> Int {
        guard k >= 0 && k <= n else { return 0 }
        return row(n)[k]
    }
}
