// Reference solution: Group words by shifting. Two words are shifts of each other exactly when they
// have the same gaps between neighbouring letters, counted modulo 26, so that list of gaps is the
// group's key. (Equal gap lists also mean equal lengths, since a word of n letters has n - 1 gaps.) A dictionary maps each key to its group's position in the
// result, which keeps the groups in order of first appearance. O(total letters) time and space.

public enum ShiftGroups {
    public static func groups(of words: [String]) -> [[String]] {
        var groupIndex: [[Int]: Int] = [:]
        var result: [[String]] = []
        for word in words {
            let key = shiftKey(word)
            if let index = groupIndex[key] {
                result[index].append(word)
            } else {
                groupIndex[key] = result.count
                result.append([word])
            }
        }
        return result
    }

    // The gap from each letter to the next, wrapped into 0...25. A one-letter word has no gaps, so
    // every one-letter word shares the empty key, as it should: any letter shifts to any other.
    private static func shiftKey(_ word: String) -> [Int] {
        let values = word.unicodeScalars.map { Int($0.value) }
        var key: [Int] = []
        for index in values.indices.dropFirst() {
            key.append((values[index] - values[index - 1] + 26) % 26)
        }
        return key
    }
}
