// Generated from src/dsa/content/lessons/patterns/pat-templates-linear.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A stack for nesting: are the brackets balanced?
func isBalanced(_ text: String) -> Bool {
    let opener: [Character: Character] = [")": "(", "]": "[", "}": "{"]
    var stack: [Character] = []
    for character in text {
        if let needed = opener[character] {       // a closer
            guard stack.popLast() == needed else { return false }
        } else if "([{".contains(character) {     // an opener
            stack.append(character)
        }
    }
    return stack.isEmpty                          // nothing left unclosed
}

for text in ["a[b(c)]{d}", "(]", "((x)", "x)"] {
    print(text, isBalanced(text))
}
