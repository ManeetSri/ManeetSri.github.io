// Generated from src/dsa/content/lessons/strings-basic/str-atoi.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func parse(_ text: String) -> Int {
    let bytes = Array(text.utf8)
    var index = 0
    while index < bytes.count && bytes[index] == UInt8(ascii: " ") {
        index += 1
    }
    var negative = false
    if index < bytes.count && (bytes[index] == UInt8(ascii: "+") || bytes[index] == UInt8(ascii: "-")) {
        negative = bytes[index] == UInt8(ascii: "-")
        index += 1
    }
    var value = 0
    while index < bytes.count && bytes[index] >= UInt8(ascii: "0") && bytes[index] <= UInt8(ascii: "9") {
        let digit = Int(bytes[index] - UInt8(ascii: "0"))
        let shifted = value.multipliedReportingOverflow(by: 10)
        let added = shifted.partialValue.addingReportingOverflow(digit)
        if shifted.overflow || added.overflow {
            return negative ? Int.min : Int.max      // clamp
        }
        value = added.partialValue
        index += 1
    }
    return negative ? -value : value
}

for text in ["9223372036854775807", "9223372036854775808", "-9223372036854775808",
             "-9223372036854775809", "  -000000000000000000000042", "123456789012345678901234567890"] {
    print("[\(text)] ->", parse(text))
}
