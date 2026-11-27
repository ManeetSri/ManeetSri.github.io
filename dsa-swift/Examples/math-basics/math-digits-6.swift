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

func power(_ base: Int, _ exponent: Int) -> Int {
    var result = 1
    for _ in 0..<exponent {
        result *= base
    }
    return result
}

func isArmstrong(_ number: Int) -> Bool {
    let k = digitCount(number)
    var n = number
    var total = 0
    while n > 0 {
        total += power(n % 10, k)
        n /= 10
    }
    return total == number
}

print((1...10_000).filter(isArmstrong))
