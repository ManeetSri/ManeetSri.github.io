// Reference solution: One sequence, four disguises. All four questions are Catalan numbers: C(n) for n
// bracket pairs or n tree nodes, C(s − 2) for a polygon with s corners, C(m − 1) for m matrices. With
// factorials and inverse factorials built once up to twice the largest index, C(n) = (2n)! / (n! (n + 1)!)
// costs three multiplications. O(N + q) time, O(N) space.

public enum CatalanDisguises {
    public enum Question: Equatable {
        case bracketStrings(pairs: Int)
        case treeShapes(nodes: Int)
        case triangulations(sides: Int)
        case matrixOrders(matrices: Int)
    }

    private static let p = 1_000_000_007

    /// Which Catalan number answers the question
    private static func index(of question: Question) -> Int {
        switch question {
        case .bracketStrings(let pairs): return pairs
        case .treeShapes(let nodes): return nodes
        case .triangulations(let sides): return sides - 2
        case .matrixOrders(let matrices): return matrices - 1
        }
    }

    private static func power(_ base: Int, _ exponent: Int) -> Int {
        var result = 1
        var base = base % p
        var exponent = exponent
        while exponent > 0 {
            if exponent & 1 == 1 {
                result = result * base % p
            }
            base = base * base % p
            exponent >>= 1
        }
        return result
    }

    public static func answers(_ questions: [Question]) -> [Int] {
        let indexes = questions.map(index(of:))
        let top = 2 * (indexes.max() ?? 0) + 1
        var factorial = [Int](repeating: 1, count: top + 1)
        for i in stride(from: 1, through: top, by: 1) {
            factorial[i] = factorial[i - 1] * i % p
        }
        var inverse = [Int](repeating: 1, count: top + 1)
        inverse[top] = power(factorial[top], p - 2)           // Fermat: a^(p−2) is a's inverse
        for i in stride(from: top, through: 1, by: -1) {
            inverse[i - 1] = inverse[i] * i % p
        }
        return indexes.map { n in factorial[2 * n] * inverse[n] % p * inverse[n + 1] % p }
    }
}
