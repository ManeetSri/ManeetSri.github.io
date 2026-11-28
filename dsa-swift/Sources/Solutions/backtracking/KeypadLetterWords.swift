// Reference solution: Keypad letter words. One level of the decision tree per digit, one branch per
// letter on that key. The path of letters is built in one array (append, explore, removeLast) and
// turned into a String only at the leaves.
// O(4ⁿ · n) time for n digits (at most four letters per key), O(n) extra space besides the output.

public enum KeypadLetterWords {
    private static let letters: [String] = ["", "", "abc", "def", "ghi", "jkl", "mno", "pqrs", "tuv", "wxyz"]

    public static func words(for digits: String) -> [String] {
        let keys = digits.compactMap { $0.wholeNumberValue }
        guard !keys.isEmpty else { return [] }
        var result: [String] = []
        var word: [Character] = []

        func explore(_ index: Int) {
            if index == keys.count {
                result.append(String(word))
                return
            }
            for letter in letters[keys[index]] {
                word.append(letter)                                 // choose
                explore(index + 1)                                  // explore
                word.removeLast()                                   // unchoose
            }
        }

        explore(0)
        return result
    }
}
