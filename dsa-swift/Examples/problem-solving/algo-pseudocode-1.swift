// Generated from src/dsa/content/lessons/problem-solving/algo-pseudocode.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func runLengthEncoded(_ text: String) -> String {
    guard let first = text.first else { return "" }
    var result = ""
    var current = first
    var count = 1
    for character in text.dropFirst() {
        if character == current {
            count += 1
        } else {
            result += "\(current)\(count)"
            current = character
            count = 1
        }
    }
    result += "\(current)\(count)"
    return result
}

print(runLengthEncoded("aaabccdddd"))
print(runLengthEncoded("z"))
print("Empty text gives \"\(runLengthEncoded(""))\"")
