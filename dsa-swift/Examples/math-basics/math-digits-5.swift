// Generated from src/dsa/content/lessons/math-basics/math-digits.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func isPalindrome(_ number: Int) -> Bool {
    if number < 0 || (number % 10 == 0 && number != 0) {
        return false
    }
    var n = number
    var half = 0
    while n > half {
        half = half * 10 + n % 10
        n /= 10
    }
    return n == half || n == half / 10
}

for x in [1221, 12321, 123, 10, 0, -121] {
    print(x, isPalindrome(x))
}
