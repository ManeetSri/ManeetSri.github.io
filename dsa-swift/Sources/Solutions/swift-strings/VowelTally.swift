// Reference solution: Count the vowels.
// Lowercase each character and check it against a set of the five vowels.
// O(n) time, O(1) extra space.

public enum VowelTally {
    public static func count(in text: String) -> Int {
        let vowels: Set<Character> = ["a", "e", "i", "o", "u"]
        var total = 0
        for character in text where character.isASCII {
            if vowels.contains(Character(character.lowercased())) {
                total += 1
            }
        }
        return total
    }
}
