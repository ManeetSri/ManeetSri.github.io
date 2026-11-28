// Generated from src/dsa/content/lessons/stacks/stack-decode-simplify.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func decode(_ encoded: String) -> String {
    var saved: [(prefix: String, count: Int)] = []
    var current = ""
    var count = 0
    for character in encoded {
        if let digit = character.wholeNumberValue {
            count = count * 10 + digit                 // counts can have several digits
        } else if character == "[" {
            saved.append((current, count))             // put the outer work aside
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

for encoded in ["3[ab]", "2[a3[b]]c", "x2[yz]w", "10[z]", "plain"] {
    print("\(encoded) -> \(decode(encoded))")
}
