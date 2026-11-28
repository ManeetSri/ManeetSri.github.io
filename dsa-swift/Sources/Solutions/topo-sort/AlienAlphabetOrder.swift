// Reference solution: Alphabet of an unknown language. Only neighbouring words carry information,
// and only at their first difference: there, the earlier word's letter comes first in the alphabet,
// which is an edge between letters. If there's no difference and the earlier word is longer, the
// list can't be sorted under any alphabet (a word must come before its own extensions). Then
// Kahn's algorithm orders the letters; if a cycle leaves some stuck, the constraints contradict
// each other. Letters are seeded in first-appearance order, so the output is deterministic.
// O(C) time for C characters in all the words, plus O(1) for the at most 26 letters and 26² edges.

public enum AlienAlphabetOrder {
    public static func alphabet(_ words: [String]) -> String {
        var letters: [Character] = []                     // every letter, in order of first appearance
        var after: [Character: [Character]] = [:]         // edges: key comes before each value
        var waitingOn: [Character: Int] = [:]             // in-degrees
        for word in words {
            for letter in word where waitingOn[letter] == nil {
                waitingOn[letter] = 0
                after[letter] = []
                letters.append(letter)
            }
        }

        var seen = Set<String>()                          // edges already added, as two-letter keys
        for (earlier, later) in zip(words, words.dropFirst()) {
            guard let (first, second) = firstDifference(earlier, later) else {
                if earlier.count > later.count { return "" }      // "apple" before "app": impossible
                continue                                          // equal, or a prefix first: no info
            }
            if seen.insert(String([first, second])).inserted {
                after[first]!.append(second)
                waitingOn[second]! += 1
            }
        }

        var order = letters.filter { waitingOn[$0] == 0 }
        var head = 0
        while head < order.count {
            let letter = order[head]
            head += 1
            for next in after[letter]! {
                waitingOn[next]! -= 1
                if waitingOn[next] == 0 {
                    order.append(next)
                }
            }
        }
        return order.count == letters.count ? String(order) : ""
    }

    /// The letters at the first position where the two words differ, or nil if one is a prefix of
    /// the other (or they're equal).
    private static func firstDifference(_ a: String, _ b: String) -> (Character, Character)? {
        for (x, y) in zip(a, b) where x != y {
            return (x, y)
        }
        return nil
    }
}
