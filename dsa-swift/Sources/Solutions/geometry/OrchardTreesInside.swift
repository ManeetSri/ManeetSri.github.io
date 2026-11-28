// Reference solution: Trees inside the orchard. Pick's theorem links a lattice polygon's area A to the
// grid points strictly inside it (I) and on its boundary (B): A = I + B/2 - 1, so I = (2A - B + 2) / 2.
// The shoelace formula gives 2A exactly as an Int (the absolute value, since the corners may run either
// way), and an edge from a to b passes through gcd(|dx|, |dy|) + 1 grid points, its two ends included,
// so summing gcd(|dx|, |dy|) over the edges counts each boundary point once. No grid scan, so huge
// fields are as fast as small ones. O(n log C) time for n corners and coordinates up to C, O(1) space.

public enum OrchardTreesInside {
    static func gcd(_ a: Int, _ b: Int) -> Int {
        var (a, b) = (a, b)
        while b != 0 {
            (a, b) = (b, a % b)
        }
        return a
    }

    public static func treesInside(_ fence: [[Int]]) -> Int {
        let n = fence.count
        var twiceArea = 0
        var boundary = 0
        for i in 0..<n {
            let a = fence[i], b = fence[(i + 1) % n]
            twiceArea += a[0] * b[1] - a[1] * b[0]
            boundary += gcd(abs(b[0] - a[0]), abs(b[1] - a[1]))
        }
        return (abs(twiceArea) - boundary + 2) / 2
    }
}
