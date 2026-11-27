// Reference solution: Remove or split. Every pile is an independent game, so by the Sprague–Grundy
// theorem the whole position is won for the player to move exactly when the XOR of the piles' Grundy
// numbers isn't 0. A pile's Grundy number is the mex (smallest missing value) of the Grundy numbers it
// can move to: g(n − s) for each allowed removal s, and g(a) XOR g(n − a) for each split into a and
// n − a with a < n − a, because a split leaves a sum of two games. Fill g from 0 up to the largest pile.
// O(M² + M · r + piles) time for largest pile M and r removal sizes, O(M) space.

public enum PileSplitGame {
    public static func firstPlayerWins(piles: [Int], removals: [Int]) -> Bool {
        let largest = piles.max() ?? 0
        var grundy = Array(repeating: 0, count: largest + 1)
        // seenAt[v] == n means value v is an option of n. A pile has fewer than removals.count + largest
        // options, so its mex, and every Grundy number, is below that.
        var seenAt = Array(repeating: -1, count: removals.count + largest + 2)
        for n in stride(from: 1, through: largest, by: 1) {
            for s in removals where s <= n {
                seenAt[grundy[n - s]] = n
            }
            var a = 1
            while a < n - a {
                let v = grundy[a] ^ grundy[n - a]          // XOR can exceed both, so check the range
                if v < seenAt.count { seenAt[v] = n }
                a += 1
            }
            var mex = 0
            while seenAt[mex] == n { mex += 1 }
            grundy[n] = mex
        }
        return piles.reduce(0) { $0 ^ grundy[$1] } != 0
    }
}
