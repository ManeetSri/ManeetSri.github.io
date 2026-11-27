// Generated from src/dsa/content/lessons/math-basics/math-digits.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var n = 4721
var digitSum = 0
while n > 0 {
    let digit = n % 10
    print(digit, terminator: " ")
    digitSum += digit
    n /= 10
}
print()
print("Sum:", digitSum)
