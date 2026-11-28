// Reference solution: Find the n₀. Linear: solve b ≤ (c − a)·n with a rounded-up division, O(1).
// Quadratic: (c − a)·n ≥ b + k/n only gets easier as n grows, so the first n that works is the answer.

public enum BigOWitness {
    public static func linearStart(a: Int, b: Int, c: Int) -> Int? {
        if c < a { return nil }                   // a·n eventually overtakes c·n
        if c == a { return b == 0 ? 1 : nil }     // only b is left, and it must be 0
        let gap = c - a
        let start = b / gap + (b % gap == 0 ? 0 : 1)
        return max(1, start)
    }

    public static func quadraticStart(a: Int, b: Int, k: Int, c: Int) -> Int? {
        if c < a { return nil }
        if c == a { return b == 0 && k == 0 ? 1 : nil }
        let gap = c - a
        var n = 1
        while gap * n * n < b * n + k {           // at most about b + √k + 1 passes
            n += 1
        }
        return n
    }
}
