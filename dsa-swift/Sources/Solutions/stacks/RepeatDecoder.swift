// Reference solution: Decode repeats. Build the current piece of text as you read. An opening bracket
// saves the text so far and the repeat count on a stack and starts a fresh piece; a closing bracket
// repeats the piece and glues it back onto the saved text. O(length of the output) time and space,
// since every output character is written a bounded number of times per nesting level.

public enum RepeatDecoder {
    public static func decode(_ encoded: String) -> String {
        var saved: [(prefix: String, count: Int)] = []
        var current = ""
        var count = 0
        for character in encoded {
            if let digit = character.wholeNumberValue {
                count = count * 10 + digit
            } else if character == "[" {
                saved.append((current, count))
                current = ""
                count = 0
            } else if character == "]" {
                let (prefix, repeats) = saved.removeLast()
                current = prefix + String(repeating: current, count: repeats)
            } else {
                current.append(character)
            }
        }
        return current
    }
}
