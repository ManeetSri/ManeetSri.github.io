// Reference solution: Characters at offsets. Convert the text to [Character] once, O(n); after that
// each offset is an O(1) array read. O(n + q) in total for q offsets, instead of O(n · q) when the
// String is walked from the start for every offset.

public enum CharactersAtOffsets {
    public static func characters(in text: String, at offsets: [Int]) -> String {
        let characters = Array(text)
        var result = ""
        for offset in offsets {
            result.append(characters[offset])
        }
        return result
    }
}
