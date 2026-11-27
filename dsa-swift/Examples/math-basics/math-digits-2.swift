// Generated from src/dsa/content/lessons/math-basics/math-digits.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func digitCount(_ number: Int) -> Int {
    var n = number
    var count = 0
    repeat {
        count += 1
        n /= 10
    } while n != 0
    return count
}

print(digitCount(4721), digitCount(0), digitCount(-305))
