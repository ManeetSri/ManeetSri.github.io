// Reference solution: Group anagrams into families. Anagrams have the same letter counts, so a
// 26-slot count array is a key every member of a family shares ([Int] is Hashable). A dictionary
// maps each key to the index of its group, which keeps groups in order of first appearance.
// O(n · (L + 26)) time for n words of length up to L, O(n · L) space.

public enum AnagramFamilies {
    public static func groups(_ words: [String]) -> [[String]] {
        var groupIndex: [[Int]: Int] = [:]
        var result: [[String]] = []
        for word in words {
            var key = [Int](repeating: 0, count: 26)
            for byte in word.utf8 {
                key[Int(byte - UInt8(ascii: "a"))] += 1
            }
            if let index = groupIndex[key] {
                result[index].append(word)
            } else {
                groupIndex[key] = result.count
                result.append([word])
            }
        }
        return result
    }
}
