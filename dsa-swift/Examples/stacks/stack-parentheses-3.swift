// Generated from src/dsa/content/lessons/stacks/stack-parentheses.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func firstProblem(in text: String) -> String {
    let opener: [Character: Character] = [")": "(", "]": "[", "}": "{"]
    var open: [(bracket: Character, position: Int)] = []
    for (position, character) in text.enumerated() {
        switch character {
        case "(", "[", "{":
            open.append((character, position))
        case ")", "]", "}":
            guard let top = open.popLast() else {
                return "unexpected \(character) at \(position)"
            }
            if top.bracket != opener[character] {
                return "\(character) at \(position) doesn't match \(top.bracket) at \(top.position)"
            }
        default:
            break
        }
    }
    if let unclosed = open.last {
        return "\(unclosed.bracket) at \(unclosed.position) is never closed"
    }
    return "balanced"
}

for text in ["let a = [1, 2)", "f(x))", "{ if (ok) {", "[{}]"] {
    print(firstProblem(in: text))
}
