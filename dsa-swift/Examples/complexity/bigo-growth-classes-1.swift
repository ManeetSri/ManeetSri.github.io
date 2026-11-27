// Generated from src/dsa/content/lessons/complexity/bigo-growth-classes.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func digitCount(_ number: Int) -> Int {
    var n = number
    var digits = 1
    while n >= 10 {
        n /= 10
        digits += 1
    }
    return digits
}

for number in [7, 42, 1_000, 123_456_789, Int.max] {
    print(number, digitCount(number))
}
