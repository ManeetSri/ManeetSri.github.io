// Reference solution: Strings within a zero and one budget. A 0/1 knapsack with two capacities: each
// string costs its 0s and its 1s and is worth 1. best[z][o] is the most strings within z zeros and o
// ones; both loops run downward, so a string that costs nothing in one dimension still can't be
// chosen twice. O(L + n · zeros · ones) time for total length L, O(zeros · ones) space.

public enum ZeroOneStringBudget {
    public static func mostStrings(_ strings: [String], zeros: Int, ones: Int) -> Int {
        var best = Array(repeating: Array(repeating: 0, count: ones + 1), count: zeros + 1)
        for string in strings {
            var a = 0
            var b = 0
            for character in string.utf8 {
                if character == UInt8(ascii: "0") { a += 1 } else { b += 1 }
            }
            if a > zeros || b > ones { continue }
            for z in stride(from: zeros, through: a, by: -1) {
                for o in stride(from: ones, through: b, by: -1) {
                    best[z][o] = max(best[z][o], best[z - a][o - b] + 1)
                }
            }
        }
        return best[zeros][ones]
    }
}
