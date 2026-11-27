// Generated from src/dsa/content/lessons/stacks/stack-parentheses.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func isBalanced(_ text: String) -> Bool {
    let opener: [Character: Character] = [")": "(", "]": "[", "}": "{"]
    var open: [Character] = []
    for character in text {
        switch character {
        case "(", "[", "{":
            open.append(character)
        case ")", "]", "}":
            guard open.popLast() == opener[character] else {
                return false                     // empty stack, or the wrong kind
            }
        default:
            break                                // not a bracket
        }
    }
    return open.isEmpty
}

for text in ["{[()]}", "([)]", "if (a[i] > 0) { go() }", "((", "]"] {
    print(text, isBalanced(text))
}
