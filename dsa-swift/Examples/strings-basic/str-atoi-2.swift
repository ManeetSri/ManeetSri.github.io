// Generated from src/dsa/content/lessons/strings-basic/str-atoi.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func parseBasic(_ text: String) -> Int {
    let bytes = Array(text.utf8)
    var index = 0

    // 1. Skip leading spaces
    while index < bytes.count && bytes[index] == UInt8(ascii: " ") {
        index += 1
    }

    // 2. One optional sign
    var negative = false
    if index < bytes.count && (bytes[index] == UInt8(ascii: "+") || bytes[index] == UInt8(ascii: "-")) {
        negative = bytes[index] == UInt8(ascii: "-")
        index += 1
    }

    // 3. Digits until anything else
    var value = 0
    while index < bytes.count && bytes[index] >= UInt8(ascii: "0") && bytes[index] <= UInt8(ascii: "9") {
        value = value * 10 + Int(bytes[index] - UInt8(ascii: "0"))
        index += 1
    }
    return negative ? -value : value
}

for text in ["42", "   -17", "+8 apples", "apples 8", "+-5", "-", ""] {
    print("[\(text)] ->", parseBasic(text))
}
