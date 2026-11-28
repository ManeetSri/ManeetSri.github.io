// Generated from src/dsa/content/lessons/math-basics/math-number-systems.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func fromBase(_ text: String, _ base: Int) -> Int? {
    var value = 0
    for ch in text {
        guard let digit = ch.hexDigitValue, digit < base else { return nil }
        value = value * base + digit
    }
    return value
}

print(fromBase("101101", 2) ?? -1)
print(fromBase("2d", 16) ?? -1)
print(fromBase("19", 8) ?? -1)
