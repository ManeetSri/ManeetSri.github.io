// Reference solution: Balanced brackets. Opening brackets go on a stack; each closing bracket must
// match the most recent unclosed opener, which is the top. Anything left open at the end makes it
// unbalanced. O(n) time, O(n) space for the stack.

public enum BracketCheck {
    private static let opener: [Character: Character] = [")": "(", "]": "[", "}": "{"]

    public static func isBalanced(_ text: String) -> Bool {
        var open: [Character] = []
        for character in text {
            switch character {
            case "(", "[", "{":
                open.append(character)
            case ")", "]", "}":
                guard open.popLast() == opener[character] else {
                    return false
                }
            default:
                continue
            }
        }
        return open.isEmpty
    }
}
