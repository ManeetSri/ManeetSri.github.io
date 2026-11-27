// Generated from src/dsa/content/lessons/strings-basic/str-big-number-arithmetic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func digits(_ number: String) -> [Int] {
    number.utf8.reversed().map { Int($0 - UInt8(ascii: "0")) }
}

func text(_ digits: [Int]) -> String {
    digits.reversed().map { String($0) }.joined()
}

let d = digits("907")
print(d)
print(d[0], d[2])
print(text(d))
