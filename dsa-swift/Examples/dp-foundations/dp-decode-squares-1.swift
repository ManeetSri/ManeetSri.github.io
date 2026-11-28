// Generated from src/dsa/content/lessons/dp-foundations/dp-decode-squares.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// The decoding counts for every prefix of a digit string, with A = 1, B = 2, ..., Z = 26
func decodeTable(_ message: String) -> [Int] {
    let digits = message.compactMap { $0.wholeNumberValue }
    let n = digits.count
    // 1. State: ways[i] = the number of ways to decode the first i digits
    var ways = Array(repeating: 0, count: n + 1)
    // 3. Base case: the empty message has one decoding, the empty word
    ways[0] = 1
    // 4. Order: left to right
    for i in stride(from: 1, through: n, by: 1) {
        // 2. Transition: the last letter used one digit (1 to 9) ...
        if digits[i - 1] != 0 {
            ways[i] += ways[i - 1]
        }
        // ... or two digits (10 to 26)
        if i >= 2 {
            let pair = digits[i - 2] * 10 + digits[i - 1]
            if pair >= 10 && pair <= 26 {
                ways[i] += ways[i - 2]
            }
        }
    }
    // 5. Answer: the last entry
    return ways
}

print("2611:", decodeTable("2611"))
print("1201:", decodeTable("1201"))
for message in ["10", "100", "06", "301", "2525", "1111"] {
    print(message, "->", decodeTable(message).last!)
}
