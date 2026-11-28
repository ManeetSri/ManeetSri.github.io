// Reference solution: Spot-check a matrix product. Freivalds' algorithm: for each trial, draw a random
// 0/1 vector r and compare A(Br) with Cr, three O(n²) matrix-vector products. A mismatch proves
// A × B ≠ C and is returned as the witness; a wrong C survives one trial with probability at most 1/2, so
// `trials` independent trials all miss with probability at most 2^(−trials). O(trials · n²) time.

public enum FreivaldsProductCheck {
    private static func times(_ m: [[Int]], _ v: [Int]) -> [Int] {
        m.map { row in
            var total = 0
            for (x, y) in zip(row, v) {
                total += x * y
            }
            return total
        }
    }

    public static func findWitness(_ a: [[Int]], _ b: [[Int]], _ c: [[Int]], trials: Int, using generator: inout some RandomNumberGenerator) -> [Int]? {
        let n = a.count
        for _ in 0..<max(0, trials) {
            let r = (0..<n).map { _ in Int.random(in: 0...1, using: &generator) }   // fresh every trial
            if times(a, times(b, r)) != times(c, r) {
                return r
            }
        }
        return nil
    }
}
