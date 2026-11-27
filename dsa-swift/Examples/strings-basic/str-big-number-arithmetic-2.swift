// Generated from src/dsa/content/lessons/strings-basic/str-big-number-arithmetic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func digits(_ number: String) -> [Int] {
    number.utf8.reversed().map { Int($0 - UInt8(ascii: "0")) }
}

func text(_ digits: [Int]) -> String {
    digits.reversed().map { String($0) }.joined()
}

func add(_ a: String, _ b: String) -> String {
    let x = digits(a)
    let y = digits(b)
    var result: [Int] = []
    var carry = 0
    for place in 0..<max(x.count, y.count) {
        let total = (place < x.count ? x[place] : 0) + (place < y.count ? y[place] : 0) + carry
        result.append(total % 10)
        carry = total / 10
    }
    if carry > 0 {
        result.append(carry)             // the sum can have one more digit
    }
    return text(result)
}

print(add("999", "1"))
print(add("12345678901234567890", "98765432109876543210"))
print(add("0", "0"))
